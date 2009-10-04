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
// file: mAConfig.cpp
// desc: wxConfig subclass for handling volatile configuration preferences
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"

#include <wx/wx.h>

#include "mAConfig.h"

mAConfig::mAConfig() : wxConfig()
{}

bool mAConfig::DoReadString( const wxString & key, wxString * pStr ) const
{
    std::map< wxString, wxString >::const_iterator i = clargs.find( key );
    
    if( i != clargs.end() )
    {
        *pStr = (*i).second;
        return true;
    }
    
    else
        return wxConfig::DoReadString( key, pStr );
    
    return false;
}

bool mAConfig::DoReadLong( const wxString & key, long * pl ) const
{
    std::map< wxString, wxString >::const_iterator i = clargs.find( key );
    if( i != clargs.end() )
    {
        if( (*i).second.ToLong( pl ) )
            return true;
    }
    
    else
        return wxConfig::DoReadLong( key, pl );
    
    return false;
}

/*
bool DoReadInt( const wxString & key, int * pi ) const;
bool DoReadDouble( const wxString & key, double * val ) const;
bool DoReadBool( const wxString & key, bool * val ) const;
*/  

bool mAConfig::WriteCommandLineArgument( const wxString & key, 
                                         const wxString & value )
{
    clargs[key] = value;
    return true;
}

bool mAConfig::WriteCommandLineArgument( const wxString & key, long l )
{
    wxString s;
    s.Printf( _T( "%i" ), l );
    clargs[key] = s;
    return true;
}

bool mAConfig::WriteCommandLineArgument( const wxString & key, double d )
{
    wxString s;
    s.Printf( _T( "%f" ), d );
    clargs[key] = s;
    return true;
}

bool mAConfig::WriteCommandLineArgument( const wxString & key, bool b )
{
    wxString s;
    s.Printf( _T( "%i" ), b ? 1 : 0 ); 
    clargs[key] = s;
    return true;
}




