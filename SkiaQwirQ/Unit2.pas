unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SkiaQwirQ;

type
  TForm2 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.FormCreate(Sender: TObject);
var
  Game: TSkiaQwirQ;
begin
  Game := TSkiaQwirQ.Create(Self);
  Game.Parent := Self;
  Game.TabStop := True;
  Game.Align := TAlignLayout.Client;
  Game.SetFocus;
end;

end.
