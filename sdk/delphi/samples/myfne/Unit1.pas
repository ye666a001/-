unit Unit1;

interface
uses e;

procedure DefineConstsCommandsAndDatatype1();


implementation

const Command1_Args: array[0..1] of ARG_INFO = 
  (
    (m_szName:'num1'; m_szExplain:''; m_shtBitmapIndex:0; m_shtBitmapCount:0; m_dtDataType:SDT_INT; m_nDefault:0; m_dwState:0),
    (m_szName:'num2'; m_szExplain:''; m_shtBitmapIndex:0; m_shtBitmapCount:0; m_dtDataType:SDT_INT; m_nDefault:0; m_dwState:0)
  );
procedure Command1(pRetData: pMDATA_INF; nArgCount: Integer; pArgInf: pMDATA_INF); cdecl;
begin  pRetData.m_Value.m_int := ArgArray(pArgInf)[0].m_Value.m_int + ArgArray(pArgInf)[1].m_Value.m_int;end;

procedure Command2(pRetData: pMDATA_INF; nArgCount: Integer; pArgInf: pMDATA_INF); cdecl;
begin  pRetData.m_Value.m_bool := ETrue;end;


procedure DefineEnum1();
var datatypeIndex: Integer;
begin
  datatypeIndex := DefineEnumDatatype('枚举一', 'Enum1', '关于枚举一的说明', 0);

  DefineEnumElement(datatypeIndex, 'A', 'constA', '', 1001, 0);
  DefineEnumElement(datatypeIndex, 'B', 'constB', '', 1002, 0);
  DefineEnumElement(datatypeIndex, 'C', 'constC', '', 1003, 0);
end;

procedure Datatype1_m1 (pRetData: pMDATA_INF; nArgCount: Integer; pArgInf: pMDATA_INF); cdecl;
begin  pRetData.m_Value.m_int := 1999;end;
//normal datatype
procedure DefineDatatype1();
var datatypeIndex : integer;
begin
  datatypeIndex := DefineDatatype('普通类型一', 'Datatype1', 'about Datatype1', 0);

  DefineMethod(datatypeIndex, Datatype1_m1, [], '方法一', 'method1', '', SDT_INT, 0, LVL_SIMPLE);
  DefineMethod(datatypeIndex, Datatype1_m1, [], '方法二', 'method2', '', SDT_INT, 0, LVL_SIMPLE);

  DefineElement(datatypeIndex, '整数成员', 'element1', '', SDT_INT, nil, 0, 0);
  DefineElement(datatypeIndex, '文本成员', 'element2', '', SDT_TEXT, nil, 0, 0);
end;

procedure DefineConstsCommandsAndDatatype1();
begin

  DefineConst('常量一', 'const1', '这个常量一的说明，文本常量', CT_TEXT, 0, '常量一的值(文本)');
  DefineConst('常量二', 'const2', '这个常量二的说明，数值常量', CT_NUM, 1999, nil);
  DefineConst('常量三', 'const3', '这个常量二的说明，逻辑常量', CT_BOOL, 1, nil);

  DefineCommand(Command1, Command1_Args, '命令一', 'command1', '命令一的说明，返回两个参数的和', SDT_INT, 0, LVL_SIMPLE, 1);
  DefineCommand(Command2, [], '命令二', 'command2', '命令一的说明，直接返回真', SDT_BOOL, 0, LVL_SIMPLE, 1);

  DefineEnum1();
  DefineDatatype1();
end;

end.
