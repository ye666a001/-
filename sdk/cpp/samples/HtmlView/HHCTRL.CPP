
/*
    版权声明：
    本文件版权为易语言作者吴涛所有，仅授权给第三方用作开发易语言支持库，禁止用于其他任何场合。
*/

#include "stdafx.h"
#include <AFXPRIV.H>
#include "hhctrl.h"
#include "htmlview.h"

INT WINAPI NotifySys (INT nMsg, DWORD dwParam1, DWORD dwParam2 = 0);

#include "untshare.cpp"

extern CHtmlViewApp theApp;

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static const char THIS_FILE[] = __FILE__;
#endif

BEGIN_MESSAGE_MAP(CHHCtrl, CWnd)
    //{{AFX_MSG_MAP(CHHCtrl)
	ON_WM_SETFOCUS()
    ON_WM_SIZE()
    ON_WM_PAINT()
    ON_WM_DESTROY()
    //}}AFX_MSG_MAP
END_MESSAGE_MAP()

BEGIN_EVENTSINK_MAP(CHHCtrl, CWnd)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 102, OnStatusTextChange, VTS_BSTR)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 108, OnProgressChange, VTS_I4 VTS_I4)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 105, OnCommandStateChange, VTS_I4 VTS_BOOL)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 106, OnDownloadBegin, VTS_NONE)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 104, OnDownloadComplete, VTS_NONE)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 113, OnTitleChange, VTS_BSTR)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 252, NavigateComplete2, VTS_DISPATCH VTS_PVARIANT)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 250, BeforeNavigate2, VTS_DISPATCH VTS_PVARIANT VTS_PVARIANT VTS_PVARIANT VTS_PVARIANT VTS_PVARIANT VTS_PBOOL)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 112, OnPropertyChange, VTS_BSTR)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 251, OnNewWindow2, VTS_PDISPATCH VTS_PBOOL)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 259, DocumentComplete, VTS_DISPATCH VTS_PVARIANT)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 253, OnQuit, VTS_NONE)
    ON_EVENT(CHHCtrl, AFX_IDW_PANE_FIRST, 254, OnVisible, VTS_BOOL)
END_EVENTSINK_MAP()

CHHCtrl::CHHCtrl() : CWnd()
{
    m_pBrowserApp = NULL;
	m_blHasForceURL = m_blHasTitle = FALSE;
}

CHHCtrl::~CHHCtrl()
{
    if (m_pBrowserApp != NULL)
        m_pBrowserApp->Release();
}

void CHHCtrl::OnDraw(CDC* pDC)
{
    // this class should never do its own drawing;
    // the browser control should handle everything

    ASSERT(FALSE);  // make certain we aren't called
}

/*
	OLECMDID_OPEN
	OLECMDID_SAVEAS
	OLECMDID_PRINT
	OLECMDID_PRINTPREVIEW
	OLECMDID_PAGESETUP
*/
void CHHCtrl::RunCmd (OLECMDID cmdid)
{
    if (m_pBrowserApp != NULL) {
        LPDISPATCH lpDisp;
		m_pBrowserApp->get_Document(&lpDisp);

        if (lpDisp != NULL) {
            // the control will handle all printing UI

            LPOLECOMMANDTARGET lpTarget;
            if (SUCCEEDED(lpDisp->QueryInterface(IID_IOleCommandTarget,
                    (LPVOID*) &lpTarget))) {
                lpTarget->Exec(NULL, cmdid, 0, NULL, NULL);
                lpTarget->Release();
            }
            lpDisp->Release();
        }
    }
}

void CHHCtrl::OnDestroy()
{
    if (m_pBrowserApp)
	{
        m_pBrowserApp->Release();
        m_pBrowserApp = NULL;
    }

    if (::IsWindow (m_wndBrowser.m_hWnd))
        m_wndBrowser.DestroyWindow ();

    CWnd::OnDestroy ();
}

void CHHCtrl::PostNcDestroy() 
{
	CWnd::PostNcDestroy ();
	NotifySys (NRS_UNIT_DESTROIED, m_dwWinFormID, m_dwUnitID);
	delete this;
}

void CHHCtrl::OnSize(UINT nType, int cx, int cy)
{
    CWnd::OnSize(nType, cx, cy);

	if (::IsWindow(m_wndBrowser.m_hWnd))
	{
		// need to push non-client borders out of the client area
		CRect rect;
		GetClientRect(rect);
		//::AdjustWindowRectEx(rect,
		//	m_wndBrowser.GetStyle(), FALSE, WS_EX_CLIENTEDGE);
		m_wndBrowser.SetWindowPos(NULL, rect.left, rect.top,
			rect.Width(), rect.Height(), SWP_NOACTIVATE | SWP_NOZORDER);
	}
}

void CHHCtrl::OnPaint()
{
    Default();
}

void CHHCtrl::OnSetFocus(CWnd* pOldWnd) 
{
	CWnd::OnSetFocus(pOldWnd);
	if (::IsWindow (m_wndBrowser.m_hWnd))
		m_wndBrowser.SetFocus ();
}

BOOL CHHCtrl::Create (HWND hParentWnd, DWORD dwStyle, UINT uID,
					  INT x, INT y, INT cx, INT cy)
{
	if (!CWnd::CreateEx (NULL, AfxRegisterWndClass (CS_DBLCLKS | CS_HREDRAW | CS_VREDRAW,
			::LoadCursor (NULL, IDC_ARROW), HBRUSH (::GetStockObject (WHITE_BRUSH))),
			_T(""), dwStyle, x, y, cx, cy, hParentWnd, (HMENU)uID, NULL))
		return FALSE;

	AfxEnableControlContainer();

	RECT rectClient;
	GetClientRect(&rectClient);

	// create the control window
	// AFX_IDW_PANE_FIRST is a safe but arbitrary ID
	if (!m_wndBrowser.CreateControl(CLSID_WebBrowser, NULL,
				WS_VISIBLE | WS_CHILD, rectClient, this, AFX_IDW_PANE_FIRST))
	{
		DestroyWindow();
		return FALSE;
	}

	LPUNKNOWN lpUnk = m_wndBrowser.GetControlUnknown();
	HRESULT hr = lpUnk->QueryInterface(IID_IWebBrowser2, (void**) &m_pBrowserApp);
	if (!SUCCEEDED(hr))
	{
		m_pBrowserApp = NULL;
		m_wndBrowser.DestroyWindow();
		DestroyWindow();
		return FALSE;
	}

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////

CString CHHCtrl::GetType() const
{
    ASSERT(m_pBrowserApp != NULL);

    BSTR bstr;
    m_pBrowserApp->get_Type(&bstr);
    CString retVal(bstr);
    return retVal;
}

long CHHCtrl::GetLeft() const
{
    ASSERT(m_pBrowserApp != NULL);

    long result;
    m_pBrowserApp->get_Left(&result);
    return result;
}

long CHHCtrl::GetTop() const
{
    ASSERT(m_pBrowserApp != NULL);
    long result;
    m_pBrowserApp->get_Top(&result);
    return result;
}

long CHHCtrl::GetHeight() const
{
    ASSERT(m_pBrowserApp != NULL);
    long result;
    m_pBrowserApp->get_Height(&result);
    return result;
}

BOOL CHHCtrl::GetVisible() const
{
    ASSERT(m_pBrowserApp != NULL);

    VARIANT_BOOL result;
    m_pBrowserApp->get_Visible(&result);
    return ((result == VARIANT_TRUE) ? TRUE: FALSE);
}

CString CHHCtrl::GetLocationName() const
{
    ASSERT(m_pBrowserApp != NULL);

    BSTR bstr;
    m_pBrowserApp->get_LocationName(&bstr);
    CString retVal(bstr);
    return retVal;
}

CString CHHCtrl::GetLocationURL() const
{
    ASSERT(m_pBrowserApp != NULL);

    BSTR bstr;
    m_pBrowserApp->get_LocationURL(&bstr);
    CString retVal(bstr);
    return retVal;
}

BOOL CHHCtrl::GetBusy() const
{
    ASSERT(m_pBrowserApp != NULL);

    VARIANT_BOOL result;
    m_pBrowserApp->get_Busy(&result);
    return ((result == VARIANT_TRUE) ? TRUE: FALSE);
}

READYSTATE CHHCtrl::GetReadyState() const
{
    ASSERT(m_pBrowserApp != NULL);

    READYSTATE result;
    m_pBrowserApp->get_ReadyState(&result);
    return result;
}

BOOL CHHCtrl::GetOffline() const
{
    ASSERT(m_pBrowserApp != NULL);

    VARIANT_BOOL result;
    m_pBrowserApp->get_Offline(&result);
    return ((result == VARIANT_TRUE) ? TRUE: FALSE);
}

BOOL CHHCtrl::GetSilent() const
{
    ASSERT(m_pBrowserApp != NULL);

    VARIANT_BOOL result;
    m_pBrowserApp->get_Silent(&result);
    return ((result == VARIANT_TRUE) ? TRUE: FALSE);
}

void CHHCtrl::ExecWB(OLECMDID cmdID, OLECMDEXECOPT cmdexecopt,
    VARIANT* pvaIn, VARIANT* pvaOut)
{
    ASSERT(m_pBrowserApp != NULL);
    m_pBrowserApp->ExecWB(cmdID, cmdexecopt, pvaIn, pvaOut);
}

HRESULT CHHCtrl::Navigate(LPCTSTR lpszURL, DWORD dwFlags /* = 0 */,
    LPCTSTR lpszTargetFrameName /* = NULL */ ,
    LPCTSTR lpszHeaders /* = NULL */, LPVOID lpvPostData /* = NULL */,
    DWORD dwPostDataLen /* = 0 */)
{
    CString strURL(lpszURL);
    BSTR bstrURL = strURL.AllocSysString();

    COleSafeArray vPostData;
    if (lpvPostData != NULL)
    {
        if (dwPostDataLen == 0)
            dwPostDataLen = lstrlen((LPCTSTR) lpvPostData);

        vPostData.CreateOneDim(VT_UI1, dwPostDataLen, lpvPostData);
    }

    HRESULT hResult = m_pBrowserApp->Navigate(bstrURL,
        COleVariant((long) dwFlags, VT_I4),
        COleVariant(lpszTargetFrameName, VT_BSTR),
        vPostData,
        COleVariant(lpszHeaders, VT_BSTR));
	::SysFreeString(bstrURL);
	return hResult;
}

HRESULT CHHCtrl::NavigateChm(LPCTSTR szChmFileName, LPCTSTR URL, LPCTSTR lpszTargetFrameName)
{
    if (szChmFileName == NULL || *szChmFileName == '\0')
        return STG_E_FILENOTFOUND;  // CHM file wasn't located

    char szURL[MAX_PATH * 2];
    wsprintf(szURL, "its:%s::%s", szChmFileName, URL);
    return Navigate(szURL, NULL, lpszTargetFrameName);
}

/////////////////////////////////////////////////////////////////////////////
// CHHCtrl event reflectors

void CHHCtrl::NavigateComplete2(LPDISPATCH /* pDisp */, VARIANT* URL)
{
    ASSERT(V_VT(URL) == VT_BSTR);

    // USES_CONVERSION;

    CString str(V_BSTR(URL));
    OnNavigateComplete2(str);
}

void CHHCtrl::BeforeNavigate2(LPDISPATCH /* pDisp */, VARIANT* URL,
        VARIANT* Flags, VARIANT* TargetFrameName,
        VARIANT* PostData, VARIANT* Headers, BOOL* pfCancel)
{
    ASSERT(V_VT(URL) == VT_BSTR);
    ASSERT(V_VT(TargetFrameName) == VT_BSTR);
    ASSERT(V_VT(PostData) == (VT_VARIANT | VT_BYREF));
    ASSERT(V_VT(Headers) == VT_BSTR);
    ASSERT(pfCancel != NULL);

    //USES_CONVERSION;

    VARIANT* vtPostedData = V_VARIANTREF(PostData);
    CByteArray array;
    if (V_VT(vtPostedData) & VT_ARRAY)
	{
        // must be a vector of bytes
        ASSERT(vtPostedData->parray->cDims == 1 && vtPostedData->parray->cbElements == 1);

        vtPostedData->vt |= VT_UI1;
        COleSafeArray safe(vtPostedData);

        DWORD dwSize = safe.GetOneDimSize();
        LPVOID pVoid;
        safe.AccessData(&pVoid);

        array.SetSize(dwSize);
        LPBYTE lpByte = array.GetData();

        memcpy(lpByte, pVoid, dwSize);
        safe.UnaccessData();
    }
    // make real parameters out of the notification

    CString strTargetFrameName(V_BSTR(TargetFrameName));
    CString strURL = V_BSTR(URL);
    CString strHeaders = V_BSTR(Headers);
    DWORD nFlags = V_I4(Flags);

    // notify the user's class
    OnBeforeNavigate2(strURL, nFlags, strTargetFrameName, array, strHeaders, pfCancel);
}

void CHHCtrl::DocumentComplete(LPDISPATCH pDisp, VARIANT* URL)
{
    UNUSED_ALWAYS(pDisp);
    ASSERT(V_VT(URL) == VT_BSTR);

    CString str(V_BSTR(URL));
    OnDocumentComplete(str);
}

/////////////////////////////////////////////////////////////////////////////
// CHHCtrl Events

void CHHCtrl::OnProgressChange(long lProgress, long lProgressMax)
{
	EVENT_NOTIFY event (m_dwWinFormID, m_dwUnitID, 3);
	event.m_nArgCount = 1;
	event.m_nArgValue [0] = lProgressMax == 0 ? 100 :
			MulDiv (lProgress, 100, lProgressMax);
	NotifySys (NRS_EVENT_NOTIFY, (DWORD)&event);
}

void CHHCtrl::OnCommandStateChange(long lCommand, BOOL bEnable)
{
	if (lCommand == CSC_NAVIGATEFORWARD || lCommand == CSC_NAVIGATEBACK)
	{
		EVENT_NOTIFY event (m_dwWinFormID, m_dwUnitID, 8);
		event.m_nArgCount = 2;
		event.m_nArgValue [0] = lCommand == CSC_NAVIGATEFORWARD ? 0 : 1;
		event.m_nArgValue [1] = bEnable ? 1 : 0;
		NotifySys (NRS_EVENT_NOTIFY, (DWORD)&event);
	}
}

void CHHCtrl::OnDownloadBegin()
{
	NotifySys (NRS_EVENT_NOTIFY, (DWORD)&EVENT_NOTIFY (m_dwWinFormID, m_dwUnitID, 2));
}

void CHHCtrl::OnQuit()
{
}

void CHHCtrl::OnDocumentComplete(LPCTSTR lpszURL)
{
	m_blHasForceURL = TRUE;
	SetStr (m_strForceURL, (LPTSTR)lpszURL);

    HWND hWnd = m_hWnd;
	NotifySys (NRS_EVENT_NOTIFY, (DWORD)&EVENT_NOTIFY (m_dwWinFormID, m_dwUnitID, 5));
    if (::IsWindow (hWnd))
    {
	    m_blHasForceURL = FALSE;
	    m_strForceURL.Empty ();
    }
}

void CHHCtrl::OnDownloadComplete()
{
	NotifySys (NRS_EVENT_NOTIFY, (DWORD)&EVENT_NOTIFY (m_dwWinFormID, m_dwUnitID, 4));
}

void CHHCtrl::OnTitleChange(LPCTSTR lpszText)
{
	m_blHasTitle = TRUE;
	SetStr (m_strTitle, (LPTSTR)lpszText);

    HWND hWnd = m_hWnd;
	NotifySys (NRS_EVENT_NOTIFY, (DWORD)&EVENT_NOTIFY (m_dwWinFormID, m_dwUnitID, 7));
	
    if (::IsWindow (hWnd))
    {
        m_blHasTitle = FALSE;
        m_strTitle.Empty ();
    }
}

void CHHCtrl::OnPropertyChange(LPCTSTR lpszProperty)
{
    UNUSED_ALWAYS(lpszProperty);
}

void CHHCtrl::OnNewWindow2(LPDISPATCH* ppDisp, BOOL* pfCancel)
{
	EVENT_NOTIFY event (m_dwWinFormID, m_dwUnitID, 9);
	if (NotifySys (NRS_EVENT_NOTIFY, (DWORD)&event) != 0 &&
			event.m_blHasRetVal == TRUE &&
			event.m_nRetVal == 0)
		*pfCancel = TRUE;
	else
		*pfCancel = FALSE;

    UNUSED_ALWAYS(ppDisp);
}

void CHHCtrl::OnVisible(BOOL fVisible)
{
    UNUSED_ALWAYS(fVisible);
}

void CHHCtrl::OnBeforeNavigate2(LPCTSTR lpszURL, DWORD nFlags,
    LPCTSTR lpszTargetFrameName, CByteArray& baPostData,
    LPCTSTR lpszHeaders, BOOL* pfCancel)
{
	m_blHasForceURL = TRUE;
	SetStr (m_strForceURL, (LPTSTR)lpszURL);

    HWND hWnd = m_hWnd;

	EVENT_NOTIFY event (m_dwWinFormID, m_dwUnitID, 0);
	if (NotifySys (NRS_EVENT_NOTIFY, (DWORD)&event) != 0 &&
			event.m_blHasRetVal == TRUE &&
			event.m_nRetVal == 0)
		*pfCancel = TRUE;
	else
		*pfCancel = FALSE;

    if (::IsWindow (hWnd))
    {
	    m_blHasForceURL = FALSE;
	    m_strForceURL.Empty ();

        UNUSED_ALWAYS(nFlags);
        UNUSED_ALWAYS(lpszTargetFrameName);
        UNUSED_ALWAYS(baPostData);
        UNUSED_ALWAYS(lpszHeaders);
    }
}

void CHHCtrl::OnStatusTextChange(LPCTSTR pszText)
{
	SetStr (m_strStatusText, (LPTSTR)pszText);
	NotifySys (NRS_EVENT_NOTIFY, (DWORD)&EVENT_NOTIFY (m_dwWinFormID, m_dwUnitID, 6));
}

void CHHCtrl::OnNavigateComplete2(LPCTSTR strURL)
{
	m_blHasForceURL = TRUE;
	SetStr (m_strForceURL, (LPTSTR)strURL);
	
    HWND hWnd = m_hWnd;
    NotifySys (NRS_EVENT_NOTIFY, (DWORD)&EVENT_NOTIFY (m_dwWinFormID, m_dwUnitID, 1));
    if (::IsWindow (hWnd))
    {
	    m_blHasForceURL = FALSE;
	    m_strForceURL.Empty ();
    }
}


#ifdef _DEBUG
void CHHCtrl::AssertValid() const
{
    CWnd::AssertValid();
}

void CHHCtrl::Dump(CDumpContext& dc) const
{
    CWnd::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////

// !!! 此处的定义顺序绝对不可改变
static EVENT_ARG_INFO s_HtmlViewerArgInfo [] =
{
//****** 载入进度改变
	{
/*name*/	_WT("进度百分比"),
/*explain*/	_WT("参数值指示当前文档已经被载入的百分比"),
/*state*/	NULL,
	},

//****** 命令状态被改变
	{
/*name*/	_WT("命令"),
/*explain*/	_WT("参数值指示允许状态被改变的命令类型，为以下常量值之一："
		"0: #前进； 1: #后退"),
/*state*/	NULL,
	}, {
/*name*/	_WT("是否被允许"),
/*explain*/	_WT("参数值指示该命令当前是否被允许"),
/*state*/	EAS_IS_BOOL_ARG,
	},

};

// !!! 此处的定义顺序绝对不可改变，主默认信息放在首位。
EVENT_INFO g_HtmlViewerEvent [] =
{
	{
	_WT("即将跳转"),
	_WT("在浏览器即将跳转到另一个页面之前产生此事件，"
		"在事件处理子程序中读取“地址”属性即可得知即将跳转到的地址，"
		"返回假不允许跳转，返回真或不返回值允许跳转"),
/*m_dwState*/			EV_RETURN_BOOL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("跳转完毕"),
	_WT("当浏览器已跳转到另一个页面之后产生此事件，"
		"在事件处理子程序中读取“地址”属性即可得知已跳转到的地址"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("载入开始"),
	_WT("本事件在“即将跳转”事件之后触发，表示浏览器已开始载入将要显示的文档。注意文档可能会被分批载入。"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("载入进度改变"),
	_WT("在浏览器载入文档的过程中，每当文档被载入一部分即触发本事件，用作通知载入进度"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			1,
/*m_pBeginArgInfo*/		s_HtmlViewerArgInfo,
	}, {
	_WT("载入完毕"),
	_WT("当将要显示在浏览器内的文档被载入完毕后触发本事件。注意文档可能会被分批载入，此事件发生时并不一定意味着整个文档被已载入完毕。另请参考“已就绪”事件。"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("已就绪"),
	_WT("当浏览器已经将所需显示的文档处理完毕后发送本事件，"
		"在事件处理子程序中读取“地址”属性即可得知已就绪文档的地址"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("状态文本被改变"),
	_WT("当浏览器的状态条文本被改变后发送本事件，"
			"在事件处理子程序中读取“状态条文本”属性即可得知其内容"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("标题被改变"),
	_WT("当浏览器的标题文本被改变后发送本事件，"
			"在事件处理子程序中读取“标题”属性即可得知其内容"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	}, {
	_WT("命令状态被改变"),
	_WT("当“前进”、“后退”等命令的允许状态被改变后发送此事件，"
		"用户程序应该根据状态值允许或禁止对应的按钮或菜单项。"),
/*m_dwState*/			NULL,
/*m_nArgCount*/			2,
/*m_pBeginArgInfo*/		&s_HtmlViewerArgInfo [1],
	}, {
	_WT("即将打开新窗口"),
	_WT("在浏览器即将打开新窗口浏览另一个页面之前产生此事件，"
		"事件处理子程序返回假不允许打开，返回真或不返回值允许打开"),
/*m_dwState*/			EV_RETURN_BOOL,
/*m_nArgCount*/			0,
/*m_pBeginArgInfo*/		NULL,
	},
};
INT g_HtmlViewerEventCount = sizeof (g_HtmlViewerEvent) / sizeof (g_HtmlViewerEvent [0]);

// 注意顺序不可改变!!!
UNIT_PROPERTY g_HtmlViewerProperty [] =
{
	FIXED_WIN_UNIT_PROPERTY,
	{
	/*m_szName*/			_WT("字体大小"),
	/*m_szEgName*/			_WT("FontSize"),
	/*m_szExplain*/			_WT("指定浏览页面时所使用的字体尺寸"),
	/*m_shtType*/			UD_PICK_INT,
	/*m_wState*/			NULL,
	/*m_szzPickStr*/		_WT("最小\0较小\0中等\0较大\0最大\0\0"),
	}, {
	/*m_szName*/			_WT("离线浏览"),
	/*m_szEgName*/			_WT("Offline"),
	/*m_szExplain*/			_WT("指定浏览器是否从缓存里面读取超文本页面数据"),
	/*m_shtType*/			UD_BOOL,
	/*m_wState*/			NULL,
	/*m_szzPickStr*/		NULL,
	}, {
	/*m_szName*/			_WT("静默"),
	/*m_szEgName*/			_WT("Silent"),
	/*m_szExplain*/			_WT("本属性如果为真，则浏览过程中不允许浏览器显示自己的对话框"),
	/*m_shtType*/			UD_BOOL,
	/*m_wState*/			NULL,
	/*m_szzPickStr*/		NULL,
	}, {
	/*m_szName*/			_WT("地址"),
	/*m_szEgName*/			_WT("url"),
	/*m_szExplain*/			_WT("指定欲显示的网络或本机超文本页面地址"),
	/*m_shtType*/			UD_FILE_NAME,
	/*m_wState*/			NULL,
	/*m_szzPickStr*/		_WT("请输入网页文件的名称：\0网页文件 (*.htm;*.html)|*.htm;*.html\0html\0" "0\0\0"),
	}, {
	/*m_szName*/			_WT("状态条文本"),
	/*m_szEgName*/			_WT("StatusText"),
	/*m_szExplain*/			_WT("用作在运行时提供浏览器的当前状态条文本"),
	/*m_shtType*/			UD_TEXT,
	/*m_wState*/			UW_ONLY_READ,
	/*m_szzPickStr*/		NULL,
	}, {
	/*m_szName*/			_WT("标题"),
	/*m_szEgName*/			_WT("Caption"),
	/*m_szExplain*/			_WT("用作在运行时提供浏览器的当前标题文本"),
	/*m_shtType*/			UD_TEXT,
	/*m_wState*/			UW_ONLY_READ,
	/*m_szzPickStr*/		NULL,
	},
};
INT g_HtmlViewerPropertyCount = sizeof (g_HtmlViewerProperty) / sizeof (g_HtmlViewerProperty [0]);


void CPIHtmlViewer::init ()
{
	CPropertyInfo::init ();

	m_nFontSize = 2;
    m_blOffline = FALSE;
    m_blSilent = FALSE;
	m_strURL.Empty ();
}

BOOL CPIHtmlViewer::Serialize (CArchive& ar)
{
	if (CPropertyInfo::Serialize (ar) == FALSE)
		return FALSE;

	TRY
	{
		if (ar.IsLoading () == TRUE)
		{
			DWORD dwUnitDataVer;
			ar >> dwUnitDataVer;
			if (dwUnitDataVer > CUR_UNIT_VER)
				return FALSE;
			ar >> m_nFontSize >> m_blOffline >> m_blSilent;
		}
		else
		{
			ar << (DWORD)CUR_UNIT_VER;
			ar << m_nFontSize << m_blOffline << m_blSilent;
		}

		SerializeCString (m_strURL, ar);
		return TRUE;
	}
	END_TRY

	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////

HUNIT WINAPI Create_HtmlViewer (LPBYTE pAllData, INT nAllDataSize,
		DWORD dwStyle, HWND hParentWnd, UINT uID, HMENU hMenu, INT x, INT y, INT cx, INT cy,
		DWORD dwWinFormID, DWORD dwUnitID, HWND hDesignWnd, BOOL blInDesignMode)
{
	CHHCtrl* pUnit = new CHHCtrl;
	CHKV_RET_VAL (pUnit != NULL, NULL)

	if (pUnit->m_info.LoadData (pAllData, nAllDataSize) == FALSE)
	{
		delete pUnit;
		return NULL;
	}

	pUnit->m_dwWinFormID = dwWinFormID;
	pUnit->m_dwUnitID = dwUnitID;
	pUnit->m_blInDesignMode = blInDesignMode;

	if (pUnit->Create (hParentWnd, dwStyle | WS_CHILD | WS_CLIPSIBLINGS,
			uID, x, y, cx, cy))
	{
		pUnit->SetOffline (pUnit->m_info.m_blOffline);
		pUnit->SetSilent (pUnit->m_info.m_blSilent);

		COleVariant vaZoomFactor ((LONG)max (0, min (4, pUnit->m_info.m_nFontSize)));
		pUnit->ExecWB (OLECMDID_ZOOM, OLECMDEXECOPT_DONTPROMPTUSER, &vaZoomFactor, NULL);

		if (!pUnit->m_info.m_strURL.IsEmpty ())
			pUnit->Navigate (pUnit->m_info.m_strURL);
		return (HUNIT)pUnit;
	}
	else
		return NULL;
}

BOOL WINAPI NotifyPropertyChanged_HtmlViewer (HUNIT hUnit, INT nPropertyIndex,
											  PUNIT_PROPERTY_VALUE pPropertyVaule,
											  LPTSTR* ppszTipText)
{
	ASSERT (hUnit != NULL);
	if (hUnit == NULL)  return FALSE;
	CHHCtrl* pUnit = (CHHCtrl*)hUnit;
	ASSERT (pUnit->GetSafeHwnd () != NULL);

	if (ppszTipText != NULL)
		*ppszTipText = NULL;

// 注意此处的属性索引必须与属性表完全一致。
	switch (nPropertyIndex)
	{
	case 0:
		{
			pUnit->m_info.m_nFontSize = max (0, min (4, pPropertyVaule->m_int));
			COleVariant vaZoomFactor ((LONG)pUnit->m_info.m_nFontSize);
			pUnit->ExecWB (OLECMDID_ZOOM, OLECMDEXECOPT_DONTPROMPTUSER, &vaZoomFactor, NULL);
		}
		break;
	case 1:
		pUnit->SetOffline (pUnit->m_info.m_blOffline = pPropertyVaule->m_bool);
		break;
	case 2:
		pUnit->SetSilent (pUnit->m_info.m_blSilent = pPropertyVaule->m_bool);
		break;
	case 3:
		SetStr (pUnit->m_info.m_strURL, pPropertyVaule->m_szText);
		pUnit->Navigate (pUnit->m_info.m_strURL);
		break;
	case 4:
		break;
	case 5:
		break;
    default:
        ASSERT (FALSE);
        break;
	}

	return FALSE;
}

// !! 对于运行时可能被用户操作改变（不考虑直接调用API函数）的属性，在运行时必须取其现行实际值。
BOOL WINAPI GetPropertyData_HtmlViewer (HUNIT hUnit, INT nPropertyIndex,
										PUNIT_PROPERTY_VALUE pPropertyVaule)
{
	ASSERT (hUnit != NULL);
	if (hUnit == NULL)  return FALSE;
	CHHCtrl* pUnit = (CHHCtrl*)hUnit;
	ASSERT (pUnit->GetSafeHwnd () != NULL);

// 注意此处的属性索引必须与属性表完全一致。
	switch (nPropertyIndex)
	{
	case 0:
		pPropertyVaule->m_int = pUnit->m_info.m_nFontSize;
		break;
	case 1:
		pPropertyVaule->m_bool = pUnit->m_blInDesignMode ?
				pUnit->m_info.m_blOffline : pUnit->GetOffline ();
		break;
	case 2:
		pPropertyVaule->m_bool = pUnit->m_blInDesignMode ?
				pUnit->m_info.m_blSilent : pUnit->GetSilent ();
		break;
	case 3:
		if (pUnit->m_blInDesignMode == FALSE)
		{
			pUnit->m_info.m_strURL = pUnit->m_blHasForceURL ?
					pUnit->m_strForceURL : pUnit->GetLocationURL ();
		}
		pPropertyVaule->m_szText = (LPTSTR)(LPCTSTR)pUnit->m_info.m_strURL;
		break;
	case 4:
		pPropertyVaule->m_szText = (LPTSTR)(LPCTSTR)pUnit->m_strStatusText;
		break;
	case 5:
		if (pUnit->m_blHasTitle == FALSE)
			pUnit->m_strTitle = pUnit->GetLocationName ();
		pPropertyVaule->m_szText = (LPTSTR)(LPCTSTR)pUnit->m_strTitle;
		break;
	default:
		ASSERT (FALSE);
		return FALSE;
	}

	return TRUE;
}

HGLOBAL WINAPI GetAllPropertyData_HtmlViewer (HUNIT hUnit)
{
	ASSERT (hUnit != NULL);
	return ((CHHCtrl*)hUnit)->m_info.SaveData ();
}

extern "C"
PFN_INTERFACE WINAPI htmlview_GetInterface_HtmlViewer (INT nInterfaceNO)
{
	return nInterfaceNO == ITF_CREATE_UNIT ? (PFN_INTERFACE)Create_HtmlViewer :
			nInterfaceNO == ITF_NOTIFY_PROPERTY_CHANGED ? (PFN_INTERFACE)NotifyPropertyChanged_HtmlViewer :
			nInterfaceNO == ITF_GET_ALL_PROPERTY_DATA ? (PFN_INTERFACE)GetAllPropertyData_HtmlViewer :
			nInterfaceNO == ITF_GET_PROPERTY_DATA ? (PFN_INTERFACE)GetPropertyData_HtmlViewer :
			NULL;
}

