unit mypanel;

interface

uses e, elib, ExtCtrls, Graphics, Classes, Forms, Controls, Messages, Windows;

procedure DefineMyPanel();

type
  TMyPanel = class(TPanel)
  public
    FWinFormID, FUnitID: Cardinal;
    FInDesignMode: EBool;
  public
    function SaveProperties(): HGLOBAL;
    function LoadProperties(Data: PBYTE; Size: Integer): Boolean;
  public
    procedure WndProc(var msg: TMessage); override;
    procedure CallBaseWndProc(var msg: TMessage);
  end;

implementation

procedure TMyPanel.WndProc(var msg: TMessage);
begin
  ELib_WinControlWndProc(self, msg, CallBaseWndProc, true);
end;

procedure TMyPanel.CallBaseWndProc(var msg: TMessage);
begin
  inherited WndProc(msg);
end;

const MyPanelCurrentVersion = 1;

function TMyPanel.SaveProperties: HGLOBAL;
var
  w: ELib_TPropWriter;
begin
  result := 0;
  w := ELib_TPropWriter.Create();
  try
    w.WriteInt(MyPanelCurrentVersion);
    w.WriteInt(self.Color);
    w.WriteInt(ELib_GetAlignIndex(self.Align));
    result := w.AllocHGlobal();
  finally
    w.Free();
  end;
end;

function TMyPanel.LoadProperties(Data: PBYTE; Size: Integer): Boolean;
var
  r: ELib_TPropReader;
  ver: Integer;
begin
  result := true;
  if (Data = nil) or (Size = 0) then exit;

  result := false;
  r := ELib_TPropReader.Create(Data, Size);
  try
    ver := r.ReadInt();
    if ver > MyPanelCurrentVersion then exit;
    self.Color := r.ReadInt();
    self.Align := ELib_GetAlignFromIndex(r.ReadInt());
    Result := True;
  finally
    r.Free();
  end;
end;


function MyPanel_OnCreate(
    pAllData: PBYTE; nAllDataSize: Integer;
    dwStyle,hParentWnd,uID,hMenu: Cardinal; x,y,cx,cy: Integer;
    dwWinFormID,dwUnitID,hDesignWnd: Cardinal; blInDesignMode: EBool
  ): HUNIT; stdcall;
var
  Panel: TMyPanel;
begin
  Panel := TMyPanel(ELib_CreateControl(Result, TMyPanel, dwStyle, hParentWnd, x, y, cx, cy));
  if Result = 0 then exit;

  with Panel do
  begin
    FWinFormID := dwWinFormID;
    FUnitID := dwUnitID;
    FInDesignMode := blInDesignMode;
  end;

  Panel.LoadProperties(pAllData, nAllDataSize);
end;

function MyPanel_OnGetProperty(
    hUnit: HUNIT; nIndex: Integer; pValue: PUNIT_PROPERTY_VALUE
  ): EBool; stdcall;
var
  panel: TMyPanel;
begin
  Result := EFalse;
  panel := TMyPanel(ELib_GetControl(hUnit));
  if panel = nil then exit;

  case nIndex of
    0: begin //底色
      pValue.m_clr := ELib_ToEBackColor(panel.Color);
    end;
    1: begin //对齐
      pValue.m_int := ELib_GetAlignIndex(panel.Align);
    end;
  end;

  Result := ETrue;
end;

//属性改变
function MyPanel_OnSetProperty(
    hUnit: HUNIT; nIndex: Integer;
    pValue: PUNIT_PROPERTY_VALUE; ppszTipText: PPCHAR
  ): EBool; stdcall
var
  panel: TMyPanel;
begin
  Result := EFalse;
  panel := TMyPanel(ELib_GetControl(hUnit));
  if panel = nil then exit;

  case nIndex of
    0: begin // 底色
      panel.Color := ELib_FromEBackColor(pValue.m_clr);
    end;
    1: begin // 对齐
      panel.Align := ELib_GetAlignFromIndex(pValue.m_int);
    end;
  end;
end;

function MyPanel_OnGetAllProperties (hUnit: HUNIT): HGLOBAL; stdcall;
var
  panel: TMyPanel;
begin
  Result := 0;
  panel := TMyPanel(ELib_GetControl(hUnit));
  if panel = nil then exit;

  Result := panel.SaveProperties();
end;

function MyPanel_OnPropertyUpDateUI(hUnit: HUNIT; nPropertyIndex: Integer): EBool; stdcall;
begin
  Result := ETrue;
end;

procedure DefineMyPanel();
var index: Integer;
begin
  index := DefineUIDatatype
  (
      '我的VCL面板', 'MyPanel', //szName, szEGName
      '', //szExplain
      LDT_IS_CONTAINER, 101, //dwState, dwUnitBmpID
      nil, //pfnGetInterface
      MyPanel_OnCreate, //onCreateUnit
      MyPanel_OnGetProperty, //onGetPropertyValue
      MyPanel_OnSetProperty, //onSetPropertyValue
      MyPanel_OnGetAllProperties, //onGetAllPropertiesValue
      MyPanel_OnPropertyUpDateUI, //onPropertyUpdateUI
      nil, //onInitDlgCustomData
      nil, //onGetIconPropertyValue
      nil, //onIsNeedThisKey
      nil, //onLanguageConv
      nil, //onMsgFilter
      nil  //onNotifyUnit
  );

  DefineProperty(index, '底色', 'BackColor', '背景颜色', UD_COLOR_BACK, 0, nil);
  ELib_DefineAlignProperty(index);

  //DefineEvent(index, '事件名称', '事件的说明', 0, [], _SDT_NULL);

end;

end.
