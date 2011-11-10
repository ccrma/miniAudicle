/*----------------------------------------------------------------------------
miniAudicle
GUI to chuck audio programming environment

Copyright (c) 2005 Spencer Salazar.  All rights reserved.
http://chuck.cs.princeton.edu/
http://soundlab.cs.princeton.edu/

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
U.S.A.
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// file: mAVMMonitor.h
// desc: Virtual Machine monitor 
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#ifndef __MA_CONSOLE_MONITOR_H__
#define __MA_CONSOLE_MONITOR_H__

#include "wx/textctrl.h"
#include "wx/mdi.h"
#include "wx/wfstream.h"
#include "mAMenuBar.h"

#include "util_thread.h"
#include <stdio.h>

#ifdef __LINUX__
class mAConsoleMonitor : public wxFrame
#else
class mAConsoleMonitor : public wxMDIChildFrame
#endif /* __LINUX__ */
{
public:
#ifdef __LINUX__
    mAConsoleMonitor( wxWindow * parent, 
        wxWindowID id, const wxString & title, 
        const wxPoint & pos = wxDefaultPosition, 
        const wxSize & size = wxDefaultSize, 
        long style = wxDEFAULT_FRAME_STYLE );
#else
    mAConsoleMonitor( wxMDIParentFrame * parent, 
        wxWindowID id, const wxString & title, 
        const wxPoint & pos = wxDefaultPosition, 
        const wxSize & size = wxDefaultSize, 
        long style = wxDEFAULT_FRAME_STYLE );
#endif /* __LINUX__ */
    ~mAConsoleMonitor();
    
    void OnClose( wxCloseEvent & event );
    void OnDataAvailable( wxCommandEvent & event );

#ifdef __LINUX__
    //void OnChar( wxKeyEvent & event );
    //void SetMenuBar( mAMenuBar * menubar );
#endif

#if defined( __LINUX__ ) || defined( __WINDOWS_PTHREAD__ )
    static void * callback( void * );
#else
    static unsigned __stdcall callback( void * );
#endif

private:
    wxTextCtrl * text;
    XThread th;
    XMutex * fd_mutex;
    t_CKBOOL th_go;

    t_CKUINT scrollback_size;

    int out_fd;
    int err_fd;
    FILE * stdlib_fd;
    
#ifdef __LINUX__
    mAMenuBar * menubar;
#endif
};

#endif /* __MA_CONSOLE_MONITOR_H__ */

