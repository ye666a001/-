library myfne;

uses
  e,
  SysUtils,
  Classes,
  Unit1 in 'Unit1.pas',
  mypanel in 'mypanel.pas';

{$R *.res}
{$E fne} //指定编译出的文件名后缀为"fne"


//易语言支持库要求的导出函数 GetNewInf()
function GetNewInf() : pLIB_INFO; stdcall; export;
begin
  result := GetLibInfo();
end;

//函数导出表(exports)
exports
  GetNewInf;


begin

  DefineLib
  (
      'myfne', '{5CAFDDB6-22E7-4B27-823A-A80A3919189F}', //szName, szGuid
      'Delphi开发的一个简单的易语言支持库，主要用于演示。', //szExplain
      1, 0, 1, __GBK_LANG_VER, //nMajorVersion, nMinorVersion, nBuildNumber, nLanguage
      0, //dwState
      '大连大有吴涛易语言软件开发有限公司', 'www.dywt.com.cn', '', //szAuthor,szHomePage,szOther
      2, '0000分类1'#0'0000分类2'#0, //nCategoryCount, szzCategory
      nil, nil, //pfnRunAddInFn, szzAddInFnInfo
      nil, //pfnNotifyLib (can be nil, default to DefaultProcessNotifyLib)
      nil, //szzDependFiles
      nil  //pfnFreeLibData
  );

  DefineConstsCommandsAndDatatype1;

  DefineMyPanel;

end.

