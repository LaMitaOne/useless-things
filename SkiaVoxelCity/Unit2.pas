unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SkiaVoxelCity;

type
  TForm2 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
 private
    { Private-Deklarationen }
    Game: TSkiaVoxelCity;
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation
{$R *.fmx}

procedure TForm2.FormCreate(Sender: TObject);
begin
  Game := TSkiaVoxelCity.Create(Self);
  Game.Parent := Self;
  Game.Align := TAlignLayout.Client;
end;

procedure TForm2.FormActivate(Sender: TObject);
begin
  if Assigned(Game) then
    Game.SetFocus;
end;

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(Game) then
  begin
    Game.Free;
    Game := nil;
  end;

  CanClose := True;
end;



end.



