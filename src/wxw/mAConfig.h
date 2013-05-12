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
// file: mAConfig.h
// desc: wxConfig subclass for handling volatile configuration preferences
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#ifndef __MA_CONFIG_H__
#define __MA_CONFIG_H__

#include "wx/config.h"

#include <map>

class mAConfig : public wxConfig
{
public:
    mAConfig();
    
    virtual bool WriteCommandLineArgument( const wxString & key, const wxString & value );
    virtual bool WriteCommandLineArgument( const wxString & key, long value );
    virtual bool WriteCommandLineArgument( const wxString & key, double value );
    virtual bool WriteCommandLineArgument( const wxString & key, bool value );
    
protected:
    virtual bool DoReadString( const wxString & key, wxString * pStr ) const;
    virtual bool DoReadLong( const wxString & key, long * pl ) const;
    /*
    virtual bool DoReadInt( const wxString & key, int * pi ) const;
    virtual bool DoReadDouble( const wxString & key, double * val ) const;
    virtual bool DoReadBool( const wxString & key, bool * val ) const;
    */
    std::map< wxString, wxString > clargs;
};

#endif // __MA_CONFIG_H__
