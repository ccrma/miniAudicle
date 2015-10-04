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
// file: miniAudicleConsoleMonitor.mm
// desc: pipes stdin and stderr to itself and display their contents on-screen
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import "miniAudicleConsoleMonitor.h"
#import "miniAudiclePreferencesController.h"
#import "mAConsoleMonitorView.h"
#import <unistd.h>
#import "chuck_errmsg.h"

//#define __USE_NEW_CONSOLE_MONITOR__ 1
#undef __CK_DEBUG__
@implementation miniAudicleConsoleMonitor

//-----------------------------------------------------------------------------
// name: init
// desc: initializer, called upon upon instantiation
//-----------------------------------------------------------------------------
- (id)init
{
    if( self = [super init] )
    {
        _useCustomConsoleMonitor = YES;
        
        if(NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max)
            // OS X 10.11 and greater
            _useCustomConsoleMonitor = NO;
        
        NSNumber * useCustom = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesUseCustomConsoleMonitor];
        if(useCustom != nil)
            _useCustomConsoleMonitor = [useCustom boolValue];
        
#ifndef __CK_DEBUG__
        int fd[2];
        
        if( pipe( fd ) )
        {
            //unable to create the pipe!
            return self;
        }
        
        dup2( fd[1], STDOUT_FILENO );
        
        std_out = [[NSFileHandle alloc] initWithFileDescriptor:fd[0]];
        [std_out waitForDataInBackgroundAndNotifyForModes:[NSArray arrayWithObjects:
            NSDefaultRunLoopMode, 
            NSConnectionReplyMode,
            NSModalPanelRunLoopMode,
            NSEventTrackingRunLoopMode,
            nil
            ]];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readData:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:std_out];
        
        if(setlinebuf(stdout))
        {
            EM_log(CK_LOG_SYSTEM, "(miniAudicle): unable to set chout buffering to line-based");
        }
        
        if( pipe( fd ) )
        {
            //unable to create the pipe!
            return self;
        }
        
        dup2( fd[1], STDERR_FILENO );
        
        std_err = [[NSFileHandle alloc] initWithFileDescriptor:fd[0]];
        [std_err waitForDataInBackgroundAndNotifyForModes:[NSArray arrayWithObjects:
            NSDefaultRunLoopMode, 
            NSConnectionReplyMode,
            NSModalPanelRunLoopMode,
            NSEventTrackingRunLoopMode,
            nil
            ]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readData:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:std_err];
#endif

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferencesChanged:)
                                                     name:mAPreferencesChangedNotification
                                                   object:nil];
        scrollback_size = 10000;
        NSNumber * sbs = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesScrollbackBufferSize];
        if( sbs != nil )
            scrollback_size = [sbs intValue];
        if(scrollback_size == 0)
            scrollback_size = 10000;
    }
    
    return self;
}

//-----------------------------------------------------------------------------
// name: awakeFromNib
// desc: called after the nib resource file has been completely loaded.  since
//       text_view is defined in the nib file, it is not guaranteed to be a 
//       non-nil value until the nib file has been fully loaded.  
//-----------------------------------------------------------------------------
- (void)awakeFromNib
{
    if(_useCustomConsoleMonitor)
        panel = new_panel;
    else
    {
        [text_view setFont:[NSFont fontWithName:@"Monaco" size:10]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boundsOrFrameDidChange:)
                                                     name:NSViewFrameDidChangeNotification
                                                   object:text_view];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boundsOrFrameDidChange:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:text_view];
        [text_view setPostsFrameChangedNotifications:YES];
    }
}

//-----------------------------------------------------------------------------
// name: activateMonitor
// desc: send the monitor to the front
//-----------------------------------------------------------------------------
- (void)activateMonitor
{
    [panel makeKeyAndOrderFront:self];
}

//-----------------------------------------------------------------------------
// name: toggleIsActive
// desc: send the monitor to the front; if its already in front, close it
//-----------------------------------------------------------------------------
- (void)toggleIsActive:(id)sender
{
    if( [panel isKeyWindow] )
        [panel close];
    
    else
        [panel makeKeyAndOrderFront:sender];    
}

//-----------------------------------------------------------------------------
// name: readData
// desc: called by the NSNotificationCenter when data is available for read on
//       either of the pipes.  [n object] points to the pipe which raises the
//       notification.  
//-----------------------------------------------------------------------------
- (void)readData:(NSNotification *)n
{
    NSString * t_string = [[NSString alloc] initWithData:[[n object] availableData]
                                                encoding:NSASCIIStringEncoding];
    
    [t_string autorelease];
    
    [[n object] waitForDataInBackgroundAndNotifyForModes:[NSArray arrayWithObjects:
        NSDefaultRunLoopMode, 
        NSConnectionReplyMode,
        NSModalPanelRunLoopMode,
        NSEventTrackingRunLoopMode,
        nil
        ]];
    
    
    if(_useCustomConsoleMonitor)
    {
        //printf( "%s", [t_string cString] );
        [view appendString:t_string];
    }
    else
    {
        // append the string to the text view
        NSTextStorage * ts = [text_view textStorage];
        //    [ts replaceCharactersInRange:NSMakeRange( [ts length], 0 )
        //                      withString:t_string];
        [ts appendAttributedString:[[NSAttributedString alloc] initWithString:t_string
                                                                   attributes:@{
                                                                                NSFontAttributeName: [NSFont fontWithName:@"Monaco" size:10]
                                                                                }]];
        //    [text_view setFont:[NSFont fontWithName:@"Monaco" size:10]];
        
        // delete lines in excess of the buffer size
        NSString * text = [text_view string];
        unsigned len = [text length];
        if( len > scrollback_size )
        {
            NSRange range = NSMakeRange( 0, len - scrollback_size );
            NSUInteger line_end;
            [text getLineStart:NULL end:&line_end
                   contentsEnd:NULL forRange:range];
            range.length = line_end;
            [ts deleteCharactersInRange:range];
        }
        
        [text_view setNeedsDisplay:YES];
    }
}

//-----------------------------------------------------------------------------
// name: boundsOrFrameDidChange
// desc: called whenever the size of the console changes, i.e. text has been 
// appended requiring a scroll to the end
//-----------------------------------------------------------------------------
- (void)boundsOrFrameDidChange:(NSNotification *)n
{
    if(_useCustomConsoleMonitor)
    { }
    else
    {
        [text_view scrollRectToVisible:NSMakeRect( 0.0, NSMaxY( [text_view frame] ),
                                                  1.0, 0.0 )];
    }
}

//-----------------------------------------------------------------------------
// name: clearBuffer
// desc: clears the console buffer
//-----------------------------------------------------------------------------
- (void)clearBuffer:(id)sender
{
    if(_useCustomConsoleMonitor)
    {
        [view clear];
    }
    else
    {
        NSMutableString * s = [[text_view textStorage] mutableString];
        [s deleteCharactersInRange:NSMakeRange( 0, [s length] )];
    }
}

//-----------------------------------------------------------------------------
// name: preferencesChanged
// desc: called when a user changes preferences
//-----------------------------------------------------------------------------
- (void)preferencesChanged:(NSNotification *)n
{
    NSNumber *sbs = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesScrollbackBufferSize];
    if( sbs != nil )
        scrollback_size = [sbs intValue];
    if(scrollback_size == 0)
        scrollback_size = 10000;
}

@end
