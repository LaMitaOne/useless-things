{*******************************************************************************
  SkiaMadMarble (3D Isometric Physics Prototype)
********************************************************************************
  An isometric ball-rolling prototype inspired by Marble Madness.
  Features vector-based gravity on slanted ramps (3D physics), 4-point
  perimeter collision for precise edge detection, multi-level height maps
  with a massive multi-branch path generator, dynamic camera system,
  color-coded elevation layers, explosion physics on falling, and a lava floor.

  Author:  Lara Miriam Tamy Reschke
  License: MIT
*******************************************************************************}

unit SkiaMadMarble;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math,
  System.Generics.Collections, System.UITypes, System.SyncObjs, FMX.Types,
  FMX.Controls, FMX.Forms, FMX.Skia, System.Skia;

type
  TTileKind = (tkEmpty, tkFlat, tkRampN, tkRampS, tkRampE, tkRampW, tkGoal);

  TSkiaMadMarble = class(TSkCustomControl)
  private
    FThread: TThread;
    FActive: Boolean;
    FLock: TCriticalSection;
    FKeys: set of Byte;

    FMap: array of array of TTileKind;
    FTileHeights: array of array of Single;
    FTileColors: array of array of TAlphaColor;
    FMapSize: Integer;

    FMarbleX, FMarbleY, FMarbleZ: Single;
    FVelX, FVelY, FVelZ: Single;

    FCameraX, FCameraY: Single;
    FWinTimer: Single;
    FExplosionTimer: Single;
    FMarbleVisible: Boolean;

    FGlobalTime: Single;
    FGoalX, FGoalY: Integer;

    procedure GenerateRandomLevel;
    procedure DoPhysicsUpdate(DeltaSec: Double);
    procedure SafeInvalidate;
    procedure StartThread;
    procedure StopThread;

    function GetTileHeight(GX, GY: Integer; FracX, FracY: Single): Single;
    function DarkenColor(Color: TAlphaColor; Factor: Single): TAlphaColor;
    procedure SetTile(GX, GY: Integer; Kind: TTileKind; Height: Single; Color: TAlphaColor);
    procedure FillArea(X1, Y1, X2, Y2: Integer; Kind: TTileKind; Height: Single; Color: TAlphaColor);

    procedure DrawIsometricTile(const ACanvas: ISkCanvas; GX, GY: Single; H1, H2, H3, H4: Single; TopColor, LeftColor, RightColor: TAlphaColor; const OffsetX, OffsetY: Single);
    procedure DrawLava(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
    procedure DrawMap(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
    procedure DrawMarble(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
    procedure DrawGoal(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
    procedure DrawExplosion(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
    procedure DrawUI(const ACanvas: ISkCanvas);
  protected
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

const
  TILE_W = 64;
  TILE_H = 32;
  HEIGHT_Z = 24;
  MARBLE_RADIUS = 0.45;

{ TSkiaMadMarble }

constructor TSkiaMadMarble.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLock := TCriticalSection.Create;
  Align := TAlignLayout.Client;
  HitTest := True;
  CanFocus := True;
  TabStop := True;

  FActive := True;
  Randomize;

  // Large map size to fill the whole screen and allow sprawling paths
  FMapSize := 50;
  SetLength(FMap, FMapSize, FMapSize);
  SetLength(FTileHeights, FMapSize, FMapSize);
  SetLength(FTileColors, FMapSize, FMapSize);

  GenerateRandomLevel;
  StartThread;
end;

destructor TSkiaMadMarble.Destroy;
begin
  StopThread;
  FreeAndNil(FLock);
  inherited;
end;

function TSkiaMadMarble.DarkenColor(Color: TAlphaColor; Factor: Single): TAlphaColor;
var
  Rec: TAlphaColorRec;
begin
  Rec.Color := Color;
  Rec.R := Round(Rec.R * Factor);
  Rec.G := Round(Rec.G * Factor);
  Rec.B := Round(Rec.B * Factor);
  Result := Rec.Color;
end;

procedure TSkiaMadMarble.SetTile(GX, GY: Integer; Kind: TTileKind; Height: Single; Color: TAlphaColor);
begin
  if (GX >= 0) and (GX < FMapSize) and (GY >= 0) and (GY < FMapSize) then
  begin
    FMap[GX, GY] := Kind;
    FTileHeights[GX, GY] := Height;
    FTileColors[GX, GY] := Color;
  end;
end;

procedure TSkiaMadMarble.FillArea(X1, Y1, X2, Y2: Integer; Kind: TTileKind; Height: Single; Color: TAlphaColor);
var
  X, Y: Integer;
begin
  for Y := Y1 to Y2 do
    for X := X1 to X2 do
      SetTile(X, Y, Kind, Height, Color);
end;

procedure TSkiaMadMarble.GenerateRandomLevel;
const
  LevelColors: array[1..4] of TAlphaColor = ($FFB53517, $FFD8563C, $FFE4C730, $FF557D44);
var
  Visited: array of array of Boolean;
  ValidEndPoints: TList<TPoint>;

  // Recursive branch generator
  procedure BranchOut(StartX, StartY: Integer; StartHeight: Integer; Depth: Integer);
  var
    Dir, I: Integer;
    DX, DY: Integer;
    TargetHeight: Integer;
    RampKind: TTileKind;
    RampColor, PlatColor: TAlphaColor;
    LX, LY, W, H: Integer;
    IsValid: Boolean;
    Tries: Integer;
    CX, CY: Integer;
  begin
    if Depth <= 0 then Exit;
    Tries := 4 + Random(3); // 4 to 6 branches per point

    CX := StartX;
    CY := StartY;

    for I := 1 to Tries do
    begin
      Dir := Random(4);
      case Dir of
        0: begin DX := 0; DY := -1; end; // North
        1: begin DX := 0; DY := 1; end;  // South
        2: begin DX := 1; DY := 0; end;  // East
        3: begin DX := -1; DY := 0; end; // West
      end;

      // Determine next height
      if StartHeight >= 4 then
        TargetHeight := StartHeight - 1
      else if StartHeight <= 1 then
        TargetHeight := StartHeight + 1
      else
        TargetHeight := StartHeight + (Random(2) * 2 - 1);

      // Ramp position
      CX := StartX + DX;
      CY := StartY + DY;

      if (CX < 1) or (CX >= FMapSize-1) or (CY < 1) or (CY >= FMapSize-1) or Visited[CX, CY] then
        Continue;

      // Landing platform position
      LX := CX + DX;
      LY := CY + DY;

      if (LX < 1) or (LX >= FMapSize-1) or (LY < 1) or (LY >= FMapSize-1) or Visited[LX, LY] then
        Continue;

      // Platform size (2x2 to 4x4)
      W := 1 + Random(3);
      H := 1 + Random(3);
      IsValid := True;
      for var Y := LY to LY + H do
        for var X := LX to LX + W do
          if (X >= FMapSize) or (Y >= FMapSize) or Visited[X, Y] then
            IsValid := False;

      if not IsValid then
        Continue;

      // Define Ramp Kind
      if TargetHeight > StartHeight then
      begin
        case Dir of
          0: RampKind := tkRampN;
          1: RampKind := tkRampS;
          2: RampKind := tkRampE;
          3: RampKind := tkRampW;
        end;
        RampColor := LevelColors[TargetHeight];
      end
      else
      begin
        case Dir of
          0: RampKind := tkRampS;
          1: RampKind := tkRampN;
          2: RampKind := tkRampW;
          3: RampKind := tkRampE;
        end;
        RampColor := LevelColors[StartHeight];
      end;

      Visited[CX, CY] := True;
      SetTile(CX, CY, RampKind, Min(StartHeight, TargetHeight), RampColor);

      PlatColor := LevelColors[TargetHeight];
      FillArea(LX, LY, LX + W, LY + H, tkFlat, TargetHeight, PlatColor);
      for var Y := LY to LY + H do
        for var X := LX to LX + W do
          Visited[X, Y] := True;

      // Add to valid points so we can place the goal here later
      ValidEndPoints.Add(Point(LX + W, LY + H));

      // Recursively branch out from the end of the new platform to fill the map
      BranchOut(LX + W, LY + H, TargetHeight, Depth - 1);
    end;
  end;

begin
  SetLength(Visited, FMapSize, FMapSize);
  ValidEndPoints := TList<TPoint>.Create;
  try
    for var Y := 0 to FMapSize - 1 do
      for var X := 0 to FMapSize - 1 do
      begin
        FMap[X, Y] := tkEmpty;
        Visited[X, Y] := False;
      end;

    // ---------------------------------------------------------
    // RECURSIVE MULTI-PATH MAP GENERATOR
    // Sprawls outward in multiple directions, filling the map
    // with a web of valid interconnected platforms and ramps.
    // ---------------------------------------------------------

    var CX := 2;
    var CY := 2;
    var CurrentHeight := 1;

    // Start Area
    FillArea(CX, CY, CX + 2, CY + 2, tkFlat, CurrentHeight, LevelColors[CurrentHeight]);
    for var Y := CY to CY + 2 do
      for var X := CX to CX + 2 do
        Visited[X, Y] := True;

    FMarbleX := CX + 1.0;
    FMarbleY := CY + 1.0;
    FMarbleZ := CurrentHeight;

    ValidEndPoints.Add(Point(CX + 2, CY + 2));

    // Start recursive branching to create a massive web of paths
    BranchOut(CX + 2, CY + 2, CurrentHeight, 6); // Depth 6 fills a 50x50 map nicely

    // Place Goal on the furthest valid point so it's always naturally reachable!
    if ValidEndPoints.Count > 0 then
    begin
      var BestPt := ValidEndPoints[0];
      var MaxDist := 0;
      for var Pt in ValidEndPoints do
      begin
        var Dist := Sqr(Pt.X - CX) + Sqr(Pt.Y - CY);
        if Dist > MaxDist then
        begin
          MaxDist := Dist;
          BestPt := Pt;
        end;
      end;

      FGoalX := BestPt.X;
      FGoalY := BestPt.Y;

      // Only set the goal tile if it is a valid flat tile
      if (FGoalX >= 0) and (FGoalX < FMapSize) and (FGoalY >= 0) and (FGoalY < FMapSize) then
        SetTile(FGoalX, FGoalY, tkGoal, FTileHeights[FGoalX, FGoalY], $FFFFFF00)
      else
        SetTile(CX + 2, CY + 2, tkGoal, 1, $FFFFFF00); // Fallback
    end
    else
    begin
      // Absolute failsafe (should never happen with the algorithm)
      FGoalX := CX + 2;
      FGoalY := CY + 2;
      SetTile(FGoalX, FGoalY, tkGoal, 1, $FFFFFF00);
    end;

  finally
    ValidEndPoints.Free;
  end;

  // Reset Physics state
  FVelX := 0; FVelY := 0; FVelZ := 0;
  FWinTimer := 0;
  FExplosionTimer := 0;
  FMarbleVisible := True;

  FCameraX := FMarbleX;
  FCameraY := FMarbleY;
end;

function TSkiaMadMarble.GetTileHeight(GX, GY: Integer; FracX, FracY: Single): Single;
var
  BaseHeight: Single;
begin
  Result := -1;
  if (GX < 0) or (GX >= FMapSize) or (GY < 0) or (GY >= FMapSize) then Exit;
  if FMap[GX, GY] = tkEmpty then Exit;

  BaseHeight := FTileHeights[GX, GY];

  case FMap[GX, GY] of
    tkFlat, tkGoal:
      Result := BaseHeight;
    tkRampN: Result := BaseHeight + (1.0 - FracY);
    tkRampS: Result := BaseHeight + FracY;
    tkRampE: Result := BaseHeight + FracX;
    tkRampW: Result := BaseHeight + (1.0 - FracX);
  end;
end;

procedure TSkiaMadMarble.DoPhysicsUpdate(DeltaSec: Double);
var
  Left, Right, Up, Down: Boolean;
  Accel, FloorZ: Single;
  GX, GY: Integer;
  FracX, FracY: Single;
  H_N, H_S, H_E, H_W, H_C: Single;
begin
  if not FActive then Exit;

  FGlobalTime := FGlobalTime + DeltaSec;

  // Win / Goal Timer
  if FWinTimer > 0 then
  begin
    FWinTimer := FWinTimer - DeltaSec;
    if FWinTimer <= 0 then GenerateRandomLevel;
    Exit;
  end;

  // Explosion / Death Timer
  if FExplosionTimer > 0 then
  begin
    FExplosionTimer := FExplosionTimer - DeltaSec;
    if FExplosionTimer <= 0 then GenerateRandomLevel;
    Exit;
  end;

  FLock.Acquire;
  try
    Left := (Byte(vkLeft) in FKeys) or (Byte(Ord('A')) in FKeys);
    Right := (Byte(vkRight) in FKeys) or (Byte(Ord('D')) in FKeys);
    Up := (Byte(vkUp) in FKeys) or (Byte(Ord('W')) in FKeys);
    Down := (Byte(vkDown) in FKeys) or (Byte(Ord('S')) in FKeys);
  finally
    FLock.Release;
  end;

  // Basic Acceleration and Friction
  Accel := 18;
  if Left then FVelX := Max(FVelX - Accel * DeltaSec, -6);
  if Right then FVelX := Min(FVelX + Accel * DeltaSec, 6);
  if Up then FVelY := Max(FVelY - Accel * DeltaSec, -6);
  if Down then FVelY := Min(FVelY + Accel * DeltaSec, 6);

  FVelX := FVelX * 0.96;
  FVelY := FVelY * 0.96;
  FVelZ := FVelZ - 35 * DeltaSec; // Gravity

  FMarbleX := FMarbleX + FVelX * DeltaSec;
  FMarbleY := FMarbleY + FVelY * DeltaSec;
  FMarbleZ := FMarbleZ + FVelZ * DeltaSec;

  // 4-POINT PERIMETER COLLISION
  H_N := GetTileHeight(Trunc(FMarbleX), Trunc(FMarbleY - MARBLE_RADIUS), Frac(FMarbleX), Frac(FMarbleY - MARBLE_RADIUS));
  H_S := GetTileHeight(Trunc(FMarbleX), Trunc(FMarbleY + MARBLE_RADIUS), Frac(FMarbleX), Frac(FMarbleY + MARBLE_RADIUS));
  H_W := GetTileHeight(Trunc(FMarbleX - MARBLE_RADIUS), Trunc(FMarbleY), Frac(FMarbleX - MARBLE_RADIUS), Frac(FMarbleY));
  H_E := GetTileHeight(Trunc(FMarbleX + MARBLE_RADIUS), Trunc(FMarbleY), Frac(FMarbleX + MARBLE_RADIUS), Frac(FMarbleY));
  H_C := GetTileHeight(Trunc(FMarbleX), Trunc(FMarbleY), Frac(FMarbleX), Frac(FMarbleY));

  if (H_N < 0) and (H_S < 0) and (H_E < 0) and (H_W < 0) then
    FloorZ := -1
  else
  begin
    FloorZ := H_C;
    if H_N > FloorZ then FloorZ := H_N;
    if H_S > FloorZ then FloorZ := H_S;
    if H_E > FloorZ then FloorZ := H_E;
    if H_W > FloorZ then FloorZ := H_W;
  end;

  if FloorZ < 0 then
  begin
    if FMarbleZ < -1.5 then
    begin
      FExplosionTimer := 0.8;
      FMarbleVisible := False;
      FVelX := 0; FVelY := 0; FVelZ := 0;
    end;
  end
  else
  begin
    if FMarbleZ <= FloorZ + 0.1 then
    begin
      FMarbleZ := FloorZ;

      GX := Trunc(FMarbleX);
      GY := Trunc(FMarbleY);
      FracX := Frac(FMarbleX);
      FracY := Frac(FMarbleY);

      // RAMP PHYSICS
      case FMap[GX, GY] of
        tkRampN: FVelY := FVelY + 8 * DeltaSec;
        tkRampS: FVelY := FVelY - 8 * DeltaSec;
        tkRampE: FVelX := FVelX - 8 * DeltaSec;
        tkRampW: FVelX := FVelX + 8 * DeltaSec;
      end;

      FVelZ := 0;

      if FMap[GX, GY] = tkGoal then
        FWinTimer := 2.0;
    end;
  end;

  // Smooth Camera Follow
  FCameraX := FCameraX + (FMarbleX - FCameraX) * 6 * DeltaSec;
  FCameraY := FCameraY + (FMarbleY - FCameraY) * 6 * DeltaSec;
end;

procedure TSkiaMadMarble.Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  OffsetX, OffsetY: Single;
begin
  ACanvas.Clear($FF111122);

  OffsetX := (Width / 2) - ((FCameraX - FCameraY) * (TILE_W / 2));
  OffsetY := (Height / 2) - ((FCameraX + FCameraY) * (TILE_H / 2)) - 100;

  DrawLava(ACanvas, OffsetX, OffsetY);
  DrawMap(ACanvas, OffsetX, OffsetY);
  DrawGoal(ACanvas, OffsetX, OffsetY);

  if FMarbleVisible then
    DrawMarble(ACanvas, OffsetX, OffsetY);

  if FExplosionTimer > 0 then
    DrawExplosion(ACanvas, OffsetX, OffsetY);

  DrawUI(ACanvas);
end;

procedure TSkiaMadMarble.DrawIsometricTile(const ACanvas: ISkCanvas; GX, GY: Single; H1, H2, H3, H4: Single; TopColor, LeftColor, RightColor: TAlphaColor; const OffsetX, OffsetY: Single);
var
  P1, P2, P3, P4: TPointF;
  PB: ISkPathBuilder;
  Paint: ISkPaint;
begin
  P1 := PointF((GX - GY) * (TILE_W / 2) + OffsetX, (GX + GY) * (TILE_H / 2) + OffsetY - H1 * HEIGHT_Z);
  P2 := PointF(((GX+1) - GY) * (TILE_W / 2) + OffsetX, ((GX+1) + GY) * (TILE_H / 2) + OffsetY - H2 * HEIGHT_Z);
  P3 := PointF(((GX+1) - (GY+1)) * (TILE_W / 2) + OffsetX, ((GX+1) + (GY+1)) * (TILE_H / 2) + OffsetY - H3 * HEIGHT_Z);
  P4 := PointF((GX - (GY+1)) * (TILE_W / 2) + OffsetX, (GX + (GY+1)) * (TILE_H / 2) + OffsetY - H4 * HEIGHT_Z);

  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  // Right Face
  Paint.Color := RightColor;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P2.X, P2.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P3.X, P3.Y + H3 * HEIGHT_Z);
  PB.LineTo(P2.X, P2.Y + H2 * HEIGHT_Z);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  // Left Face
  Paint.Color := LeftColor;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P4.X, P4.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P3.X, P3.Y + H3 * HEIGHT_Z);
  PB.LineTo(P4.X, P4.Y + H4 * HEIGHT_Z);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  // Top Face
  Paint.Color := TopColor;
  PB := TSkPathBuilder.Create;
  PB.MoveTo(P1.X, P1.Y);
  PB.LineTo(P2.X, P2.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P4.X, P4.Y);
  PB.Close;
  ACanvas.DrawPath(PB.Snapshot, Paint);
end;

procedure TSkiaMadMarble.DrawLava(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
var
  PB: ISkPathBuilder;
  Paint: ISkPaint;
  Z: Single;
  P1, P2, P3, P4: TPointF;
begin
  Z := -2;
  P1 := PointF((0 - 0) * (TILE_W / 2) + OffsetX, (0 + 0) * (TILE_H / 2) + OffsetY - Z * HEIGHT_Z);
  P2 := PointF((FMapSize - 0) * (TILE_W / 2) + OffsetX, (FMapSize + 0) * (TILE_H / 2) + OffsetY - Z * HEIGHT_Z);
  P3 := PointF((FMapSize - FMapSize) * (TILE_W / 2) + OffsetX, (FMapSize + FMapSize) * (TILE_H / 2) + OffsetY - Z * HEIGHT_Z);
  P4 := PointF((0 - FMapSize) * (TILE_W / 2) + OffsetX, (0 + FMapSize) * (TILE_H / 2) + OffsetY - Z * HEIGHT_Z);

  PB := TSkPathBuilder.Create;
  PB.MoveTo(P1.X, P1.Y);
  PB.LineTo(P2.X, P2.Y);
  PB.LineTo(P3.X, P3.Y);
  PB.LineTo(P4.X, P4.Y);
  PB.Close;

  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  // Dark base layer
  Paint.Color := $FFCC3300;
  ACanvas.DrawPath(PB.Snapshot, Paint);

  // Glowing overlay layer
  Paint.Color := $FFFF6600;
  Paint.Alpha := 180;
  Paint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Solid, 8.0);
  ACanvas.DrawPath(PB.Snapshot, Paint);
end;

procedure TSkiaMadMarble.DrawMap(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
var
  X, Y: Integer;
  BaseH: Single;
  C: TAlphaColor;
begin
  for Y := 0 to FMapSize - 1 do
  begin
    for X := 0 to FMapSize - 1 do
    begin
      // Goal is drawn separately in DrawGoal for animation
      if FMap[X, Y] = tkEmpty then Continue;

      BaseH := FTileHeights[X, Y];
      C := FTileColors[X, Y];

      case FMap[X, Y] of
        tkFlat:
          DrawIsometricTile(ACanvas, X, Y, BaseH, BaseH, BaseH, BaseH, C, DarkenColor(C, 0.7), DarkenColor(C, 0.5), OffsetX, OffsetY);
        tkRampN:
          DrawIsometricTile(ACanvas, X, Y, BaseH+1, BaseH+1, BaseH, BaseH, C, DarkenColor(C, 0.7), DarkenColor(C, 0.5), OffsetX, OffsetY);
        tkRampS:
          DrawIsometricTile(ACanvas, X, Y, BaseH, BaseH, BaseH+1, BaseH+1, C, DarkenColor(C, 0.7), DarkenColor(C, 0.5), OffsetX, OffsetY);
        tkRampE:
          DrawIsometricTile(ACanvas, X, Y, BaseH, BaseH+1, BaseH+1, BaseH, C, DarkenColor(C, 0.7), DarkenColor(C, 0.5), OffsetX, OffsetY);
        tkRampW:
          DrawIsometricTile(ACanvas, X, Y, BaseH+1, BaseH, BaseH, BaseH+1, C, DarkenColor(C, 0.7), DarkenColor(C, 0.5), OffsetX, OffsetY);
      end;
    end;
  end;
end;

procedure TSkiaMadMarble.DrawGoal(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
var
  CX, CY: Single;
  BaseH: Single;
  Paint, Glow: ISkPaint;
  Pulse: Single;
  Rec: TAlphaColorRec;
begin
  if (FGoalX < 0) or (FGoalX >= FMapSize) or (FGoalY < 0) or (FGoalY >= FMapSize) then Exit;
  if FMap[FGoalX, FGoalY] <> tkGoal then Exit;

  BaseH := FTileHeights[FGoalX, FGoalY];
  CX := (FGoalX - FGoalY) * (TILE_W / 2) + OffsetX + (TILE_W / 2);
  CY := (FGoalX + FGoalY) * (TILE_H / 2) + OffsetY - (BaseH * HEIGHT_Z);

  // Draw base tile (dark grey so the portal stands out)
  DrawIsometricTile(ACanvas, FGoalX, FGoalY, BaseH, BaseH, BaseH, BaseH, $FF222222, $FF111111, $FF000000, OffsetX, OffsetY);

  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  // Pulsating portal effect
  Pulse := (Sin(FGlobalTime * 4) + 1) / 2; // 0.0 to 1.0

  // Outer Glow (Magenta)
  Glow := TSkPaint.Create(Paint);
  Glow.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Solid, 15.0 + Pulse * 10.0);
  Glow.Color := $FFFF00FF; // Magenta
  Glow.Alpha := Trunc(150 + Pulse * 100);
  ACanvas.DrawCircle(PointF(CX, CY), 15 + Pulse * 5, Glow);

  // Inner Swirl (Bright Yellow)
  Rec.R := 255;
  Rec.G := 255;
  Rec.B := 0;
  Rec.A := Trunc(200 + Pulse * 55);
  Paint.Color := Rec.Color;
  ACanvas.DrawCircle(PointF(CX, CY), 12, Paint);

  // Center Highlight (White flash)
  Rec.R := 255;
  Rec.G := 255;
  Rec.B := 255;
  Rec.A := Trunc(255 * Pulse);
  Paint.Color := Rec.Color;
  ACanvas.DrawCircle(PointF(CX, CY), 6, Paint);
end;

procedure TSkiaMadMarble.DrawMarble(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
var
  CX, CY, ShadowY, FloorZ: Single;
  GX, GY: Integer;
  Paint, Glow: ISkPaint;
begin
  CX := (FMarbleX - FMarbleY) * (TILE_W / 2) + OffsetX;
  CY := (FMarbleX + FMarbleY) * (TILE_H / 2) + OffsetY - (FMarbleZ * HEIGHT_Z);

  GX := Trunc(FMarbleX);
  GY := Trunc(FMarbleY);
  FloorZ := GetTileHeight(GX, GY, Frac(FMarbleX), Frac(FMarbleY));

  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  // Shadow
  if FloorZ >= 0 then
  begin
    ShadowY := (FMarbleX + FMarbleY) * (TILE_H / 2) + OffsetY - (FloorZ * HEIGHT_Z);
    Paint.Color := $FF000000;
    Paint.Alpha := 100;
    ACanvas.DrawOval(TRectF.Create(CX-10, ShadowY - 4, CX+10, ShadowY + 4), Paint);
    Paint.Alpha := 255;
  end;

  // Glowing outline
  Glow := TSkPaint.Create(Paint);
  Glow.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Solid, 4.0);
  Glow.Color := $FF00FFFF;
  ACanvas.DrawCircle(PointF(CX, CY), 10, Glow);

  // Body
  Paint.Color := $FFCCCCCC;
  ACanvas.DrawCircle(PointF(CX, CY), 10, Paint);

  // Highlight
  Paint.Color := $FFFFFFFF;
  ACanvas.DrawCircle(PointF(CX - 3, CY - 3), 3, Paint);
end;

procedure TSkiaMadMarble.DrawExplosion(const ACanvas: ISkCanvas; const OffsetX, OffsetY: Single);
var
  I: Integer;
  CX, CY, Progress, Radius, Dist: Single;
  Paint: ISkPaint;
begin
  CX := (FMarbleX - FMarbleY) * (TILE_W / 2) + OffsetX;
  CY := (FMarbleX + FMarbleY) * (TILE_H / 2) + OffsetY - (FMarbleZ * HEIGHT_Z);

  Progress := 1.0 - (FExplosionTimer / 0.8);

  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;

  for I := 0 to 7 do
  begin
    Dist := Progress * 40;
    Radius := 12 * (1.0 - Progress) + 4;
    Paint.Color := TAlphaColors.Yellow;
    Paint.Alpha := Trunc(255 * (1.0 - Progress));
    ACanvas.DrawCircle(
      PointF(CX + Cos(I * Pi/4 + Progress * 2) * Dist,
             CY + Sin(I * Pi/4 + Progress * 2) * Dist),
      Radius, Paint);
  end;

  Paint.Color := $FFFFFFFF;
  Paint.Alpha := Trunc(255 * (1.0 - Progress));
  ACanvas.DrawCircle(PointF(CX, CY), 20 * (1.0 - Progress) + 5, Paint);
end;

procedure TSkiaMadMarble.DrawUI(const ACanvas: ISkCanvas);
var
  Font: TSkFont;
  Paint: ISkPaint;
begin
  Font := TSkFont.Create;
  try
    Paint := TSkPaint.Create(TSkPaintStyle.Fill);
    Paint.AntiAlias := True;

    if FWinTimer > 0 then
    begin
      Paint.Color := TAlphaColors.Lime;
      ACanvas.DrawSimpleText('GOAL! Generating new level...', 10, 30, Font, Paint);
    end
    else if FExplosionTimer > 0 then
    begin
      Paint.Color := TAlphaColors.Red;
      ACanvas.DrawSimpleText('BOOM! Don''t fall into the lava!', 10, 30, Font, Paint);
    end
    else
    begin
      Paint.Color := TAlphaColors.White;
      ACanvas.DrawSimpleText('WASD/Arrows: Roll Marble | Reach the Magenta Portal!', 10, 30, Font, Paint);
    end;
  finally
    Font.Free;
  end;
end;

procedure TSkiaMadMarble.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  FLock.Acquire;
  try
    case Key of
      vkLeft, Byte(Ord('A')): Include(FKeys, vkLeft);
      vkRight, Byte(Ord('D')): Include(FKeys, vkRight);
      vkUp, Byte(Ord('W')): Include(FKeys, vkUp);
      vkDown, Byte(Ord('S')): Include(FKeys, vkDown);
    end;
  finally
    FLock.Release;
  end;
  Key := 0;
  inherited;
end;

procedure TSkiaMadMarble.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  FLock.Acquire;
  try
    case Key of
      vkLeft, Byte(Ord('A')): Exclude(FKeys, vkLeft);
      vkRight, Byte(Ord('D')): Exclude(FKeys, vkRight);
      vkUp, Byte(Ord('W')): Exclude(FKeys, vkUp);
      vkDown, Byte(Ord('S')): Exclude(FKeys, vkDown);
    end;
  finally
    FLock.Release;
  end;
  Key := 0;
  inherited;
end;

procedure TSkiaMadMarble.SafeInvalidate;
begin
  if csDestroying in ComponentState then Exit;
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

procedure TSkiaMadMarble.StartThread;
begin
  if Assigned(FThread) then Exit;
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
        if DeltaMS = 0 then DeltaMS := 1;
        LastTime := NowTime;
        if FActive then
        begin
          DoPhysicsUpdate(DeltaMS / 1000);
          SafeInvalidate;
        end;
        Sleep(16); // Lock to ~60 FPS
      end;
    end);
  FThread.FreeOnTerminate := True;
  FThread.Start;
end;

procedure TSkiaMadMarble.StopThread;
begin
  FActive := False;
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    Sleep(50);
  end;
end;

end.
