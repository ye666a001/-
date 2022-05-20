unit elib;

////////////////////////////////////////////////////////////////////////////////
//
//   易语言支持库开发包(EDK) for Delphi, 1.0
// ---------------------------------------------
// (2008/5, 大连大有吴涛易语言软件开发有限公司)
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  e, Classes, Types, Messages, Controls, Graphics, Forms, ExtCtrls, Windows, CommCtrl;

type

  TVclFormContainer = class(TForm)
  end;

  TVclPanelContainer = class(TPanel)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  ELib_TPropReader = class
  public
    constructor Create(DataAddress: Pointer; DataLength: Cardinal);
    function Read(Buffer: Pointer; Count: Cardinal): Boolean;
    function ReadInt(): Integer;
    function ReadBool(): EBool;
    function ReadDouble(): Double;
    function ReadString(): String;
    function ReadDWord(): DWORD;
    function ReadByte(): Byte;
    function ReadCardinal(): Cardinal;
    function ReadFont(): TLogFont; overload;
    function ReadFont(out fontVar: TLogFont): Boolean; overload;
    function ReadStrings(stringsVar: TStrings): Boolean;
    function ReadMemoryStream(memoryVar: TMemoryStream): Boolean;
  private
    FDataAddress: Pointer;
    FDataLength: Cardinal;
    FPosition: Cardinal;
  end;

  ELib_TPropWriter = class
  public
    constructor Create();
    function Write(DataAddress: Pointer; Count: Cardinal): Boolean;
    function WriteInt(intValue: Integer): Boolean;
    function WriteBool(boolValue: EBool): Boolean;
    function WriteDouble(doubleValue: Double): Boolean;
    function WriteString(stringValue: String): Boolean;
    function WriteFont(fontValue: LOGFONT): Boolean;
    function WriteDWord(dwordValue: DWORD): Boolean;
    function WriteByte(byteValue: Byte): Boolean;
    function WriteCardinal(cardinalValue: Cardinal): Boolean;
    function WriteStrings(stringsValue: TStrings): Boolean;
    function WriteMemoryStream(memoryValue: TMemoryStream): Boolean;
    function AllocHGlobal(): HGLOBAL;
    function GetDataAddress(): Pointer;
    function GetDataLength(): Cardinal;
    destructor Destroy; override;
  private
    FMemoryStream: TMemoryStream;
  end;

  // 一个可以 Attach 到一块已经存在的内存的 MemoryStream
  // 该 MemoryStream 不可改变大小
  TAttachedMemoryStream = class(TCustomMemoryStream)
  public
    constructor Create(Ptr: Pointer; Size: LongInt);
    function Write(const Buffer; Count: LongInt): Longint; override;
  end;

  TContainer = TWinControl;
  TContainerClass = class of TContainer;

{
  创建一个控件并注册到易语言系统.

  * 是否使用Container取决于 ContainerClass 参数

  * 关于 NeedClick 的简单说明:
  在易语言中,一个VCL控件如果是放在Panel上时,它的相关消息(比如WM_LBUTTONDOWN)必须转发给Panel,才能被易语言的"该控件_鼠标左键被按下"接收到<原因是加了Panel之后,注册给易语言的实际上是这个Panel,而不是实际的控件,导致易语言只能接收到Panel的消息而不是实际控件的消息>

  但是,如果这个控件把WM_LBUTTONDOWN转发给了父窗口(Panel)又会导致它的Click事件被破坏(无法收到).所以,如果想接收Click,就必须不转发WM_LBUTTONDOWN.

  所以.要么接收Click,要么接收WM_LBUTTONDOWN.
}
function ELib_CreateControl(out UnitHandle: HUNIT; ControlClass: TWinControlClass;
  dwStyle, hParentWnd: Cardinal; x,y,cx,cy: Integer; ContainerClass: TContainerClass = nil; AUnitID: Cardinal = 0; AFormID: Cardinal = 0): TWinControl;
//将TWinControl对象注册到易系统, 返回其HUNIT. 失败返回0.
// 如果 ContainerClass 不为 nil 则会自动创建一个该类型的 Form 作为该控件的父控件
// 同时该控件之前的父窗口成为 Form 的父窗口
function ELib_RegControl(Control: TWinControl; AContainer: TContainer = nil; AFormID: Cardinal = 0; AUnitID: Cardinal = 0): HUNIT;

//根据HUNIT获取对应的TWinControl对象. 失败返回nil.
function ELib_GetControl(UnitHandle: HUNIT): TWinControl; overload;
//根据易对象获取对应的TWinControl对象. 失败返回nil.
function ELib_GetControl(SelfMData: PMDATA_INF): TWinControl; overload;

//为易语言非可视控件设置所需参数: 单线边框, 最小尺寸为26*26, 居中显示图片
procedure ELib_SettingForFunctionalControl(control: TPanel; imageResourceID: Integer;
                                           fixMinSize: Boolean = true; fixMaxSize: Boolean = true);

//从一个已经注册过的TWinControl对象中取得其HUNIT. 失败返回0.
function ELib_GetHUNIT(Control: TWinControl): HUNIT; overload;
//获取易对象的HUNIT
function ELib_GetHUNIT(SelfMData: PMDATA_INF): HUNIT; overload;

// 从一个 TStream 的内容生产一个 HGLOBAL
// 该函数的用途参看 ITF_GET_ALL_PROPERTY_DATA
function ELib_AllocHGlobal(Stream: TStream): HGLOBAL;

// Boolean <--> EBool
function ELib_BooleanToEBool(Value: Boolean): EBool;
function ELib_EBoolToBoolean(value: EBool): Boolean;

// 从图片数据创建出一个 TBitmap
// 失败返回nil; 请注意返回值的释放问题
function ELib_CreateBitmap(Data: Pointer; Size: Cardinal): Graphics.TBitmap;
// 从易语言格式的图片组数据创建为HImageList
function ELib_CreateImageList(Data: Pointer; AOwner: TComponent; out TransparentColor: TColor): TImageList; overload;
function ELib_CreateImageList(Data: Pointer; AOwner: TComponent): TImageList; overload;

// 把一个 TBitmap 平铺,以填满指定的大小
// 如果 DisplaySize 的宽度,高度皆小于或等于位图本身,则保持原位图不变,并返回 False
function ELib_TileBitmap(var Bitmap: Graphics.TBitmap; var DisplaySize: TSize): Boolean;

// 把一个 TBitmap 平铺并生成新的 TBitmap 对象
// 如果 DisplaySize 的宽度,高度皆小于或等于位图本身,则返回nil
function ELib_CreateTitledBitmap(const Bitmap: Graphics.TBitmap; var DisplaySize: TSize): Graphics.TBitmap;

// 处理易默认背景色
function ELib_ToEBackColor(color: TColor): Cardinal;
function ELib_FromEBackColor(color: Cardinal): TColor;

// '对齐'(Align) 属性
procedure ELib_DefineAlignProperty(datatypeIndex: Integer);
function ELib_GetAlignFromIndex(index: Integer): TAlign;
function ELib_GetAlignIndex(align: TAlign): Integer;
procedure ELib_SetAlignByIndex(control: TWinControl; ePropIndex: Integer);

//'边框'属性
procedure ELib_DefineBorderProperty(datatypeIndex: Integer);
procedure ELib_SetBorderByIndex(panel: TPanel; ePropIndex: Integer);
function  ELib_GetBorderIndex(panel: TPanel): Integer;

//'字体'属性
procedure ELib_SetFont(font: TFont; const LogFont: TLogFont);
procedure ELib_SetDefaultFont(font: TFont);
function ELib_GetLogFont(const font: TFont): TLogFont;
procedure ELib_SetFont_Songti9(font: TFont);


type TCallWndProc = procedure(var Msg: TMessage) of object;
procedure ELib_WinControlWndProc(Control: TWinControl; var msg: TMessage; CallBaseWndProc: TCallWndProc; RealignOnMoveSize: Boolean = false);

// 根据TStrings的内容创建一个易语言数组
function ELib_TStringsToEArray(const Strings: TStrings): Pointer;

implementation

{$R VclFromContainer.dfm}

uses
  Math, SysUtils;

type
  ContainerPropData = record
    CWndPtr: HUNIT;
    Child: TWinControl;
    OldProc: Pointer;
    Painting: Boolean;
  end;

  ControlPropData = record
    Recreating: Boolean;
    OldProc: Pointer;
    MouseTracking: Boolean;
    MouseEntered: Boolean;
    case HasContainer: Boolean of
      True: (Container: TContainer; FormID, UnitID: Cardinal;);
      False: (CWndPtr: HUNIT);
  end;

  WndPropData = record
    Control: TWinControl;
    case IsContainer: Boolean of
      True: (ContainerData: ContainerPropData);
      False: (ControlData: ControlPropData);
  end;
  PWndPropData = ^WndPropData;

const
  ELIB_WND_PROP_NAME: PChar = 'dywt.com.cn/elib/vcl/wnd_prop_name';

function _GetPropData(arg: HWND): PWndPropData; overload;
begin
  Result := PWndPropData(GetProp(arg,ELIB_WND_PROP_NAME));
end;

function _GetPropData(arg: TWinControl): PWndPropData; overload;
begin
  Result := _GetPropData(arg.Handle);
end;

function _RemovePropData(arg: TWinControl): Boolean;
var
  pData: PWndPropData;
begin
  Result := False;
  pData := _GetPropData(arg);
  if not Assigned(pData) then exit;
  Result := RemoveProp(arg.Handle, ELIB_WND_PROP_NAME) <> 0;
  Dispose(pData);
end;

function _SetPropData(Control: TWinControl; Data: PWndPropData): Boolean;
begin
  _RemovePropData(Control);
  Result := SetProp(Control.Handle, ELIB_WND_PROP_NAME, Cardinal(Data));
end;


function ELib_ContainerNewProc(Handle: HWND; Msg: Cardinal; wParam, lParam: Integer): Cardinal; stdcall;
var
  Data: PWndPropData;
  AContainer: TWinControl;
begin
  Result := 0;
  AContainer := FindControl(Handle);
  if not Assigned(AContainer) then
    exit;
  Data := _GetPropData(FindControl(Handle));
  Assert(Data.IsContainer);
  with Data.ContainerData do
  begin
    case Msg of
      WM_ENABLE:
      begin
        Child.Enabled := wParam <> 0;
        AContainer.Enabled := wParam <> 0;
      end;
      WM_SETFOCUS:
      begin
        if not Child.Focused and Child.Visible and Child.Enabled then
          SetFocus(Child.Handle);
      end;
      WM_SHOWWINDOW:
      begin
        AContainer.Visible := (wParam <> 0);
      end;
      {WM_PAINT, WM_NCPAINT, WM_ERASEBKGND:
      begin
        if not Painting then
        begin
          Painting := true;
          Child.Perform(Msg, wParam, lParam);
          Child.Invalidate;
          Painting := false;
        end;
      end;}
    end;
    Result := CallWindowProc(OldProc, Handle, Msg, wParam, lParam);
  end;
end;

function ELib_ChildNewProc(Handle: HWND; Msg: Cardinal; wParam, lParam: Integer): Cardinal; stdcall;
var
  Data: PWndPropData;
  AControl: TWinControl;
  EventData: EVENT_NOTIFY2;
function GetEShiftState: Integer;
var
  ShiftState: TShiftState;
begin
  Result:= 0;
  ShiftState := KeyboardStateToShiftState;
  if ssCtrl in ShiftState then
    Result:= Result or 1; // 名称：Ctrl键状态 类型：数值型    值：1。
  if ssShift in ShiftState then
    Result:= Result or 2; //  名称：Shift键状态 类型：数值型    值：2。
  if ssAlt in ShiftState then
    Result:= Result or 4; //  名称：Alt键状态 类型：数值型    值：4。
end;
procedure SendMouseEventData(Index:Integer; FormID, UnitID: Cardinal);
begin
  Init_EVENT_NOTIFY2(EventData, FormID, UnitID, Index);
  EventData.m_nArgCount := 3;
  EventData.m_nArgValue[0].m_inf.m_Value.m_int := LOWORD(lParam);
  EventData.m_nArgValue[1].m_inf.m_Value.m_int := HIWORD(lParam);
  EventData.m_nArgValue[2].m_inf.m_Value.m_int := GetEShiftState;
  NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
end;
begin
  Result := 0;
  Data := _GetPropData(Handle);
  if not Assigned(Data) then exit;
  AControl := Data.Control;
  if not Assigned(AControl) then exit;

  Assert(Data.IsContainer = false);
  with Data.ControlData do
  begin
    Result := CallWindowProc(OldProc, Handle, Msg, wParam, lParam);

    if Msg = WM_NCDESTROY then Exit;
    if HasContainer then
    begin
      case Msg of
        WM_SHOWWINDOW:
        begin
          Container.Visible := wParam <> 0;
        end;
        WM_LBUTTONDOWN: begin
          SendMouseEventData(-1, FormID, UnitID);
        end;
        WM_LBUTTONUP: begin
          SendMouseEventData(-2, FormID, UnitID);
        end;
        WM_LBUTTONDBLCLK: begin
          SendMouseEventData(-3, FormID, UnitID);
        end;
        WM_RBUTTONDOWN: begin
          SendMouseEventData(-4, FormID, UnitID);
        end;
        WM_RBUTTONUP: begin
          SendMouseEventData(-5, FormID, UnitID);
        end;
        WM_MOUSEMOVE: begin
          SendMouseEventData(-6, FormID, UnitID);
        end;
        WM_SETFOCUS: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -7);
          EventData.m_nArgCount := 0;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_KILLFOCUS: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -8);
          EventData.m_nArgCount := 0;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_KEYDOWN: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -9);
          EventData.m_nArgCount := 2;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          EventData.m_nArgValue[1].m_inf.m_Value.m_int := GetEShiftState;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_KEYUP: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -10);
          EventData.m_nArgCount := 2;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          EventData.m_nArgValue[1].m_inf.m_Value.m_int := GetEShiftState;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_CHAR: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -11);
          EventData.m_nArgCount := 1;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
        WM_MOUSEWHEEL: begin
          Init_EVENT_NOTIFY2(EventData, FormID, UnitID, -12);
          EventData.m_nArgCount := 2;
          EventData.m_nArgValue[0].m_inf.m_Value.m_int := wParam;
          EventData.m_nArgValue[1].m_inf.m_Value.m_int := GetEShiftState;
          NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@EventData));
        end;
      end;
    end;
  end;
end;

function ELib_GetControl(UnitHandle: HUNIT): TWinControl; overload;
var
  Handle: HWND;
  Data: PWndPropData;
begin
  Result := nil;
  if UnitHandle = 0 then exit;
  Handle := HWND(NotifySys(NAS_GET_HWND_OF_CWND_OBJECT, Cardinal(UnitHandle), 0));
  Data := PWndPropData(GetProp(Handle, ELIB_WND_PROP_NAME));
  if not Assigned(Data) then exit;
  if Data.IsContainer then
    Result := Data.ContainerData.Child
  else
    Result := FindControl(Handle);
end;

function ELib_GetControl(selfMData: PMDATA_INF): TWinControl; overload;
begin
  result := ELib_GetControl(ELib_GetHUNIT(selfMData));
end;

function ELib_GetHUNIT(control: TWinControl): HUNIT; overload;
var
  Data: PWndPropData;
begin
  Result := 0;
  Data := _GetPropData(Control);
  if not Assigned(Data) then exit;
  if Data.IsContainer then
    Result := Data.ContainerData.CWndPtr
  else
  with Data.ControlData do
    if HasContainer then
      Result := _GetPropData(Container).ContainerData.CWndPtr
    else
      Result := Data.ControlData.CWndPtr;
end;

function ELib_GetHUNIT(selfMData: PMDATA_INF): HUNIT; overload;
begin
  Result := HUNIT(NotifySys (NRS_GET_AND_CHECK_UNIT_PTR,
            selfMData.m_Value.m_unit.m_dwFormID, selfMData.m_Value.m_unit.m_dwUnitID));
end;

type
  TChildStuff = record
    Instance: TWinControl;
    Handle: HWND;
    ParentCtrl:TWinControl;
    ParentHandle: HWND;
    PropData: PWndPropData;
  end;
  TChildrenStuf = array of TChildStuff;

// 取出AControl中所有需要在AControl重建时特殊处理的子控件(递归)
// 返回值包含了子控件以及对其进行处理时所必须的一些数据
function _GetChildren(AControl: TWinControl): TChildrenStuf;
var
  ChildHandle: HWND;
  Children: TChildrenStuf;
  I, H: Integer;
begin
  ChildHandle := 0;
  // 循环遍历所有的直接子窗口
  repeat
    ChildHandle := FindWindowEx(AControl.Handle, ChildHandle, nil, nil);
    if (ChildHandle = 0)  or (NotifySys(NAS_IS_EWIN, ChildHandle) = 0) then break;
    // 将此子窗口记录下来
    SetLength(Result, Length(Result) + 1);
    with Result[Length(Result) - 1] do
    begin
      Handle := ChildHandle;
      Instance := FindControl(Handle);
      // 是否有对应的Delphi TWinControl实例??
      if Assigned(Instance) then
      begin
        // 对应TWinControl实例, 说明其与AControl在VCL层有父子关系
        // 会在AControl重建时被自动重建
        PropData := _GetPropData(Handle);
        if PropData <> nil then
        begin
          if not PropData.IsContainer then
            PropData.ControlData.Recreating := True; //阻止子控件销毁自身
          // 递归处理其子窗口
          Children := _GetChildren(Instance);
          if Length(Children) > 0 then
          begin
            H := High(Result);
            SetLength(Result, Length(Result) + Length(Children));
            for I := Low(Children) to High(Children)do
              Result[H + I + 1] := Children[I];
          end;
        end;
      end;
      ParentHandle := GetParent(Handle);
      ParentCtrl := FindControl(ParentHandle);
    end;
  until False;

  // 不能在上面的遍历循环中进行SetParent,否则会导致"窗口链"中断,循环终止
  for I := Low(Result) to High(Result) do
  begin
    with Result[I] do
      if Instance = nil then
        SetParent(Handle, 0);
  end;
end;

procedure _SetChildren(AControl: TWinControl; const Children: TChildrenStuf);
var
  I: Integer;
begin
  for I := Low(Children) to High(Children) do
    with Children[I] do
    begin
      if Instance = nil then
      begin
        if Assigned(ParentCtrl) then
          SetParent(Handle, ParentCtrl.Handle)
        else
          SetParent(Handle, ParentHandle)
      end
      else
      begin
        if Assigned(PropData) then
        begin
          Assert(not PropData.IsContainer);
          with PropData.ControlData do
          begin
            OldProc := Pointer(SetWindowLong(Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
            Recreating := False;
            _SetPropData(Instance, PropData);
            // 重新 Attach CWnd 对象
            NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
            NotifySys(NAS_ATTACH_CWND_OBJECT, Instance.Handle, Cardinal(CWndPtr));
          end;
        end;
      end;
    end;
end;


{type
  TChildStuff = record
    Instance: TWinControl;
    Handle: HWND;
    PropData: PWndPropData;
  end;
  TChildrenStuf = array of TChildStuff;

// 取出AControl中所有需要在AControl重建时特殊处理的子控件(递归)
// 返回值包含了子控件以及对其进行处理时所必须的一些数据
function _GetChildren(AControl: TWinControl): TChildrenStuf;
var
  ChildHandle: HWND;
  I: Integer;
begin
  ChildHandle := 0;
  // 循环遍历所有的直接子窗口
  repeat
    ChildHandle := FindWindowEx(AControl.Handle, ChildHandle, nil, nil);
    if ChildHandle = 0 then break;
    // 将此子窗口记录下来
    SetLength(Result, Length(Result) + 1);
    with Result[Length(Result) - 1] do
    begin
      Handle := ChildHandle;
      Instance := FindControl(Handle);
      // 是否有对应的Delphi TWinControl实例??
      if Assigned(Instance) then
      begin
        PropData := _GetPropData(Instance);
        Assert(not PropData.IsContainer);
        PropData.ControlData.Recreating := False; //避免子窗口销毁自身对象
        Instance.Parent := nil;
      end
    end;
  until False;

  // 不能在上面的遍历循环中进行,否则会导致"窗口链"中断,循环终止
  for I := Low(Result) to High(Result) do
  begin
    with Result[I] do
      if Instance = nil then
        SetParent(Handle, 0);
  end;
end;

procedure _SetChildren(AControl: TWinControl; const Children: TChildrenStuf);
var
  I: Integer;
begin
  for I := Low(Children) to High(Children) do
    with Children[I] do
    begin
      if Assigned(Instance) then
      begin
        Assert(not PropData.IsContainer);
        with PropData.ControlData do
        begin
          OldProc := Pointer(SetWindowLong(Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
          Recreating := False;
          _SetPropData(Instance, PropData);
          // 重新 Attach CWnd 对象
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
          NotifySys(NAS_ATTACH_CWND_OBJECT, Instance.Handle, Cardinal(CWndPtr));
        end
      end
      else
      begin
        SetParent(Handle, AControl.Handle);
      end;
    end;
end;}

type
  TTrackMouseEventTimer = class(TTimer)
  public
    FControl: TControl;
    procedure OnTimerHandler(Sender: TObject);
  end;

procedure TTrackMouseEventTimer.OnTimerHandler(Sender: TObject);
begin
  if not PtInRect(Bounds(FControl.LRDockWidth, FControl.Top, FControl.Width, FControl.Height), Mouse.CursorPos) then
  begin
    FControl.Perform(CM_MOUSELEAVE, 0, 0);
    Self.Free;
  end;
end;

procedure MyTrackMouseEvent(AControl: TControl);
var
  Timer: TTrackMouseEventTimer;
begin
  Timer := TTrackMouseEventTimer.Create(AControl);
  Timer.FControl := AControl;
  Timer.OnTimer := Timer.OnTimerHandler;
  Timer.OnTimerHandler(Timer);
  Timer.Interval := 100;
end;

procedure ELib_WinControlWndProc(control: TWinControl; var msg: TMessage; CallBaseWndProc: TCallWndProc; RealignOnMoveSize: Boolean);
var
  pData, pContainerData: PWndPropData;
  ParentWnd: HWND;
  ParentWndCtrl: TWinControl;
  Children: TChildrenStuf;
  Tme: Windows.TTrackMouseEvent;
  TrackOK: LongBool;
  Visible: boolean;
begin
  case msg.Msg of
    WM_MOUSEMOVE:
    begin
      CallBaseWndProc(msg);
      pData := _GetPropData(control);
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        if not MouseEntered then
        begin
          MouseEntered := True;
          control.Perform(CM_MOUSEENTER, 0, 0);
        end;
        if not MouseTracking then
        begin
          MouseTracking := True;
          Tme.cbSize := sizeof(Tme);
          Tme.hwndTrack := control.Handle;
          Tme.dwFlags := TME_LEAVE;
          TrackOK := Windows.TrackMouseEvent(Tme);
          Assert(TrackOK);
        end;
      end;
    end;
    WM_MOUSELEAVE:
    begin
      CallBaseWndProc(msg);
      control.Perform(CM_MOUSELEAVE, 0, 0);
      pData := _GetPropData(control);
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        MouseEntered := False;
        MouseTracking := False;
      end;
    end;
    WM_MOVE, WM_SIZE:
    begin
      CallBaseWndProc(msg);
      if RealignOnMoveSize then
      begin
        {TempAlign := Control.Align;
        Control.Align := alNone;
        Control.Align := TempAlign;}
      end;
    end;
    WU_INIT: begin
      CallBaseWndProc(msg);
      ParentWnd := GetParent(control.Handle);
      ParentWndCtrl := FindControl(ParentWnd);
      if not (control is TForm) then
      begin
        if ParentWndCtrl <> nil then
          control.Parent := ParentWndCtrl
        else
          control.ParentWindow := ParentWnd;
      end
    end;
    CM_RECREATEWND: begin
      pData := _GetPropData(control);
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        if HasContainer then
          Visible := IsWindowVisible(Container.Handle)
        else
          Visible := IsWindowVisible(control.Handle);

        Recreating := True;
        Children := _GetChildren(control);
        CallBaseWndProc(msg);
        _SetChildren(control, Children);
        // 已经重新创建完毕
        Recreating := False;
        // 为新创建的窗口设置 PropData
        _SetPropData(control, pData);
        // 如果有父窗口
        if HasContainer then
        begin
          pContainerData := _GetPropData(Container);
          // 设置父窗口的 Child
          pContainerData.ContainerData.Child := control; // ??
          OldProc := Pointer(SetWindowLong(Control.Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
        end
        else
        begin
          // 重新 Attach CWnd 对象
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
          NotifySys(NAS_ATTACH_CWND_OBJECT, control.Handle, Cardinal(CWndPtr));
        end;

        if HasContainer then
        begin
          ShowWindow(Container.Handle, IfThen(Visible, SW_SHOW, SW_HIDE));
          Container.Visible := Visible
        end
        else
        begin
          ShowWindow(Control.Handle, IfThen(Visible, SW_SHOW, SW_HIDE));
          Control.Visible := Visible;
        end
      end;
    end;
    WM_NCDESTROY: begin
      pData := _GetPropData(control);
      { 释放自身时递归回来 }
      if not Assigned(pData)then
      begin
        CallBaseWndProc(msg);
        exit;
      end;
      Assert(Assigned(pData), '没有调用 ELib_RegControl ??');
      Assert(pData.IsContainer = False);
      with pData.ControlData do
      begin
        { 重新创建时的销毁 }
        if Recreating then
        begin
          CallBaseWndProc(msg);
          exit;
        end;
        { 正常销毁 }
        CallBaseWndProc(msg);
        if HasContainer then
        begin
          pData := _GetPropData(Container);
          // 删除 CWnd 对象
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(pData.ContainerData.CWndPtr), 0);
          NotifySys(NAS_DELETE_CWND_OBJECT, Cardinal(pData.ContainerData.CWndPtr), 0);
          // 移除 PropData
          _RemovePropData(Container);
          _RemovePropData(control);
          // 释放自身
          control.Free();
        end
        else
        begin
          // 删除 CWnd 对象
          NotifySys(NAS_DETACH_CWND_OBJECT, Cardinal(CWndPtr), 0);
          NotifySys(NAS_DELETE_CWND_OBJECT, Cardinal(CWndPtr), 0);
          // 移除 PropData
          _RemovePropData(control);
          // 释放自身
          control.Free();
        end;
      end;
    end;
    else begin
      try
        CallBaseWndProc(msg);
      except
        on EAbstractError do
          assert(false, '"在事件中销毁窗口或控件"的情况下可能导致非法访问或EAbstractError错误');
      end;
    end;
  end;

end;

function ELib_RegControl(Control: TWinControl; AContainer: TContainer = nil; AFormID: Cardinal = 0; AUnitID: Cardinal = 0): HUNIT;
var
  Data: PWndPropData;
begin
  New(Data);
  Data.Control := control;
  if not Assigned(AContainer) then
  begin
    Data.IsContainer := False;
    with Data.ControlData do
    begin
      Recreating := False;
      MouseTracking := False;
      MouseEntered := False;
      HasContainer := False;
      CWndPtr := HUNIT(NotifySys(NAS_CREATE_CWND_OBJECT_FROM_HWND, Control.Handle, 0));
      OldProc := Pointer(SetWindowLong(Control.Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
      _SetPropData(control, Data);
      Result := CWndPtr;
    end;
  end
  else
  begin
    Assert(AFormID <> 0);
    Assert(AUnitID <> 0); // 如果指定了使用容器,那么这两个参数必须赋值
    control.Parent := AContainer;
    control.Align := alClient;
    //
    Data.IsContainer := True;
    with Data.ContainerData do
    begin
      Child := control;
      CWndPtr := HUNIT(NotifySys(NAS_CREATE_CWND_OBJECT_FROM_HWND, AContainer.Handle, 0));
      OldProc := Pointer(SetWindowLong(AContainer.Handle, GWL_WNDPROC, Integer(@ELib_ContainerNewProc)));
      _SetPropData(AContainer, Data);
      Painting := false;
      Result := CWndPtr;
    end;
    //
    New(Data);
    Data.Control := control;
    Data.IsContainer := False;
    with Data.ControlData do
    begin
      Recreating := False;
      MouseTracking := False;
      MouseEntered := False;
      HasContainer := True;
      Container := AContainer;
      FormID := AFormID;
      UnitID := AUnitID;
      OldProc := Pointer( SetWindowLong(Control.Handle, GWL_WNDPROC, Integer(@ELib_ChildNewProc)));
      _SetPropData(control, Data);
    end;
  end;
end;

function ELib_CreateControl(out UnitHandle: HUNIT; ControlClass: TWinControlClass;
  dwStyle, hParentWnd: Cardinal; x,y,cx,cy: Integer; ContainerClass: TContainerClass = nil; AUnitID: Cardinal = 0; AFormID: Cardinal = 0): TWinControl;
var
  T: TWinControl;
  C: TContainer;
begin
  if Assigned(ContainerClass) then
  begin
    C := ContainerClass.CreateParented(hParentWnd);
    Result := ControlClass.Create(C);
    Result.Visible := True;
    T := C;
  end
  else
  begin
    C := nil;
    Result := ControlClass.CreateParented(hParentWnd);
    T := Result;
  end;

  UnitHandle := ELib_RegControl(Result, C, AUnitID, AFormID);

  dwStyle := dwStyle or WS_CHILD or WS_CLIPSIBLINGS or Cardinal(GetWindowLong(Result.Handle, GWL_STYLE));
  SetWindowLong(Result.Handle, GWL_STYLE, dwStyle);
  with T do begin
    Left := x;
    Top := y;
    Width := cx;
    Height := cy;
    Visible := False;
    Enabled := (dwStyle and WS_DISABLED ) = 0;
  end;
end;

procedure ELib_SettingForFunctionalControl(control: TPanel; imageResourceID: Integer; fixMinSize: Boolean = true; fixMaxSize: Boolean = true);
var image: TImage;
begin
  //单线边框
  with control do begin
    BorderStyle := bsSingle;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Ctl3D := false;
    //限制最大最小尺寸为26*26
    with Constraints do begin
      if fixMinSize then begin
        MinWidth  := 26;
        MinHeight := 26;
      end;
      if fixMaxSize then begin
        MaxWidth  := 26;
        MaxHeight := 26;
      end;
    end;
  end;

  //居中放图片框
  image := TImage.Create(control);
  with image do begin
    Picture.Bitmap.LoadFromResourceID(HInstance, imageResourceID);
    Align := alClient;
    Center := true;
  end;
  control.InsertControl(image);
end;

function ELib_AllocHGlobal(Stream: TStream):HGLOBAL;
var
  ptr: Pointer;
  OldPos: Int64;
begin
  Result := GlobalAlloc(GMEM_MOVEABLE, Stream.Size);
  if Result = 0 then exit;
  ptr := GlobalLock(Result);
  if ptr = nil then
  begin
    GlobalFree(Result);
    Result := 0;
    exit;
  end;
  OldPos := Stream.Position;
  Stream.Position := 0;
  Stream.ReadBuffer(ptr^, Stream.Size);
  Stream.Position := OldPos;
end;

function ELib_BooleanToEBool(value: Boolean): EBool;
begin
  if value then
    Result := ETrue
  else
    Result := EFalse;
end;

function ELib_EBoolToBoolean(value: EBool): Boolean;
begin
  if value = ETrue then
    Result := true
  else
    Result := false;
end;

{ TAttachedROMemoryStream }

constructor TAttachedMemoryStream.Create(Ptr: Pointer; Size: Integer);
begin
  inherited Create();
  Self.SetPointer(Ptr, Size);
end;

function TAttachedMemoryStream.Write(const Buffer; Count: Integer): Longint;
var
  Ptr: Pointer;
begin
  Result := 0;
  if Count < 0 then exit;
  if Position + Count > Size then
    Count := Size - Position;
  Ptr := Memory;
  Move(Buffer, Ptr, Count);
  Result := Count;
end;

function ELib_CreateBitmap(data: Pointer; size: Cardinal): Graphics.TBitmap;
var
  Handle: HBITMAP;
begin
  Result := nil;
  Handle := NotifySys(NAS_GET_HBITMAP, Cardinal(Data), Size);
  if Handle = 0 then exit;
  Result := Graphics.TBitmap.Create();
  Result.Handle := Handle;
end;

function ELib_TileBitmap(var bitmap: Graphics.TBitmap; var DisplaySize: TSize): Boolean;
var
  NewBitmap: Graphics.TBitmap;
begin
  NewBitmap := ELib_CreateTitledBitmap(Bitmap, DisplaySize);
  Result := True;
  if Assigned(NewBitmap) then
    Bitmap.Assign(NewBitmap)
  else
    Result := False;
end;

function ELib_CreateTitledBitmap(const bitmap: Graphics.TBitmap; var DisplaySize: TSize): Graphics.TBitmap;
var
  X,Y: Integer;
begin
  Result := nil;
  if not Assigned(Bitmap) then exit;
  if (Bitmap.Width = 0) or (Bitmap.Height = 0) then exit;
  if (DisplaySize.cx <= Bitmap.Width) and (DisplaySize.cy <= Bitmap.Height) then exit;
  X :=0; Y := 0;
  Result := Graphics.TBitmap.Create();
  Result.Width := Bitmap.Width * Ceil(DisplaySize.cx / Bitmap.Width);
  Result.Height := Bitmap.Height * Ceil(DisplaySize.cy / Bitmap.Height);
  try
    while X < DisplaySize.cx  do
    begin
      while Y < DisplaySize.cy do
      begin
        Result.Canvas.Draw(X, Y, Bitmap);
        Inc(Y, Bitmap.Height);
      end;
      Y := 0;
      Inc(X, Bitmap.Width);
    end
  except
    FreeAndNil(Result);
    raise
  end;
end;

function ELib_ToEBackColor(color: TColor): Cardinal;
begin
  Result := Cardinal(color);
  if (Result <> clSystemColor) and (Result and clSystemColor <> 0) then
    Result := GetSysColor(Result and not clSystemColor);
  if Result = GetSysColor(COLOR_BTNFACE) then
    Result := CLR_DEFAULT;
end;

function ELib_FromEBackColor(color: Cardinal): TColor;
begin
  if Cardinal(color) = clSystemColor then
    result := TColor(GetSysColor(COLOR_BTNFACE))
  else
    result := TColor(color);
end;


function ELib_StreamReadInteger(Stream: TStream): Integer;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadSmallInt(Stream: TStream): Smallint;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadCardinal(Stream: TStream): Cardinal;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadDouble(Stream: TStream): Double;
begin
  Stream.Read(Result, sizeof(Result));
end;

function ELib_StreamReadString(Stream: TStream): String;
var
  LenWithZero: Integer;
  Ptr: PChar;
begin
  Result := '';
  LenWithZero := ELib_StreamReadInteger(Stream);
  if LenWithZero = 0 then exit;
  Ptr := GetMemory(LenWithZero);
  try
    Stream.Read(Ptr^, LenWithZero);
    Result := Ptr;
  finally
    FreeMemory(Ptr);
  end;
end;

function ELib_StreamReadStrings(Stream: TStream; var Strings: TStringList): Integer;
var
  StringsCount, I: Integer;
begin
  StringsCount := ELib_StreamReadInteger(Stream);
  for I:= 0 to StringsCount - 1 do
  begin
    Strings.Append(ELib_StreamReadString(Stream));
  end;
  Result := StringsCount;
end;

function ELib_StreamReadLogFont(Stream: TStream; var Font: LOGFONT): Boolean;
begin
  Result := Stream.Read(Font, sizeof(Font)) = sizeof(LOGFONT);
end;

function ELib_StreamWriteInteger(Stream: TStream; Value: Integer): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteSmallInt(Stream: TStream; Value: SmallInt): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteCardinal(Stream: TStream; Value: Cardinal): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteDouble(Stream: TStream; Value: Double): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;

function ELib_StreamWriteString(Stream: TStream; const Value: String): Boolean;
begin
  Result := False;
  if not ELib_StreamWriteInteger(Stream, Length(Value) + 1) then
    exit;
  if Stream.Write(PChar(Value)^, Length(Value) + 1) <> Length(Value) + 1 then
    exit;
  Result := True;
end;

function ELib_StreamWriteStrings(Stream: TStream; const Value: TStrings): Boolean;
var
  I: Integer;
begin
  Result := False;
  ELib_StreamWriteInteger(Stream,Value.Count);
  for I := 0 to Value.Count - 1 do
  begin
    if not ELib_StreamWriteString(Stream, Value[I]) then exit;
  end;
  Result := True;
end;

function ELib_StreamWriteFont(Stream: TStream; const Value: LogFont): Boolean;
begin
  Result := Stream.Write(Value, sizeof(Value)) = sizeof(Value);
end;


{ ELib_PropReader }


{ ELib_TPropReader }

constructor ELib_TPropReader.Create(DataAddress: Pointer; DataLength: Cardinal);
begin
  FDataAddress := DataAddress;
  FDataLength := DataLength;
  FPosition := 0;
end;

function ELib_TPropReader.Read(Buffer: Pointer; Count: Cardinal): Boolean;
var Source: Pointer;
begin
  Result := false;
  if (FDataLength - FPosition < Count) or
     (FDataAddress = nil) or (FDataLength = 0)
    then exit;

  Source := Pointer(Cardinal(FDataAddress) + FPosition);
  CopyMemory(Buffer, Source, Count);

  FPosition := FPosition + Count;
  Result := true;
end;

function ELib_TPropReader.ReadBool(): EBool;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadByte(): Byte;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadCardinal(): Cardinal;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadDouble(): Double;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadDWord(): DWORD;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadFont(): TLogFont;
begin
  Read(@result, sizeof(TLogFont));
end;

function ELib_TPropReader.ReadFont(out fontVar: TLogFont): Boolean;
begin
  Result := Read(@fontVar, sizeof(fontVar));
end;

function ELib_TPropReader.ReadInt(): Integer;
begin
  Read(@Result, sizeof(Result));
end;

function ELib_TPropReader.ReadString(): String;
var
  strlen: DWORD;
  strbuffer: array of Char;
begin
  Result := '';
  strlen := ReadDWord();
  if strlen <= 0 then exit;

  SetLength(strbuffer, strlen + 1); //the last is #0
  if Read(@strbuffer[0], strlen) = false then exit;

  Result := PChar(@strbuffer[0]);
end;

function ELib_TPropReader.ReadStrings(stringsVar: TStrings): Boolean;
var
  count,i: Integer;
begin
  Assert(stringsVar <> nil);
  Result := false;
  stringsVar.Clear;
  count := ReadInt();
  if count <= 0 then exit;
  for i := 1 to count do begin
    stringsVar.Add(ReadString());
  end;
  Result := true;
end;

function ELib_TPropReader.ReadMemoryStream(memoryVar: TMemoryStream): Boolean;
var size: Cardinal;
begin
  Assert(memoryVar <> nil);
  memoryVar.Clear;
  size := ReadCardinal();
  memoryVar.SetSize(size);
  Read(memoryVar.Memory, size);
  Result := true;
end;

{ ELib_TPropWriter }

constructor ELib_TPropWriter.Create;
begin
  inherited;
  FMemoryStream := TMemoryStream.Create;
end;

destructor ELib_TPropWriter.Destroy;
begin
  FMemoryStream.Free();
  inherited;
end;

function ELib_TPropWriter.Write(DataAddress: Pointer; Count: Cardinal): Boolean;
begin
  Result := true;
  if FMemoryStream.Write(DataAddress^, Count) <> Integer(Count) then
    Result := false;
end;

function ELib_TPropWriter.WriteBool(boolValue: EBool): Boolean;
begin
  Result := Write(@boolValue, sizeof(boolValue));
end;

function ELib_TPropWriter.WriteByte(byteValue: Byte): Boolean;
begin
  Result := Write(@byteValue, sizeof(byteValue));
end;

function ELib_TPropWriter.WriteDouble(doubleValue: Double): Boolean;
begin
  Result := Write(@doubleValue, sizeof(doubleValue));
end;

function ELib_TPropWriter.WriteDWord(dwordValue: DWORD): Boolean;
begin
  Result := Write(@dwordValue, sizeof(dwordValue));
end;

function ELib_TPropWriter.WriteFont(fontValue: LOGFONT): Boolean;
begin
  Result := Write(@fontValue, sizeof(fontValue));
end;

function ELib_TPropWriter.WriteInt(intValue: Integer): Boolean;
begin
  Result := Write(@intValue, sizeof(intValue));
end;

function ELib_TPropWriter.WriteCardinal(cardinalValue: Cardinal): Boolean;
begin
  Result := Write(@cardinalValue, sizeof(cardinalValue));
end;

function ELib_TPropWriter.WriteString(stringValue: String): Boolean;
var
  strlen: Cardinal;
begin
  Result := false;
  strlen := Length(stringValue);
  if WriteDWord(strlen) = false then exit;
  if strlen = 0 then exit;

  Result := Write(PChar(stringValue), strlen);
end;

function ELib_TPropWriter.WriteStrings(stringsValue: TStrings): Boolean;
var i: Integer;
begin
  if stringsValue = nil then begin
    WriteInt(0); Result := true; exit;
  end;

  WriteInt(stringsValue.Count);
  for i:= 0 to stringsValue.Count - 1 do begin
    WriteString(stringsValue.Strings[i]);
  end;
  Result := true;
end;

function ELib_TPropWriter.WriteMemoryStream(memoryValue: TMemoryStream): Boolean;
begin
  if memoryValue = nil then begin
    WriteCardinal(0); Result := true; exit;
  end;

  WriteCardinal(memoryValue.Size);
  Write(memoryValue.Memory, memoryValue.Size);
  Result := true;
end;


function ELib_TPropWriter.AllocHGlobal: HGLOBAL;
begin
  Result := ELib_AllocHGlobal(FMemoryStream);
end;

function ELib_TPropWriter.GetDataAddress: Pointer;
begin
  Result := FMemoryStream.Memory;
end;

function ELib_TPropWriter.GetDataLength: Cardinal;
begin
  Result := Cardinal(FMemoryStream.Size);
end;

function ELib_CreateImageList(Data: Pointer; AOwner: TComponent; out TransparentColor: TColor): TImageList; overload;
var
  Stream: TAttachedMemoryStream;
  ComStream: TStreamAdapter;
const
  Sig: Cardinal = $4C54494D;//MakeLong(MakeWord(Ord('M'), Ord('I')), MakeWord(Ord('T'), Ord('L')));
begin
  Result := nil;
  Stream := TAttachedMemoryStream.Create(Data, MaxInt);
  ComStream := TStreamAdapter.Create(Stream, soOwned);
  try
    if ELib_StreamReadCardinal(Stream) <> Sig then
      raise EExternalException.Create('无效的易语言图片组数据');
    TransparentColor := ELib_StreamReadInteger(Stream);
    Result := TImageList.Create(AOwner);
    Result.Handle := ImageList_Read(ComStream);
  finally
    ComStream.Free;
  end;
end;

function ELib_CreateImageList(Data: Pointer; AOwner: TComponent): TImageList; overload;
var
  Clr: TColor;
begin
  Result := ELib_CreateImageList(Data, AOwner, Clr);
end;

procedure ELib_DefineAlignProperty(datatypeIndex: Integer);
begin
  DefineProperty(datatypeIndex, '对齐', 'Align', '与 VCL 中 TWinControl.Align 功能一致', UD_PICK_INT, 0,
      '无'#0'上'#0'下'#0'左'#0'右'#0'平铺'#0'自定义'#0);
end;


const _EAlignsIndexMap: array[0..6] of TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient, alCustom);

//see ELib_DefineAlignProperty()
function ELib_GetAlignFromIndex(index: Integer): TAlign;
begin
  if (index < 0) or (index > 6) then begin
    Result := alNone;
    exit;
  end;
  Result := _EAlignsIndexMap[index];
end;

procedure ELib_SetAlignByIndex(control: TWinControl; ePropIndex: Integer);
begin
  control.Align := alNone;
  control.Align := ELib_GetAlignFromIndex(ePropIndex);
end;

function ELib_GetAlignIndex(align: TAlign): Integer;
begin
  case align of
    alNone: Result := 0;
    alTop:  Result := 1;
    alBottom: Result := 2;
    alLeft: Result := 3;
    alRight: Result := 4;
    alClient: Result := 5;
    alCustom: Result := 6;
    else Result := 0;
  end;
end;

procedure ELib_DefineBorderProperty(datatypeIndex: Integer);
begin
  DefineProperty(datatypeIndex, '边框', 'Border', nil, UD_PICK_INT, 0,
      '无边框'#0'凹入式'#0'凸出式'#0'浅凹入式'#0'镜框式'#0'单线边框式'#0'自定义式'#0);
end;

procedure ELib_SetBorderByIndex(panel: TPanel; ePropIndex: Integer);
begin
  with panel do begin
    case ePropIndex of
      0: begin //无边框
        BorderStyle := bsNone;
        BevelInner := bvNone;
        BevelOuter := bvNone;
        BevelWidth := 1;
      end;
      1: begin //凹入式
        BorderStyle := bsNone;
        BevelInner := bvLowered;
        BevelOuter := bvLowered;
        BevelWidth := 1;
      end;
      2: begin //凸出式
        BorderStyle := bsNone;
        BevelInner := bvNone;
        BevelOuter := bvRaised;
        BevelWidth := 1;
      end;
      3: begin //浅凹入式
        BorderStyle := bsNone;
        BevelInner := bvLowered;
        BevelOuter := bvNone;
        BevelWidth := 1;
      end;
      4: begin //镜框式
        BorderStyle := bsNone;
        BevelInner := bvLowered;
        BevelOuter := bvRaised;
        BevelWidth := 2;
      end;
      5: begin //单线边框式
        BorderStyle := bsSingle;
        BevelInner := bvNone;
        BevelOuter := bvNone;
        BevelWidth := 1;
      end;
      6: begin //自定义式
      end;
    end; //case
  end; //with
end;

function  ELib_GetBorderIndex(panel: TPanel): Integer;
begin
  with panel do begin
    if
      (BorderStyle = bsNone) and
      (BevelInner = bvNone) and
      (BevelOuter = bvNone) and
      (BevelWidth = 1) then
        Result := 0 //无边框
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvLowered) and
      (BevelOuter = bvLowered) and
      (BevelWidth = 1) then
        Result := 1 //凹入式
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvNone) and
      (BevelOuter = bvRaised) and
      (BevelWidth = 1) then
        Result := 2 //凸出式
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvLowered) and
      (BevelOuter = bvNone) and
      (BevelWidth = 1) then
        Result := 3 //浅凹入式
    else if
      (BorderStyle = bsNone) and
      (BevelInner = bvLowered) and
      (BevelOuter = bvRaised) and
      (BevelWidth = 2) then
        Result := 4 //镜框式
    else if
      (BorderStyle = bsSingle) and
      (BevelInner = bvNone) and
      (BevelOuter = bvNone) and
      (BevelWidth = 1) then
        Result := 5 //单线边框式
    else
      Result := 6; //自定义式
  end;
end;

//set TLogFont to TFont
procedure ELib_SetFont(font: TFont; const LogFont: TLogFont);
var
	Style: TFontStyles;
begin
	with LogFont do
	begin
		font.Name := lfFaceName;
		font.Height := lfHeight;
		Style := [];
		if lfWeight > FW_REGULAR then Include(Style, fsBold);
		if lfItalic <> 0 then Include(Style, fsItalic);
		if lfUnderline <> 0 then Include(Style, fsUnderline);
		if lfStrikeOut <> 0 then Include(Style, fsStrikeOut);
		font.Style := Style;
	end;
end;

procedure ELib_SetDefaultFont(font: TFont);
begin
		font.Name := '宋体';
		font.Height := -12;
    font.Style := [];
end;

function ELib_GetLogFont(const font: TFont): TLogFont;
var logfont: TLogFont;
begin
  GetObject(font.Handle, sizeof(logfont), @logfont);
  result := logfont;
end;

//宋体小五号
procedure ELib_SetFont_Songti9(font: TFont);
begin
  with font do begin
    Name := '宋体';
    Height := -12;
    Style := [];
  end;
end;

function ELib_TStringsToEArray(const Strings: TStrings): Pointer;
var
  Memory: ELib_TPropWriter;
  I: Integer;
begin
  Memory := ELib_TPropWriter.Create;
  try
    Memory.WriteInt(1);
    Memory.WriteInt(0);
    if Strings.Count > 0 then
    begin
      for I := 0 to Strings.Count - 1 do
      begin
        Memory.WriteInt(Integer(CloneTextData(PChar(Strings[I]))));
        PInteger(Integer(Memory.GetDataAddress) + sizeof(Integer))^ := I + 1;
      end;
    end;
    result := MMalloc(Memory.GetDataLength);
    Move(Memory.GetDataAddress^, result^, Memory.GetDataLength);
  finally
    Memory.Free;
  end;
end;

{ TVclPanelContainer }

constructor TVclPanelContainer.Create(AOwner: TComponent);
begin
  inherited;
  // 设置 Container 无边框
  BorderStyle := bsNone;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Ctl3D := False;
end;

end.

