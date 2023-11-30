unit RWT.FMXObjectInspector;

interface

uses
  System.Classes,
  System.Rtti,  
  Generics.Collections,
  FMX.Controls,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Grid;

type
  TControlClass = class of TControl;

  TObjectInspectorControlClick = procedure(Sender: TObject) of object;

  TFMXObjectInspector = class(TVertScrollBox)
  private
    FKeysGrid: TStringGrid;
    FSplitter: TSplitter;
    FKeys: TDictionary<string, TControlClass>;
    FValues: TGridPanelLayout;
    FStartValues: TDictionary<string, TValue>;
    FControlClick: TObjectInspectorControlClick;

    procedure KeysGridResize(Sender: TObject);
    procedure KeyNotify<T>(Sender: TObject; const Item: T; Action: TCollectionNotification);

    procedure StringGridSelectCell(Sender: TObject; const ACol, ARow: Integer;
      var CanSelect: Boolean);
    //function GetControls: TGridPanelLayout.TControlCollection;

    procedure ControlClicked(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddKey<T>(const Text: string; const ControlClass: TControlClass; const Value: T);

  published
    //property Controls: TGridPanelLayout.TControlCollection read GetControls;
    property OnControlClick: TObjectInspectorControlClick read FControlClick write FControlClick;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  FMX.Types,
  FMX.Edit;

{ TFMXObjectInspector }

procedure TFMXObjectInspector.AddKey<T>(const Text: string;
  const ControlClass: TControlClass; const Value: T);
begin
  FStartValues.Add(Text, TValue.From<T>(Value));
  FKeys.Add(Text, ControlClass);
end;

procedure TFMXObjectInspector.ControlClicked(Sender: TObject);
begin
  if Assigned(FControlClick) then
    FControlClick(Sender);
end;

constructor TFMXObjectInspector.Create(AOwner: TComponent);
begin
  inherited;
    
  FKeys := TDictionary<string, TControlClass>.Create;
  FKeys.OnKeyNotify := KeyNotify<string>;

  FStartValues := TDictionary<string, TValue>.Create;

  FKeysGrid := TStringGrid.Create(Self);
  FKeysGrid.Parent := Self;
  FKeysGrid.Align := TAlignLayout.Left;
  FKeysGrid.Options := [TGridOption.RowLines, TGridOption.RowSelect];
  FKeysGrid.RowHeight := 20;
  FKeysGrid.AddObject(TStringColumn.Create(FKeysGrid));
  FKeysGrid.OnResize := KeysGridResize;
  FKeysGrid.OnSelectCell := StringGridSelectCell;
  FKeysGrid.EnabledScroll := False;
  FKeysGrid.RowCount := 0;
  FKeysGrid.Visible := True;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := TAlignLayout.Left;
  FSplitter.Width := 3;
  FSplitter.ShowGrip := False;
  FSplitter.Visible := True;

  FValues := TGridPanelLayout.Create(Self);
  FValues.Parent := Self;
  FValues.Align := TAlignLayout.Client;

  FValues.ColumnCollection.ClearAndResetID;
  FValues.ControlCollection.ClearAndResetID;
  FValues.RowCollection.ClearAndResetID;

  var col := FValues.ColumnCollection.Add;
  col.SizeStyle := TGridPanelLayout.TSizeStyle.Percent;
  col.Value := 100;
  FValues.Visible := True;
end;

destructor TFMXObjectInspector.Destroy;
begin
  FStartValues.Free;
  FKeys.Free;
  inherited;
end;

//function TFMXObjectInspector.GetControls: TGridPanelLayout.TControlCollection;
//begin
//  Result := FValues.ControlCollection;
//end;

procedure TFMXObjectInspector.KeyNotify<T>(Sender: TObject; const Item: T;
  Action: TCollectionNotification);
begin
  var Key := TValue.From<T>(Item).AsString;

  case Action of
    cnAdding: ;
    cnAdded:
      begin
        FKeysGrid.RowCount := FKeysGrid.RowCount + 1;
        FKeysGrid.Cells[0, FKeysGrid.RowCount - 1] := Key;

        FValues.ControlCollection.BeginUpdate;
        FValues.RowCollection.BeginUpdate;

        var row := FValues.RowCollection.Add;
        row.SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
        row.Value := 22;

        var aControl: TControlClass;

        if FKeys.TryGetValue(Key, aControl) then
        begin
          var Control := aControl.Create(FValues);
          Control.Parent := FValues;
          Control.Visible := True;
          Control.Align := TAlignLayout.Client;
          Control.OnClick := ControlClicked;

          var Value: TValue;
          if FStartValues.TryGetValue(Key, Value) then 
          begin          
            if Control is TEdit then TEdit(Control).Text := Value.AsString;
            if Control is TCheckbox then TCheckbox(Control).IsChecked := Value.AsBoolean;
            if Control is TButton then TButton(Control).Text := Value.AsString;
            
          end;
          FValues.ControlCollection.AddControl(Control);
        end;

        FValues.RowCollection.EndUpdate;
        FValues.ControlCollection.EndUpdate;
      end;
    cnExtracting: ;
    cnExtracted: ;
    cnDeleting: ;
    cnRemoved: ;
  end;
end;

procedure TFMXObjectInspector.KeysGridResize(Sender: TObject);
begin
  FKeysGrid.Columns[0].Width := FKeysGrid.Width - 5;
end;

procedure TFMXObjectInspector.StringGridSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if FValues.CellCount > 0 then
  begin
    FValues.Controls[ARow].SetFocus;
    if FValues.Controls[ARow] is TEdit then
      TEdit(FValues.Controls[ARow]).SelectAll;
  end;
end;

end.
