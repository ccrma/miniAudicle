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
// file: mAMenuBar.h
// desc: Creates and manages the miniAudicle menubar
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#ifndef __MA_MENUBAR_H__
#define __MA_MENUBAR_H__

#include "wx/menu.h"

#include "chuck_def.h"

class mAMenuBar : public wxMenuBar
{
public:
    mAMenuBar();
    ~mAMenuBar();

    wxMenu * GetFileHistoryMenu();
    void OnVMStart();
    void OnVMStop();
    void SetLogLevel( t_CKUINT log_level );

    int AddWindow( const wxString & name );
    void ChangeWindow( int id, const wxString & name );
    void RemoveWindow( int id );
    void SynchronizeWindowMenuTo( mAMenuBar * menu );
    
private:
    t_CKBOOL vm_on;
    wxMenu * file_history_menu;
    wxMenu * chuck_menu;
    wxMenu * log_menu;

    wxMenu * window_menu;
    wxMenuItem * window_menu_separator;
    int last_id;
    t_CKUINT window_menu_items;
};

#endif /* __MA_MENUBAR_H__ */
