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
// file: mAMenuBar.cpp
// desc: Creates and manages the miniAudicle menubar
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"

#include "mAMenuBar.h"
#include "mAParentFrame.h"
#include "mAEvents.h"

#include "icons/add.xpm"
#include "icons/remove.xpm"
#include "icons/replace.xpm"

mAMenuBar::mAMenuBar() : wxMenuBar()
{
    vm_on = FALSE;

    wxMenu * file_menu = new wxMenu;
    wxMenu * edit_menu = new wxMenu;
    chuck_menu = new wxMenu;
    log_menu = new wxMenu;
    window_menu = new wxMenu;
    wxMenu * help_menu = new wxMenu;
    file_history_menu = new wxMenu;
    
    file_menu->Append( wxID_NEW, _T( "&New\tCtrl+N" ) );
    file_menu->Append( wxID_OPEN, _T( "&Open...\tCtrl+O" ) );
    file_menu->Append( wxID_CLOSE, _T( "&Close\tCtrl+W" ) );

    file_menu->AppendSeparator();
    file_menu->Append( wxID_SAVE, _T( "&Save\tCtrl+S" ) );
    file_menu->Append( wxID_SAVEAS, _T( "Save &As...\tShift+Ctrl+S" ) );

    //file_menu->AppendSeparator();
    //file_menu->Append( wxID_PREVIEW, _T( "Print Pre&view" ) );
    //file_menu->Append( wxID_PRINT, _T( "&Print...\tCtrl+P" ) );

    file_menu->AppendSeparator();
    file_menu->Append( wxID_ANY, _T( "Recent &Files..." ), 
        file_history_menu );

    file_menu->AppendSeparator();
    file_menu->Append( wxID_EXIT, _T( "E&xit\tAlt+X" ) );

    edit_menu->Append( mAID_UNDO, _T( "&Undo\tCtrl+Z" ) );
    edit_menu->Append( mAID_REDO, _T( "&Redo\tCtrl+Y" ) );
    edit_menu->AppendSeparator();
    edit_menu->Append( mAID_CUT, _T( "Cu&t\tCtrl+X" ) );
    edit_menu->Append( mAID_COPY, _T( "&Copy\tCtrl+C" ) );
    edit_menu->Append( mAID_PASTE, _T( "&Paste\tCtrl+V" ) );
//  edit_menu->Append( mAID_DELETE, _T( "&Delete\tDel" ) );
    edit_menu->AppendSeparator();
    edit_menu->Append( mAID_SELECTALL, _T( "Select A&ll\tCtrl+A" ) );
    edit_menu->AppendSeparator();
    edit_menu->Append( mAID_PREFERENCES, _T( "Pre&ferences...\tAlt+," ) );

    chuck_menu->Append( mAID_ADD, _T( "&Add Shred\tAlt++" ) );
    chuck_menu->Append( mAID_REPLACE, _T( "Re&place Shred\tAlt+=" ) );
    chuck_menu->Append( mAID_REMOVE, _T( "&Remove Shred\tAlt+-" ) );
    chuck_menu->AppendSeparator();
    chuck_menu->Append( mAID_ADD_ALL_OPEN_DOCUMENTS, _T( "Add All Open Documents\tAlt+Ctrl++" ) );
    chuck_menu->Append( mAID_REPLACE_ALL_OPEN_DOCUMENTS, _T( "Re&place All Open Documents\tAlt+Ctrl+=" ) );
    chuck_menu->Append( mAID_REMOVE_ALL_OPEN_DOCUMENTS, _T( "&Remove All Open Documents\tAlt+Ctrl+-" ) );
    chuck_menu->AppendSeparator();
    chuck_menu->Append( mAID_REMOVELAST, _T( "Remove &Last Shred" ) );
    chuck_menu->Append( mAID_REMOVEALL, _T( "Remove All Shreds\tAlt+DEL" ) );
    chuck_menu->AppendSeparator();
    chuck_menu->Append( mAID_ABORT_CURRENT_SHRED, _T( "Abort Currently Running Shred\tAlt+K" ) );
    chuck_menu->AppendSeparator();
    chuck_menu->Append( mAID_TOGGLE_VM, _T( "&Start Virtual Machine\tAlt+." ) );
    
    log_menu->AppendCheckItem( mAID_LOG + 0, _T( "&None" ) );
    log_menu->AppendCheckItem( mAID_LOG + 1, _T( "&Core" ) );
    log_menu->AppendCheckItem( mAID_LOG + 2, _T( "&System" ) );
    log_menu->AppendCheckItem( mAID_LOG + 3, _T( "S&evere" ) );
    log_menu->AppendCheckItem( mAID_LOG + 4, _T( "&Warning" ) );
    log_menu->AppendCheckItem( mAID_LOG + 5, _T( "&Info" ) );
    log_menu->AppendCheckItem( mAID_LOG + 6, _T( "C&onfig" ) );
    log_menu->AppendCheckItem( mAID_LOG + 7, _T( "&Fine" ) );
    log_menu->AppendCheckItem( mAID_LOG + 8, _T( "F&iner" ) );
    log_menu->AppendCheckItem( mAID_LOG + 9, _T( "Fi&nest" ) );
    log_menu->AppendCheckItem( mAID_LOG + 10, _T( "Cra&zy" ) );
    chuck_menu->Append( mAID_LOG, _T( "&Log Level" ), log_menu );
    
    chuck_menu->Enable( mAID_ADD, false );
    chuck_menu->Enable( mAID_REMOVE, false );
    chuck_menu->Enable( mAID_REPLACE, false );
    chuck_menu->Enable( mAID_ADD_ALL_OPEN_DOCUMENTS, false );
    chuck_menu->Enable( mAID_REMOVE_ALL_OPEN_DOCUMENTS, false );
    chuck_menu->Enable( mAID_REPLACE_ALL_OPEN_DOCUMENTS, false );
    chuck_menu->Enable( mAID_REMOVELAST, false );
    chuck_menu->Enable( mAID_REMOVEALL, false );
    chuck_menu->Enable( mAID_ABORT_CURRENT_SHRED, false );

    window_menu->Append( mAID_WINDOW_VM, _T( "&Virtual Machine Monitor\tCtrl+1" ) );
    window_menu->Append( mAID_WINDOW_CONSOLE, _T( "&Console Monitor\tCtrl+2" ) );
    window_menu_separator = new wxMenuItem( window_menu );

#if wxABI_VERSION > 20600 || !defined( __LINUX__ )
    help_menu->Append( mAID_MINIWEB, _T( "miniAudicle Website..." ) );
    help_menu->Append( mAID_CHUCKWEB, _T( "ChucK Website..." ) );
    help_menu->AppendSeparator();
#endif
    help_menu->Append( wxID_ABOUT, _T( "About miniAudicle" ) );

    this->Append( file_menu, _T( "&File" ) );
    this->Append( edit_menu, _T( "&Edit" ) );
    this->Append( chuck_menu, _T( "&ChucK" ) );
    this->Append( window_menu, _T( "&Window" ) );
    this->Append( help_menu, _T( "&Help" ) );

    last_id = mAID_WINDOW_CONSOLE;
    window_menu_items = 0;
}

mAMenuBar::~mAMenuBar()
{
    // tell the main app to remove this menu bar from its list of menu bars
    // to update, so it wont try to update this instance
    wxGetApp().RemoveMenuBar( this );
}

wxMenu * mAMenuBar::GetFileHistoryMenu()
{
    return file_history_menu;
}

void mAMenuBar::OnVMStart()
{
    vm_on = TRUE;

    chuck_menu->Enable( mAID_ADD, true );
    chuck_menu->Enable( mAID_REMOVE, true );
    chuck_menu->Enable( mAID_REPLACE, true );
    chuck_menu->Enable( mAID_ADD_ALL_OPEN_DOCUMENTS, true );
    chuck_menu->Enable( mAID_REMOVE_ALL_OPEN_DOCUMENTS, true );
    chuck_menu->Enable( mAID_REPLACE_ALL_OPEN_DOCUMENTS, true );
    chuck_menu->Enable( mAID_REMOVELAST, true );
    chuck_menu->Enable( mAID_REMOVEALL, true );
    chuck_menu->Enable( mAID_ABORT_CURRENT_SHRED, true );

    chuck_menu->FindItem( mAID_TOGGLE_VM )->SetText( _T( "&Stop Virtual Machine\tAlt+." ) );
#ifdef __WINDOWS_DS__
    chuck_menu->FindItem( mAID_TOGGLE_VM )->Enable( false );
#endif
}

void mAMenuBar::OnVMStop()
{
    vm_on = FALSE;

    chuck_menu->Enable( mAID_ADD, false );
    chuck_menu->Enable( mAID_REMOVE, false );
    chuck_menu->Enable( mAID_REPLACE, false );
    chuck_menu->Enable( mAID_ADD_ALL_OPEN_DOCUMENTS, false );
    chuck_menu->Enable( mAID_REMOVE_ALL_OPEN_DOCUMENTS, false );
    chuck_menu->Enable( mAID_REPLACE_ALL_OPEN_DOCUMENTS, false );
    chuck_menu->Enable( mAID_REMOVELAST, false );
    chuck_menu->Enable( mAID_REMOVEALL, false );
    chuck_menu->Enable( mAID_ABORT_CURRENT_SHRED, false );

    chuck_menu->FindItem( mAID_TOGGLE_VM )->SetText( _T( "&Start Virtual Machine\tAlt+." ) );

}

void mAMenuBar::SetLogLevel( t_CKUINT log_level )
{
    for( int i = mAID_LOG; i <= mAID_LOG_HIGHEST; i++ )
    {
        log_menu->Check( i, ( i - mAID_LOG == log_level ) );
    }
}

int mAMenuBar::AddWindow( const wxString & name )
{
    if( window_menu_items == 0 )
        window_menu->Append( window_menu_separator );

    window_menu->Append( ++last_id, name );
    window_menu_items++;

    return last_id;
}

void mAMenuBar::ChangeWindow( int id, const wxString & name )
{
    window_menu->SetLabel( id, name );
}

void mAMenuBar::RemoveWindow( int id )
{
    wxMenuItem * item = window_menu->Remove( id );
    delete item;
    window_menu_items--;
    if( window_menu_items == 0 )
        window_menu->Remove( window_menu_separator );
}

void mAMenuBar::SynchronizeWindowMenuTo( mAMenuBar * menu )
// assumes that window_menu only has the original two items
{
    size_t len = menu->window_menu->GetMenuItemCount(), i = 0;

    if( len > 3 )
    // if the window menu has less than 4 items, there is nothing to synchronize
    {
        if( window_menu_items == 0 )
            window_menu->Append( window_menu_separator );

        for( i = 3; i < len; i++ )
        {
            wxMenuItem * item = menu->window_menu->FindItemByPosition( i );
            window_menu->Append( item->GetId(), item->GetText() );
        }
    }

    window_menu_items = menu->window_menu_items;
    last_id = menu->last_id;
}

