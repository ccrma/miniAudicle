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
// file: mADocument.cpp
// desc: ChucK source document definition
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"

#include "wx/wx.h"
#include "wx/txtstrm.h"

#include "mADocument.h"
#include "mAView.h"

IMPLEMENT_DYNAMIC_CLASS( mAChuckDocument, wxDocument )

bool mAChuckDocument::OnSaveDocument( const wxString & filename )
{
    mAChuckView * view = ( mAChuckView * ) GetFirstView();

    if( !view->window->SaveFile( filename ) )
        return false;
    Modify( false );
    m_savedYet = true;
    return true;
}

bool mAChuckDocument::OnOpenDocument( const wxString & filename )
{
    mAChuckView * view = ( mAChuckView * ) GetFirstView();
    if( !view->window->LoadFile( filename ) )
        return false;

    SetFilename( filename, true );
    Modify( false );
    UpdateAllViews();
    m_savedYet = true;
    return true;
}

bool mAChuckDocument::IsModified() const
{
    mAChuckView * view = ( mAChuckView * ) GetFirstView();

    if( view && view->window )
        return ( wxDocument::IsModified() || view->window->GetModify() );
    else
        return wxDocument::IsModified();
}

void mAChuckDocument::Modify( bool mod )
{
    mAChuckView * view = ( mAChuckView * ) GetFirstView();

    wxDocument::Modify( mod );
    
    if( view )
    {
        view->SetModified( mod );
        
        if( !mod && view->window )
#ifdef __LINUX__
            view->window->SaveFile( _T( "/dev/null" ) );
#else
            view->window->SaveFile( _T( "NUL" ) );
#endif
    }
}
