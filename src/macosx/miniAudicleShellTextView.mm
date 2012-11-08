/*----------------------------------------------------------------------------
miniAudicle
Cocoa GUI to chuck audio programming environment

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
// file: miniAudicleShellTextView.mm
// desc: NSTextView subclass to support console-like text I/O in a text view
//
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import "miniAudicleShellTextView.h"

@implementation miniAudicleShellTextView

- (id)init
{
    if( self = [super init] )
    {
        line_data = nil;
        [self startLine];
    }
    
    return self;
}

- (void)dealloc
{
    if( line_data != nil )
        [line_data release];
    [super dealloc];
}

- (void)startLine
{
    if( line_data != nil )
        [line_data release];
    line_data = [NSMutableString new];
}

- (NSString *)lineData
{
    return line_data;
}

- (void)keyDown:(NSEvent *)e
{   
    char character = [[e characters] UTF8String][0];
    
    if( character == NSDeleteCharacter )
        // backspace
    {
        if( [line_data length] > 0 )
        {
            [[self textStorage] deleteCharactersInRange:NSMakeRange( [[self textStorage] length] - 1, 1 )];
            [line_data deleteCharactersInRange:NSMakeRange( [line_data length] - 1, 1 )];
            [self appendString:@""];
        }
    }
    
    else if( character == NSCarriageReturnCharacter )
        // new line/carriage return
    {
        [line_data appendString:@"\n"];
        [self appendString:@"\n"];
        
        NSNotification * n = [NSNotification notificationWithName:@"mAShellTextViewDataAvailable"
                                                           object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
    
    else
    {
        [self appendString:[e characters]];
        [line_data appendString:[e characters]];
    }
    
}

- (void)appendString:(NSString *)s
{
    NSTextStorage * text_storage = [self textStorage];
    NSMutableAttributedString * t_mastring = [[NSMutableAttributedString alloc] initWithString:s];
    [t_mastring autorelease];
    
    // first delete the cursor
    if( [text_storage length] > 0 )
        [text_storage deleteCharactersInRange:NSMakeRange( [text_storage length] - 1, 1 )];

    // append the data
    [text_storage appendAttributedString:t_mastring];
    
    // append the cursor
    [t_mastring initWithString:@"_"];
    [text_storage appendAttributedString:t_mastring];
    [text_storage setFont:[NSFont fontWithName:@"Monaco" size:10]];
    
    //[self setString:text_data];
    [self scrollRangeToVisible:NSMakeRange( [text_storage length] - 1, 1 )];
}

@end
