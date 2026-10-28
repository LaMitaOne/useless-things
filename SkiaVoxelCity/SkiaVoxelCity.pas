{*******************************************************************************
  VoxelCityBuilder v0.1 - Isometric Voxel Terraforming & City Builder
********************************************************************************
  Features:
  - Isometric voxel terrain generation with smooth height blending.
  - Terraforming tools (Raise/Lower) that gently pull adjacent tiles for slopes.
  - Real 3D isometric voxel buildings (Houses) and objects (Trees).
  - Road placement that drapes strictly over existing terrain without altering it.
  - Accurate 2D Point-in-Polygon raycasting for mouse cursor selection.
    The cursor snaps to the visible visual surface under the mouse,
    including cliff sides and elevated tiles.
  - UI toolbar and hotkeys for tool selection.

  Author:  Lara Miriam Tamy Reschke
  License: MIT
*******************************************************************************}


unit SkiaVoxelCity;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math, System.UITypes,
  System.SyncObjs, System.Generics.Collections, FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Skia, System.Skia, Winapi.Windows;

const
  MAP_SIZE = 48;
  TILE_W = 32;
  TILE_H = 16;
  HEIGHT_Z = 6;

type
  TToolType = (ttLower, ttRaise, ttTree, ttHouse, ttRoad, ttBulldoze);

  TSkiaVoxelCity = class(TSkCustomControl)
  private
    FThread: TThread;
    FActive: Boolean;
    FLock: TCriticalSection;
    FHeightMap: array[0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of Single;
    FColorMap: array[0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of TAlphaColor;
    FObjects: array[0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of Byte;
    FCameraX, FCameraY: Single;
    FZoom: Single;
    FMouseScreen: TPointF;
    FMouseWorld: TPoint;
    FMouseHitHeight: Single;
    FIsDragging: Boolean;
    FDragStartCam: TPointF;
    FDragStartScreen: TPointF;
    FCurrentTool: TToolType;
    FAnimPhase: Single;
    FClouds: TList<TPointF>;
    FFillPaint: ISkPaint;
    FStrokePaint: ISkPaint;
    procedure GenerateTerrain;
    function SafeHeight(GX, GY: Integer): Single;
    function SafeObject(GX, GY: Integer): Byte;
    procedure UpdateTileColor(GX, GY: Integer);
    procedure DoUpdate(DeltaSec: Double);
    procedure DrawVoxelColumn(const ACanvas: ISkCanvas; GX, GY: Integer; const OX, OY: Single);
    procedure DrawWater(const ACanvas: ISkCanvas; const OX, OY: Single);
    procedure DrawMap(const ACanvas: ISkCanvas; const OX, OY: Single);
    procedure DrawObjects(const ACanvas: ISkCanvas; const OX, OY: Single);
    procedure DrawTree(const ACanvas: ISkCanvas; CX, CY, H: Single);
    procedure DrawHouse(const ACanvas: ISkCanvas; CX, CY, H: Single);
    procedure DrawRoads(const ACanvas: ISkCanvas; const OX, OY: Single);
    procedure DrawCursor(const ACanvas: ISkCanvas; const OX, OY: Single);
    procedure DrawClouds(const ACanvas: ISkCanvas; const OX, OY: Single);
    procedure DrawUI(const ACanvas: ISkCanvas);
    procedure SafeInvalidate;
    procedure StartThread;
    procedure StopThread;
    function DarkenColor(C: TAlphaColor; F: Single): TAlphaColor;
    function IsKeyDown(Key: Integer): Boolean;
    procedure ApplyTool;
    procedure UpdateMouseRaycast;
    procedure ClampCamera;
  protected
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation
{ ===================== Helpers ===================== }

function TSkiaVoxelCity.IsKeyDown(Key: Integer): Boolean;
begin
  Result := (GetAsyncKeyState(Key) and $8000) <> 0;
end;

function TSkiaVoxelCity.DarkenColor(C: TAlphaColor; F: Single): TAlphaColor;
var
  R: TAlphaColorRec;
begin
  R.Color := C;
  R.R := Round(R.R * F);
  R.G := Round(R.G * F);
  R.B := Round(R.B * F);
  Result := R.Color;
end;

function TSkiaVoxelCity.SafeHeight(GX, GY: Integer): Single;
begin
  if (GX < 0) or (GX >= MAP_SIZE) or (GY < 0) or (GY >= MAP_SIZE) then
    Result := 0
  else
    Result := FHeightMap[GX, GY];
end;

function TSkiaVoxelCity.SafeObject(GX, GY: Integer): Byte;
begin
  if (GX < 0) or (GX >= MAP_SIZE) or (GY < 0) or (GY >= MAP_SIZE) then
    Result := 0
  else
    Result := FObjects[GX, GY];
end;
{ ===================== Terrain Generation ===================== }

procedure TSkiaVoxelCity.GenerateTerrain;
var
  X, Y, I: Integer;
  H, DCenter: Single;
begin
  Randomize;
  for Y := 0 to MAP_SIZE - 1 do
  begin
    for X := 0 to MAP_SIZE - 1 do
    begin
      H := 9.0;
      H := H + Sin(X * 0.14) * Cos(Y * 0.14) * 3.5;
      H := H + Sin(X * 0.31 + 0.7) * 1.8;
      H := H + Cos(Y * 0.27 + 1.2) * 2.5;
      H := H + Sin((X + Y) * 0.09) * 1.5;
      DCenter := Hypot(X - MAP_SIZE / 2, Y - MAP_SIZE / 2) / (MAP_SIZE / 2);
      if DCenter < 0.35 then
        H := H - (0.35 - DCenter) * 18.0;
      FHeightMap[X, Y] := H;
      FObjects[X, Y] := 0;
      if (H > 5.0) and (Random < 0.05) then
        FObjects[X, Y] := 1;
      UpdateTileColor(X, Y);
    end;
  end;
  FClouds.Clear;
  for I := 0 to 5 do
    FClouds.Add(PointF(Random(MAP_SIZE * TILE_W), Random(MAP_SIZE * TILE_H)));
end;

procedure TSkiaVoxelCity.UpdateTileColor(GX, GY: Integer);
var
  H: Single;
  Rec: TAlphaColorRec;
begin
  H := FHeightMap[GX, GY];
  Rec.A := 255;
  if H < 3.0 then
  begin
    Rec.R := 15;
    Rec.G := 35;
    Rec.B := 90;
  end
  else if H < 4.0 then
  begin
    Rec.R := 30;
    Rec.G := 60;
    Rec.B := 120;
  end
  else if H < 5.0 then
  begin
    Rec.R := 200;
    Rec.G := 175;
    Rec.B := 90;
  end
  else if H < 16.0 then
  begin
    if (GX * 7 + GY * 13) mod 5 < 2 then
    begin
      Rec.R := 45;
      Rec.G := 145;
      Rec.B := 55;
    end
    else
    begin
      Rec.R := 55;
      Rec.G := 165;
      Rec.B := 65;
    end;
  end
  else if H < 20.0 then
  begin
    Rec.R := 105;
    Rec.G := 95;
    Rec.B := 85;
  end
  else
  begin
    Rec.R := 235;
    Rec.G := 240;
    Rec.B := 245;
  end;
  FColorMap[GX, GY] := Rec.Color;
end;
{ ===================== Camera Logic ===================== }

procedure TSkiaVoxelCity.ClampCamera;
var
  MaxOffsetX, MaxOffsetY: Single;
begin
  MaxOffsetX := MAP_SIZE * 0.6;
  MaxOffsetY := MAP_SIZE * 0.6;
  FCameraX := EnsureRange(FCameraX, (MAP_SIZE / 2) - MaxOffsetX, (MAP_SIZE / 2) + MaxOffsetX);
  FCameraY := EnsureRange(FCameraY, (MAP_SIZE / 2) - MaxOffsetY, (MAP_SIZE / 2) + MaxOffsetY);
end;
{ ===================== Game Loop / Updates ===================== }

procedure TSkiaVoxelCity.DoUpdate(DeltaSec: Double);
var
  I: Integer;
  CloudPos: TPointF;
begin
  if not FActive then
    Exit;
  FAnimPhase := FAnimPhase + DeltaSec;
  for I := 0 to FClouds.Count - 1 do
  begin
    CloudPos := FClouds[I];
    CloudPos.X := CloudPos.X + 15 * DeltaSec;
    CloudPos.Y := CloudPos.Y + 5 * DeltaSec;
    if (CloudPos.X > MAP_SIZE * TILE_W) or (CloudPos.Y > MAP_SIZE * TILE_H) then
    begin
      CloudPos.X := -200 - Random(500);
      CloudPos.Y := Random(Trunc(MAP_SIZE * TILE_H));
    end;
    FClouds[I] := CloudPos;
  end;
  if IsKeyDown(VK_LEFT) or IsKeyDown(Ord('A')) then
    FCameraX := FCameraX - 120 * DeltaSec;
  if IsKeyDown(VK_RIGHT) or IsKeyDown(Ord('D')) then
    FCameraX := FCameraX + 120 * DeltaSec;
  if IsKeyDown(VK_UP) or IsKeyDown(Ord('W')) then
    FCameraY := FCameraY - 120 * DeltaSec;
  if IsKeyDown(VK_DOWN) or IsKeyDown(Ord('S')) then
    FCameraY := FCameraY + 120 * DeltaSec;

  ClampCamera;
end;

procedure TSkiaVoxelCity.ApplyTool;
var
  GX, GY, DX, DY: Integer;
  H, NewH, Diff: Single;
begin
  GX := FMouseWorld.X;
  GY := FMouseWorld.Y;
  if (GX < 0) or (GX >= MAP_SIZE) or (GY < 0) or (GY >= MAP_SIZE) then
    Exit;
  H := FHeightMap[GX, GY];
  case FCurrentTool of
    ttLower:
      begin
        NewH := Max(-2, H - 1.5);
        FHeightMap[GX, GY] := NewH;
        UpdateTileColor(GX, GY);
        for DX := -1 to 1 do
          for DY := -1 to 1 do
          begin
            if (DX = 0) and (DY = 0) then
              Continue;
            if SafeObject(GX + DX, GY + DY) = 3 then
              Continue;
            if (GX + DX >= 0) and (GX + DX < MAP_SIZE) and (GY + DY >= 0) and (GY + DY < MAP_SIZE) then
            begin
              Diff := FHeightMap[GX + DX, GY + DY] - NewH;
              if (Diff > 0) and (Diff < 2.0) then
              begin
                FHeightMap[GX + DX, GY + DY] := FHeightMap[GX + DX, GY + DY] - 0.5;
                UpdateTileColor(GX + DX, GY + DY);
              end;
            end;
          end;
      end;
    ttRaise:
      begin
        NewH := Min(24, H + 1.5);
        FHeightMap[GX, GY] := NewH;
        UpdateTileColor(GX, GY);
        for DX := -1 to 1 do
          for DY := -1 to 1 do
          begin
            if (DX = 0) and (DY = 0) then
              Continue;
            if SafeObject(GX + DX, GY + DY) = 3 then
              Continue;
            if (GX + DX >= 0) and (GX + DX < MAP_SIZE) and (GY + DY >= 0) and (GY + DY < MAP_SIZE) then
            begin
              Diff := NewH - FHeightMap[GX + DX, GY + DY];
              if (Diff > 0) and (Diff < 2.0) then
              begin
                FHeightMap[GX + DX, GY + DY] := FHeightMap[GX + DX, GY + DY] + 0.5;
                UpdateTileColor(GX + DX, GY + DY);
              end;
            end;
          end;
      end;
    ttTree:
      begin
        if H > 4.0 then
          FObjects[GX, GY] := 1;
      end;
    ttHouse:
      begin
        if H > 4.0 then
          FObjects[GX, GY] := 2;
      end;
    ttRoad:
      begin
        if H > 3.5 then
        begin
          FObjects[GX, GY] := 3;
        end;
      end;
    ttBulldoze:
      begin
        FObjects[GX, GY] := 0;
      end;
  end;
end;
{ ===================== Raycast & Input ===================== }

procedure TSkiaVoxelCity.UpdateMouseRaycast;
var
  OX, OY: Single;
  BaseGX, BaseGY: Integer;
  H, HFX, HFY: Single;
  P1, P2, P3, P4: TPointF;
  BestGX, BestGY, BestI: Integer;
  BestY, TestH: Single;
  Found: Boolean;
  Poly: array of TPointF;

  function PointInPolygon(P: TPointF; const APoly: array of TPointF): Boolean;
  var
    i, k: Integer;
    A, B: TPointF;
  begin
    Result := False;
    k := High(APoly);
    for i := 0 to High(APoly) do
    begin
      A := APoly[i];
      B := APoly[k];
      if ((A.Y > P.Y) <> (B.Y > P.Y)) and (P.X < (B.X - A.X) * (P.Y - A.Y) / (B.Y - A.Y) + A.X) then
        Result := not Result;
      k := i;
    end;
  end;

begin
  OX := (Width / FZoom / 2) - ((FCameraX - FCameraY) * (TILE_W / 2));
  OY := (Height / FZoom / 2) - ((FCameraX + FCameraY) * (TILE_H / 2)) - 40;

  BaseGX := FMouseWorld.X;
  BaseGY := FMouseWorld.Y;

  BestGX := -1;
  BestGY := -1;
  BestI := -1;
  BestY := 10000;
  Found := False;

  for var dGY := -1 to 1 do
  begin
    for var dGX := -1 to 1 do
    begin
      var CheckGX := BaseGX + dGX;
      var CheckGY := BaseGY + dGY;
      if (CheckGX < 0) or (CheckGX >= MAP_SIZE) or (CheckGY < 0) or (CheckGY >= MAP_SIZE) then
        Continue;

      H := FHeightMap[CheckGX, CheckGY];
      HFX := SafeHeight(CheckGX + 1, CheckGY);
      HFY := SafeHeight(CheckGX, CheckGY + 1);

      for var I := 0 to 4 do
      begin
        case I of
          0:
            TestH := H;
          1:
            if H > HFX then
              TestH := HFX
            else
              Continue;
          2:
            if H > HFX then
              TestH := H - ((H - HFX) / 2)
            else
              Continue;
          3:
            if H > HFY then
              TestH := HFY
            else
              Continue;
          4:
            if H > HFY then
              TestH := H - ((H - HFY) / 2)
            else
              Continue;
        end;

        P1 := PointF((CheckGX - CheckGY) * (TILE_W / 2) + OX, (CheckGX + CheckGY) * (TILE_H / 2) + OY - TestH * HEIGHT_Z);
        P2 := PointF((CheckGX + 1 - CheckGY) * (TILE_W / 2) + OX, (CheckGX + 1 + CheckGY) * (TILE_H / 2) + OY - TestH * HEIGHT_Z);
        P3 := PointF((CheckGX - CheckGY) * (TILE_W / 2) + OX, (CheckGX + 1 + CheckGY + 1) * (TILE_H / 2) + OY - TestH * HEIGHT_Z);
        P4 := PointF((CheckGX - 1 - CheckGY) * (TILE_W / 2) + OX, (CheckGX + CheckGY + 1) * (TILE_H / 2) + OY - TestH * HEIGHT_Z);

        SetLength(Poly, 4);
        Poly[0] := P1;
        Poly[1] := P2;
        Poly[2] := P3;
        Poly[3] := P4;

        if PointInPolygon(PointF(FMouseScreen.X / FZoom, FMouseScreen.Y / FZoom), Poly) then
        begin
          var MinY := Min(Min(P1.Y, P2.Y), Min(P3.Y, P4.Y));
          if MinY < BestY then
          begin
            BestY := MinY;
            BestGX := CheckGX;
            BestGY := CheckGY;
            BestI := I;
            Found := True;
          end;
        end;
      end;
    end;
  end;

  if Found then
  begin
    FMouseWorld.X := BestGX;
    FMouseWorld.Y := BestGY;
    H := FHeightMap[BestGX, BestGY];
    HFX := SafeHeight(BestGX + 1, BestGY);
    HFY := SafeHeight(BestGX, BestGY + 1);
    case BestI of
      0:
        FMouseHitHeight := H;
      1:
        FMouseHitHeight := HFX;
      2:
        FMouseHitHeight := H - ((H - HFX) / 2);
      3:
        FMouseHitHeight := HFY;
      4:
        FMouseHitHeight := H - ((H - HFY) / 2);
    end;
  end
  else
    FMouseHitHeight := -100;
end;

procedure TSkiaVoxelCity.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  OX, OY, Dx, Dy: Single;
begin
  inherited;
  FMouseScreen := PointF(X, Y);

  OX := (Width / FZoom / 2) - ((FCameraX - FCameraY) * (TILE_W / 2));
  OY := (Height / FZoom / 2) - ((FCameraX + FCameraY) * (TILE_H / 2)) - 40;
  Dx := X / FZoom - OX - (TILE_W / 2);
  Dy := Y / FZoom - OY - (TILE_H / 2) + (4.0 * HEIGHT_Z);
  FMouseWorld.X := Trunc((Dx / (TILE_W / 2) + Dy / (TILE_H / 2)) / 2);
  FMouseWorld.Y := Trunc((Dy / (TILE_H / 2) - Dx / (TILE_W / 2)) / 2);

  UpdateMouseRaycast;

  if (Y >= Height - 40) and (Y <= Height - 10) then
  begin
    var BtnIdx := Trunc((X - 10) / 110);
    if (BtnIdx >= 0) and (BtnIdx <= Integer(High(TToolType))) then
    begin
      FCurrentTool := TToolType(BtnIdx);
      Exit;
    end;
  end;
  if Button = TMouseButton.mbLeft then
  begin
    ApplyTool;
  end
  else if Button = TMouseButton.mbRight then
  begin
    FIsDragging := True;
    FDragStartCam := PointF(FCameraX, FCameraY);
    FDragStartScreen := PointF(X, Y);
  end;
end;

procedure TSkiaVoxelCity.MouseMove(Shift: TShiftState; X, Y: Single);
var
  OX, OY, Dx, Dy: Single;
begin
  inherited;
  FMouseScreen := PointF(X, Y);

  OX := (Width / FZoom / 2) - ((FCameraX - FCameraY) * (TILE_W / 2));
  OY := (Height / FZoom / 2) - ((FCameraX + FCameraY) * (TILE_H / 2)) - 40;
  Dx := X / FZoom - OX - (TILE_W / 2);
  Dy := Y / FZoom - OY - (TILE_H / 2) + (4.0 * HEIGHT_Z);
  FMouseWorld.X := Trunc((Dx / (TILE_W / 2) + Dy / (TILE_H / 2)) / 2);
  FMouseWorld.Y := Trunc((Dy / (TILE_H / 2) - Dx / (TILE_W / 2)) / 2);

  UpdateMouseRaycast;

  if FIsDragging then
  begin
    FCameraX := FDragStartCam.X - ((X - FDragStartScreen.X) / FZoom) * 0.15;
    FCameraY := FDragStartCam.Y - ((Y - FDragStartScreen.Y) / FZoom) * 0.15;
    ClampCamera;
  end
  else if (ssLeft in Shift) then
  begin
    ApplyTool;
  end;
end;

procedure TSkiaVoxelCity.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if Button = TMouseButton.mbRight then
    FIsDragging := False;
end;

procedure TSkiaVoxelCity.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  case KeyChar of
    '1':
      FCurrentTool := ttLower;
    '2':
      FCurrentTool := ttRaise;
    '3':
      FCurrentTool := ttTree;
    '4':
      FCurrentTool := ttHouse;
    '5':
      FCurrentTool := ttRoad;
    '6':
      FCurrentTool := ttBulldoze;
  end;
end;

procedure TSkiaVoxelCity.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  inherited;
  if WheelDelta > 0 then
    FZoom := Min(3.0, FZoom + 0.1)
  else
    FZoom := Max(0.5, FZoom - 0.1);
  ClampCamera;
  Handled := True;
end;

{ ===================== Rendering ===================== }
procedure TSkiaVoxelCity.DrawVoxelColumn(const ACanvas: ISkCanvas; GX, GY: Integer; const OX, OY: Single);
var
  H, HFX, HFY: Single;
  C: TAlphaColor;
  P1, P2, P3, P4: TPointF;
  PB2, PB3, PB4: TPointF;
  Rec: TAlphaColorRec;
  TopC, RightC, LeftC: TAlphaColor;
  PB: ISkPathBuilder;
begin
  if (GX < 0) or (GX >= MAP_SIZE) or (GY < 0) or (GY >= MAP_SIZE) then
    Exit;
  H := FHeightMap[GX, GY];
  C := FColorMap[GX, GY];
  Rec.Color := C;
  TopC := Rec.Color;
  RightC := DarkenColor(TopC, 0.62);
  LeftC := DarkenColor(TopC, 0.42);
  P1 := PointF((GX - GY) * (TILE_W / 2) + OX, (GX + GY) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  P2 := PointF((GX + 1 - GY) * (TILE_W / 2) + OX, (GX + 1 + GY) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  P3 := PointF((GX - GY) * (TILE_W / 2) + OX, (GX + 1 + GY + 1) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  P4 := PointF((GX - 1 - GY) * (TILE_W / 2) + OX, (GX + GY + 1) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  HFX := SafeHeight(GX + 1, GY);
  HFY := SafeHeight(GX, GY + 1);
  FFillPaint.AntiAlias := False;
  if H > HFX then
  begin
    PB2 := PointF(P2.X, P2.Y + (H - HFX) * HEIGHT_Z);
    PB3 := PointF(P3.X, P3.Y + (H - HFX) * HEIGHT_Z);
    FFillPaint.Color := RightC;
    PB := TSkPathBuilder.Create;
    PB.MoveTo(P2.X, P2.Y);
    PB.LineTo(P3.X, P3.Y);
    PB.LineTo(PB3.X, PB3.Y);
    PB.LineTo(PB2.X, PB2.Y);
    PB.Close;
    ACanvas.DrawPath(PB.Snapshot, FFillPaint);
  end;
  if H > HFY then
  begin
    PB4 := PointF(P4.X, P4.Y + (H - HFY) * HEIGHT_Z);
    PB3 := PointF(P3.X, P3.Y + (H - HFY) * HEIGHT_Z);
    FFillPaint.Color := LeftC;
    PB := TSkPathBuilder.Create;
    PB.MoveTo(P4.X, P4.Y);
    PB.LineTo(P3.X, P3.Y);
    PB.LineTo(PB3.X, PB3.Y);
    PB.LineTo(PB4.X, PB4.Y);
    PB.Close;
    ACanvas.DrawPath(PB.Snapshot, FFillPaint);
  end;
  FFillPaint.Color := TopC;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P1.X, P1.Y);
  PB.LineTo(P2.X, P2.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P4.X, P4.Y);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, FFillPaint);
end;

procedure TSkiaVoxelCity.DrawWater(const ACanvas: ISkCanvas; const OX, OY: Single);
var
  X, Y: Integer;
  H: Single;
  P1, P2, P3, P4: TPointF;
  PB: ISkPathBuilder;
begin
  for Y := 0 to MAP_SIZE - 1 do
  begin
    for X := 0 to MAP_SIZE - 1 do
    begin
      H := FHeightMap[X, Y];
      if H < 4.0 then
      begin
        P1 := PointF((X - Y) * (TILE_W / 2) + OX, (X + Y) * (TILE_H / 2) + OY - 4.0 * HEIGHT_Z);
        P2 := PointF((X + 1 - Y) * (TILE_W / 2) + OX, (X + 1 + Y) * (TILE_H / 2) + OY - 4.0 * HEIGHT_Z);
        P3 := PointF((X - Y) * (TILE_W / 2) + OX, (X + 1 + Y + 1) * (TILE_H / 2) + OY - 4.0 * HEIGHT_Z);
        P4 := PointF((X - 1 - Y) * (TILE_W / 2) + OX, (X + Y + 1) * (TILE_H / 2) + OY - 4.0 * HEIGHT_Z);
        FFillPaint.Color := $880022AA;
        FFillPaint.AntiAlias := True;
        PB := TSkPathBuilder.Create;
        PB.MoveTo(P1.X, P1.Y);
        PB.LineTo(P2.X, P2.Y);
        PB.LineTo(P3.X, P3.Y);
        PB.LineTo(P4.X, P4.Y);
        PB.Close;
        ACanvas.DrawPath(PB.Snapshot, FFillPaint);
      end;
    end;
  end;
end;

procedure TSkiaVoxelCity.DrawMap(const ACanvas: ISkCanvas; const OX, OY: Single);
var
  X, Y: Integer;
begin
  for Y := 0 to MAP_SIZE - 1 do
    for X := 0 to MAP_SIZE - 1 do
      DrawVoxelColumn(ACanvas, X, Y, OX, OY);
end;

procedure TSkiaVoxelCity.DrawTree(const ACanvas: ISkCanvas; CX, CY, H: Single);
begin
  FFillPaint.Color := $FF6B4226;
  FFillPaint.AntiAlias := False;
  ACanvas.DrawRect(TRectF.Create(CX - 2, CY - 6, CX + 2, CY), FFillPaint);
  FFillPaint.Color := $FF22703A;
  FFillPaint.AntiAlias := True;
  ACanvas.DrawCircle(PointF(CX, CY - 10), 6, FFillPaint);
  ACanvas.DrawCircle(PointF(CX - 3, CY - 6), 4, FFillPaint);
  ACanvas.DrawCircle(PointF(CX + 3, CY - 6), 4, FFillPaint);
end;

procedure TSkiaVoxelCity.DrawHouse(const ACanvas: ISkCanvas; CX, CY, H: Single);
var
  W, D, WH, DH: Single;
  P1, P2, P3, P4, R1, R2, R3, R4: TPointF;
  PB: ISkPathBuilder;
begin
  W := 12;
  D := 12;
  WH := 14;
  DH := 8;
  P1 := PointF(CX - W, CY);
  P2 := PointF(CX, CY + D * (TILE_H / TILE_W));
  P3 := PointF(CX + W, CY);
  P4 := PointF(CX, CY - D * (TILE_H / TILE_W));
  FFillPaint.AntiAlias := True;
  FFillPaint.Color := $FFB5B5B5;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P1.X, P1.Y);
  PB.LineTo(P2.X, P2.Y);
  PB.LineTo(P2.X, P2.Y - WH);
  PB.LineTo(P1.X, P1.Y - WH);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, FFillPaint);
  FFillPaint.Color := $FF8A8A8A;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P2.X, P2.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P3.X, P3.Y - WH);
  PB.LineTo(P2.X, P2.Y - WH);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, FFillPaint);
  R1 := PointF(P1.X, P1.Y - WH);
  R2 := PointF(P2.X, P2.Y - WH);
  R3 := PointF(P3.X, P3.Y - WH);
  R4 := PointF(P4.X, P4.Y - WH);
  FFillPaint.Color := $FFB54343;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(R1.X, R1.Y);
  PB.LineTo(R2.X, R2.Y);
  PB.LineTo(CX, CY - WH - DH);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, FFillPaint);
  PB := TSkPathBuilder.Create;
  PB.MoveTo(R2.X, R2.Y);
  PB.LineTo(R3.X, R3.Y);
  PB.LineTo(CX, CY - WH - DH);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, FFillPaint);
end;

procedure TSkiaVoxelCity.DrawRoads(const ACanvas: ISkCanvas; const OX, OY: Single);
var
  X, Y: Integer;
  Center, P: TPointF;
  PB: ISkPathBuilder;

  function IsoToScreen(IX, IY: Integer; IH: Single): TPointF;
  begin
    Result.X := (IX - IY) * (TILE_W / 2) + OX + TILE_W / 2;
    Result.Y := (IX + IY) * (TILE_H / 2) + OY + TILE_H - IH * HEIGHT_Z;
  end;

begin
  FFillPaint.Style := TSkPaintStyle.Fill;
  FFillPaint.AntiAlias := True;
  FStrokePaint.Style := TSkPaintStyle.Stroke;
  FStrokePaint.StrokeWidth := 12;
  FStrokePaint.AntiAlias := True;
  for Y := 0 to MAP_SIZE - 1 do
  begin
    for X := 0 to MAP_SIZE - 1 do
    begin
      if FObjects[X, Y] = 3 then
      begin
        Center := IsoToScreen(X, Y, FHeightMap[X, Y]);
        FFillPaint.Color := $FF3A3A3A;
        ACanvas.DrawCircle(Center, 6, FFillPaint);
        FStrokePaint.Color := $FF3A3A3A;
        if SafeObject(X + 1, Y) = 3 then
        begin
          P := IsoToScreen(X + 1, Y, FHeightMap[X + 1, Y]);
          PB := TSkPathBuilder.Create;
          PB.MoveTo(Center.X, Center.Y);
          PB.LineTo(P.X, P.Y);
          ACanvas.DrawPath(PB.Snapshot, FStrokePaint);
        end;
        if SafeObject(X, Y + 1) = 3 then
        begin
          P := IsoToScreen(X, Y + 1, FHeightMap[X, Y + 1]);
          PB := TSkPathBuilder.Create;
          PB.MoveTo(Center.X, Center.Y);
          PB.LineTo(P.X, P.Y);
          ACanvas.DrawPath(PB.Snapshot, FStrokePaint);
        end;
      end;
    end;
  end;
  FStrokePaint.Style := TSkPaintStyle.Fill;
end;

procedure TSkiaVoxelCity.DrawObjects(const ACanvas: ISkCanvas; const OX, OY: Single);
var
  X, Y: Integer;
  CX, CY, H: Single;
begin
  for Y := 0 to MAP_SIZE - 1 do
  begin
    for X := 0 to MAP_SIZE - 1 do
    begin
      if (FObjects[X, Y] = 1) or (FObjects[X, Y] = 2) then
      begin
        H := FHeightMap[X, Y];
        CX := (X - Y) * (TILE_W / 2) + OX + TILE_W / 2;
        CY := (X + Y) * (TILE_H / 2) + OY + TILE_H - (H * HEIGHT_Z);
        if FObjects[X, Y] = 1 then
          DrawTree(ACanvas, CX, CY, H);
        if FObjects[X, Y] = 2 then
          DrawHouse(ACanvas, CX, CY, H);
      end;
    end;
  end;
end;

procedure TSkiaVoxelCity.DrawCursor(const ACanvas: ISkCanvas; const OX, OY: Single);
var
  P1, P2, P3, P4: TPointF;
  PB: ISkPathBuilder;
  GX, GY: Integer;
  H: Single;
begin
  if FMouseHitHeight <= -50 then
    Exit;

  GX := FMouseWorld.X;
  GY := FMouseWorld.Y;
  if (GX < 0) or (GX >= MAP_SIZE) or (GY < 0) or (GY >= MAP_SIZE) then
    Exit;

  H := FMouseHitHeight;

  P1 := PointF((GX - GY) * (TILE_W / 2) + OX, (GX + GY) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  P2 := PointF((GX + 1 - GY) * (TILE_W / 2) + OX, (GX + 1 + GY) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  P3 := PointF((GX - GY) * (TILE_W / 2) + OX, (GX + 1 + GY + 1) * (TILE_H / 2) + OY - H * HEIGHT_Z);
  P4 := PointF((GX - 1 - GY) * (TILE_W / 2) + OX, (GX + GY + 1) * (TILE_H / 2) + OY - H * HEIGHT_Z);

  FStrokePaint.Color := TAlphaColors.White;
  FStrokePaint.StrokeWidth := 2;
  FStrokePaint.AntiAlias := True;
  FStrokePaint.Style := TSkPaintStyle.Stroke;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P1.X, P1.Y);
  PB.LineTo(P2.X, P2.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P4.X, P4.Y);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, FStrokePaint);
  FStrokePaint.Style := TSkPaintStyle.Fill;
end;

procedure TSkiaVoxelCity.DrawClouds(const ACanvas: ISkCanvas; const OX, OY: Single);
var
  CloudPos: TPointF;
  CX, CY: Single;
begin
  FFillPaint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Normal, 35.0);
  for CloudPos in FClouds do
  begin
    CX := (CloudPos.X - CloudPos.Y) * 0.5 + OX;
    CY := (CloudPos.X + CloudPos.Y) * 0.25 + OY;
    FFillPaint.Color := $28000000;
    ACanvas.DrawCircle(PointF(CX, CY + 20), 120, FFillPaint);
    ACanvas.DrawCircle(PointF(CX + 200, CY + 100), 150, FFillPaint);
    ACanvas.DrawCircle(PointF(CX - 150, CY + 120), 100, FFillPaint);
    FFillPaint.Color := $50FFFFFF;
    ACanvas.DrawCircle(PointF(CX + 30, CY - 30), 120, FFillPaint);
    ACanvas.DrawCircle(PointF(CX + 230, CY + 50), 150, FFillPaint);
    ACanvas.DrawCircle(PointF(CX - 120, CY + 90), 100, FFillPaint);
  end;
  FFillPaint.MaskFilter := nil;
end;

procedure TSkiaVoxelCity.DrawUI(const ACanvas: ISkCanvas);
var
  Font: TSkFont;
  Paint: ISkPaint;
  BtnX, BtnY, i: Integer;
  BtnText: string;
  BtnRect: TRectF;
begin
  Font := TSkFont.Create;
  try
    Paint := TSkPaint.Create(TSkPaintStyle.Fill);
    Paint.AntiAlias := True;
    Paint.Color := $CC101018;
    ACanvas.DrawRect(TRectF.Create(0, Height - 50, Width, Height), Paint);
    BtnX := 10;
    BtnY := Trunc(Height) - 40;
    for i := 0 to Integer(High(TToolType)) do
    begin
      case TToolType(i) of
        ttLower:
          BtnText := '1: Lower';
        ttRaise:
          BtnText := '2: Raise';
        ttTree:
          BtnText := '3: Tree';
        ttHouse:
          BtnText := '4: House';
        ttRoad:
          BtnText := '5: Road';
        ttBulldoze:
          BtnText := '6: Bulldoze';
      end;
      BtnRect := TRectF.Create(BtnX, BtnY, BtnX + 100, BtnY + 30);
      if FCurrentTool = TToolType(i) then
        Paint.Color := $FF3399FF
      else
        Paint.Color := $FF2A2A3A;
      ACanvas.DrawRect(BtnRect, Paint);
      Paint.Color := TAlphaColors.White;
      ACanvas.DrawSimpleText(BtnText, BtnX + 8, BtnY + 20, Font, Paint);
      BtnX := BtnX + 110;
    end;
    Paint.Color := $FFCCCCCC;
    ACanvas.DrawSimpleText('Keys: WASD to Scroll | Left Click: Build | Right Drag: Pan | Wheel: Zoom', 10, 20, Font, Paint);
  finally
    Font.Free;
  end;
end;

procedure TSkiaVoxelCity.Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  OX, OY: Single;
begin
  FLock.Acquire;
  try
    ACanvas.Clear($FF0A0A1A);
    ACanvas.Save;
    ACanvas.Scale(FZoom, FZoom);
    OX := (Width / FZoom / 2) - ((FCameraX - FCameraY) * (TILE_W / 2));
    OY := (Height / FZoom / 2) - ((FCameraX + FCameraY) * (TILE_H / 2)) - 40;
    DrawMap(ACanvas, OX, OY);
    DrawWater(ACanvas, OX, OY);
    DrawRoads(ACanvas, OX, OY);
    DrawObjects(ACanvas, OX, OY);
    DrawCursor(ACanvas, OX, OY);
    DrawClouds(ACanvas, OX, OY);
    ACanvas.Restore;
    DrawUI(ACanvas);
  finally
    FLock.Release;
  end;
end;
{ ===================== Threading & Lifecycle ===================== }

procedure TSkiaVoxelCity.SafeInvalidate;
begin
  if csDestroying in ComponentState then
    Exit;
  TThread.Queue(nil,
    procedure
    begin
      if not (csDestroying in ComponentState) and Assigned(Self) then
      begin
        Redraw;
        Repaint;
      end;
    end);
end;

procedure TSkiaVoxelCity.StartThread;
begin
  if Assigned(FThread) then
    Exit;
  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      LastTime, NowTime, DeltaMS: Cardinal;
    begin
      LastTime := TThread.GetTickCount;
      while not TThread.CheckTerminated do
      begin
        NowTime := TThread.GetTickCount;
        DeltaMS := NowTime - LastTime;
        if DeltaMS = 0 then
          DeltaMS := 1;
        LastTime := NowTime;
        if FActive then
        begin
          DoUpdate(DeltaMS / 1000);
          SafeInvalidate;
        end;
        Sleep(12);
      end;
    end);
  FThread.FreeOnTerminate := True;
  FThread.Start;
end;

procedure TSkiaVoxelCity.StopThread;
begin
  FActive := False;
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    Sleep(50);
  end;
end;

constructor TSkiaVoxelCity.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLock := TCriticalSection.Create;
  Align := TAlignLayout.Client;
  HitTest := True;
  CanFocus := True;
  TabStop := True;
  FClouds := TList<TPointF>.Create;
  FActive := True;
  FCurrentTool := ttRaise;
  FZoom := 1.25;
  FMouseScreen := PointF(Width / 2, Height / 2);
  FFillPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  FFillPaint.AntiAlias := False;
  FStrokePaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  GenerateTerrain;
  FCameraX := MAP_SIZE / 2;
  FCameraY := MAP_SIZE / 2;
  ClampCamera;
  StartThread;
end;

destructor TSkiaVoxelCity.Destroy;
begin
  StopThread;
  FreeAndNil(FClouds);
  FreeAndNil(FLock);
  inherited;
end;

end.

