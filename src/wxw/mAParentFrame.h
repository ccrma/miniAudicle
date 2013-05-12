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
// file: mAParentWindow.h
// desc: wxWidgets MDI Parent window
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#ifndef __MA_PARENT_FRAME_H__
#define __MA_PARENT_FRAME_H__

#include "wx/app.h"
#include "wx/mdi.h"
#include "wx/docview.h"
#include "wx/docmdi.h"
#include "wx/dialog.h"
#include "wx/sizer.h"

#include "mAView.h"
#include "mAVMMonitor.h"
#include "mAConsoleMonitor.h"
#include "mAPreferencesWindow.h"
#include "mAMenuBar.h"

#include "miniAudicle.h"

#include <list>
#include <map>

#ifdef __WINDOWS_DS__
typedef wxMDIChildFrame mAFrameType;
#else
typedef wxFrame mAFrameType;
#endif

class mAParentFrame;

class mAApp : public wxApp
{
public:
    mAApp();
    bool OnInit();
    int OnExit();

    void LoadCommandLineArguments();
    void LoadPreferences();
    void SavePreferences();

    void OnVMStart();
    void OnVMStop();
    void OnAbortCurrentShred( wxCommandEvent & event );
    void OnLogLevel( wxCommandEvent & event );
    void OnPreferencesCommand( wxCommandEvent & event );
    void OnWindowCommand( wxCommandEvent & event );
    void OnChar( wxKeyEvent & event );

    void SetLockdown( t_CKBOOL lockdown );
    t_CKBOOL IsInLockdown();

    void RemoveMenuBar( mAMenuBar * menubar );
    void RemoveView( mAChuckView * view );

    int AddWindowMenuItem( mAFrameType * frame );
    void ChangeWindowMenuItem( int id );
    void RemoveWindowMenuItem( int id );
    
    void EditingPreferencesChanged();
    void SyntaxColoringPreferencesChanged();

    mADocMDIChildFrame * CreateChildFrame( wxDocument * doc, mAChuckView * view );
    mAFrameType * CreateChildFrame( wxWindowID id = wxID_ANY );

private:
    mAParentFrame * parent_frame;
    wxDocManager * doc_manager;
    miniAudicle * ma;
    mAVMMonitor * vm_monitor;
    mAConsoleMonitor * console_monitor;
    mAPreferencesWindow * preferences_window;
    t_CKBOOL vm_on;
    t_CKBOOL in_lockdown;

    std::map< int, mAFrameType * > window_menu_map;

    /* Each child window of the parent frame has to have its own menu bar.  
    Additionally, each time the VM state is changed, the ChucK menu has to
    be greyed/ungreyed to reflect the change.  Thus mAApp keeps track of 
    each window's menu bar, and updates them as necessary when the VM is 
    turned on.  mAMenuBars will remove themselves from this list when their
    destructor is called. */
    std::list< mAMenuBar * > menu_bars;
    
    /* we need to have a list of all the document views, so we can notify
    them when editing preferences have changed (also when the VM is turned 
    on/off for Win32) */
    std::list< mAChuckView * > views;
};

DECLARE_APP( mAApp )

class mAParentFrame : public wxDocMDIParentFrame
{
    DECLARE_CLASS( mAParentFrame )
    
public:  
    mAParentFrame( miniAudicle * ma, wxDocManager *manager, wxFrame *frame, 
                   const wxString & title, const wxPoint& pos, const wxSize& size, long type);
    ~mAParentFrame();
    
    void OnAdd( wxCommandEvent & event );
    void OnRemove( wxCommandEvent & event );
    void OnReplace( wxCommandEvent & event );
    
    void OnAddAllOpenDocuments( wxCommandEvent & event );
    void OnRemoveAllOpenDocuments( wxCommandEvent & event );
    void OnReplaceAllOpenDocuments( wxCommandEvent & event );
    
    void OnRemovelast( wxCommandEvent & event );
    void OnRemoveall( wxCommandEvent & event );
    
    void OnToggleVM( wxCommandEvent & event );
    
    void OnEditMenu( wxCommandEvent & event );
    
    void OnMiniWeb( wxCommandEvent & event );
    void OnChucKWeb( wxCommandEvent & event );
    void OnAbout( wxCommandEvent & event );
    
    void OnCloseWindow( wxCloseEvent & event );
    
    DECLARE_EVENT_TABLE()
        
private:
    miniAudicle * ma;
    bool vm_on;
    t_CKUINT docid;
    
    wxDialog about_dialog;
};

#endif /* __MA_PARENT_FRAME_H__ */
