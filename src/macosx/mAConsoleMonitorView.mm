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

#import "mAConsoleMonitorView.h"

static void debug_fprintf( FILE * f, const char * fmt, ... )
{
#ifdef __CK_DEBUG__
    va_list ap;
    va_start( ap, fmt );
    vfprintf( f, fmt, ap );
    va_end( ap );
#endif
}

static void debug_printf( const char * fmt, ... )
{
#ifdef __CK_DEBUG__
    va_list ap;
    va_start( ap, fmt );
    vfprintf( stdout, fmt, ap );
    va_end( ap );
#endif
}

mAConsoleMonitorViewIndex mAConsoleMonitorViewIndexMax()
{
    mAConsoleMonitorViewIndex i = { UINT_MAX, UINT_MAX };
    return i;
}

bool operator< ( mAConsoleMonitorViewIndex i1, mAConsoleMonitorViewIndex i2 )
{
    if( i1.string < i2.string )
        return true;
    if( i1.string == i2.string &&
        i1.character < i2.character )
        return true;
    
    return false;
}

bool operator> ( mAConsoleMonitorViewIndex i1, mAConsoleMonitorViewIndex i2 )
{
    if( i1.string > i2.string )
        return true;
    if( i1.string == i2.string &&
        i1.character > i2.character )
        return true;
    
    return false;
}

bool operator== ( mAConsoleMonitorViewIndex i1, mAConsoleMonitorViewIndex i2 )
{
    return memcmp( &i1, &i2, sizeof( mAConsoleMonitorViewIndex ) ) == 0;
}

BOOL mAConsoleMonitorViewRangeLengthIsZero( mAConsoleMonitorViewRange r )
{
    if( r.start.string == r.finish.string &&
        r.start.character == r.finish.character )
        return YES;
    return NO;
}

bool operator== ( mAConsoleMonitorViewRange r1, mAConsoleMonitorViewRange r2 )
{
    return memcmp( &r1, &r2, sizeof( mAConsoleMonitorViewRange ) ) == 0;
}

BOOL mAConsoleMonitorViewRangesAreEqual( mAConsoleMonitorViewRange r1, 
                                         mAConsoleMonitorViewRange r2 )
{
    return memcmp( &r1, &r2, sizeof( mAConsoleMonitorViewRange ) ) == 0;
}

mAConsoleMonitorViewRange mAConsoleMonitorViewRangeZero()
{
    mAConsoleMonitorViewRange r = { { 0, 0 }, { 0, 0 } };
    return r;
}

mAConsoleMonitorViewRange mAConsoleMonitorViewRangeMax()
{
    mAConsoleMonitorViewRange r = { { UINT_MAX, UINT_MAX }, 
                                    { UINT_MAX, UINT_MAX } };
    
    return r;
}

mAConsoleMonitorViewRange operator+ ( mAConsoleMonitorViewRange r1,
                                      mAConsoleMonitorViewRange r2 )
/* more of a union operation than addition */
{
    mAConsoleMonitorViewRange u = { { 0, 0 }, { 0, 0 } };
    
    if( r1.start.string < r2.start.string )
    {
        u.start.string = r1.start.string;
        u.start.character = r1.start.character;
    }
    
    else if( r2.start.string < r1.start.string )
    {
        u.start.string = r2.start.string;
        u.start.character = r2.start.character;
    }
    
    else
    {
        if( r1.start.character < r2.start.character )
        {
            u.start.string = r1.start.string;
            u.start.character = r1.start.character;
        }
        
        else
        {
            u.start.string = r2.start.string;
            u.start.character = r2.start.character;
        }
    }
    
    if( r1.finish.string > r2.finish.string )
    {
        u.finish.string = r1.finish.string;
        u.finish.character = r1.finish.character;
    }
    
    else if( r2.finish.string > r1.finish.string )
    {
        u.finish.string = r2.finish.string;
        u.finish.character = r2.finish.character;
    }
    
    else
    {
        if( r1.finish.character > r2.finish.character )
        {
            u.finish.string = r1.finish.string;
            u.finish.character = r1.finish.character;
        }
        
        else
        {
            u.finish.string = r2.finish.string;
            u.finish.character = r2.finish.character;
        }
    }
    
    return u;
}

mAConsoleMonitorViewRange operator- ( mAConsoleMonitorViewRange r1,
                                      mAConsoleMonitorViewRange r2 )
/* subtraction of ranges is kind of weird and isn't exactly intuitively related
   to arithmetic subtraction.  so for our purposes we will define range 
   subtraction for r1 and r2, where r2 either starts exactly at the beginning 
   of r1 or ends exactly at the end of r1, as the subrange of r1 which does not
   contain r2.  */
{
    mAConsoleMonitorViewRange u = { { 0, 0 }, { 0, 0 } };
    
    if( r1.start.string == r2.start.string )
    {
        
    }
        
    return u;
}    


@interface mAConsoleMonitorString : NSObject
{
    NSMutableAttributedString * _string; // the string
    float _x;                     // location of string, in lines
    float _height;                // height of string, in lines
}

- (id)init;
- (id)initWithString:(NSMutableAttributedString *)s x:(float)x height:(float)h;
- (void)dealloc;
- (NSMutableAttributedString *)string;
- (float)height;
- (float)x;
- (void)setString:(NSMutableAttributedString *)string;
- (void)setHeight:(float)height;
- (void)setX:(float)x;

@end

@implementation mAConsoleMonitorString : NSObject

- (id)init
{
    if( self = [super init] )
    {
        _string = nil;
        _height = 0;
    }
    
    return self;
}

- (id)initWithString:(NSMutableAttributedString *)s x:(float)x height:(float)h
{
    if( self = [self init] )
    {
        _string = [s retain];
        _height = h;
        _x = x;
    }
    
    return self;
}

- (void)dealloc
{
    [_string release];
    [super dealloc];
}

- (NSMutableAttributedString *)string
{
    return _string;
}

- (float)x
{
    return _x;
}

- (float)height
{
    return _height;
}

- (void)setString:(NSMutableAttributedString *)string
{
    [_string release];
    _string = [string retain];
}

- (void)setX:(float)x
{
    _x = x;
}

- (void)setHeight:(float)height
{
    _height = height;
}

@end

@interface mAConsoleMonitorViewOptimizationData : NSObject
{
    unsigned lines_to_string_start;
    unsigned string_index;
    float string_height;
}

- (id)init;
- (id)initWithLinesToStringStart:(unsigned)l stringIndex:(unsigned)index;
- (unsigned)linesToStringStart;
- (unsigned)stringIndex;

@end

@implementation mAConsoleMonitorViewOptimizationData

- (id)init
{
    if( self = [super init] )
    {
        lines_to_string_start = 0;
        string_index = 0;
    }
    
    return self;
}

- (id)initWithLinesToStringStart:(unsigned)lines stringIndex:(unsigned)index
{
    if( self = [self init] )
    {
        lines_to_string_start = lines;
        string_index = index;
    }
    
    return self;
}

- (unsigned)linesToStringStart
{
    return lines_to_string_start;
}

- (unsigned)stringIndex
{
    return string_index;
}

@end

@interface mAConsoleMonitorView (Private)

- (void)recalculateOptimizationData;
- (unsigned)numberOfLinesForString:(NSAttributedString *)string;
- (mAConsoleMonitorViewIndex)characterAtPoint:(NSPoint)p;
- (mAConsoleMonitorViewRange)wordAtPoint:(NSPoint)p;
- (mAConsoleMonitorViewRange)lineAtPoint:(NSPoint)p;
- (void)applySelection:(mAConsoleMonitorViewRange)oldSelectedRange
                scroll:(BOOL)doScroll;

@end

@implementation mAConsoleMonitorView

- (id)initWithFrame:(NSRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        strings = [[NSMutableArray alloc] init];
        num_lines = 0;
        
        font = [[NSFont fontWithName:@"Monaco" size:10] retain];
        paragraph_style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        left_margin = 3;
        right_margin = 6;
        //[paragraph_style setFirstLineHeadIndent:left_margin];
        //[paragraph_style setHeadIndent:left_margin];
        //[paragraph_style setTailIndent:-right_margin];
        [paragraph_style setFirstLineHeadIndent:0];
        [paragraph_style setHeadIndent:0];
        [paragraph_style setTailIndent:0];
        
        attributes = [[NSMutableDictionary alloc] init];
        [attributes setObject:font forKey:NSFontAttributeName];
        [attributes setObject:paragraph_style 
                       forKey:NSParagraphStyleAttributeName];
        
        append_to = nil;
        
        chars_per_line = 0;
        line_height = 0;
        
        optimization_data = [[NSMutableArray alloc] init];
        
        selected_range.start.string = 0;
        selected_range.start.character = 0;
        selected_range.finish.string = 0;
        selected_range.finish.character = 0;
        
    }
    
    return self;
}

- (void)dealloc
{
    [strings makeObjectsPerformSelector:@selector( release )];
    [strings release];
    [attributes release];
    [font release];
    [paragraph_style release];
    [optimization_data makeObjectsPerformSelector:@selector( release )];
    [optimization_data release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [self setFrameSize:[[self enclosingScrollView] contentSize]];
    text_width = [self frame].size.width;

    line_height = [[[[NSLayoutManager alloc] init] autorelease] defaultLineHeightForFont:font];
    [[self enclosingScrollView] setVerticalLineScroll:line_height];
    [[self enclosingScrollView] setVerticalPageScroll:0];

    //debug_fprintf( stdout, "chars_per_line: %u\nline_height: %f\n", chars_per_line, line_height );
}

- (void)resetCursorRects
{
    [self discardCursorRects];    
    [self addCursorRect:[[self enclosingScrollView] documentVisibleRect] cursor:[NSCursor IBeamCursor]];
}

- (void)mouseDown:(NSEvent *)e
{
    //debug_printf( "mouse down\n" );
    
    mAConsoleMonitorViewRange old_range = selected_range;
    unsigned num_clicks = [e clickCount];
    
    if( num_clicks == 1 )
    {
        NSPoint local_point = [self convertPoint:[e locationInWindow] fromView:nil];

        mAConsoleMonitorViewIndex i = [self characterAtPoint:local_point];
        if( i == mAConsoleMonitorViewIndexMax() )
        {
            selected_range.start.string = [strings count] - 1;
            selected_range.start.character = [[[strings objectAtIndex:selected_range.start.string] string] length];
            selected_range.finish = selected_range.start;
        }
        
        else
        {    
            selected_range.start = i;
            selected_range.finish = i;
        }
        
        start_range = selected_range;

        //debug_printf( "%u %u\n", i.string, i.character );
    }
    
    else if( num_clicks == 2 )
    {
        //debug_printf( "double click\n" );
        NSPoint local_point = [self convertPoint:[e locationInWindow] fromView:nil];
        
        selected_range = [self wordAtPoint:local_point];
        
        if( selected_range == mAConsoleMonitorViewRangeMax() )
        {
            selected_range.start.string = [strings count] - 1;
            selected_range.start.character = [[[strings objectAtIndex:selected_range.start.string] string] length];
            selected_range.finish = selected_range.start;
        }
        
        start_range = selected_range;
        /*debug_printf( "selected range: %i:%i to %i:%i\n", 
                selected_range.start.string,
                selected_range.start.character,
                selected_range.finish.string,
                selected_range.finish.character );*/
    }

    else
    {
        NSPoint local_point = [self convertPoint:[e locationInWindow] fromView:nil];
        
        selected_range = [self lineAtPoint:local_point];

        if( selected_range == mAConsoleMonitorViewRangeMax() )
        {
            selected_range.start.string = [strings count] - 1;
            selected_range.start.character = [[[strings objectAtIndex:selected_range.start.string] string] length];
            selected_range.finish = selected_range.start;
        }
        
        start_range = selected_range;
    }
    
    /*debug_printf( "selected range: %i:%i to %i:%i\n", 
            selected_range.start.string,
            selected_range.start.character,
            selected_range.finish.string,
            selected_range.finish.character );*/
    
    [self applySelection:old_range scroll:YES];
}

- (void)mouseDragged:(NSEvent *)e
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    mAConsoleMonitorViewRange old_range = selected_range;
    
    NSPoint local_point = [self convertPoint:[e locationInWindow] fromView:nil];
    
    mAConsoleMonitorViewRange r;
    
    unsigned num_clicks = [e clickCount];
    
    if( num_clicks == 1 )
    {
        mAConsoleMonitorViewIndex i = [self characterAtPoint:local_point];
        
        if( i == mAConsoleMonitorViewIndexMax() )
        {
            // have selected_range continue to the end
            r.start.string = [strings count] - 1;
            r.start.character = [[[strings objectAtIndex:r.start.string] string] length];
            r.finish = r.start;
        }
        
        else
        {
            r.start = i;
            r.finish = i;
        }
    }
    
    else if( num_clicks == 2 )
    {
        r = [self wordAtPoint:local_point];
        
        if( r == mAConsoleMonitorViewRangeMax() )
        {
            // have selected_range continue to the end
            r.start.string = [strings count] - 1;
            r.start.character = [[[strings objectAtIndex:r.start.string] string] length];
            r.finish = r.start;
        }
    }
    
    else
    {
        r = [self lineAtPoint:local_point];
        
        if( r == mAConsoleMonitorViewRangeMax() )
        {
            // have selected_range continue to the end
            r.start.string = [strings count] - 1;
            r.start.character = [[[strings objectAtIndex:r.start.string] string] length];
            r.finish = r.start;
        }
    }
    
    if( ( r.start > selected_range.start && r.finish < selected_range.finish ) )
    {
        /*debug_printf( "subtracting range r: %u:%u %u:%u\n", 
                r.start.string, r.start.character,
                r.finish.string, r.finish.character );*/
        
        if( r.start < start_range.start )
        {
            selected_range.start = r.start;
        }
        
        if( r.finish > start_range.finish )
        {
            selected_range.finish = r.finish;
        }
        
        selected_range = selected_range + start_range;
    }
    
    else
    {
        /*debug_printf( "adding range r: %u:%u %u:%u\n", 
                r.start.string, r.start.character,
                r.finish.string, r.finish.character );*/
        
        if( r.start < start_range.start )
        {
            selected_range.finish = start_range.finish;
            
            // scroll up if needed
            NSRect visible_rect = [[self enclosingScrollView] documentVisibleRect];
            float top = visible_rect.origin.y;
            
            if( local_point.y <= top )
            {
                visible_rect.origin.y = local_point.y;
                [self scrollRectToVisible:visible_rect];
                
                [self performSelector:@selector( mouseDragged: )
                           withObject:e
                           afterDelay:0.1
                              inModes:[NSArray arrayWithObjects:
                                  NSDefaultRunLoopMode, 
                                  NSConnectionReplyMode,
                                  NSModalPanelRunLoopMode,
                                  NSEventTrackingRunLoopMode,
                                  nil
                                  ]];
            }
            
            else
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
        
        if( r.finish > start_range.finish )
        {
            selected_range.start = start_range.start;
            
            // scroll down if needed
            NSRect visible_rect = [[self enclosingScrollView] documentVisibleRect];
            float bottom = visible_rect.origin.y + visible_rect.size.height;
            
            if( local_point.y >= bottom )
            {
                visible_rect.origin.y = local_point.y - visible_rect.size.height;
                [self scrollRectToVisible:visible_rect];
                
                [self performSelector:@selector( mouseDragged: )
                           withObject:e
                           afterDelay:0.1
                              inModes:[NSArray arrayWithObjects:
                                  NSDefaultRunLoopMode, 
                                  NSConnectionReplyMode,
                                  NSModalPanelRunLoopMode,
                                  NSEventTrackingRunLoopMode,
                                  nil
                                  ]];
            }
            
            else
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
        
        if( r == start_range )
        {
            selected_range = start_range;
        }
        
        selected_range = selected_range + r;
    }
    
    /*debug_printf( "selected range: %i:%i to %i:%i\n", 
            selected_range.start.string,
            selected_range.start.character,
            selected_range.finish.string,
            selected_range.finish.character );*/
    
    [self applySelection:old_range scroll:YES];
}

- (void)dragScroll:(id)arg
{
    NSPoint local_point = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] 
                                    fromView:nil];
    
    if( selected_range.start < start_range.start )
    {
        // scroll up if needed
        NSRect visible_rect = [[self enclosingScrollView] documentVisibleRect];
        float top = visible_rect.origin.y;
        
        if( local_point.y <= top )
        {
            visible_rect.origin.y = local_point.y;
            [self scrollRectToVisible:visible_rect];
            
            [self performSelector:@selector( dragScroll: )
                       withObject:nil
                       afterDelay:0.1
                          inModes:[NSArray arrayWithObjects:
                              NSDefaultRunLoopMode, 
                              NSConnectionReplyMode,
                              NSModalPanelRunLoopMode,
                              NSEventTrackingRunLoopMode,
                              nil
                              ]];            
        }
        
        else
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    if( selected_range.finish > start_range.finish )
    {
        // scroll down if needed
        NSRect visible_rect = [[self enclosingScrollView] documentVisibleRect];
        float bottom = visible_rect.origin.y + visible_rect.size.height;
        
        if( local_point.y >= bottom )
        {
            visible_rect.origin.y = local_point.y - visible_rect.size.height;
            [self scrollRectToVisible:visible_rect];
            
            [self performSelector:@selector( dragScroll: )
                       withObject:nil
                       afterDelay:0.1
                          inModes:[NSArray arrayWithObjects:
                              NSDefaultRunLoopMode, 
                              NSConnectionReplyMode,
                              NSModalPanelRunLoopMode,
                              NSEventTrackingRunLoopMode,
                              nil
                              ]];            
        }
        
        else
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)mouseUp:(NSEvent *)e
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSPoint local_point = [self convertPoint:[e locationInWindow] fromView:nil];

    if( selected_range.start < start_range.start )
    {
        // scroll up if needed
        NSRect visible_rect = [[self enclosingScrollView] documentVisibleRect];
        float top = visible_rect.origin.y;
        
        if( local_point.y <= top )
        {
            visible_rect.origin.y = local_point.y;
            [self scrollRectToVisible:visible_rect];
        }
    }
    
    if( selected_range.finish > start_range.finish )
    {
        // scroll down if needed
        NSRect visible_rect = [[self enclosingScrollView] documentVisibleRect];
        float bottom = visible_rect.origin.y + visible_rect.size.height;
        
        if( local_point.y >= bottom )
        {
            visible_rect.origin.y = local_point.y - visible_rect.size.height;
            [self scrollRectToVisible:visible_rect];
        }        
    }
}

- (void)drawRect:(NSRect)aRect
{    
    /* make a rect that aligns with top/bottom of text lines, by integer
    dividing the original origin.y/size.height by the line_height and then
    multiplying that by the line_height, thus rounding to a multiple of
    line_height.  round up for origin.y, round down for size.height */
    NSRect real_rect = NSMakeRect( left_margin, 
                                   ( ( ( int ) aRect.origin.y ) / ( ( int ) line_height ) ) * line_height,
                                   text_width - right_margin,
                                   ( ( ( ( int ) aRect.size.height ) / ( ( int ) line_height ) ) + 1 ) * line_height );
    /*
    debug_printf( "original: %f %f %f %f\nnew: %f %f %f %f\n", 
            aRect.origin.x, aRect.origin.y, 
            aRect.size.width, aRect.size.height,
            real_rect.origin.x, real_rect.origin.y, 
            real_rect.size.width, real_rect.size.height );
    */
    
    // clear background
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:real_rect];
    
    // determine which lines (indices in optimization_data) to draw
    unsigned first_line = real_rect.origin.y / line_height;
    if( first_line >= [optimization_data count] )
        return;
    unsigned last_line = ( real_rect.origin.y + real_rect.size.height ) / line_height + 1;
    if( last_line >= [optimization_data count] )
        last_line = [optimization_data count] - 1;
    
    float pixels_to_first_string_start = [[optimization_data objectAtIndex:first_line] linesToStringStart] * line_height;
    if( pixels_to_first_string_start )
    {
        real_rect.origin.y -= pixels_to_first_string_start;
        real_rect.size.height += pixels_to_first_string_start;
    }
    
    unsigned first_string = [[optimization_data objectAtIndex:first_line] stringIndex];
    unsigned last_string = [[optimization_data objectAtIndex:last_line] stringIndex];
    
    //debug_printf( "first_string: %u last_string: %u\n", first_string, last_string );
    
    float y = real_rect.origin.y;
    
    mAConsoleMonitorString * temp;
    
    for( unsigned i = first_string; i <= last_string; i++ )
    {
        temp = [strings objectAtIndex:i];
        [[temp string] drawInRect:NSMakeRect( left_margin, y, 
                                              text_width - right_margin,
                                              [self frame].size.height - y )];
        y += [temp height] * line_height;
    }
}

- (void)handleResize:(id)object
{
    //text_width = [self frame].size.width;
    text_width = [[self enclosingScrollView] contentSize].width;

    line_height = [[[[NSLayoutManager alloc] init] autorelease] defaultLineHeightForFont:font];
    [[self enclosingScrollView] setVerticalLineScroll:line_height];
    [[self enclosingScrollView] setVerticalPageScroll:0];
    
    [self recalculateOptimizationData];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    if( [self inLiveResize] )
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector( handleResize: )
                                                   object:nil];
        [self performSelector:@selector( handleResize: ) 
                   withObject:nil
                   afterDelay:0.25];
    }
    
    else
        [self handleResize:nil];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)appendString:(NSString *)aString
{
    //debug_printf( "---\n---appendString---\n---\n" );
    
    //debug_printf( "appendString: %s\n", [aString cString] );
    
    unsigned original_num_lines = num_lines;
    
    unsigned i = 0, begin = 0, len = [aString length];
    //unsigned total_num_lines_added = 0;
    for( i = 0; i < len; i++ )
    {
        if( [aString characterAtIndex:i] == '\n' )
            // make a new line
        {
            unsigned num_lines_added = 0;
            NSMutableAttributedString * new_string = [[NSMutableAttributedString alloc] initWithString:[aString substringWithRange:NSMakeRange( begin, i - begin )]
                                                                                            attributes:attributes];
            [new_string appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
            
            if( append_to )
            {
                // capture height of old string
                unsigned old_append_to_height = [[strings objectAtIndex:[strings count] - 1] height];
                // x will be the same for the new append_to string
                unsigned old_x = [[strings objectAtIndex:[strings count] - 1] x];
                
                // get rid of the old mAConsoleMonitorString in strings
                [[strings objectAtIndex:[strings count] - 1] autorelease];
                [strings removeObjectAtIndex:[strings count] - 1];
                
                // append the additional string
                [append_to appendAttributedString:[new_string autorelease]];
                // get the new height of the string
                num_lines_added = [self numberOfLinesForString:append_to] - 1;
                // add to strings
                [strings addObject:[[mAConsoleMonitorString alloc] initWithString:append_to
                                                                                x:old_x
                                                                           height:num_lines_added]];
                
                // fix num_lines_added to the actual number of lines added
                num_lines_added -= old_append_to_height;
                append_to = nil;
                
                // pretend like the original append_to line was never there, so
                // it will be forced to redraw
                original_num_lines--;
                
                // make optimizations
                for( unsigned int j = 0; j < num_lines_added; j++ )
                    [optimization_data addObject:[[mAConsoleMonitorViewOptimizationData alloc] initWithLinesToStringStart:j + old_append_to_height
                                                                                                              stringIndex:[strings count] - 1]];
            }
            
            else
            {
                num_lines_added = [self numberOfLinesForString:new_string] - 1;
                [strings addObject:[[mAConsoleMonitorString alloc] initWithString:new_string
                                                                                x:num_lines
                                                                           height:num_lines_added]];
                
                // make optimizations
                for( unsigned int j = 0; j < num_lines_added; j++ )
                    [optimization_data addObject:[[mAConsoleMonitorViewOptimizationData alloc] initWithLinesToStringStart:j
                                                                                                              stringIndex:[strings count] - 1]];
            }
            
            num_lines += num_lines_added;
            
            begin = i + 1;
            
            //debug_fprintf( stdout, "appended 1: %s\n", [new_string cString] );
        }
    }
    
    /*  append any trailing characters that come after the last newline
        we keep this string of text handy in an NSMutableAttributedString 
        (append_to) so we can append characters from any future appendString 
        that come before the next newline */
    if( [aString characterAtIndex:i - 1] != '\n' )
    {
        NSMutableAttributedString * new_string = [[NSMutableAttributedString alloc] initWithString:[aString substringWithRange:NSMakeRange( begin, i - begin )]
                                                                                        attributes:attributes];
        unsigned num_lines_added = [self numberOfLinesForString:new_string];
        [strings addObject:[[mAConsoleMonitorString alloc] initWithString:new_string
                                                                        x:num_lines
                                                                   height:num_lines_added]];
        append_to = new_string;
        
        // make optimizations
        for( unsigned int j = 0; j < num_lines_added; j++ )
            [optimization_data addObject:[[mAConsoleMonitorViewOptimizationData alloc] initWithLinesToStringStart:j
                                                                                                      stringIndex:[strings count] - 1]];
        
        num_lines += num_lines_added;
        
        //debug_fprintf( stdout, "appended 2: %s\n", [new_string cString] );
    }
    
    // adjust the frame to include the new lines, if needed
    // we specify enough space for num_lines + 1 so that there is always an
    // esthetically-pleasing empty line at the bottom of the view
    if( [[self enclosingScrollView] contentSize].height < ( num_lines + 1 ) * line_height )
        [self setFrameSize:NSMakeSize( [self frame].size.width, 
                                       ( num_lines + 1 ) * line_height )];
    else
        [self setFrameSize:NSMakeSize( [self frame].size.width, 
                                       [[self enclosingScrollView] contentSize].height )];
    
    // scroll down
    [self scrollPoint:NSMakePoint( 0, ( num_lines + 1 ) * line_height )];

    // set the visible part of the new appended lines to be displayed
    NSRect new_lines_rect = NSMakeRect( 0, original_num_lines * line_height,
                                        [self frame].size.width, 
                                        ( num_lines - original_num_lines + 1 ) * line_height );
    
    //debug_printf( "start line: %s\n", [[[strings objectAtIndex:[[optimization_data objectAtIndex:original_num_lines] stringIndex]] string] cString] );
    
    [self setNeedsDisplayInRect:NSIntersectionRect( [[self enclosingScrollView] documentVisibleRect],
                                                    new_lines_rect )];
}

- (void)clear
{
    [strings makeObjectsPerformSelector:@selector( release )];
    [strings removeAllObjects];
    
    [optimization_data makeObjectsPerformSelector:@selector( release )];
    [optimization_data removeAllObjects];
    
    [self setFrameSize:NSMakeSize( [self frame].size.width, 
                                   [[self enclosingScrollView] contentSize].height )];
    
    [self setNeedsDisplayInRect:[[self enclosingScrollView] documentVisibleRect]];
    
    num_lines = 0;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)canBecomeKeyView
{
    return YES;
}
/*
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    if( [[theEvent characters] isEqualToString:@"c"] && 
        ( [theEvent modifierFlags] & NSCommandKeyMask ) )
    {
        [self doCommandBySelector:@selector( copy: )];
        return YES;
    }
    
    return [super performKeyEquivalent:theEvent];
}
*/
- (void)copy:(id)sender
{
    NSPasteboard * pb = [NSPasteboard generalPasteboard];
    NSArray * types = [NSArray arrayWithObjects:NSStringPboardType, nil];    
    [pb declareTypes:types owner:self];
    
    unsigned start_string_index = selected_range.start.string;
    unsigned finish_string_index = selected_range.finish.string;
    unsigned current_string_index = start_string_index;
    
    NSMutableString * copy_string = [NSMutableString string];
    
    for( ; current_string_index <= finish_string_index; current_string_index++ )
    {
        NSMutableAttributedString * current_string = ( NSMutableAttributedString * ) [[strings objectAtIndex:current_string_index] string];
        
        unsigned range_location = ( current_string_index == start_string_index ? 
                                    selected_range.start.character : 0 );
        unsigned range_length = ( current_string_index == finish_string_index ?
                                  selected_range.finish.character : [current_string length] )  
            - range_location;
        
        NSRange range = NSMakeRange( range_location, range_length );
        
        [copy_string appendString:[[current_string attributedSubstringFromRange:range] string]];
    }
    
    [pb setString:copy_string forType:NSStringPboardType];
}

- (void)selectAll:(id)sender
{
    mAConsoleMonitorViewRange old_selected_range = selected_range;
    
    selected_range.start.string = 0;
    selected_range.start.character = 0;
    selected_range.finish.string = [strings count] - 1;
    selected_range.finish.character = [[[strings objectAtIndex:selected_range.finish.string] string] length];
    
    [self applySelection:old_selected_range scroll:NO];
}

@end

@implementation mAConsoleMonitorView (Private)

- (void)recalculateOptimizationData
{
    static NSEnumerator * enumerator = nil;
    static unsigned i = 0;
    
    [optimization_data makeObjectsPerformSelector:@selector( release )];
    [optimization_data autorelease];
    
    optimization_data = [[NSMutableArray alloc] init];
    
    num_lines = 0;
    
    //debug_printf( "----------------------resizing... text_width - left_margin - right_margin: %f\n", text_width - left_margin - right_margin );
    if( !enumerator )
        enumerator = [strings objectEnumerator];
    mAConsoleMonitorString * cmstring;
    unsigned height;
    for( ; cmstring = [enumerator nextObject]; i++ )
    {
        height = [self numberOfLinesForString:[cmstring string]] - 1;
        [cmstring setX:num_lines];
        [cmstring setHeight:height];
        //debug_printf( "width for %s: %f\n", [[cmstring string] cString], 
        //        [[cmstring string] sizeWithAttributes:attributes].width );
        num_lines += height;
        for( unsigned j = 0; j < height; j++ )
            [optimization_data addObject:[[mAConsoleMonitorViewOptimizationData alloc] initWithLinesToStringStart:j
                                                                                                      stringIndex:i]];
    }
    
    // reset for next time through
    enumerator = nil;
    i = 0;
    
    // adjust the frame to include the new lines
    // we specify enough space for num_lines + 1 so that there is always an
    // esthetically-pleasing empty line at the bottom of the view
    if( [[self enclosingScrollView] contentSize].height < ( num_lines + 1 ) * line_height )
        [self setFrameSize:NSMakeSize( [self frame].size.width, 
                                       ( num_lines + 1 ) * line_height )];
    else
        [self setFrameSize:NSMakeSize( [self frame].size.width, 
                                       [[self enclosingScrollView] contentSize].height )];
    
    [self setNeedsDisplayInRect:[[self enclosingScrollView] documentVisibleRect]];
}

- (unsigned)numberOfLinesForString:(NSAttributedString *)string
{
    NSTextStorage * text_storage = [[[NSTextStorage alloc] initWithAttributedString:string]
        autorelease];
    NSTextContainer * text_container = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize( text_width - left_margin - right_margin, FLT_MAX )] 
        autorelease];
    NSLayoutManager * layout_manager = [[[NSLayoutManager alloc] init] autorelease];
    
    [layout_manager addTextContainer:text_container];
    [text_storage addLayoutManager:layout_manager];
    
    (void) [layout_manager glyphRangeForTextContainer:text_container];
    
    return ( unsigned ) ( [layout_manager usedRectForTextContainer:text_container].size.height 
                          / line_height );
}

- (mAConsoleMonitorViewIndex)characterAtPoint:(NSPoint)p
{
    unsigned line = ( unsigned ) floor( p.y / line_height );
    if( line >= [optimization_data count] )
        return mAConsoleMonitorViewIndexMax();
    
    unsigned string_index = [[optimization_data objectAtIndex:line] stringIndex];
    NSTextStorage * ts = [[[NSTextStorage alloc] initWithAttributedString:( NSMutableAttributedString * )[[strings objectAtIndex:string_index] string]]
        autorelease];
    
    NSTextContainer * text_container = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize( text_width - left_margin - right_margin, FLT_MAX )] 
        autorelease];
    NSLayoutManager * layout_manager = [[[NSLayoutManager alloc] init] autorelease];
    
    [layout_manager addTextContainer:text_container];
    [ts addLayoutManager:layout_manager];
    
    p.x += left_margin;
    p.y = [[optimization_data objectAtIndex:line] linesToStringStart] * line_height + line_height / 2;
    
    //debug_printf( "p.x: %f p.y: %f\n", p.x, p.y );

    (void) [layout_manager glyphRangeForTextContainer:text_container];
    
    float fraction;
    unsigned glyph = [layout_manager glyphIndexForPoint:p
                                        inTextContainer:text_container
                         fractionOfDistanceThroughGlyph:&fraction];
    
    unsigned character = [layout_manager characterIndexForGlyphAtIndex:glyph + ( ( fraction > .5 ) ? 1 : 0 )];
    
    //debug_printf( "glyph: %i\n", glyph );
    
    mAConsoleMonitorViewIndex i = { string_index, character };
    
    return i;
}

- (mAConsoleMonitorViewRange)wordAtPoint:(NSPoint)p
{
    unsigned line = ( unsigned ) floor( p.y / line_height );
    if( line >= [optimization_data count] )
        return mAConsoleMonitorViewRangeMax();
    
    unsigned string_index = [[optimization_data objectAtIndex:line] stringIndex];
    NSTextStorage * ts = [[[NSTextStorage alloc] initWithAttributedString:( NSMutableAttributedString * )[[strings objectAtIndex:string_index] string]]
        autorelease];
    
    NSTextContainer * text_container = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize( text_width - left_margin - right_margin, FLT_MAX )] 
        autorelease];
    NSLayoutManager * layout_manager = [[[NSLayoutManager alloc] init] autorelease];
    
    [layout_manager addTextContainer:text_container];
    [ts addLayoutManager:layout_manager];
    
    p.x += left_margin;
    p.y = [[optimization_data objectAtIndex:line] linesToStringStart] * line_height + line_height / 2;
    
    //debug_printf( "p.x: %f p.y: %f\n", p.x, p.y );
    
    (void) [layout_manager glyphRangeForTextContainer:text_container];
    
    float fraction;
    unsigned glyph = [layout_manager glyphIndexForPoint:p
                                        inTextContainer:text_container
                         fractionOfDistanceThroughGlyph:&fraction];
    
    unsigned character = [layout_manager characterIndexForGlyphAtIndex:glyph];
    
    //debug_printf( "glyph: %i\n", glyph );
    
    NSRange range = [ts doubleClickAtIndex:character];
    
    mAConsoleMonitorViewRange r = { { string_index, range.location }, 
                                    { string_index, range.location + range.length } };
    
    return r;
}

- (mAConsoleMonitorViewRange)lineAtPoint:(NSPoint)p
{
    unsigned line = ( unsigned ) floor( p.y / line_height );
    if( line >= [optimization_data count] )
        return mAConsoleMonitorViewRangeMax();
    
    unsigned string_index = [[optimization_data objectAtIndex:line] stringIndex];
    
    mAConsoleMonitorViewRange r = { string_index, 0, string_index, 
        [[[strings objectAtIndex:string_index] string] length] };
    
    return r;
}

- (void)applySelection:(mAConsoleMonitorViewRange)oldSelectedRange
                scroll:(BOOL)doScroll
{
    // determine difference between old and new selected ranges
    //NSRange highlight_range = ;
    
    // apply selection color attributes and determine what needs to be drawn
    if( !mAConsoleMonitorViewRangesAreEqual( selected_range, oldSelectedRange ) )
    {
        // first remove the selection attributes from the old selected range
        if( !mAConsoleMonitorViewRangeLengthIsZero( oldSelectedRange ) )
        {
            unsigned start_string_index = oldSelectedRange.start.string;
            unsigned finish_string_index = oldSelectedRange.finish.string;
            unsigned current_string_index = start_string_index;
            
            for( ; current_string_index <= finish_string_index; current_string_index++ )
            {
                NSMutableAttributedString * current_string = ( NSMutableAttributedString * ) [[strings objectAtIndex:current_string_index] string];
                
                unsigned range_location = ( current_string_index == start_string_index ? 
                                            oldSelectedRange.start.character : 0 );
                unsigned range_length = ( current_string_index == finish_string_index ?
                                          oldSelectedRange.finish.character : [current_string length] )  
                    - range_location;
                
                NSRange attr_range = NSMakeRange( range_location, range_length );
                
                [current_string removeAttribute:NSBackgroundColorAttributeName
                                          range:attr_range];
                
                [current_string removeAttribute:NSForegroundColorAttributeName
                                          range:attr_range];
            }
            
            mAConsoleMonitorString * start_string = [strings objectAtIndex:oldSelectedRange.start.string];
            mAConsoleMonitorString * finish_string = [strings objectAtIndex:oldSelectedRange.finish.string];
            
            NSRect inval_rect = NSMakeRect( 0, [start_string x] * line_height, text_width, 
                                            ( [finish_string x] + [finish_string height] ) * line_height);
            
            [self setNeedsDisplayInRect:inval_rect];            
        }
        
        // apply selection attributes to new selected range
        if( !mAConsoleMonitorViewRangeLengthIsZero( selected_range ) )
        {
            unsigned start_string_index = selected_range.start.string;
            unsigned finish_string_index = selected_range.finish.string;
            unsigned current_string_index = start_string_index;
            
            for( ; current_string_index <= finish_string_index; current_string_index++ )
            {
                NSMutableAttributedString * current_string = ( NSMutableAttributedString * ) [[strings objectAtIndex:current_string_index] string];
                
                unsigned range_location = ( current_string_index == start_string_index ? 
                                            selected_range.start.character : 0 );
                unsigned range_length = ( current_string_index == finish_string_index ?
                                          selected_range.finish.character : [current_string length] )
                    - range_location;
                
                NSRange attr_range = NSMakeRange( range_location, range_length );
                
                [current_string addAttribute:NSBackgroundColorAttributeName
                                       value:[NSColor selectedTextBackgroundColor]
                                       range:attr_range];
                
                [current_string addAttribute:NSForegroundColorAttributeName
                                       value:[NSColor selectedTextColor]
                                       range:attr_range];
            }
            
            mAConsoleMonitorString * start_string = [strings objectAtIndex:selected_range.start.string];
            mAConsoleMonitorString * finish_string = [strings objectAtIndex:selected_range.finish.string];
            
            NSRect inval_rect = NSMakeRect( 0, [start_string x] * line_height, text_width, 
                                            ( [finish_string x] + [finish_string height] ) * line_height);
            
            [self setNeedsDisplayInRect:inval_rect];
        }
    }
}

@end
