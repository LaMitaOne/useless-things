{*******************************************************************************
  SkiaQwirQ (Neon Puzzle Prototype)
********************************************************************************
  Top-down puzzle engine with the original 12 Kwird levels.
  Fixed rotator center rotation and outer walls.
  Author:  Lara Miriam Tamy Reschke
  License: MIT
*******************************************************************************}
unit SkiaQwirQ;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math,
  System.Generics.Collections, System.UITypes, System.SyncObjs, FMX.Types,
  FMX.Controls, FMX.Forms, FMX.Skia, System.Skia;

const
  MAX_GRID_W = 40;
  MAX_GRID_H = 30;
  TILE_SIZE = 36;

type
  TTileType = (ttEmpty, ttWall, ttDoor, ttHole);
  TEntityType = (etNone, etPlayer, etBlock, etRotator);

  TEntity = class
    X, Y: Integer;
    Typ: TEntityType;
    W, H: Integer;
    RotDir: Integer;
    Shape: array of array of Boolean;
  end;

  TSkiaQwirQ = class(TSkCustomControl)
  private
    FThread: TThread;
    FActive: Boolean;
    FLock: TCriticalSection;
    FKeys: set of Byte;
    FGrid: array[0..MAX_GRID_W-1, 0..MAX_GRID_H-1] of TTileType;
    FEntities: TObjectList<TEntity>;
    FPlayer: TEntity;
    FPlayerDir: TPoint;
    FBlinkTimer: Single;
    FBlinking: Boolean;
    FMoveCooldown: Single;
    FCurrentLevel: Integer;
    FLevelW, FLevelH: Integer;

    procedure LoadLevel(LevelNum: Integer);
    procedure NextLevel;
    procedure CalculateLevelBounds(LevelNum: Integer);
    function GetTileChar(LevelNum, X, Y: Integer): Char;
    function GetEntityAt(X, Y: Integer): Integer;
    function CanMoveBlock(Idx, DirX, DirY: Integer): Boolean;
    function IsRotatorTargetClear(X, Y, RotatorIdx: Integer): Boolean;
    procedure DoPhysicsUpdate(DeltaSec: Double);
    procedure SafeInvalidate;
    procedure StartThread;
    procedure StopThread;
    procedure DrawEntities(const ACanvas: ISkCanvas);
    procedure DrawUI(const ACanvas: ISkCanvas);
  protected
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  end;

implementation

const
  CLevelData: array[1..12] of string = (
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '|      ##  MM        DD  ##      |' + '|      ##  MM        DD  ##      |' + '|  22      MMMM####DDDD      11  |' + '|  22      MMMM####DDDD      11  |' + '|      ##  MM        DD  ##      |' + '|      ##  MM        DD  ##      |' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '|      ##    aaaa    ##      |' + '      ##    aaaa    ##      |' + '  22        bbbb        11  |' + '  22        bbbb        11  |' + '      ##    cccc    ##      |' + '      ##    cccc    ##      |' + '------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '--------------------------' + '|########        ##      |' + '|########        ##      |' + '|########            11  |' + '|########            11  |' + '|########MM  aaaa##      |' + '|########MM  aaaa##      |' + '|      ##MMMMaaaa########|' + '|      ##MMMMaaaa########|' + '|  22            ########|' + '|  22            ########|' + '|      ##        ########|' + '|      ##        ########|' + '--------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '---------------------------------' + '|########OOOOOO          ########|' + '|########OOOOOO          ########|' + '|      ##OOOOOOOO  aaaa  ##      |' + '|      ##OOOOOOOO  aaaa  ##      |' + '|  22      OOOOOO  aaaa      11  |' + '|  22      OOOOOO  aaaa      11  |' + '|      ##OOOOOOOO  aaaa  ##      |' + '|      ##OOOOOOOO  aaaa  ##      |' + '|########OOOOOO          ########|' + '|########OOOOOO          ########|' + '---------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '-----------------------------' + '|########            ########|' + '|########            ########|' + '|      ##    MM      ##      |' + '|      ##    MM      ##      |' + '|  22  OO    MMaa        11  |' + '|  22  OO    MMaa        11  |' + '|      ##    MM      ##      |' + '|      ##    MM      ##      |' + '|########            ########|' + '|########            ########|' + '-----------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '---------------------------' + '|      ##  ##  ##  ##      |' + '|      ##  ##  ##  ##      |' + '|      ##          ##  11  |' + '|      ##          ##  11  |' + '|      OO    ##    aa      |' + '|      OO    ##    aa      |' + '|  22  ##          ##  33  |' + '|  22  ##          ##  33  |' + '|      ##  ##  ##  ##      |' + '|      ##  ##  ##  ##      |' + '---------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '---------------------------' + '|########  QQ      ########|' + '|########  QQ      ########|' + '|          QQYYYY          |' + '|          QQYYYY          |' + '|        FFQQ              |' + '|        FFQQ              |' + '|  22  FFFFFFSSSS      11  |' + '|  22  FFFFFFSSSS      11  |' + '|        FFMM              |' + '|        FFMM              |' + '|          MMDDDD          |' + '|          MMDDDD          |' + '|########  MM      ########|' + '|########  MM      ########|' + '---------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '-------------------------------' + '|######        dd        ######|' + '|######        dd        ######|' + '|######        dd        ######|' + '|######        dd        ######|' + '|######aa  bbccddffgg  hh######|' + '|######aa  bbccddffgg  hh######|' + '|      aa  bbccddffgg  hh      |' + '|      aa  bbccddffgg  hh      |' + '|  22  aa  bb  ee  gg  hh  11  |' + '|  22  aa  bb  ee  gg  hh  11  |' + '|      aa  bb  ee  gg  hh      |' + '|      aa  bb  ee  gg  hh      |' + '|######    bb      gg    ######|' + '|######    bb      gg    ######|' + '-------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '-----------------------------------' + '|            ##  aa  ##            |' + '|            ##  aa  ##            |' + '|            ##  DD  ##            |' + '|            ##  DD  ##            |' + '|            MMDDDD  cc            |' + '|            MMDDDD  cc            |' + '|      22    MM      dd    11      |' + '|      22    MM      dd    11      |' + '|            MMQQQQ  ee            |' + '|            MMQQQQ  ee            |' + '|            ##  QQ  ##            |' + '|            ##  QQ  ##            |' + '|            ##  bb  ##            |' + '|            ##  bb  ##            |' + '-----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '-----------------------------' + '|          VV  XX            |' + '|          VV  XX            |' + '|        VVVV  XXXX      33  |' + '|        VVVV  XXXX      33  |' + '|          AAAA  SS          |' + '|          AAAA  SS          |' + '|            AA  SSSS        |' + '|            AA  SSSS        |' + '|  22    QQQQ  MMMM      11  |' + '|  22    QQQQ  MMMM      11  |' + '|          QQ  MM            |' + '|          QQ  MM            |' + '-----------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '-------------------' + '|######      ######|' + '|######      ######|' + '|####          ####|' + '|####          ####|' + '|####  QQQQ    ####|' + '|####  QQQQ    ####|' + '|##    QQ11AA    ##|' + '|##    QQ11AA    ##|' + '|##      AAAA    ##|' + '|##      AAAA    ##|' + '|  ZZZZ      WWWW  |' + '|  ZZZZ      WWWW  |' + '|    ZZ  ##  WW    |' + '|    ZZ  ##  WW    |' + '|DDDDDD      XXXXXX|' + '|DDDDDD      XXXXXX|' + '|  DD  aaaaaa  XX  |' + '|  DD  aaaaaa  XX  |',
    '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '-------------------------------' + '|  11    ##          ee        |' + '|  11    ##          ee        |' + '|        ##    MM  ##########  |' + '|        ##    MM  ##########  |' + '|######  ##  ddMMMM    ######  |' + '|######  ##  ddMMMM    ######  |' + '|  aaaaaa##########OO    ####  |' + '|  aaaaaa##########OO    ####  |' + '-------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------' + '----------------------------------'
  );

  CWallChars = ['#', '-', '|', '='];

{ TSkiaQwirQ }

constructor TSkiaQwirQ.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  HitTest := True;
  CanFocus := True;
  TabStop := True;
  FLock := TCriticalSection.Create;
  FActive := True;
  FEntities := TObjectList<TEntity>.Create(True);
  FCurrentLevel := 1;
  LoadLevel(FCurrentLevel);
  StartThread;
end;

destructor TSkiaQwirQ.Destroy;
begin
  StopThread;
  FreeAndNil(FEntities);
  FreeAndNil(FLock);
  inherited;
end;

procedure TSkiaQwirQ.NextLevel;
begin
  Inc(FCurrentLevel);
  if FCurrentLevel > 12 then FCurrentLevel := 1;
  LoadLevel(FCurrentLevel);
end;

function TSkiaQwirQ.GetTileChar(LevelNum, X, Y: Integer): Char;
var
  RowStr: string;
  StringX, StringY: Integer;
begin
  Result := ' ';
  if (Y >= 0) and (Y <= 12) and (X >= 0) and (X <= 16) then
  begin
    StringY := Y * 2;
    StringX := X * 2;
    RowStr := Copy(CLevelData[LevelNum], (StringY * 34) + 1, 34);
    if (StringX >= 0) and (StringX < Length(RowStr)) then
      Result := RowStr[StringX + 1];
  end;
end;

procedure TSkiaQwirQ.CalculateLevelBounds(LevelNum: Integer);
var
  X, Y: Integer;
  C: Char;
  MaxX, MaxY: Integer;
begin
  MaxX := 0;
  MaxY := 0;
  for Y := 0 to 12 do
  begin
    for X := 0 to 16 do
    begin
      C := GetTileChar(LevelNum, X, Y);
      if C <> ' ' then
      begin
        if X > MaxX then MaxX := X;
        if Y > MaxY then MaxY := Y;
      end;
    end;
  end;
  FLevelW := MaxX + 1;
  FLevelH := MaxY + 1;
  Width := FLevelW * TILE_SIZE;
  Height := FLevelH * TILE_SIZE;
end;

procedure TSkiaQwirQ.LoadLevel(LevelNum: Integer);
var
  X, Y, I, J: Integer;
  C: Char;
  Ent: TEntity;
  Visited: array[0..MAX_GRID_W-1, 0..MAX_GRID_H-1] of Boolean;

  procedure FloodFind(StartX, StartY: Integer; TargetChar: Char; var MinX, MinY, MaxX, MaxY: Integer);
  var
    Stack: TStack<TPoint>;
    Cur: TPoint;
    GX, GY: Integer;
  begin
    Stack := TStack<TPoint>.Create;
    try
      Stack.Push(Point(StartX, StartY));
      Visited[StartX, StartY] := True;
      while Stack.Count > 0 do
      begin
        Cur := Stack.Pop;
        GX := Cur.X;
        GY := Cur.Y;
        if GX < MinX then MinX := GX;
        if GX > MaxX then MaxX := GX;
        if GY < MinY then MinY := GY;
        if GY > MaxY then MaxY := GY;
        if (GX > 0) and (not Visited[GX-1, GY]) and (GetTileChar(LevelNum, GX-1, GY) = TargetChar) then
        begin Visited[GX-1, GY] := True; Stack.Push(Point(GX-1, GY)); end;
        if (GX < 16) and (not Visited[GX+1, GY]) and (GetTileChar(LevelNum, GX+1, GY) = TargetChar) then
        begin Visited[GX+1, GY] := True; Stack.Push(Point(GX+1, GY)); end;
        if (GY > 0) and (not Visited[GX, GY-1]) and (GetTileChar(LevelNum, GX, GY-1) = TargetChar) then
        begin Visited[GX, GY-1] := True; Stack.Push(Point(GX, GY-1)); end;
        if (GY < 12) and (not Visited[GX, GY+1]) and (GetTileChar(LevelNum, GX, GY+1) = TargetChar) then
        begin Visited[GX, GY+1] := True; Stack.Push(Point(GX, GY+1)); end;
      end;
    finally
      Stack.Free;
    end;
  end;

begin
  FLock.Acquire;
  try
    FEntities.Clear;
    CalculateLevelBounds(LevelNum);
    for Y := 0 to MAX_GRID_H - 1 do
      for X := 0 to MAX_GRID_W - 1 do
      begin
        FGrid[X, Y] := ttWall;
        Visited[X, Y] := False;
      end;

    for Y := 0 to 12 do
    begin
      for X := 0 to 16 do
      begin
        if Visited[X, Y] then Continue;
        C := GetTileChar(LevelNum, X, Y);
        if C in CWallChars then
        begin
          FGrid[X, Y] := ttWall;
          Visited[X, Y] := True;
        end
        else if C = ' ' then
        begin
          FGrid[X, Y] := ttEmpty;
          Visited[X, Y] := True;
        end
        else if C = 'O' then
        begin
          FGrid[X, Y] := ttHole;
          Visited[X, Y] := True;
        end
        else if C = '2' then
        begin
          FGrid[X, Y] := ttDoor;
          Visited[X, Y] := True;
        end
        else if C = '1' then
        begin
          FPlayer := TEntity.Create;
          FPlayer.X := X; FPlayer.Y := Y;
          FPlayer.Typ := etPlayer;
          FPlayer.W := 1; FPlayer.H := 1;
          FPlayer.RotDir := 0;
          SetLength(FPlayer.Shape, 1, 1);
          FPlayer.Shape[0, 0] := True;
          FGrid[X, Y] := ttEmpty;
          Visited[X, Y] := True;
          FEntities.Add(FPlayer);
        end
        else if (C in ['a'..'z']) or (C in ['A'..'Z']) then
        begin
          var MinX, MinY, MaxX, MaxY: Integer;
          MinX := X; MinY := Y; MaxX := X; MaxY := Y;
          FloodFind(X, Y, C, MinX, MinY, MaxX, MaxY);

          Ent := TEntity.Create;
          if C in ['A'..'Z'] then
          begin
            Ent.Typ := etRotator;
            Ent.W := 3;
            Ent.H := 3;
            SetLength(Ent.Shape, 3, 3);
            for I := 0 to 2 do
              for J := 0 to 2 do
                Ent.Shape[I, J] := False;

            var BestX, BestY, BestCount: Integer;
            BestX := MinX; BestY := MinY; BestCount := -1;
            for I := MinX to MaxX do
            begin
              for J := MinY to MaxY do
              begin
                if GetTileChar(LevelNum, I, J) = C then
                begin
                  var Cnt: Integer := 0;
                  if GetTileChar(LevelNum, I-1, J) = C then Inc(Cnt);
                  if GetTileChar(LevelNum, I+1, J) = C then Inc(Cnt);
                  if GetTileChar(LevelNum, I, J-1) = C then Inc(Cnt);
                  if GetTileChar(LevelNum, I, J+1) = C then Inc(Cnt);
                  if Cnt > BestCount then
                  begin
                    BestCount := Cnt;
                    BestX := I;
                    BestY := J;
                  end;
                end;
              end;
            end;

            Ent.X := BestX - 1;
            Ent.Y := BestY - 1;
            Ent.Shape[1, 1] := True;

            if (GetTileChar(LevelNum, BestX, BestY-1) = C) and
               (GetTileChar(LevelNum, BestX+1, BestY) = C) and
               (GetTileChar(LevelNum, BestX, BestY+1) = C) then
            begin
              Ent.RotDir := 0;
              Ent.Shape[1, 0] := True;
              Ent.Shape[2, 1] := True;
              Ent.Shape[1, 2] := True;
            end
            else if (GetTileChar(LevelNum, BestX+1, BestY) = C) and
                    (GetTileChar(LevelNum, BestX, BestY+1) = C) and
                    (GetTileChar(LevelNum, BestX-1, BestY) = C) then
            begin
              Ent.RotDir := 1;
              Ent.Shape[2, 1] := True;
              Ent.Shape[1, 2] := True;
              Ent.Shape[0, 1] := True;
            end
            else if (GetTileChar(LevelNum, BestX, BestY+1) = C) and
                    (GetTileChar(LevelNum, BestX-1, BestY) = C) and
                    (GetTileChar(LevelNum, BestX, BestY-1) = C) then
            begin
              Ent.RotDir := 2;
              Ent.Shape[1, 2] := True;
              Ent.Shape[0, 1] := True;
              Ent.Shape[1, 0] := True;
            end
            else if (GetTileChar(LevelNum, BestX-1, BestY) = C) and
                    (GetTileChar(LevelNum, BestX, BestY-1) = C) and
                    (GetTileChar(LevelNum, BestX+1, BestY) = C) then
            begin
              Ent.RotDir := 3;
              Ent.Shape[0, 1] := True;
              Ent.Shape[1, 0] := True;
              Ent.Shape[2, 1] := True;
            end
            else
            begin
              Ent.RotDir := 0;
              Ent.Shape[1, 0] := True;
              Ent.Shape[2, 1] := True;
              Ent.Shape[1, 2] := True;
            end;
          end
          else
          begin
            Ent.Typ := etBlock;
            Ent.X := MinX;
            Ent.Y := MinY;
            Ent.W := MaxX - MinX + 1;
            Ent.H := MaxY - MinY + 1;
            Ent.RotDir := 0;
            SetLength(Ent.Shape, Ent.W, Ent.H);
            for I := 0 to Ent.W - 1 do
              for J := 0 to Ent.H - 1 do
                Ent.Shape[I, J] := (GetTileChar(LevelNum, Ent.X + I, Ent.Y + J) = C);
          end;
          for I := MinX to MaxX do
            for J := MinY to MaxY do
              if GetTileChar(LevelNum, I, J) = C then
                FGrid[I, J] := ttEmpty;
          FEntities.Add(Ent);
        end;
      end;
    end;
    FPlayerDir := Point(0, 1);
    FBlinkTimer := 3.0;
  finally
    FLock.Release;
  end;
end;

function TSkiaQwirQ.GetEntityAt(X, Y: Integer): Integer;
var
  I, LocalX, LocalY: Integer;
  Ent: TEntity;
begin
  Result := -1;
  for I := 0 to FEntities.Count - 1 do
  begin
    Ent := FEntities.List[I];
    if (Ent.Typ = etPlayer) or (Ent.Typ = etBlock) or (Ent.Typ = etRotator) then
    begin
      if (X >= Ent.X) and (X < Ent.X + Ent.W) and (Y >= Ent.Y) and (Y < Ent.Y + Ent.H) then
      begin
        LocalX := X - Ent.X;
        LocalY := Y - Ent.Y;
        if (LocalX >= 0) and (LocalX < Ent.W) and (LocalY >= 0) and (LocalY < Ent.H) then
        begin
          if Length(Ent.Shape) > 0 then
          begin
            if Ent.Shape[LocalX, LocalY] then
              Exit(I);
          end;
        end;
      end;
    end;
  end;
end;

function TSkiaQwirQ.CanMoveBlock(Idx, DirX, DirY: Integer): Boolean;
var
  X, Y: Integer;
  Ent: TEntity;
begin
  Result := True;
  Ent := FEntities.List[Idx];
  for Y := 0 to Ent.H - 1 do
  begin
    for X := 0 to Ent.W - 1 do
    begin
      if Ent.Shape[X, Y] then
      begin
        if (Ent.X + X + DirX < 0) or (Ent.X + X + DirX >= MAX_GRID_W) or
           (Ent.Y + Y + DirY < 0) or (Ent.Y + Y + DirY >= MAX_GRID_H) or
           (FGrid[Ent.X + X + DirX, Ent.Y + Y + DirY] in [ttWall, ttHole]) or
           (GetEntityAt(Ent.X + X + DirX, Ent.Y + Y + DirY) <> -1) then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

function TSkiaQwirQ.IsRotatorTargetClear(X, Y, RotatorIdx: Integer): Boolean;
var
  CheckIdx: Integer;
begin
  if (X < 0) or (X >= MAX_GRID_W) or (Y < 0) or (Y >= MAX_GRID_H) then
    Exit(False);
  if FGrid[X, Y] in [ttWall, ttHole] then
    Exit(False);

  CheckIdx := GetEntityAt(X, Y);
  if (CheckIdx <> -1) and (CheckIdx <> RotatorIdx) then
    Exit(False);

  Result := True;
end;

procedure TSkiaQwirQ.DoPhysicsUpdate(DeltaSec: Double);
var
  NX, NY, Idx: Integer;
  Block: TEntity;
  DirX, DirY: Integer;
  CanRot, Clockwise: Boolean;
  NewRotDir, I, J: Integer;
  CheckX, CheckY: Integer;
begin
  if not FActive then Exit;
  FBlinkTimer := FBlinkTimer - DeltaSec;
  if FBlinking and (FBlinkTimer <= 0) then
  begin
    FBlinking := False;
    FBlinkTimer := 2.0 + Random(4);
  end
  else if not FBlinking and (FBlinkTimer <= 0) then
  begin
    FBlinking := True;
    FBlinkTimer := 0.15;
  end;
  FMoveCooldown := FMoveCooldown - DeltaSec;
  if FMoveCooldown > 0 then Exit;

  FLock.Acquire;
  try
    if (Byte(vkLeft) in FKeys) or (Byte(Ord('A')) in FKeys) or (Byte(Ord('a')) in FKeys) then
    begin FPlayerDir := Point(-1, 0); NX := FPlayer.X - 1; NY := FPlayer.Y; end
    else if (Byte(vkRight) in FKeys) or (Byte(Ord('D')) in FKeys) or (Byte(Ord('d')) in FKeys) then
    begin FPlayerDir := Point(1, 0); NX := FPlayer.X + 1; NY := FPlayer.Y; end
    else if (Byte(vkUp) in FKeys) or (Byte(Ord('W')) in FKeys) or (Byte(Ord('w')) in FKeys) then
    begin FPlayerDir := Point(0, -1); NX := FPlayer.X; NY := FPlayer.Y - 1; end
    else if (Byte(vkDown) in FKeys) or (Byte(Ord('S')) in FKeys) or (Byte(Ord('s')) in FKeys) then
    begin FPlayerDir := Point(0, 1); NX := FPlayer.X; NY := FPlayer.Y + 1; end
    else Exit;
  finally
    FLock.Release;
  end;

  FMoveCooldown := 0.1;
  DirX := NX - FPlayer.X;
  DirY := NY - FPlayer.Y;

  if (NX >= 0) and (NX < MAX_GRID_W) and (NY >= 0) and (NY < MAX_GRID_H) and not (FGrid[NX, NY] in [ttWall, ttHole]) then
  begin
    if FGrid[NX, NY] = ttDoor then
    begin
      NextLevel;
      Exit;
    end;

    Idx := GetEntityAt(NX, NY);
    if Idx <> -1 then
    begin
      Block := FEntities.List[Idx];
      if Block.Typ = etBlock then
      begin
        if CanMoveBlock(Idx, DirX, DirY) then
        begin
          Block.X := Block.X + DirX;
          Block.Y := Block.Y + DirY;

          FPlayer.X := NX;
          FPlayer.Y := NY;
        end;
      end
      else if Block.Typ = etRotator then
      begin
        // Absolute Direction Table
        // This ensures the arm always swings correctly relative to the push direction
        if (DirX = -1) or (DirY = -1) then
          Clockwise := True
        else
          Clockwise := False;

        if Clockwise then
          NewRotDir := (Block.RotDir + 1) mod 4
        else
          NewRotDir := (Block.RotDir + 3) mod 4;

        CanRot := True;

        // Check target cells for all 3 arms based on the NEW rotation
        case NewRotDir of
          0: begin
               CheckX := Block.X + 1; CheckY := Block.Y;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X + 2; CheckY := Block.Y + 1;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X + 1; CheckY := Block.Y + 2;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
             end;
          1: begin
               CheckX := Block.X + 2; CheckY := Block.Y + 1;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X + 1; CheckY := Block.Y + 2;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X;     CheckY := Block.Y + 1;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
             end;
          2: begin
               CheckX := Block.X + 1; CheckY := Block.Y + 2;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X;     CheckY := Block.Y + 1;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X + 1; CheckY := Block.Y;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
             end;
          3: begin
               CheckX := Block.X;     CheckY := Block.Y + 1;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X + 1; CheckY := Block.Y;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
               CheckX := Block.X + 2; CheckY := Block.Y + 1;
               if not IsRotatorTargetClear(CheckX, CheckY, Idx) then CanRot := False;
             end;
        end;

        // Apply rotation if the path is clear
        if CanRot then
        begin
          Block.RotDir := NewRotDir;

          SetLength(Block.Shape, 3, 3);
          for I := 0 to 2 do
          begin
            for J := 0 to 2 do
            begin
              Block.Shape[I, J] := False;
              if (I = 1) and (J = 1) then
                Block.Shape[I, J] := True; // Center always stays

              case Block.RotDir of
                0: begin if (I = 1) and (J = 0) then Block.Shape[I, J] := True;
                         if (I = 2) and (J = 1) then Block.Shape[I, J] := True;
                         if (I = 1) and (J = 2) then Block.Shape[I, J] := True; end;
                1: begin if (I = 2) and (J = 1) then Block.Shape[I, J] := True;
                         if (I = 1) and (J = 2) then Block.Shape[I, J] := True;
                         if (I = 0) and (J = 1) then Block.Shape[I, J] := True; end;
                2: begin if (I = 1) and (J = 2) then Block.Shape[I, J] := True;
                         if (I = 0) and (J = 1) then Block.Shape[I, J] := True;
                         if (I = 1) and (J = 0) then Block.Shape[I, J] := True; end;
                3: begin if (I = 0) and (J = 1) then Block.Shape[I, J] := True;
                         if (I = 1) and (J = 0) then Block.Shape[I, J] := True;
                         if (I = 2) and (J = 1) then Block.Shape[I, J] := True; end;
              end;
            end;
          end;

          // Player pushes the arm, arm swings away, player moves into arm's old cell
          FPlayer.X := NX;
          FPlayer.Y := NY;
        end;
      end;
    end
    else
    begin
      // Normal movement on empty floor
      FPlayer.X := NX;
      FPlayer.Y := NY;
    end;
  end;
end;

{ RENDERING }

procedure TSkiaQwirQ.DrawEntities(const ACanvas: ISkCanvas);
var
  I, X, Y: Integer;
  Ent: TEntity;
  Rect: TRectF;
  Paint, GlowPaint: ISkPaint;
  CX, CY: Single;
  EyeOffsetX, EyeOffsetY: Single;
  PathBuilder: ISkPathBuilder;
  Path: ISkPath;
  FillRect: TRectF;
  RenderMask: array[0..MAX_GRID_W-1, 0..MAX_GRID_H-1] of Boolean;
begin
  // Initialize Render Mask to prevent overlapping visual glitches
  for X := 0 to MAX_GRID_W - 1 do
    for Y := 0 to MAX_GRID_H - 1 do
      RenderMask[X, Y] := False;

  for I := 0 to FEntities.Count - 1 do
  begin
    Ent := FEntities.List[I];
    if Ent.Typ = etPlayer then Continue;
    CX := Ent.X * TILE_SIZE;
    CY := Ent.Y * TILE_SIZE;
    if (Ent.Typ = etBlock) or (Ent.Typ = etRotator) then
    begin
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      if Ent.Typ = etBlock then
        Paint.Color := $FFB85C2E
      else
        Paint.Color := $FF8800CC;
      PathBuilder := TSkPathBuilder.Create;
      for X := 0 to Ent.W - 1 do
      begin
        for Y := 0 to Ent.H - 1 do
        begin
          if Ent.Shape[X, Y] then
          begin
            // Only draw if this cell hasn't been claimed by a previous entity
            if not RenderMask[Ent.X + X, Ent.Y + Y] then
            begin
              RenderMask[Ent.X + X, Ent.Y + Y] := True;
              FillRect := TRectF.Create(CX + X * TILE_SIZE, CY + Y * TILE_SIZE,
                                        CX + (X + 1) * TILE_SIZE, CY + (Y + 1) * TILE_SIZE);
              PathBuilder.AddRect(FillRect);
            end;
          end;
        end;
      end;
      Path := PathBuilder.Detach;
      ACanvas.DrawPath(Path, Paint);
      Paint.Style := TSkPaintStyle.Stroke;
      Paint.StrokeWidth := 3;
      if Ent.Typ = etBlock then
        Paint.Color := $FF880000
      else
        Paint.Color := $FFDD33FF;
      ACanvas.DrawPath(Path, Paint);
      if Ent.Typ = etBlock then
      begin
        Paint.Style := TSkPaintStyle.Fill;
        Paint.Color := $FF333333;
        for X := 0 to Ent.W - 1 do
          for Y := 0 to Ent.H - 1 do
            if Ent.Shape[X, Y] then
            begin
              ACanvas.DrawCircle(PointF(CX + X * TILE_SIZE + 6, CY + Y * TILE_SIZE + 6), 2, Paint);
              ACanvas.DrawCircle(PointF(CX + (X + 1) * TILE_SIZE - 6, CY + Y * TILE_SIZE + 6), 2, Paint);
              ACanvas.DrawCircle(PointF(CX + X * TILE_SIZE + 6, CY + (Y + 1) * TILE_SIZE - 6), 2, Paint);
              ACanvas.DrawCircle(PointF(CX + (X + 1) * TILE_SIZE - 6, CY + (Y + 1) * TILE_SIZE - 6), 2, Paint);
            end;
      end;
    end;
  end;

  // Draw the goal (door)
  PathBuilder := TSkPathBuilder.Create;
  for Y := 0 to MAX_GRID_H - 1 do
  begin
    for X := 0 to MAX_GRID_W - 1 do
    begin
      if FGrid[X, Y] = ttDoor then
      begin
        FillRect := TRectF.Create(X * TILE_SIZE + 4, Y * TILE_SIZE + 4,
                                  (X + 1) * TILE_SIZE - 4, (Y + 1) * TILE_SIZE - 4);
        PathBuilder.AddRect(FillRect);
      end;
    end;
  end;
  Path := PathBuilder.Detach;
  if not Path.IsEmpty then
  begin
    Paint := TSkPaint.Create(TSkPaintStyle.Fill);
    Paint.AntiAlias := True;
    Paint.Color := $66FFFF00;
    Paint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Solid, 10.0);
    ACanvas.DrawPath(Path, Paint);
    Paint.MaskFilter := nil;
    Paint.Color := $FFFFD700;
    ACanvas.DrawPath(Path, Paint);
    Paint.Style := TSkPaintStyle.Stroke;
    Paint.StrokeWidth := 2;
    Paint.Color := $FF000000;
    ACanvas.DrawPath(Path, Paint);
  end;

  // Draw the player
  Ent := FPlayer;
  CX := Ent.X * TILE_SIZE;
  CY := Ent.Y * TILE_SIZE;
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  Rect := TRectF.Create(CX + 4, CY + 4, CX + TILE_SIZE - 4, CY + TILE_SIZE - 4);
  GlowPaint := TSkPaint.Create(Paint);
  GlowPaint.Color := $FF00FF00;
  GlowPaint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Solid, 6.0);
  ACanvas.DrawCircle(PointF(CX + TILE_SIZE/2, CY + TILE_SIZE/2), TILE_SIZE/3, GlowPaint);
  Paint.Color := $FF00CC55;
  ACanvas.DrawRoundRect(Rect, 6, 6, Paint);
  if FBlinking then
  begin
    Paint.Color := $FFFFFFFF;
    Paint.Style := TSkPaintStyle.Stroke;
    Paint.StrokeWidth := 2;
    ACanvas.DrawLine(PointF(CX + 8, CY + 10), PointF(CX + 14, CY + 10), Paint);
    ACanvas.DrawLine(PointF(CX + 16, CY + 10), PointF(CX + 22, CY + 10), Paint);
  end
  else
  begin
    EyeOffsetX := FPlayerDir.X * 2;
    EyeOffsetY := FPlayerDir.Y * 2;
    Paint.Color := $FFFFFFFF;
    ACanvas.DrawCircle(PointF(CX + 10, CY + 10), 3, Paint);
    ACanvas.DrawCircle(PointF(CX + 18, CY + 10), 3, Paint);
    Paint.Color := $FF000000;
    ACanvas.DrawCircle(PointF(CX + 10 + EyeOffsetX, CY + 10 + EyeOffsetY), 1.5, Paint);
    ACanvas.DrawCircle(PointF(CX + 18 + EyeOffsetX, CY + 10 + EyeOffsetY), 1.5, Paint);
  end;
end;

procedure TSkiaQwirQ.DrawUI(const ACanvas: ISkCanvas);
var
  Font: TSkFont;
  Paint: ISkPaint;
begin
  Font := TSkFont.Create;
  try
    Paint := TSkPaint.Create;
    Paint.Style := TSkPaintStyle.Fill;
    Paint.AntiAlias := True;
    Paint.Color := TAlphaColors.White;
    ACanvas.DrawSimpleText('SkiaQwirQ - Level ' + IntToStr(FCurrentLevel) + ' | WASD/Arrows: Move', 10, 20, Font, Paint);
  finally
    Font.Free;
  end;
end;

procedure TSkiaQwirQ.Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  X, Y: Integer;
  CX, CY: Single;
  Rect: TRectF;
  Paint: ISkPaint;
begin
  ACanvas.Clear($FF0F0F1A);
  for Y := 0 to FLevelH - 1 do
  begin
    for X := 0 to FLevelW - 1 do
    begin
      CX := X * TILE_SIZE;
      CY := Y * TILE_SIZE;
      Rect := TRectF.Create(CX, CY, CX + TILE_SIZE, CY + TILE_SIZE);
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      case FGrid[X, Y] of
        ttEmpty: begin
                   Paint.Color := $FF1A1A2E;
                   ACanvas.DrawRect(Rect, Paint);
                 end;
        ttWall: begin
                  Paint.Color := $FF4A4A5A;
                  ACanvas.DrawRect(Rect, Paint);
                  Paint.Color := $FF2F2F3F;
                  Paint.Style := TSkPaintStyle.Stroke;
                  Paint.StrokeWidth := 3;
                  ACanvas.DrawRect(Rect, Paint);
                end;
        ttHole: begin
                  Paint.Color := $FF000000;
                  ACanvas.DrawRect(Rect, Paint);
                end;
        ttDoor: begin
                  Paint.Color := $FF1A1A2E;
                  ACanvas.DrawRect(Rect, Paint);
                end;
      end;
    end;
  end;
  DrawEntities(ACanvas);
  DrawUI(ACanvas);
end;

{ INPUT & LIFECYCLE }

procedure TSkiaQwirQ.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  GameKey: Byte;
begin
  if Key = vkEscape then Halt;
  GameKey := 0;
  case Key of
    vkLeft, vkRight, vkUp, vkDown: GameKey := Key;
  end;
  if GameKey = 0 then
  begin
    case KeyChar of
      'A', 'a': GameKey := Ord('A');
      'S', 's': GameKey := Ord('S');
      'D', 'd': GameKey := Ord('D');
      'W', 'w': GameKey := Ord('W');
    end;
  end;
  if GameKey > 0 then
  begin
    FLock.Acquire;
    try Include(FKeys, GameKey); finally FLock.Release; end;
    Key := 0;
    KeyChar := #0;
  end;
  inherited;
end;

procedure TSkiaQwirQ.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  GameKey: Byte;
begin
  GameKey := 0;
  case Key of
    vkLeft, vkRight, vkUp, vkDown: GameKey := Key;
  end;
  if GameKey = 0 then
  begin
    case KeyChar of
      'A', 'a': GameKey := Ord('A');
      'S', 's': GameKey := Ord('S');
      'D', 'd': GameKey := Ord('D');
      'W', 'w': GameKey := Ord('W');
    end;
  end;
  if GameKey > 0 then
  begin
    FLock.Acquire;
    try Exclude(FKeys, GameKey); finally FLock.Release; end;
    Key := 0;
    KeyChar := #0;
  end;
  inherited;
end;

procedure TSkiaQwirQ.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  SetFocus;
  inherited;
end;

procedure TSkiaQwirQ.SafeInvalidate;
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

procedure TSkiaQwirQ.StartThread;
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
        Sleep(16);
      end;
    end);
  FThread.FreeOnTerminate := True;
  FThread.Start;
end;

procedure TSkiaQwirQ.StopThread;
begin
  FActive := False;
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    Sleep(50);
  end;
end;

end.
