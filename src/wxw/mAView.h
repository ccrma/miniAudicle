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
// file: mAView.h
// desc: ChucK source view
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#ifndef __MA_VIEW_H__
#define __MA_VIEW_H__

#include "wx/docview.h"
#include "wx/docmdi.h"
#include "wx/textctrl.h"
#include "wx/stc/stc.h"
#include "miniAudicle.h"

class mAChuckView;

class mAChuckWindow : public wxStyledTextCtrl
{
public:
    mAChuckView * view;
    
    mAChuckWindow( mAChuckView * v, wxMDIChildFrame * frame, wxWindowID id, 
                   const wxPoint & pos, const wxSize & size, long style );
    void OnCharAdded( wxStyledTextEvent & event );
    void OnModify( wxStyledTextEvent & event );

private:
    int open_brackets, close_brackets;
};

class mADocMDIChildFrame : public wxDocMDIChildFrame
{
public:
    mADocMDIChildFrame( wxDocument * doc, wxView * view, 
        wxMDIParentFrame * parent, 
        wxWindowID id, const wxString & title, 
        const wxPoint & pos = wxDefaultPosition, 
        const wxSize & size = wxDefaultSize, 
        long style = wxDEFAULT_FRAME_STYLE,
        const wxString & name = _T( "frame" ) );
    void RegisterWithWindowMenu();
    void DeregisterWithWindowMenu();
    void ReregisterWithWindowMenu();

private:
    int m_menuid;
};

class mAChuckView : public wxView
{
public:
    mADocMDIChildFrame * frame;
    wxStyledTextCtrl * window;
  
    mAChuckView() : wxView()
    {
        frame = NULL;
        window = NULL;
    }
    ~mAChuckView() {}

    void SetMiniAudicle( miniAudicle * ma );

    bool OnCreate( wxDocument *doc, long flags );
    void OnDraw( wxDC * dc );
    void OnUpdate( wxView * sender, wxObject * hint = ( wxObject * ) NULL );
    void OnChangeFilename();
    void SetModified( bool modified );
    bool OnClose( bool deleteWindow = true );

    void Add();
    void Remove();
    void Replace();
    
    void OnVMStart();
    void OnVMStop();
    
    void EditingPreferencesChanged();
    void SyntaxColoringPreferencesChanged();
    
private:
    t_CKUINT docid;
    wxTextCtrl * arguments_text;
    int menuid;
    miniAudicle * ma;
    bool is_modified;

#ifdef __WINDOWS_DS__
    wxToolBar * otf_toolbar;
#endif

    DECLARE_DYNAMIC_CLASS( mAChuckView )
};

#endif /* __MA_VIEW_H__ */

