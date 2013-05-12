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

#import "miniAudicleShellController.h"
#import "miniAudicleShellTextView.h"
#import "miniAudicle_shell.h"

extern Chuck_VM * g_vm;

@interface miniAudicleShellController (Private)
- (void)runShell;
@end

@implementation miniAudicleShellController

- (id)init
{
    if( [super init] )
    {
        ui = new miniAudicle_Shell_UI();
        ui->init();
        
        read_pipe = [[NSFileHandle alloc] initWithFileDescriptor:ui->get_ui_read_fd()];
        write_pipe = [[NSFileHandle alloc] initWithFileDescriptor:ui->get_ui_write_fd()];
        
        [read_pipe waitForDataInBackgroundAndNotify];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readData:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:read_pipe];
        
        shell = new Chuck_Shell();
        shell->init( g_vm, ui );
        [self runShell];
        
        data = [[NSMutableString alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(closeOpenFiles:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(writeData:)
                                                     name:@"mAShellTextViewDataAvailable"
                                                   object:nil];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [text_view setFont:[NSFont fontWithName:@"Monaco" size:10]];
    [text_view startLine];
}

- (void)toggleIsActive:(id)sender
{
    if( [panel isKeyWindow] )
        [panel close];
    
    else
    {
        [panel makeKeyAndOrderFront:sender];
    }
}

- (void)writeData:(NSNotification *)n
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(writeData:)
                                                 name:@"mAShellTextViewDataAvailable"
                                               object:nil]; 
    [write_pipe writeData:[[text_view lineData] dataUsingEncoding:NSASCIIStringEncoding]];

    [text_view startLine];
}

- (void)readData:(NSNotification *)n
{   
    NSString * t_string = [[NSString alloc] initWithData:[[n object] availableData] encoding:NSASCIIStringEncoding];
    [t_string autorelease];
    [[n object] waitForDataInBackgroundAndNotify];
    [text_view appendString:t_string];
}

- (void)closeOpenFiles:(NSNotification *)n;
{
    [write_pipe closeFile];
}

@end

@implementation miniAudicleShellController (Private)
- (void)runShell
{
    shell_tid = 0;
    if( pthread_create( &shell_tid, NULL, shell_cb, ( void * )shell ) )
    {
        fprintf( stderr, "error: unable to spawn ChucK shell thread\n" );
    }
}

@end

