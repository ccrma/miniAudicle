/*----------------------------------------------------------------------------
miniAudicle
Cocoa GUI to chuck audio programming environment

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
// file: miniAudicle_Shell.cpp
// desc: Chuck_Shell_UI subclass for use in miniAudicle
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#include "miniAudicle_shell.h"

t_CKBOOL miniAudicle_Shell_UI::init()
{
    int fd[2];
    if( pipe( fd ) )
    {
        return FALSE;
    }
    
    ui_read_fd = fd[0];
    shell_write_fd = fdopen( fd[1], "w" );
    
    if( pipe( fd ) )
    {
        return FALSE;
    }
    
    shell_read_fd = fdopen( fd[0], "r" );
    ui_write_fd = fd[1];
    
    return TRUE;
}

t_CKBOOL miniAudicle_Shell_UI::next_command( const string & prompt, string & command )
{
    fprintf( shell_write_fd, "%s", prompt.c_str() );
    fflush( shell_write_fd );

    char buf[255];
    fgets( buf, 255, shell_read_fd );

    command = string( buf );

    return TRUE;
}

void miniAudicle_Shell_UI::next_result( const string & result)
{
    fprintf( shell_write_fd, "%s", result.c_str() );
    fflush( shell_write_fd );
}

int miniAudicle_Shell_UI::get_ui_write_fd()
{
    return ui_write_fd;
}

int miniAudicle_Shell_UI::get_ui_read_fd()
{
    return ui_read_fd;
}

