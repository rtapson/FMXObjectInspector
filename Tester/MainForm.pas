unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  FMX.Layouts, FMX.StdCtrls, FMX.Edit,
  RWT.FMXObjectInspector;

type
  TForm1 = class(TForm)
    VertScrollBox1: TVertScrollBox;
    StringGrid1: TStringGrid;
    Splitter1: TSplitter;
    GridPanelLayout1: TGridPanelLayout;
    Button1: TButton;
    StringColumn1: TStringColumn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FOI: TFMXObjectInspector;

    procedure ButtonClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.ButtonClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowMessage(Sender.ClassName + ' Clicked');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin

//  GridPanelLayout1.ControlCollection.BeginUpdate;

//  GridPanelLayout1.ControlCollection.ClearAndResetID;
//  GridPanelLayout1.RowCollection.ClearAndResetID;
//
//  for i := 0 to 9 do
//  begin
//
//    var anEdit1 := TEdit.Create(GridPanelLayout1);
//    anEdit1.Parent := GridPanelLayout1; //magic: place in the next empty cell
//    anEdit1.Visible := true;
//    anEdit1.Align := TAlignLayout.Client;
//    anEdit1.Text := 'Control' + i.ToString;
//    GridPanelLayout1.ControlCollection.AddControl(anEdit1);
//  end;

  FOI := TFMXObjectInspector.Create(Self);
  FOI.Parent := Self;
  FOI.Position.X := 400;
  FOI.Position.Y := 128;
  FOI.Width := 377;
  FOI.Height := 497;
  FOI.Visible := True;

  FOI.OnControlClick := ButtonClick;

  FOI.AddKey<string>('Background Color', TEdit, 'Test');
  FOI.AddKey<Boolean>('Forground Color', TCheckBox, True);
  FOI.AddKey<string>('Text', TEdit, 'Text');
  FOI.AddKey<string>('Price', TButton, 'Button Caption');


end;

end.
