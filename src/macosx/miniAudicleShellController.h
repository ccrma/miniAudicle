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
// file: miniAudicleShellController.mm
// desc: Mac OS X specific shell interface code
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#ifndef __MINIAUDICLESHELLCONTROLLER_H__
#define __MINIAUDICLESHELLCONTROLLER_H__

#import <Cocoa/Cocoa.h>
#import <pthread.h>

class miniAudicle_Shell_UI;
class Chuck_Shell;
@class miniAudicleShellTextView;

//-----------------------------------------------------------------------------
// name: miniAudicleShellController
// desc: Controller class for shell window of miniAudicle
//-----------------------------------------------------------------------------

@interface miniAudicleShellController : NSObject
{
    Chuck_Shell * shell;
    miniAudicle_Shell_UI * ui;
    pthread_t shell_tid;
    
    NSWindow * panel;
    miniAudicleShellTextView * text_view;
    NSMutableString * data;
    
    NSFileHandle * read_pipe;
    NSFileHandle * write_pipe;
}

//-----------------------------------------------------------------------------
// name: init
// desc: initialization routine, called for each instance
//-----------------------------------------------------------------------------
- (id)init;

//-----------------------------------------------------------------------------
// name: toggleIsActive
// desc: called when the "ChucK shell" menu item is selected; activates the 
//       when it is inactive, or closes it if it is active
//-----------------------------------------------------------------------------
- (void)toggleIsActive:(id)sender;

//-----------------------------------------------------------------------------
// name: writeData
// desc: callback function for when data is available on the 
//-----------------------------------------------------------------------------
- (void)writeData:(NSNotification *)n;
- (void)readData:(NSNotification *)n;
- (void)closeOpenFiles:(NSNotification *)n;

@end

#endif // __MINIAUDICLESHELLCONTROLLER_H__
