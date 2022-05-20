
/*
    版权声明：
    本文件版权为易语言作者吴涛所有，仅授权给第三方用作开发易语言支持库，禁止用于其他任何场合。
*/

#ifndef __HHCTRL_H__
#define __HHCTRL_H__

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "lib2.h"
#include "untshare.h"

#define CUR_UNIT_VER		1

class CPIHtmlViewer : public CPropertyInfo
{
public:
	INT m_nFontSize;
    BOOL m_blOffline;
    BOOL m_blSilent;
	CString m_strURL;

public:
	CPIHtmlViewer ()  { }

	virtual void init ();
	virtual BOOL Serialize (CArchive& ar);
};

extern "C"
PFN_INTERFACE WINAPI htmlview_GetInterface_HtmlViewer (INT nInterfaceNO);

HUNIT WINAPI Create_HtmlViewer (LPBYTE pAllData, INT nAllDataSize,
		DWORD dwStyle, HWND hParentWnd, UINT uID, HMENU hMenu, INT x, INT y, INT cx, INT cy,
		DWORD dwWinFormID, DWORD dwUnitID, HWND hDesignWnd = 0, BOOL blInDesignMode = FALSE);
BOOL WINAPI NotifyPropertyChanged_HtmlViewer (HUNIT hUnit, INT nPropertyIndex,
		PUNIT_PROPERTY_VALUE pPropertyVaule, LPTSTR* ppszTipText);
BOOL WINAPI GetPropertyData_HtmlViewer (HUNIT hUnit, INT nPropertyIndex,
		PUNIT_PROPERTY_VALUE pPropertyVaule);
HGLOBAL WINAPI GetAllPropertyData_HtmlViewer (HUNIT hUnit);

//////////////////////////////////////

#ifndef AFX_OLE_TRUE
#define AFX_OLE_TRUE (-1)
#define AFX_OLE_FALSE 0
#endif

class CHHCtrl : public CWnd
{
public: 
    CHHCtrl();
    virtual ~CHHCtrl();

///////////////////////////

	CPIHtmlViewer m_info;
	DWORD m_dwWinFormID, m_dwUnitID;

	BOOL m_blInDesignMode;

	BOOL m_blHasForceURL, m_blHasTitle;
	CString m_strForceURL;
	CString m_strTitle, m_strStatusText;

///////////////////////////

    BOOL Create (HWND hParentWnd, DWORD dwStyle, UINT nID,
			INT x, INT y, INT cx, INT cy);

    DECLARE_EVENTSINK_MAP()

public:
    IWebBrowser2* GetBrowser() { return m_pBrowserApp; }
                
    CString GetType() const;
    BOOL GetBusy() const;
    READYSTATE GetReadyState() const;
    CString GetLocationName() const;
    long GetLeft() const;
    void SetLeft(long nNewValue) { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->put_Left(nNewValue); }
    long GetTop() const;
    void SetTop(long nNewValue) { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->put_Top(nNewValue); }
    long GetHeight() const;
    void SetHeight(long nNewValue) { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->put_Height(nNewValue); }
    BOOL GetVisible() const;
    void SetVisible(BOOL fNewValue) { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->put_Visible((short) (fNewValue ? AFX_OLE_TRUE : AFX_OLE_FALSE)); }
    BOOL GetOffline() const;
    void SetOffline(BOOL fNewValue) { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->put_Offline((short) (fNewValue ? AFX_OLE_TRUE : AFX_OLE_FALSE)); }
    BOOL GetSilent() const;
    void SetSilent(BOOL fNewValue) { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->put_Silent((short) (fNewValue ? AFX_OLE_TRUE : AFX_OLE_FALSE)); }
    CString GetLocationURL() const;

    void GoBack() { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->GoBack(); }
    void GoForward() { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->GoForward(); }
    void GoHome() { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->GoHome(); }
    void GoSearch() { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->GoSearch(); }
    void Refresh() { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->Refresh(); }
    void Stop() { ASSERT(m_pBrowserApp != NULL); m_pBrowserApp->Stop(); }
    void RunCmd (OLECMDID cmdid);
    void ExecWB(OLECMDID cmdID, OLECMDEXECOPT cmdexecopt, VARIANT* pvaIn, VARIANT* pvaOut);

    HRESULT Navigate(LPCTSTR URL, DWORD dwFlags = 0,
                  LPCTSTR lpszTargetFrameName = NULL,
                  LPCTSTR lpszHeaders = NULL, LPVOID lpvPostData = NULL,
                  DWORD dwPostDataLen = 0);
    HRESULT NavigateChm(LPCTSTR szChmFileName, LPCTSTR URL, LPCTSTR lpszTargetFrameName = NULL);

    // Events
    virtual void OnBeforeNavigate2(LPCTSTR lpszURL, DWORD nFlags,
                                   LPCTSTR lpszTargetFrameName, 
                                   CByteArray& baPostedData,
                                   LPCTSTR lpszHeaders, BOOL* pfCancel);
    virtual void OnNavigateComplete2(LPCTSTR strURL);
    virtual void OnDownloadBegin();
    virtual void OnProgressChange(long nProgress, long nProgressMax);
    virtual void OnDownloadComplete();
    virtual void OnDocumentComplete(LPCTSTR lpszURL);
    virtual void OnStatusTextChange(LPCTSTR lpszText);
    virtual void OnTitleChange(LPCTSTR lpszText);
    virtual void OnCommandStateChange(long nCommand, BOOL fEnable);
    virtual void OnNewWindow2(LPDISPATCH* ppDisp, BOOL* Cancel);

    virtual void OnQuit();
    virtual void OnVisible(BOOL fVisible);
    virtual void OnPropertyChange(LPCTSTR lpszProperty);

public:
#ifdef _DEBUG
    virtual void AssertValid() const;
    virtual void Dump(CDumpContext& dc) const;
#endif

// Event reflectors (not normally overridden)
protected:
    virtual void NavigateComplete2(LPDISPATCH pDisp, VARIANT* URL);
    virtual void BeforeNavigate2(LPDISPATCH pDisp, VARIANT* URL,
                                 VARIANT* Flags, VARIANT* TargetFrameName, VARIANT* PostData,
                                 VARIANT* Headers,   BOOL* Cancel);
    virtual void DocumentComplete(LPDISPATCH pDisp, VARIANT* URL);
    virtual void OnDraw(CDC* pDC);

	virtual void PostNcDestroy();

public:
    //{{AFX_MSG(CHHCtrl)
	afx_msg void OnSetFocus(CWnd* pOldWnd);
    afx_msg void OnSize(UINT nType, int cx, int cy);
    afx_msg void OnPaint();
    afx_msg void OnDestroy();
    //}}AFX_MSG
    DECLARE_MESSAGE_MAP()

protected:
	CWnd m_wndBrowser;
    IWebBrowser2* m_pBrowserApp;
};

#endif // __HHCTRL_H__
