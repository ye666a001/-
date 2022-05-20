
/*
     本工程演示了如何在支持库中加入授权机制:

     授权机制的技术原理如下:
     同一易语言支持库具有以下三类不同后缀的文件:
       ".fne": 带有编辑接口信息的动态支持库文件
       ".fnr": 不带编辑接口信息的动态支持库文件
       ".lib": 支持库的静态链接库
     对于易语言系统IDE来说,支持库的".fne"文件是必需的,因为只有其中才包括可以被ide访问的支持库对外接口信息,
   只有有了它该支持库才能在易语言开发环境中被用户使用,而".fnr"仅用作在用户编译好的程序运行时使用,".lib"仅
   用作在编译时静态链接用户程序使用,它们均不包括编辑接口信息.
     因此,授权机制被设置为: 由支持库自己在"GetNewInf"函数中检查用户是否获得了授权,如果获得了,则返回正常的
   编辑接口信息,支持库可以正常在IDE中使用,否则返回一个空白的编辑接口信息,此时IDE将无法使用此支持库.
     仔细查看本文件中所有使用了"__E_STATIC_LIB"宏(用作编译静态库版本)和"__COMPILE_FNR"宏(用作编译fnr动态
   库版本)的代码部分可得知: 编译静态库时所有的编辑接口信息均不需要,编译fnr版本时,仅仅需要简单的LIB_DATA_TYPE_INFO
   类型信息数组(其中的绝大部分编辑信息譬如事件/属性定义信息均被跳过),从而保证了用户无法通过lib/fnr倒推出fne.
     本例程授权检查处理较为简单,更为安全的做法为譬如直接将编辑接口信息数据放置在fne文件外部且不附带在支持
   库安装包中,用户购买授权后再通过网络把基于该用户计算机硬件代码加密后的编辑接口信息发送给用户实时解密使用.
   此时由于对外公开发布的支持库安装包中有实质数据缺失,破解将无从下手.但是支持库安装包中有支持库的fnr版本,
   用户可以通过执行预先编译好的exe文件来查看支持库效果,以便其判断是否购买.
     注意: 具有支持库授权机制的易语言系统最低版本是5.4,所以必须设置LIB_INFO中的对应系统要求成员.
*/

/*
    版权声明：
    本文件版权为易语言作者吴涛所有，仅授权给第三方用作开发易语言支持库，禁止用于其他任何场合。
*/

#include "stdafx.h"
#include "resource.h"
#include "HtmlView.h"
#include "lib2.h"
#include "lang.h"
#include "hhctrl.h"
#include "fnshare.h"

#ifdef _DEBUG
// #define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CHtmlViewApp

BEGIN_MESSAGE_MAP(CHtmlViewApp, CWinApp)
	//{{AFX_MSG_MAP(CHtmlViewApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CHtmlViewApp construction

CHtmlViewApp::CHtmlViewApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CHtmlViewApp object

#ifndef __E_STATIC_LIB

CHtmlViewApp theApp;

#endif

/////////////////////////////////////////////////////////////////////////////

INT g_nLastNotifyResult;
PFN_NOTIFY_SYS g_fnNotifySys = NULL;

INT WINAPI NotifySys (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
	ASSERT (g_fnNotifySys != NULL);
	if (g_fnNotifySys != NULL)
		return g_nLastNotifyResult = g_fnNotifySys (nMsg, dwParam1, dwParam2);
	else
		return g_nLastNotifyResult = 0;
}

#include "fnshare.cpp"

/////////////////////////////////////////////////////////////////////////////


#ifndef __E_STATIC_LIB

extern UNIT_PROPERTY g_HtmlViewerProperty [];
extern INT g_HtmlViewerPropertyCount;

#ifndef __COMPILE_FNR  // fnr版本不需要此信息

INT s_nHtmlViewerElementCmdIndex [] =
{
	0, 1, 2, 3, 4
};

extern EVENT_INFO g_HtmlViewerEvent [];
extern INT g_HtmlViewerEventCount;

#endif

// 下面的定义顺序绝对不可改动。
static LIB_DATA_TYPE_INFO s_DataType[] = 
{
	{
/*m_szName*/					_WT("超文本浏览框"),
/*m_szEgName*/					_WT("HtmlViewer"),
/*m_szExplain*/					_WT("提供对HTML页面的浏览支持"),
/*m_nCmdCount*/					_CMDS_COUNT (sizeof (s_nHtmlViewerElementCmdIndex) / sizeof (s_nHtmlViewerElementCmdIndex [0])),
/*m_pnCmdsIndex*/				_CMDS_PTR (s_nHtmlViewerElementCmdIndex),
/*m_dwState*/					_DT_OS (__OS_WIN) | LDT_WIN_UNIT,
/*m_dwUnitBmpID*/				IDB_HTMLVIEWER_BITMAP,
/*m_nEventCount*/				_EVENTS_COUNT (g_HtmlViewerEventCount),
/*m_pEventBegin*/				_EVENTS_PTR (g_HtmlViewerEvent),
/*m_nPropertyCount*/			g_HtmlViewerPropertyCount,
/*m_pPropertyBegin*/			g_HtmlViewerProperty,
/*m_pfnGetInterface*/			htmlview_GetInterface_HtmlViewer,
/*m_nElementCount*/				_ELEMENTS_COUNT (0),
/*m_pElementBegin*/				_ELEMENTS_PTR (NULL),
	},
};

///////////////////////////////////

#ifndef __COMPILE_FNR  // fnr版本不需要此信息

//*** 命令定义信息:

ARG_INFO s_ArgInfo[] =
{
//****** 执行命令	**	0
	{
/*name*/	_WT("欲执行的命令"),
/*explain*/	_WT("指定欲执行命令的类型，为以下常量值之一： "
			"0: #前进； "
			"1: #后退； "
			"2: #到首页； "
			"3: #到搜索页； "
			"4: #刷新； "
			"5: #停止； "
			"6: #另存为； "
			"7: #打印； "
			"8: #打印预览； "
			"9: #页面设置"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_INT,
/*default*/	0,
/*state*/	NULL,
	},
//****** 跳转	**	1
	{
/*name*/	_WT("欲打开文档地址"),
/*explain*/	_WT("指定文档位于互联网或本机上的地址"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_TEXT,
/*default*/	0,
/*state*/	NULL,
	}, {
/*name*/	_WT("CHM文件名称"),
/*explain*/	_WT("如果欲打开文档处于 .CHM 文件内，本参数提供该 CHM 文件的名称。"
		"如果本参数被省略，默认值为空文本"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_TEXT,
/*default*/	0,
/*state*/	AS_DEFAULT_VALUE_IS_EMPTY,
	}, {
/*name*/	_WT("目标窗口名称"),
/*explain*/	_WT("指定文档是否在单独窗口中打开，相同的名称指定相同的窗口。"
		"如果欲在浏览框内部打开，提供空文本参数值即可。"
		"如果本参数被省略，默认值为空文本"),
/*bmp inx*/	0,
/*bmp num*/	0,
/*type*/	SDT_TEXT,
/*default*/	0,
/*state*/	AS_DEFAULT_VALUE_IS_EMPTY,
	}
};

static CMD_INFO s_CmdInfo[] =
{
/////////////////////////////////// 超文本浏览框

//****** 执行命令（成员）	** 0
	{
/*ccname*/	_WT("执行命令"),
/*egname*/	_WT("Execute"),
/*explain*/	_WT("执行指定的浏览器命令"),
/*category*/-1,
/*state*/	_CMD_OS (__OS_WIN),
/*ret*/		_SDT_NULL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/1,
/*arg lp*/	s_ArgInfo,
	},
//****** 跳转（成员）	** 1
	{
/*ccname*/	_WT("跳转"),
/*egname*/	_WT("Navigate"),
/*explain*/	_WT("打开互联网或者本机上指定位置处的文档"),
/*category*/-1,
/*state*/	_CMD_OS (__OS_WIN),
/*ret*/		_SDT_NULL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/3,
/*arg lp*/	&s_ArgInfo [1],
	},
//****** 取文档类型（成员）	** 2
	{
/*ccname*/	_WT("取文档类型"),
/*egname*/	_WT("GetType"),
/*explain*/	_WT("返回超文本浏览框中现行文档的类型文本"),
/*category*/-1,
/*state*/	_CMD_OS (__OS_WIN),
/*ret*/		SDT_TEXT,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/0,
/*arg lp*/	NULL,
	},
//****** 是否正在下载（成员）	** 3
	{
/*ccname*/	_WT("是否正在下载"),
/*egname*/	_WT("GetBusy"),
/*explain*/	_WT("如果当前正在下载文档或执行页面跳转，返回真，否则返回假"),
/*category*/-1,
/*state*/	_CMD_OS (__OS_WIN),
/*ret*/		SDT_BOOL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/0,
/*arg lp*/	NULL,
	},
//****** 是否就绪（成员）	** 4
	{
/*ccname*/	_WT("是否就绪"),
/*egname*/	_WT("IsReady"),
/*explain*/	_WT("如果浏览框当前已经准备就绪，返回真，否则返回假"),
/*category*/-1,
/*state*/	_CMD_OS (__OS_WIN),
/*ret*/		SDT_BOOL,
/*reserved*/0,
/*level*/	LVL_SIMPLE,
/*bmp inx*/	0,
/*bmp num*/	0,
/*ArgCount*/0,
/*arg lp*/	NULL,
	},

};

#endif

#endif

///////////////////////////////////

extern "C"
void htmlview_fnExecute (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	CHHCtrl* pUnit = (CHHCtrl*)GetWndPtr (pArgInf);

	switch (pArgInf [1].m_int)
	{
	case 0:
		pUnit->GoForward ();
		break;
	case 1:
		pUnit->GoBack ();
		break;
	case 2:
		pUnit->GoHome ();
		break;
	case 3:
		pUnit->GoSearch ();
		break;
	case 4:
		pUnit->Refresh ();
		break;
	case 5:
		pUnit->Stop ();
		break;
	case 6:
		pUnit->RunCmd (OLECMDID_SAVEAS);
		break;
	case 7:
		pUnit->RunCmd (OLECMDID_PRINT);
		break;
	case 8:
		pUnit->RunCmd (OLECMDID_PRINTPREVIEW);
		break;
	case 9:
		pUnit->RunCmd (OLECMDID_PAGESETUP);
		break;
	}
}

extern "C"
void htmlview_fnNavigate (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	CHHCtrl* pUnit = (CHHCtrl*)GetWndPtr (pArgInf);

	LPCTSTR szDocument = (LPCTSTR)pArgInf [1].m_pText;
	LPTSTR szChmFileName = pArgInf [2].m_dtDataType == _SDT_NULL ? NULL :
			(LPTSTR)pArgInf [2].m_pText;
	LPTSTR szWinName = pArgInf [3].m_dtDataType == _SDT_NULL ? NULL :
			(LPTSTR)pArgInf [3].m_pText;

	if (szChmFileName == NULL || *szChmFileName == '\0')
		pUnit->Navigate (szDocument, 0, szWinName);
	else
		pUnit->NavigateChm (szChmFileName, szDocument, szWinName);
}

extern "C"
void htmlview_fnGetType (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
    pRetData->m_pText = CloneTextData ((LPTSTR)(LPCTSTR)
            ((CHHCtrl*)GetWndPtr (pArgInf))->GetType ());
}

extern "C"
void htmlview_fnGetBusy (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	pRetData->m_bool = ((CHHCtrl*)GetWndPtr (pArgInf))->GetBusy ();
}

extern "C"
void htmlview_fnIsReady (PMDATA_INF pRetData, INT nArgCount, PMDATA_INF pArgInf)
{
	pRetData->m_bool = ((CHHCtrl*)GetWndPtr (pArgInf))->GetReadyState () ==
			READYSTATE_COMPLETE;
}

//*** 命令实现信息:
#ifndef __E_STATIC_LIB

PFN_EXECUTE_CMD s_RunFunc [] =	// 索引应与s_CmdInfo中的命令定义顺序对应
{
	htmlview_fnExecute,
	htmlview_fnNavigate,
	htmlview_fnGetType,
	htmlview_fnGetBusy,
	htmlview_fnIsReady
};

static const char* const g_CmdNames[] = 
{
	"htmlview_fnExecute",
	"htmlview_fnNavigate",
	"htmlview_fnGetType",
	"htmlview_fnGetBusy",
	"htmlview_fnIsReady",
};

///////////////////////////////////

#ifndef __COMPILE_FNR  // fnr版本不需要此信息

//*** 常量定义信息:

// !!! 注意常量值由于已经运用到程序中，所以绝对不能改动。
// 顺序及值不能改动

LIB_CONST_INFO s_ConstInfo [] =
{
	{	_WT("前进"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	0,	},
	{	_WT("后退"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	1,	},
	{	_WT("到首页"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	2,	},
	{	_WT("到搜索页"),NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	3,	},
	{	_WT("刷新"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	4,	},
	{	_WT("停止"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	5,	},
	{	_WT("另存为"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	6,	},
	{	_WT("打印"),	NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	7,	},
	{	_WT("打印预览"),NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	8,	},
	{	_WT("页面设置"),NULL,	NULL,	LVL_SIMPLE,	CT_NUM,	NULL,	9,	},

};

#endif

#endif

/////////////////////////////////////////////////////////////////////////////

INT WINAPI ProcessNotifyLib (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
	INT nRet = NR_OK;
	switch (nMsg)
	{
	case NL_SYS_NOTIFY_FUNCTION:
		g_fnNotifySys = (PFN_NOTIFY_SYS)dwParam1;
		break;
	default:
		nRet = NR_ERR;
		break;
	}

	return nRet;
}

EXTERN_C INT WINAPI htmlview_ProcessNotifyLib (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
#ifndef __E_STATIC_LIB
	if(nMsg == NL_GET_CMD_FUNC_NAMES)
		return (INT) g_CmdNames;
	else if(nMsg == NL_GET_NOTIFY_LIB_FUNC_NAME)
		return (INT) "htmlview_ProcessNotifyLib";
	else if(nMsg == NL_GET_DEPENDENT_LIBS)
		return NULL;
#endif
	return ProcessNotifyLib(nMsg, dwParam1, dwParam2);
}

#ifndef __E_STATIC_LIB

/////////////////////////////////////////////////////////////////////////////

//////////// 库定义开始
// 定义一个正常的库信息,用作在已经被授权时使用

static LIB_INFO2 s_LibInfo2 =
{
    {
        /*Lib Format Ver*/		LIB_FORMAT_VER,		// 保留未用。

        // 本支持库的GUID串：
        // guid: {5014D8FA-6DCA-40b6-8FA6-26D8183666EB}
        #define		LI_LIB_GUID_STR	"5014D8FA6DCA40b68FA626D8183666EB"
        /*guid str*/			_T (LI_LIB_GUID_STR),

        /*m_nMajorVersion*/		2,
        /*m_nMinorVersion*/		0,

        //!!!	注意：凡是增删或更改了命令、窗口组件、数据类型、帮助信息等，只要对帮助
        //!!! 文件生成会产生影响，都必须升级版本号，而不能只修改BuildNumber。
        //!!!   改动后尽量升级版本号!!!
        /*m_nBuildNumber*/		51,	// 1: 2.5;  2: 2.5补遗版; 3: 3.0版;  50: 3.39; 51: 4.11
		        // 构建版本号，无需对此版本号作任何处理。
		        //   本版本号仅用作区分相同正式版本号的库（譬如仅仅修改了几个 BUG）。
		        // 任何公布过给用户使用的版本其此版本号都应该不一样。
		        //   赋值时应该顺序递增。

        // 支持授权机制的易语言系统最低版本是5.4版本,此处必须提出要求.
        /*m_nRqSysMajorVer*/		5,
        /*m_nRqSysMinorVer*/		4,

        /*m_nRqSysKrnlLibMajorVer*/	3,
        /*m_nRqSysKrnlLibMinorVer*/	0,

        /*name*/				_T ("需要授权的超文本浏览框支持库"),
        /*lang*/				__GBK_LANG_VER,
        /*explain*/				_WT("本支持库实现了对超文本浏览框窗口组件的支持,正常使用本支持库需要授权."),
        #ifndef __COMPILE_FNR
        /*dwState*/				_LIB_OS (__OS_WIN) | LBS_LIB_INFO2,
        #else
        /*dwState*/				LBS_NO_EDIT_INFO | _LIB_OS (__OS_WIN) | LBS_LIB_INFO2,
        #endif

        /*szAuthor*/	_WT("大有吴涛易语言软件公司"),
        /*szZipCode*/	_WT("116001"),
        /*szAddress*/	_WT("辽宁省大连市中山区人民路55号亚太国际金融中心"),
        /*szPhoto*/		_WT("+86(0411)39895831"),
        /*szFax*/		_WT("+86(0411)39895834"),
        /*szEmail*/		_WT("service@dywt.com.cn"),
        /*szHomePage*/	_WT("http://www.eyuyan.com"),
        /*szOther*/		_WT("祝您一帆风顺，心想事成！"),

        // 此信息fne和fnr版本均需要,不过fnr版本只需要其中的必要信息.
        /*type count*/			sizeof (s_DataType) / sizeof (s_DataType[0]),
        /*PLIB_DATA_TYPE_INFO*/	s_DataType,

        #ifndef __COMPILE_FNR
            /*CategoryCount*/   0,	// 加了类别需加此值。
            /*category*/        _WT("\0"	// 类别说明表每项为一字符串,前四位数字表示图象索引号(从1开始,0无).
				                    "\0"),
            /*CmdCount*/        sizeof (s_CmdInfo) / sizeof (s_CmdInfo [0]),
            /*BeginCmd*/        s_CmdInfo,
        #else
            // fnr版本不需要以下信息
            /*CategoryCount*/   0,
            /*category*/        NULL,
            /*CmdCount*/        0,
            /*BeginCmd*/        NULL,
        #endif

        /*m_pCmdsFunc*/             s_RunFunc,
        /*pfnRunAddInFn*/			NULL,
        /*szzAddInFnInfo*/			NULL,

        /*pfnNotify*/				htmlview_ProcessNotifyLib,

        /*pfnRunSuperTemplate*/		NULL,
        /*szzSuperTemplateInfo*/	NULL,

        #ifndef __COMPILE_FNR
            /*nLibConstCount*/			sizeof (s_ConstInfo) / sizeof (s_ConstInfo [0]),
            /*pLibConst*/				s_ConstInfo,
        #else
            // fnr版本不需要以下信息
            /*nLibConstCount*/			0,
            /*pLibConst*/				NULL,
        #endif

        /*szzDependFiles*/			NULL,
    },

    _T(""),
    _T("本支持库的授权方法为在支持库同目录内放置一个名为\"HtmlView.elic\"的文本文件,其中的内容为被授权用户的名称。"),
    _T("http://www.eyuyan.com"),
    _T(""),

};

#ifndef __COMPILE_FNR

static INT WINAPI htmlview_EmptyProcessNotifyLib (INT nMsg, DWORD dwParam1, DWORD dwParam2)
{
	return NR_ERR;
}

// 定义一个空的库信息,用作未授权时使用. 除开接口信息外的成员值必须与正常值一样.
static LIB_INFO2 s_LibInfo2Empty =
{
    {
        /*Lib Format Ver*/		LIB_FORMAT_VER,		// 保留未用。

        // 本支持库的GUID串：
        // guid: {5014D8FA-6DCA-40b6-8FA6-26D8183666EB}
        #define		LI_LIB_GUID_STR	"5014D8FA6DCA40b68FA626D8183666EB"
        /*guid str*/			_T (LI_LIB_GUID_STR),

        /*m_nMajorVersion*/		2,
        /*m_nMinorVersion*/		0,

        //!!!	注意：凡是增删或更改了命令、窗口组件、数据类型、帮助信息等，只要对帮助
        //!!! 文件生成会产生影响，都必须升级版本号，而不能只修改BuildNumber。
        //!!!   改动后尽量升级版本号!!!
        /*m_nBuildNumber*/		51,	// 1: 2.5;  2: 2.5补遗版; 3: 3.0版;  50: 3.39; 51: 4.11
		        // 构建版本号，无需对此版本号作任何处理。
		        //   本版本号仅用作区分相同正式版本号的库（譬如仅仅修改了几个 BUG）。
		        // 任何公布过给用户使用的版本其此版本号都应该不一样。
		        //   赋值时应该顺序递增。

        // 支持授权机制的易语言系统最低版本是5.4版本,此处必须提出要求.
        /*m_nRqSysMajorVer*/		5,
        /*m_nRqSysMinorVer*/		4,

        /*m_nRqSysKrnlLibMajorVer*/	3,
        /*m_nRqSysKrnlLibMinorVer*/	0,

        /*name*/				_T ("需要授权的超文本浏览框支持库"),
        /*lang*/				__GBK_LANG_VER,
        /*explain*/				_WT("本支持库实现了对超文本浏览框窗口组件的支持,正常使用本支持库需要授权."),
        #ifndef __COMPILE_FNR
        /*dwState*/				_LIB_OS (__OS_WIN) | LBS_LIB_INFO2,
        #else
        /*dwState*/				LBS_NO_EDIT_INFO | _LIB_OS (__OS_WIN) | LBS_LIB_INFO2,
        #endif

        /*szAuthor*/	_WT("大有吴涛易语言软件公司"),
        /*szZipCode*/	_WT("116001"),
        /*szAddress*/	_WT("辽宁省大连市中山区人民路55号亚太国际金融中心"),
        /*szPhoto*/		_WT("+86(0411)39895831"),
        /*szFax*/		_WT("+86(0411)39895834"),
        /*szEmail*/		_WT("service@dywt.com.cn"),
        /*szHomePage*/	_WT("http://www.eyuyan.com"),
        /*szOther*/		_WT("祝您一帆风顺，心想事成！"),

        //----------------------------------------  以下接口信息全部为空

        /*type count*/			0,
        /*PLIB_DATA_TYPE_INFO*/	NULL,

        /*CategoryCount*/   0,
        /*category*/        _WT("\0"
				                "\0"),
        /*CmdCount*/        0,
        /*BeginCmd*/        NULL,

        /*m_pCmdsFunc*/             NULL,
        /*pfnRunAddInFn*/			NULL,
        /*szzAddInFnInfo*/			NULL,

        /*pfnNotify*/				htmlview_EmptyProcessNotifyLib,

        /*pfnRunSuperTemplate*/		NULL,
        /*szzSuperTemplateInfo*/	NULL,

        /*nLibConstCount*/			0,
        /*pLibConst*/				NULL,

        /*szzDependFiles*/			NULL,
    },

    _T(""),
    _T("本支持库的授权方法为在支持库同目录内放置一个名为\"HtmlView.elic\"的文本文件,其中的内容为被授权用户的名称。"),
    _T("http://www.eyuyan.com"),
    _T(""),

};

#endif

PLIB_INFO2 WINAPI GetNewInf ()
{
    // 建立授权信息文件名
    TCHAR buf [MAX_PATH];
    VERIFY (::GetModuleFileName (theApp.m_hInstance, buf, MAX_PATH));
   	LPTSTR pFnd = _tcsrchr (buf, '\\');
	if (pFnd != NULL)
		*(pFnd + 1) = '\0';
    _tcscat (buf, _T("HtmlView.elic"));

    // 读入授权信息文件中记录的用户名信息
    static TCHAR s_acLicenseToUserName [128];
    s_acLicenseToUserName [0] = '\0';
	TRY
	{
		CFile file;
		if (file.Open (buf, CFile::modeRead | CFile::shareDenyWrite))
		{
			INT nLength = file.GetLength ();
            if (nLength > sizeof (s_acLicenseToUserName) / sizeof (s_acLicenseToUserName [0]) - 1)
                nLength = sizeof (s_acLicenseToUserName) / sizeof (s_acLicenseToUserName [0]) - 1;

            nLength = (INT)file.Read (s_acLicenseToUserName, nLength * sizeof (TCHAR)) / sizeof (TCHAR);
            s_acLicenseToUserName [nLength] = '\0';
		}
	}
	END_TRY

    //-------------------------------  根据是否得到授权返回对应的LIB_INFO

    s_LibInfo2.m_szLicenseToUserName = s_acLicenseToUserName;
    if (s_acLicenseToUserName [0] != '\0')  // 已经得到授权?
        return &s_LibInfo2;

    // 输出一个测试用的硬件代码,正常情况下应该是根据用户计算机的硬件特征实时获取.
    s_LibInfo2Empty.m_szHardwareCode = _T("TestHardwareCode");

    return &s_LibInfo2Empty;
}

#endif

