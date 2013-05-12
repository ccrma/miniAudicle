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
// file: miniAudicle_Shell.h
// desc: Chuck_Shell_UI subclass for use in miniAudicle
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#ifndef __MINIAUDICLE_SHELL_H__
#define __MINIAUDICLE_SHELL_H__

#include "chuck_shell.h"

class miniAudicle_Shell_UI : public Chuck_Shell_UI
{
public:
    t_CKBOOL init();
    t_CKBOOL next_command( const string &, string & );
    void next_result( const string & );
    
    int get_ui_read_fd();
    int get_ui_write_fd();
    
private:
        int ui_read_fd;
    int ui_write_fd;
    FILE * shell_read_fd;
    FILE * shell_write_fd;
    
};

#endif //__MINIAUDICLE_SHELL_H__
