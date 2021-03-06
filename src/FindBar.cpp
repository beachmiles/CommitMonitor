// CommitMonitor - simple checker for new commits in svn repositories

// Copyright (C) 2007, 2012 - Stefan Kueng

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

#include "stdafx.h"
#include "resource.h"
#include "FindBar.h"
#include "Registry.h"
#include <string>
#include <Commdlg.h>
#include <memory>


CFindBar::CFindBar()
    : m_hParent(NULL)
    , m_hBmp(NULL)
{
}

CFindBar::~CFindBar(void)
{
    DeleteObject(m_hBmp);
}

LRESULT CFindBar::DlgFunc(HWND /*hwndDlg*/, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (uMsg)
    {
    case WM_INITDIALOG:
        {
            m_hBmp = ::LoadBitmap(hResource, MAKEINTRESOURCE(IDB_CANCELNORMAL));
            SendMessage(GetDlgItem(*this, IDC_FINDEXIT), BM_SETIMAGE, IMAGE_BITMAP, (LPARAM)m_hBmp);
        }
        return TRUE;
    case WM_COMMAND:
        return DoCommand(LOWORD(wParam), HIWORD(wParam));
    default:
        return FALSE;
    }
}

LRESULT CFindBar::DoCommand(int id, int msg)
{
    bool bFindPrev = false;
    switch (id)
    {
    case IDC_FINDPREV:
        bFindPrev = true;
    case IDC_FINDNEXT:
        {
            DoFind(bFindPrev);
        }
        break;
    case IDC_FINDEXIT:
        {
            ::SendMessage(m_hParent, COMMITMONITOR_FINDEXIT, 0, 0);
        }
        break;
    case IDC_FINDTEXT:
        {
            if (msg == EN_CHANGE)
            {
                SendMessage(m_hParent, COMMITMONITOR_FINDRESET, 0, 0);
                DoFind(false);
            }
        }
        break;
    }
    return 1;
}

void CFindBar::DoFind(bool bFindPrev)
{
    int len = ::GetWindowTextLength(GetDlgItem(*this, IDC_FINDTEXT));
    std::unique_ptr<TCHAR[]> findtext(new TCHAR[len+1]);
    ::GetDlgItemText(*this, IDC_FINDTEXT, findtext.get(), len+1);
    std::wstring ft = std::wstring(findtext.get());
    bool bCaseSensitive = !!SendMessage(GetDlgItem(*this, IDC_MATCHCASECHECK), BM_GETCHECK, 0, NULL);
    if (bFindPrev)
        ::SendMessage(m_hParent, COMMITMONITOR_FINDMSGPREV, (WPARAM)bCaseSensitive, (LPARAM)ft.c_str());
    else
        ::SendMessage(m_hParent, COMMITMONITOR_FINDMSGNEXT, (WPARAM)bCaseSensitive, (LPARAM)ft.c_str());
}
