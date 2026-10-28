unit SkiaAdventureProto;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math, System.UITypes,
  System.SyncObjs, FMX.Types, FMX.Controls, FMX.Forms, FMX.Skia, System.Skia,
  System.Generics.Collections, System.Generics.Defaults;

const
  TILE_W = 64;
  TILE_H = 32;
  MAP_COLS = 20;
  MAP_ROWS = 20;

type
  TVerb = (vbLook, vbUse, vbTake, vbTalk);
  THotspotKind = (hkProp, hkCharacter, hkExit);

  THotspot = class
  public
    Name: string;
    GridX, GridY: Single;
    RenderX, RenderY: Single;
    Z: Single;
    Kind: THotspotKind;
    IsPlayer: Boolean;
    Visible: Boolean;
    Waypoints: TList<TPointF>;
    Blocking: Boolean;

    procedure CalculateRenderPos;
    function GetSortDepth: Single;
    constructor Create;
    destructor Destroy; override;
  end;

  TAdventureGame = class(TSkCustomControl)
  private
    FThread: TThread;
    FActive: Boolean;
    FLock: TCriticalSection;
    FHotspots: TObjectList<THotspot>;
    FPlayer: THotspot;
    FOccupied: array[0..MAP_COLS - 1, 0..MAP_ROWS - 1] of THotspot;

    FCameraX, FCameraY: Single;
    FZoom: Single;
    FSelectedVerb: TVerb;

    FBackgroundCache: ISkImage;
    FNeedsFullRepaint: Boolean;
    FIsIdle: Boolean;

    procedure GenerateBedroomScene;
    procedure DoUpdate(DeltaSec: Double);
    procedure SafeInvalidate;
    procedure StartThread;
    procedure StopThread;

    function IsBlocked(X, Y: Integer): Boolean;
    function FindPath(StartX, StartY, TargetX, TargetY: Integer): TList<TPointF>;

    procedure RenderBackgroundToCache(const ACanvas: ISkCanvas);
    procedure DrawIsoTile(const ACanvas: ISkCanvas; CX, CY: Single; Color: TAlphaColor);
    procedure DrawIsoBox(const ACanvas: ISkCanvas; CX, CY: Single; LenX, LenY, HeightZ: Single; TopC, LeftC, RightC: TAlphaColor);
    procedure DrawBed(const ACanvas: ISkCanvas; CX, CY: Single);
    procedure DrawTable(const ACanvas: ISkCanvas; CX, CY: Single);
    procedure DrawGlass(const ACanvas: ISkCanvas; CX, CY: Single; LiquidColor: TAlphaColor);
    procedure DrawWall(const ACanvas: ISkCanvas; CX, CY: Single; LenX, LenY, HeightZ: Single);

    procedure DrawScene(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawUI(const ACanvas: ISkCanvas; const ADest: TRectF);
  protected
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{ THotspot }

constructor THotspot.Create;
begin
  Waypoints := TList<TPointF>.Create;
  Visible := True;
  Blocking := False;
end;

destructor THotspot.Destroy;
begin
  Waypoints.Free;
  inherited;
end;

procedure THotspot.CalculateRenderPos;
begin
  RenderX := (GridX - GridY) * (TILE_W / 2);
  RenderY := (GridX + GridY) * (TILE_H / 2);
end;

function THotspot.GetSortDepth: Single;
begin
  Result := (GridX + GridY) + (Z * 0.001);
end;

{ TAdventureGame }

constructor TAdventureGame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := TAlignLayout.Client;
  HitTest := True;
  FLock := TCriticalSection.Create;
  FHotspots := TObjectList<THotspot>.Create(True);

  FZoom := 2.0;
  FCameraX := 0;
  FCameraY := 0;
  FNeedsFullRepaint := True;
  FIsIdle := True;

  GenerateBedroomScene;

  if Assigned(FPlayer) then
  begin
    FPlayer.CalculateRenderPos;
    FCameraX := FPlayer.RenderX;
    FCameraY := FPlayer.RenderY - 50;
  end;

  FActive := True;
  StartThread;
end;

destructor TAdventureGame.Destroy;
begin
  StopThread;
  FreeAndNil(FHotspots);
  FreeAndNil(FLock);
  inherited;
end;

procedure TAdventureGame.GenerateBedroomScene;
var
  H: THotspot;
begin
  FHotspots.Clear;

  // Spieler (Arthur) - Startposition
  H := THotspot.Create;
  H.Name := 'Arthur';
  H.Kind := hkCharacter;
  H.IsPlayer := True;
  H.GridX := 7;
  H.GridY := 4;
  H.Z := 30;
  H.CalculateRenderPos;
  FPlayer := H;
  FHotspots.Add(H);

  // Das Bett (Genau 1x1 Tile groß, kein Überhang)
  H := THotspot.Create;
  H.Name := 'Bed';
  H.Kind := hkProp;
  H.GridX := 2;
  H.GridY := 4;
  H.Z := 20;
  H.Blocking := True;
  H.CalculateRenderPos;
  FHotspots.Add(H);

  // Der Tisch (Genau 1x1 Tile groß, kein Überhang)
  H := THotspot.Create;
  H.Name := 'Table';
  H.Kind := hkProp;
  H.GridX := 9;
  H.GridY := 4;
  H.Z := 15;
  H.Blocking := True;
  H.CalculateRenderPos;
  FHotspots.Add(H);

  // Wände (Blockieren)
  H := THotspot.Create;
  H.Name := 'WallFront';
  H.Kind := hkProp;
  H.GridX := 0; H.GridY := 0; H.Z := 60; H.Blocking := True;
  H.CalculateRenderPos; FHotspots.Add(H);

  H := THotspot.Create;
  H.Name := 'WallLeft';
  H.Kind := hkProp;
  H.GridX := 0; H.GridY := 10; H.Z := 60; H.Blocking := True;
  H.CalculateRenderPos; FHotspots.Add(H);
end;

procedure TAdventureGame.DoUpdate(DeltaSec: Double);
var
  OldCamX, OldCamY: Single;
  MovementHappened: Boolean;
  U: THotspot;
  DirX, DirY, Len: Single;
  NextTX, NextTY: Integer;
begin
  MovementHappened := False;
  OldCamX := FCameraX;
  OldCamY := FCameraY;

  // Kollision aufbauen
  FillChar(FOccupied, SizeOf(FOccupied), 0);
  for U in FHotspots do
    if U.Blocking then
      FOccupied[Trunc(U.GridX), Trunc(U.GridY)] := U;

  // Spieler-Bewegung & Pathfinding
  if Assigned(FPlayer) and (FPlayer.Waypoints.Count > 0) then
  begin
    MovementHappened := True;
    DirX := FPlayer.Waypoints[0].X - FPlayer.GridX;
    DirY := FPlayer.Waypoints[0].Y - FPlayer.GridY;
    Len := Hypot(DirX, DirY);

    if Len < 0.2 then
      FPlayer.Waypoints.Delete(0)
    else
    begin
      NextTX := Trunc(FPlayer.Waypoints[0].X);
      NextTY := Trunc(FPlayer.Waypoints[0].Y);

      if not IsBlocked(NextTX, NextTY) then
      begin
        FPlayer.GridX := FPlayer.GridX + (DirX / Len) * 3.0 * DeltaSec;
        FPlayer.GridY := FPlayer.GridY + (DirY / Len) * 3.0 * DeltaSec;
        FPlayer.CalculateRenderPos;
      end
      else
        FPlayer.Waypoints.Clear;
    end;
  end;

  // Kamera folgt Spieler
  if Assigned(FPlayer) then
  begin
    FCameraX := FCameraX + (FPlayer.RenderX - FCameraX) * 0.05;
    FCameraY := FCameraY + (FPlayer.RenderY - 50 - FCameraY) * 0.05;
  end;

  // Idle-Skip Logik
  if (not MovementHappened) and (Abs(OldCamX - FCameraX) < 0.1) and (Abs(OldCamY - FCameraY) < 0.1) then
  begin
    if not FIsIdle then
    begin
      FIsIdle := True;
      FNeedsFullRepaint := True;
    end;
  end
  else
  begin
    FIsIdle := False;
    FNeedsFullRepaint := True;
  end;
end;

// =====================================================================
// A* PATHFINDING
// =====================================================================

function TAdventureGame.IsBlocked(X, Y: Integer): Boolean;
begin
  Result := True;
  if (X < 0) or (X >= MAP_COLS) or (Y < 0) or (Y >= MAP_ROWS) then Exit;
  if Assigned(FOccupied[X, Y]) then Exit;
  Result := False;
end;

function TAdventureGame.FindPath(StartX, StartY, TargetX, TargetY: Integer): TList<TPointF>;
var
  NodeMap: array of array of record G, H, F, ParentX, ParentY: Integer; end;
  ClosedMap, OpenMap: array of array of Boolean;
  OpenList: TList<TPoint>;
  Current: TPoint;
  NX, NY, I, BestI, BestF, GCost, HCost: Integer;
  Found: Boolean;
  DX, DY: Integer;
  WP: TPointF;
begin
  Result := TList<TPointF>.Create;
  if IsBlocked(TargetX, TargetY) then Exit;

  SetLength(NodeMap, MAP_COLS, MAP_ROWS);
  SetLength(ClosedMap, MAP_COLS, MAP_ROWS);
  SetLength(OpenMap, MAP_COLS, MAP_ROWS);
  OpenList := TList<TPoint>.Create;
  try
    NodeMap[StartX, StartY].G := 0;
    NodeMap[StartX, StartY].H := Abs(StartX - TargetX) + Abs(StartY - TargetY);
    NodeMap[StartX, StartY].F := NodeMap[StartX, StartY].H;
    NodeMap[StartX, StartY].ParentX := -1;
    OpenList.Add(Point(StartX, StartY));
    OpenMap[StartX, StartY] := True;
    Found := False;

    while OpenList.Count > 0 do
    begin
      BestI := 0;
      BestF := NodeMap[OpenList[0].X, OpenList[0].Y].F;
      for I := 1 to OpenList.Count - 1 do
        if NodeMap[OpenList[I].X, OpenList[I].Y].F < BestF then
        begin
          BestF := NodeMap[OpenList[I].X, OpenList[I].Y].F;
          BestI := I;
        end;

      Current := OpenList[BestI];
      OpenList.Delete(BestI);
      OpenMap[Current.X, Current.Y] := False;
      ClosedMap[Current.X, Current.Y] := True;

      if (Current.X = TargetX) and (Current.Y = TargetY) then
      begin
        Found := True;
        Break;
      end;

      for DX := -1 to 1 do
        for DY := -1 to 1 do
        begin
          if (DX = 0) and (DY = 0) then Continue;
          if (DX <> 0) and (DY <> 0) then Continue; // No diagonals
          NX := Current.X + DX;
          NY := Current.Y + DY;
          if (NX < 0) or (NX >= MAP_COLS) or (NY < 0) or (NY >= MAP_ROWS) then Continue;
          if IsBlocked(NX, NY) or ClosedMap[NX, NY] then Continue;

          GCost := NodeMap[Current.X, Current.Y].G + 1;
          HCost := Abs(NX - TargetX) + Abs(NY - TargetY);

          if not OpenMap[NX, NY] then
          begin
            NodeMap[NX, NY].G := GCost;
            NodeMap[NX, NY].H := HCost;
            NodeMap[NX, NY].F := GCost + HCost;
            NodeMap[NX, NY].ParentX := Current.X;
            NodeMap[NX, NY].ParentY := Current.Y;
            OpenList.Add(Point(NX, NY));
            OpenMap[NX, NY] := True;
          end
          else if GCost < NodeMap[NX, NY].G then
          begin
            NodeMap[NX, NY].G := GCost;
            NodeMap[NX, NY].F := GCost + HCost;
            NodeMap[NX, NY].ParentX := Current.X;
            NodeMap[NX, NY].ParentY := Current.Y;
          end;
        end;
    end;

    if Found then
    begin
      Current := Point(TargetX, TargetY);
      while (Current.X <> -1) and (Current.Y <> -1) do
      begin
        WP := PointF(Current.X + 0.5, Current.Y + 0.5);
        Result.Insert(0, WP);
        Current := Point(NodeMap[Current.X, Current.Y].ParentX, NodeMap[Current.X, Current.Y].ParentY);
      end;
      if Result.Count > 0 then Result.Delete(0);
    end;
  finally
    OpenList.Free;
  end;
end;

// =====================================================================
// ISO-CAT SCENARIO RENDERING
// =====================================================================

procedure TAdventureGame.RenderBackgroundToCache(const ACanvas: ISkCanvas);
var
  OffsetX, OffsetY, CX, CY: Single;
  I: Integer;
  H: THotspot;
  DrawList: TObjectList<THotspot>;
  Paint: ISkPaint;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  ACanvas.Clear($FF1A1A1A);

  OffsetX := FCameraX - (Width / FZoom) / 2;
  OffsetY := FCameraY - (Height / FZoom) / 2;

  // 1. Boden zeichnen
  for var gx := -2 to 15 do
  begin
    for var gy := -2 to 15 do
    begin
      CX := (gx - gy) * (TILE_W / 2) - OffsetX;
      CY := (gx + gy) * (TILE_H / 2) - OffsetY;
      if (gx >= 0) and (gy >= 0) and (gx < 12) and (gy < 12) then
        DrawIsoTile(ACanvas, CX, CY, $FF3A3A3A)
      else
        DrawIsoTile(ACanvas, CX, CY, $FF1A1A1A);
    end;
  end;

  // 2. Entities sortieren und zeichnen
  DrawList := TObjectList<THotspot>.Create(False);
  try
    for I := 0 to FHotspots.Count - 1 do
      if FHotspots[I].Visible then
        DrawList.Add(FHotspots[I]);

    DrawList.Sort(TDelegatedComparer<THotspot>.Construct(
      function(const A, B: THotspot): Integer
      begin
        if A.GetSortDepth < B.GetSortDepth then Result := -1
        else if A.GetSortDepth > B.GetSortDepth then Result := 1
        else Result := 0;
      end));

    for H in DrawList do
    begin
      CX := H.RenderX - OffsetX;
      CY := H.RenderY - OffsetY;

      if H.Name = 'Bed' then
        DrawBed(ACanvas, CX, CY)
      else if H.Name = 'Table' then
      begin
        DrawTable(ACanvas, CX, CY);
        // Gläser auf der Tischplatte (Z=25)
        DrawGlass(ACanvas, CX - 10, CY - 5, $FF00FFFF);
        DrawGlass(ACanvas, CX + 10, CY - 5, $FFFFFF00);
      end
      else if H.Name = 'WallFront' then
        DrawWall(ACanvas, CX, CY, 10, 0, 60)
      else if H.Name = 'WallLeft' then
        DrawWall(ACanvas, CX, CY, 0, 10, 60)
      else if H.Name = 'Arthur' then
      begin
        // Arthur Schatten
        Paint.Color := $80000000;
        ACanvas.DrawOval(TRectF.Create(CX-10, CY-2, CX+10, CY+8), Paint);
        // Arthur Figur
        Paint.Color := $FF333333; ACanvas.DrawRect(TRectF.Create(CX-6, CY-20, CX-2, CY), Paint);
        ACanvas.DrawRect(TRectF.Create(CX+2, CY-20, CX+6, CY), Paint);
        Paint.Color := $FF4444AA; ACanvas.DrawRoundRect(TRectF.Create(CX-8, CY-35, CX+8, CY-18), 4, 4, Paint);
        Paint.Color := $FFFFDAB9; ACanvas.DrawCircle(PointF(CX, CY-40), 6, Paint);
      end;
    end;
  finally
    DrawList.Free;
  end;
end;

procedure TAdventureGame.DrawIsoTile(const ACanvas: ISkCanvas; CX, CY: Single; Color: TAlphaColor);
var
  Paint: ISkPaint;
  PB: ISkPathBuilder;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.Color := Color;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX, CY - TILE_H / 2);
  PB.LineTo(CX + TILE_W / 2, CY);
  PB.LineTo(CX, CY + TILE_H / 2);
  PB.LineTo(CX - TILE_W / 2, CY);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  Paint.Color := $FF222222;
  Paint.Style := TSkPaintStyle.Stroke;
  Paint.StrokeWidth := 1;
  ACanvas.DrawPath(PB.Snapshot, Paint);
end;

procedure TAdventureGame.DrawIsoBox(const ACanvas: ISkCanvas; CX, CY: Single; LenX, LenY, HeightZ: Single; TopC, LeftC, RightC: TAlphaColor);
var
  Paint: ISkPaint;
  PB: ISkPathBuilder;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  Paint.Color := RightC;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX + (LenX) * (TILE_W/2), CY + (LenX) * (TILE_H/2));
  PB.LineTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2));
  PB.LineTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX + (LenX) * (TILE_W/2), CY + (LenX) * (TILE_H/2) - HeightZ);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  Paint.Color := LeftC;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2));
  PB.LineTo(CX - (LenY) * (TILE_W/2), CY + (LenY) * (TILE_H/2));
  PB.LineTo(CX - (LenY) * (TILE_W/2), CY + (LenY) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2) - HeightZ);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  Paint.Color := TopC;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX, CY - HeightZ);
  PB.LineTo(CX + (LenX) * (TILE_W/2), CY + (LenX) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX - (LenY) * (TILE_W/2), CY + (LenY) * (TILE_H/2) - HeightZ);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);
end;

procedure TAdventureGame.DrawBed(const ACanvas: ISkCanvas; CX, CY: Single);
var
  Paint: ISkPaint;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  Paint.Color := $80000000;
  ACanvas.DrawOval(TRectF.Create(CX-30, CY-5, CX+30, CY+15), Paint);

  // Bett-Rahmen (Genau 1x1 Tile, Höhe 20)
  DrawIsoBox(ACanvas, CX, CY, 1.0, 1.0, 20, $FF8B4513, $FF5C2E0C, $FF3D1F08);
end;

procedure TAdventureGame.DrawTable(const ACanvas: ISkCanvas; CX, CY: Single);
var
  Paint: ISkPaint;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  Paint.Color := $80000000;
  ACanvas.DrawOval(TRectF.Create(CX-30, CY-5, CX+30, CY+15), Paint);

  // Tisch (Genau 1x1 Tile, massive Höhe 25)
  DrawIsoBox(ACanvas, CX, CY, 1.0, 1.0, 25, $FFA0522D, $FF8B4513, $FF5C2E0C);
end;

procedure TAdventureGame.DrawGlass(const ACanvas: ISkCanvas; CX, CY: Single; LiquidColor: TAlphaColor);
var
  Paint: ISkPaint;
  PB: ISkPathBuilder;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  // Schatten
  Paint.Color := $80000000;
  ACanvas.DrawOval(TRectF.Create(CX-6, CY-2, CX+6, CY+4), Paint);

  // Glas-Körper (Zylinder angenähert)
  Paint.Color := $88FFFFFF;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX-4, CY);
  PB.LineTo(CX-4, CY-10);
  PB.LineTo(CX+4, CY-10);
  PB.LineTo(CX+4, CY);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  // Flüssigkeit
  Paint.Color := LiquidColor;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX-3.5, CY-1);
  PB.LineTo(CX-3.5, CY-7);
  PB.LineTo(CX+3.5, CY-7);
  PB.LineTo(CX+3.5, CY-1);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  // Deckel
  Paint.Color := $AAFFFFFF;
  ACanvas.DrawOval(TRectF.Create(CX-4, CY-12, CX+4, CY-8), Paint);
end;

procedure TAdventureGame.DrawWall(const ACanvas: ISkCanvas; CX, CY: Single; LenX, LenY, HeightZ: Single);
var
  Paint: ISkPaint;
  PB: ISkPathBuilder;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  // Vordere Wand (halbtransparent)
  Paint.Color := $88666666;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2));
  PB.LineTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX - (LenY) * (TILE_W/2), CY + (LenY) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX - (LenY) * (TILE_W/2), CY + (LenY) * (TILE_H/2));
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  Paint.Color := $AA444444;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2));
  PB.LineTo(CX + (LenX-LenY) * (TILE_W/2), CY + (LenX+LenY) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX + (LenX) * (TILE_W/2), CY + (LenX) * (TILE_H/2) - HeightZ);
  PB.LineTo(CX + (LenX) * (TILE_W/2), CY + (LenX) * (TILE_H/2));
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);
end;

// =====================================================================
// MAIN DRAW & UI
// =====================================================================

procedure TAdventureGame.DrawScene(const ACanvas: ISkCanvas; const ADest: TRectF);
begin
  if FNeedsFullRepaint then
  begin
    var LSurface := TSkSurface.MakeRaster(Round(ADest.Width), Round(ADest.Height));
    var LCanvas := LSurface.Canvas;
    LCanvas.Scale(FZoom, FZoom);
    RenderBackgroundToCache(LCanvas);
    FBackgroundCache := LSurface.MakeImageSnapshot;
    FNeedsFullRepaint := False;
  end;

  ACanvas.Clear($FF000000);
  if Assigned(FBackgroundCache) then
    ACanvas.DrawImage(FBackgroundCache, 0, 0, TSkSamplingOptions.Medium);
end;

procedure TAdventureGame.DrawUI(const ACanvas: ISkCanvas; const ADest: TRectF);
var
  Paint: ISkPaint;
  Font: ISkFont;
begin
  Paint := TSkPaint.Create;
  Font := TSkFont.Create(nil, 18);
  Paint.Color := $AA000000;
  ACanvas.DrawRect(TRectF.Create(0, Height-50, Width, Height), Paint);
  Paint.Color := TAlphaColors.White;
  Paint.Style := TSkPaintStyle.Fill;
  ACanvas.DrawSimpleText('Verb: LOOK', 20, Height-20, Font, Paint);
  ACanvas.DrawSimpleText('Zoom: ' + FloatToStrF(FZoom, ffFixed, 2, 1) + 'x', Width - 100, Height-20, Font, Paint);
end;

procedure TAdventureGame.Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
begin
  DrawScene(ACanvas, ADest);
  DrawUI(ACanvas, ADest);
end;

procedure TAdventureGame.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  WorldX, WorldY, GridX, GridY: Single;
  OffsetX, OffsetY: Single;
  IntX, IntY: Integer;
  Path: TList<TPointF>;
begin
  FIsIdle := False;
  FNeedsFullRepaint := True;

  OffsetX := FCameraX - (Width / FZoom) / 2;
  OffsetY := FCameraY - (Height / FZoom) / 2;
  WorldX := (X / FZoom) + OffsetX;
  WorldY := (Y / FZoom) + OffsetY;

  GridX := (WorldX / (TILE_W / 2) + WorldY / (TILE_H / 2)) / 2;
  GridY := (WorldY / (TILE_H / 2) - WorldX / (TILE_W / 2)) / 2;
  IntX := Trunc(GridX);
  IntY := Trunc(GridY);

  if not IsBlocked(IntX, IntY) then
  begin
    Path := FindPath(Trunc(FPlayer.GridX), Trunc(FPlayer.GridY), IntX, IntY);
    try
      FPlayer.Waypoints.Clear;
      for var WP in Path do
        FPlayer.Waypoints.Add(WP);
    finally
      Path.Free;
    end;
  end;

  inherited;
end;

procedure TAdventureGame.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  FNeedsFullRepaint := True;
  if WheelDelta > 0 then
    FZoom := Min(3.0, FZoom + 0.1)
  else
    FZoom := Max(1.0, FZoom - 0.1);
  Handled := True;
end;

procedure TAdventureGame.SafeInvalidate;
begin
  if csDestroying in ComponentState then Exit;
  TThread.Queue(nil,
    procedure
    begin
      if not (csDestroying in ComponentState) then
      begin
        Redraw;
        Repaint;
      end;
    end);
end;

procedure TAdventureGame.StartThread;
begin
  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      LastTime, NowTime: Cardinal;
      SleepTime: Integer;
    begin
      LastTime := TThread.GetTickCount;
      while not TThread.CheckTerminated do
      begin
        NowTime := TThread.GetTickCount;
        if FActive then
        begin
          DoUpdate((NowTime - LastTime) / 1000);
          SafeInvalidate;

          if FIsIdle then
            SleepTime := 100
          else
            SleepTime := 16;
        end
        else
          SleepTime := 100;

        LastTime := NowTime;
        Sleep(SleepTime);
      end;
    end);
  FThread.FreeOnTerminate := True;
  FThread.Start;
end;

procedure TAdventureGame.StopThread;
begin
  FActive := False;
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    Sleep(50);
  end;
end;

end.
