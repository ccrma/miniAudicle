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
// file: mAConsoleMonitorView.mm
// desc: controller class for miniAudicle GUI
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Winter 2007
//-----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

struct mAConsoleMonitorViewIndex
{
    unsigned string;    // index in strings
    unsigned character; // index in [strings objectAtIndex:string]
};

struct mAConsoleMonitorViewRange
{
    mAConsoleMonitorViewIndex start;
    mAConsoleMonitorViewIndex finish;
};

@interface mAConsoleMonitorView : NSView
{
    NSMutableArray * strings;
    unsigned num_lines; // not necessarily [strings count]
    
    NSFont * font;
    NSMutableParagraphStyle * paragraph_style;
    NSMutableDictionary * attributes;
    
    NSMutableArray * optimization_data;
    
    float text_width;
    float line_height;
    float left_margin, right_margin;
    
    unsigned chars_per_line;
    
    NSMutableAttributedString * append_to;
    
    mAConsoleMonitorViewRange selected_range;
    mAConsoleMonitorViewRange start_range;
    
    NSTimer * scroll_timer;
}

- (void)appendString:(NSString *)aString;
- (void)clear;

@end
