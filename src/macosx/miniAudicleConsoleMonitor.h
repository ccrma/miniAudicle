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
// file: miniAudicleConsoleMonitor.h
// desc: pipes stdin and stderr to itself and display their contents on-screen
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class mAConsoleMonitorView;
@class miniAudicleController;

//-----------------------------------------------------------------------------
// name: miniAudicleConsoleMonitor
// desc: controller class for stderr/stdout log
//-----------------------------------------------------------------------------
@interface miniAudicleConsoleMonitor : NSObject
{
    // the window that this appears in
    IBOutlet NSWindow * panel;
    // for the stderr/stdout text
    IBOutlet NSTextView * text_view;
    // for implementing/debugging new console monitor
    IBOutlet NSWindow * new_panel;
    // for implementing/debugging new console monitor
    IBOutlet mAConsoleMonitorView * view;
    IBOutlet miniAudicleController * mac;

    bool _useCustomConsoleMonitor;
    
    
    unsigned scrollback_size; // number of bytes to keep in the buffer
    
    NSFileHandle * _readFileHandle;
}

- (id)init;
- (void)awakeFromNib;
- (void)activateMonitor;
- (void)toggleIsActive:(id)sender;
- (void)readData:(NSNotification *)n;
- (void)boundsOrFrameDidChange:(NSNotification *)n;
- (void)preferencesChanged:(NSNotification *)n;
@end
