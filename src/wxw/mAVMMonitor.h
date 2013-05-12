/*----------------------------------------------------------------------------
miniAudicle
GUI to chuck audio programming environment

Copyright (c) 2005-2013 Spencer Salazar.  All rights reserved.
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

#ifndef __MA_VM_MONITOR_H__
#define __MA_VM_MONITOR_H__

#include "wx/grid.h"
#include "wx/timer.h"
#include "wx/mdi.h"
#include "wx/button.h"
#include "wx/stattext.h"

#include "miniAudicle.h"

#ifdef __LINUX__
class mAVMMonitor : public wxFrame
#else
class mAVMMonitor : public wxMDIChildFrame
#endif /* __LINUX__ */
{
private:
    wxGrid * grid;
    wxButton * vm_start;
    wxStaticText * shred_count;
    wxStaticText * time_counter;

    miniAudicle * ma;
    t_CKUINT docid;
    wxTimer * timer;
    Chuck_VM_Status status;
    t_CKBOOL vm_on;

    t_CKUINT refresh_rate;
    t_CKUINT vm_stall_count;
    t_CKUINT vm_max_stalls;

public:
#ifdef __LINUX__
    mAVMMonitor( miniAudicle * ma, wxWindow * parent, 
        wxWindowID id, const wxString & title, 
        const wxPoint & pos = wxDefaultPosition, 
        const wxSize & size = wxDefaultSize, 
        long style = wxDEFAULT_FRAME_STYLE );
#else
    mAVMMonitor( miniAudicle * ma, wxMDIParentFrame * parent, 
        wxWindowID id, const wxString & title, 
        const wxPoint & pos = wxDefaultPosition, 
        const wxSize & size = wxDefaultSize, 
        long style = wxDEFAULT_FRAME_STYLE );
#endif /* __LINUX__ */
    ~mAVMMonitor();
    
    void OnVMStart();
    void OnVMStop();
    void OnTimer( wxTimerEvent & event );
    void OnGridClick( wxGridEvent & event );
    void OnResize( wxSizeEvent & event );
    void OnClose( wxCloseEvent & event );
};

#endif /* __MA_VM_MONITOR_H__ */

