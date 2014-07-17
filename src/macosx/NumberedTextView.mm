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
// file: NumberedTextView.mm
// desc: view class for implementing a text view with scrollers and line numbers
//       Based on Koen van der Drift's MyTextView class.  
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Spring 2006
//-----------------------------------------------------------------------------

#import "NumberedTextView.h"
#import "miniAudiclePreferencesController.h"
#import "mASyntaxHighlighter.h"

#import <QuartzCore/QuartzCore.h>


#define MARGIN_WIDTH 30
#define MIN_MARGIN_WIDTH 30

#define USE_NEW_SYNTAX_COLORING 0

// images for mATextView
static NSImage * lock_image;

static NSImage * add_image;
static NSImage * replace_image;
static NSImage * remove_image;
static NSImage * removelast_image;
static NSImage * removeall_image;

static const float mATextView_initial_text_size = 36.0;

static NSImage * error_image;

@implementation mATextView

+ (void)initialize
{
    lock_image = [[NSImage imageNamed:@"lock.png"] retain];
    [lock_image setScalesWhenResized:YES];
    NSSize lock_image_size = [lock_image size];
    lock_image_size.height *= 0.65;
    lock_image_size.width *= 0.65;
    [lock_image setSize:lock_image_size];
    
    add_image = [[NSImage imageNamed:@"add.png"] retain];
    remove_image = [[NSImage imageNamed:@"remove.png"] retain];
    replace_image = [[NSImage imageNamed:@"replace.png"] retain];
    removelast_image = [[NSImage imageNamed:@"removelast.png"] retain];
    removeall_image = [[NSImage imageNamed:@"removeall.png"] retain];
    
    error_image = [[NSImage imageNamed:@"error.png"] retain];
    [error_image setScalesWhenResized:YES];
    NSSize error_image_size = [error_image size];
    error_image_size.height *= 0.4;
    error_image_size.width *= 0.4;
    [error_image setSize:error_image_size];
    
}

- (id)initWithFrame:(NSRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        animation_image = nil;
        animation_ratio = 0;
        
        animation_string = nil;
        string_animation_ratio = 0;
        string_attributes = [NSMutableDictionary new];

        error_animation_ratio = 0;
        
        if([self respondsToSelector:@selector(setAutomaticQuoteSubstitutionEnabled:)])
        {
            [self setAutomaticQuoteSubstitutionEnabled:NO];
            [self setAutomaticDashSubstitutionEnabled:NO];
            [self setAutomaticSpellingCorrectionEnabled:NO];
            [self setAutomaticTextReplacementEnabled:NO];
            [self setAutomaticLinkDetectionEnabled:NO];
            [self setAutomaticDataDetectionEnabled:NO];
        }
    }
    
    return self;
}

- (void)dealloc
{
    if( animation_string )
        [animation_string release];
    [string_attributes release];
    
    [super dealloc];
}

/*
- (void)cut:(id)sender
{
    [super cut:sender];
    [self animateString:@"cut"];
}
 
- (void)copy:(id)sender
{
    [super copy:sender];
    [self animateString:@"copy"];
}

- (void)paste:(id)sender
{
    [super paste:sender];
    [self animateString:@"paste"];
}

- (void)keyDown:(NSEvent *)e
{
    //handle shift-space chuck operator
    //if( [[e charactersIgnoringModifiers] isEqualToString:@" "] && 
    //    ( [e modifierFlags] & 0xffff0000U ) == NSShiftKeyMask )
    //{
    //    [self insertText:@" => "];
    //    return;
    //}
    
    // handle ctrl-space chuck operator
    if( [[e charactersIgnoringModifiers] isEqualToString:@" "] && 
        ( [e modifierFlags] & 0xffff0000U ) == NSControlKeyMask )
    {
        [self insertText:@" => "];
        return;
    }
    
    [super keyDown:e];
}
*/

- (void)paste:(id)sender
{
    [super pasteAsPlainText:sender];
}

- (NSRect)lockImageRect
{
    NSSize image_size = [lock_image size];
    NSRect view_rect = [[self enclosingScrollView] documentVisibleRect];
    // position in bottom right corner
    NSPoint p = NSMakePoint( view_rect.origin.x + view_rect.size.width - 15 - image_size.width, 
                             view_rect.origin.y + view_rect.size.height - 15 );
    return NSMakeRect( p.x, p.y - image_size.height, 
                       image_size.width, image_size.height );
}

- (NSRect)animationImageRect
{
    NSSize image_size = [animation_image size];
    NSRect view_rect = [[self enclosingScrollView] documentVisibleRect];

    // position slightly above center
    NSPoint p = NSMakePoint( view_rect.origin.x + view_rect.size.width / 2 - image_size.width / 2, 
                             view_rect.origin.y + view_rect.size.height / 2 + image_size.height / 3 );
    // if our slightly above center position is not totally in the visible area just center it
    if( !NSPointInRect( NSMakePoint( p.x, p.y - image_size.height ), view_rect ) )
        p = NSMakePoint( view_rect.origin.x + view_rect.size.width / 2 - image_size.width / 2,
                         view_rect.origin.y + view_rect.size.height / 2 + image_size.height / 2 );
    
    NSRect image_rect = NSMakeRect( p.x, p.y - image_size.height, 
                                    image_size.width, image_size.height );
    
    return image_rect;
}

- (NSRect)errorImageRect
{
    NSSize image_size = [error_image size];
    NSRect view_rect = [[self enclosingScrollView] documentVisibleRect];
    
    // position in top right corner
    NSPoint p = NSMakePoint( view_rect.origin.x + view_rect.size.width - 15 - image_size.width, 
                             view_rect.origin.y + 15 + image_size.height );
    return NSMakeRect( p.x, p.y - image_size.height, 
                       image_size.width, image_size.height );  
}

- (NSRect)stringRect
{
    NSSize string_size = [animation_string sizeWithAttributes:string_attributes];
    
    // position roughly with same center as error image
    NSRect rect = [self errorImageRect];
    rect.origin.x -= string_size.width / 2 - rect.size.width / 2;
    rect.origin.y = [[self enclosingScrollView] documentVisibleRect].origin.y;
    rect.size = string_size;
    
    return rect;  
}

- (void)setEditable:(BOOL)editable
{
    [super setEditable:editable];
    
    NSRect image_rect = [self lockImageRect];
    [self setNeedsDisplayInRect:image_rect];
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];

    BOOL redraw = NO;
    
    if( ![self isEditable] )
    {
        //[[NSColor blackColor] set];
        //[NSBezierPath strokeRect:image_rect];
        
        NSRect image_rect = [self lockImageRect];
        
        NSPoint p = image_rect.origin;
//        p.y += [lock_image size].height;
        
        if( NSIntersectsRect( aRect, image_rect ) )
            [lock_image drawAtPoint:p fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.25];
//            [lock_image dissolveToPoint:p fraction:0.25];
    }

    if( animation_ratio > 0.0 )
    {
        //[[NSColor blackColor] set];
        //[NSBezierPath strokeRect:image_rect];
        
        NSRect image_rect = [self animationImageRect];
        
        NSPoint p = image_rect.origin;
//        p.y += [animation_image size].height;
        
        if( NSIntersectsRect( aRect, image_rect ) )
            [animation_image drawAtPoint:p fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:animation_ratio];
//            [animation_image dissolveToPoint:p fraction:animation_ratio];
        
        redraw = YES;
    }
    
    if( error_animation_ratio > 0.0 )
    {
        NSRect image_rect = [self errorImageRect];
        
        NSPoint p = image_rect.origin;
//        p.y += [error_image size].height;
        
        if( NSIntersectsRect( aRect, image_rect ) )
            [error_image drawAtPoint:p fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:error_animation_ratio];
        
        redraw = YES;
    }
    
    if( string_animation_ratio > 0.0 )
    {
        [string_attributes setObject:[NSFont fontWithName:@"Andale Mono" 
                                                     size:mATextView_initial_text_size /** ( string_animation_ratio > 1 ? 1 : string_animation_ratio )*/]
                              forKey:NSFontAttributeName];
        [string_attributes setObject:[NSColor colorWithCalibratedWhite:0.5
                                                                 alpha:string_animation_ratio]
                              forKey:NSForegroundColorAttributeName];
        
        [animation_string drawInRect:[self stringRect] 
                      withAttributes:string_attributes];
        
        redraw = YES;
    }
    
    if( redraw )
        [self performSelector:@selector( redrawAnimation )
                   withObject:nil
                   afterDelay:0.04
                      inModes:[NSArray arrayWithObjects:
                          NSDefaultRunLoopMode,
                          NSConnectionReplyMode,
                          NSModalPanelRunLoopMode,
                          NSEventTrackingRunLoopMode,
                          nil]];
}

- (void)drawViewBackgroundInRect:(NSRect)aRect
{
    [super drawViewBackgroundInRect:aRect];
}

- (void)redrawAnimation
{
    if( animation_ratio > 0 )
    {
        animation_ratio -= 0.075;
        
        [self setNeedsDisplayInRect:[self animationImageRect]];
    }
    
    if( string_animation_ratio > 0 )
    {
        string_animation_ratio -= 0.075;
        
        [self setNeedsDisplayInRect:[self stringRect]];
    }
    
    if( error_animation_ratio > 0 )
    {
        error_animation_ratio -= 0.075;
        
        [self setNeedsDisplayInRect:[self errorImageRect]];
    }
}

- (void)animate
{
    if( ![[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesEnableOTFVisuals] )
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector( redrawAnimation )
                                               object:nil];
    animation_ratio = 1.5;
    [self redrawAnimation];
}

- (void)animateAdd
{
    animation_image = add_image;
    [self animate];
}

- (void)animateRemove
{
    animation_image = remove_image;
    [self animate];
}

- (void)animateReplace
{
    animation_image = replace_image;
    [self animate];
}

- (void)animateRemoveLast
{
    animation_image = removelast_image;
    [self animate];
}

- (void)animateRemoveAll
{
    animation_image = removeall_image;
    [self animate];
}

- (void)animateString:(NSString *)s
{
    if( ![[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesEnableOTFVisuals] )
        return;
    
    if( animation_string )
        [animation_string release];
    animation_string = [s retain];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector( redrawAnimation )
                                               object:nil];
    
    string_animation_ratio = 1.4;
    [string_attributes setObject:[NSFont fontWithName:@"Andale Mono"
                                                 size:mATextView_initial_text_size]
                          forKey:NSFontAttributeName];
    [string_attributes setObject:[NSColor colorWithCalibratedWhite:0.5
                                                             alpha:string_animation_ratio]
                          forKey:NSForegroundColorAttributeName];
    
    [self redrawAnimation];
}

- (void)animateError
{
    if( ![[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesEnableOTFVisuals] )
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector( redrawAnimation )
                                               object:nil];
    error_animation_ratio = 2.5;
    [self redrawAnimation];
}

@end

@interface NumberedTextView (Private)

- (NSRange)indentNewlinesInRange:(NSRange)range;
- (NSMutableString *)indentationForLineAfterLineEndingAtIndex:(unsigned)i;
- (void)indentLineOfIndex:(unsigned)i;

@end

@implementation NumberedTextView

-(id)initWithFrame:(NSRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [self initLineMargin:frame];
        [self initSyntaxHighlighting];
        
        [self reloadUserDefaults];
        
        error_line = 0;
        shows_error_line = NO;
        
        smart_indentation_triggers = [[NSCharacterSet characterSetWithCharactersInString:@"{}"] retain];
        
        magic_words_parens = [[NSArray arrayWithObjects:@"if", @"for", @"while",
            @"until", @"repeat", nil] retain];
        magic_words_parens_reverse = [[NSArray arrayWithObjects:@"fi", @"rof",
            @"elihw", @"litnu", @"taeper", nil] retain];
        okay_before_parens = [[NSCharacterSet characterSetWithCharactersInString:@" \n\r\t;{})"] retain];
        okay_after_parens = [[NSCharacterSet characterSetWithCharactersInString:@" \n\r\t("] retain]; 
        needed_after_parens = [[NSCharacterSet characterSetWithCharactersInString:@"("] retain];
        
        magic_words_no_parens = [[NSArray arrayWithObjects:@"else", @"do", @"class", nil] retain];
        magic_words_no_parens_reverse = [[NSArray arrayWithObjects:@"esle", @"od", @"ssalc", nil] retain];
        okay_before_no_parens = [[NSCharacterSet characterSetWithCharactersInString:@" \n\r\t;{})"] retain];
        okay_after_no_parens = [[NSCharacterSet characterSetWithCharactersInString:@" \n\r\t{"] retain];
    }
    
    return self;
}

- (void)initLineMargin:(NSRect)frame
{
    last_rect = NSMakeRect( 0, 0, 0, 0 );
    
    margin_width = MARGIN_WIDTH;
    NSRect r = NSMakeRect( margin_width, 0, frame.size.width - margin_width, frame.size.height );
    
    // initialize a scrolling view
    NSScrollView * scroll_view = [[[NSScrollView alloc] initWithFrame:r] autorelease];
    
    // set scroll view properties
    [scroll_view setHasVerticalScroller:YES];
    [scroll_view setHasHorizontalScroller:YES];
    [scroll_view setDrawsBackground:NO];
    [scroll_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[scroll_view contentView] setPostsBoundsChangedNotifications:YES];
    
    NSRect r2 = { { 0, 0 }, [scroll_view contentSize] };
    
    // create a text view, adjust it for display
    text_view = [[mATextView alloc] initWithFrame:r2];
    
    // set various text view properties
    [text_view setEditable:YES];
    [text_view setAllowsUndo:YES];
    [text_view setUsesFindPanel:YES];
    [text_view setHorizontallyResizable:YES];
    [text_view setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [text_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [text_view setSmartInsertDeleteEnabled:NO];
    [[text_view textContainer] setWidthTracksTextView:NO];
    [[text_view textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [text_view setPostsBoundsChangedNotifications:YES];
    
#ifdef SPENCER
    [text_view setWantsLayer:YES];
    [text_view setContentFilters:@[
//     [CIFilter filterWithName:@"CIGaussianBlur"
//                keysAndValues:@"inputRadius", @(0.5),
//      nil],
     [CIFilter filterWithName:@"CIBloom"
                keysAndValues:
      @"inputRadius", @(3),
      @"inputIntensity", @(1),
      nil],
     [CIFilter filterWithName:@"CIToneCurve"
                keysAndValues:
      @"inputPoint0", [CIVector vectorWithX:0 Y:0],
      @"inputPoint1", [CIVector vectorWithX:0.25 Y:0.125],
      @"inputPoint2", [CIVector vectorWithX:0.5 Y:0.5],
      @"inputPoint3", [CIVector vectorWithX:0.75 Y:0.9],
      @"inputPoint4", [CIVector vectorWithX:1 Y:1],
      nil],
//     [CIFilter filterWithName:@"CIGaussianBlur"
//                keysAndValues:@"inputRadius", @(0.5),
//      nil],
//     [CIFilter filterWithName:@"CIBloom"
//                keysAndValues:@"inputRadius", @(100),
//      @"inputIntensity", @(0.5),
//      nil],
     ]];
#endif // SPENCER
    
    [scroll_view setDocumentView:text_view];
    
    [self addSubview:scroll_view];
    
    // listen to updates from the window to force a redraw - eg when the window resizes.
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self 
                                              selector:@selector(windowDidUpdate:)
                                                  name:NSWindowDidUpdateNotification
                                                object:[self window]];
     */
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(boundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:[scroll_view contentView]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(boundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:text_view];
    
    marginAttributes = [[NSMutableDictionary alloc] init];
    
    [marginAttributes setObject:[NSFont boldSystemFontOfSize:8] forKey: NSFontAttributeName];
    [marginAttributes setObject:[NSColor darkGrayColor] forKey: NSForegroundColorAttributeName];
    
    drawNumbersInMargin = YES;
    drawLineNumbers = YES;
}

- (void)reloadUserDefaults
{
    
    BOOL _enable_syntax_highlighting = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesEnableSyntaxHighlighting];
    if( enable_syntax_highlighting && 
        enable_syntax_highlighting != _enable_syntax_highlighting )
        // syntax highlighting was turned off
        // remove all coloring
    {
        NSTextStorage * ts = [text_view textStorage];
        [ts removeAttribute:NSForegroundColorAttributeName
                      range:NSMakeRange( 0, [ts length] )];
    }
    enable_syntax_highlighting = _enable_syntax_highlighting;
    
    use_tabs = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesTabUsesTab];
    tab_width = [[NSUserDefaults standardUserDefaults] integerForKey:mAPreferencesTabWidth];
    enable_smart_indentation = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesEnableSmartIndentation];
    tab_key_smart_indents = [[NSUserDefaults standardUserDefaults] integerForKey:mAPreferencesTabKeySmartIndents];
    
    NSUnarchiver * uar = [[[NSUnarchiver alloc] initForReadingWithData:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesDefaultFont]] autorelease];
    [text_view setFont:[[[NSFont alloc] initWithCoder:uar] autorelease]];
    
    NSMutableParagraphStyle * paragraph_style = [[NSMutableParagraphStyle new] autorelease];
    [paragraph_style setTabStops:[NSArray array]];
    [paragraph_style setDefaultTabInterval:tab_width * [@" " sizeWithAttributes:[NSDictionary dictionaryWithObject:[text_view font]
                                                                                                            forKey:NSFontAttributeName]].width];
    [text_view setDefaultParagraphStyle:paragraph_style];
    [[text_view textStorage] addAttribute:NSParagraphStyleAttributeName
                                    value:paragraph_style
                                    range:NSMakeRange( 0, [[text_view textStorage] length] )];
}

- (void)initSyntaxHighlighting
{    
    syntax_highlighter = nil;
    colorer = nil;
        
#if !defined( USE_NEW_SYNTAX_COLORING ) || !USE_NEW_SYNTAX_COLORING
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syntaxColoringChanged:)
                                                 name:mASyntaxColoringChangedNotification
                                               object:nil];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingPreferencesChanged:)
                                                 name:mAPreferencesChangedNotification
                                               object:nil];
    
    [[text_view textStorage] setDelegate:self];
    [text_view setDelegate:self];
    
    NSString * bg_color_hex = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:IDEKit_TextColorsPrefKey] objectForKey:IDEKit_NameForColor( IDEKit_kLangColor_Background )];
    if( bg_color_hex )
    {
        NSColor * bg_color = [NSColor colorWithHTML:bg_color_hex];
        [text_view setBackgroundColor:bg_color];
        if( [bg_color brightnessComponent] < .5 )
            [text_view setInsertionPointColor:[NSColor whiteColor]];
        if( [bg_color brightnessComponent] >= .5 )
            [text_view setInsertionPointColor:[NSColor blackColor]];
    }
    
#if defined( USE_NEW_SYNTAX_COLORING ) && USE_NEW_SYNTAX_COLORING
    mASyntaxHighlighter * mash = [[mASyntaxHighlighter alloc] initWithTextStorage:[text_view textStorage]];
#endif
}

- (void)setSyntaxHighlighter:(IDEKit_LexParser *)sh
                     colorer:(id)c
{
    syntax_highlighter = [sh retain];
    colorer = nil;//c;
}

- (void)setSmartIndentationEnabled:(BOOL)enable
{
    enable_smart_indentation = enable;
}

- (BOOL)smartIndentationEnabled
{
    return enable_smart_indentation;
}

- (void)textStorageWillProcessEditing:(NSNotification *)notification
{
    if( !enable_smart_indentation )
        return;
    
    NSTextStorage * ts = [text_view textStorage];
    if ( [ts editedMask] == NSTextStorageEditedAttributes )
        return; 
    
    NSRange edited_range = [ts editedRange];
    
    if( edited_range.length > 0 && [ts changeInLength] > 0 )
    {
        NSRange trigger_character_range = [[ts string] rangeOfCharacterFromSet:smart_indentation_triggers 
                                                                       options:NSLiteralSearch
                                                                         range:edited_range];
        
        if( trigger_character_range.location != NSNotFound )
            [self indentNewlinesInRange:edited_range];
            /*
            [self indentNewlinesInRange:NSMakeRange( trigger_character_range.location, 
                                                     edited_range.length - ( trigger_character_range.location - edited_range.location ) )];
*/    }
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
    [self updateMargin];
    
    if( !syntax_highlighter || !enable_syntax_highlighting )
        return;
    
    NSTextStorage * ts = [text_view textStorage];    
    if ( [ts editedMask] == NSTextStorageEditedAttributes )
        return;

    // 1.2.2: changed from 'unsigned int' to 'NSUInteger'
    NSUInteger start_index, line_end_index, contents_end_index;
    [[ts string] getLineStart:&start_index 
                          end:&line_end_index 
                  contentsEnd:&contents_end_index 
                     forRange:[ts editedRange]];
    
    [syntax_highlighter colorString:ts 
                              range:NSMakeRange( start_index, contents_end_index - start_index ) 
                            colorer:colorer];
    
    // WARNING: undocumented functionality
    // allows double-click to select "words" by . boundaries
    // from https://code.google.com/p/chromium/issues/detail?id=28145
    [ts addAttribute:@"NSLanguage" value:@"en_US_POSIX"
               range:NSMakeRange(start_index, contents_end_index-start_index)];
}

- (void)syntaxColoringChanged:(NSNotification *)n
{
    [self reloadUserDefaults];

    if( !syntax_highlighter || !enable_syntax_highlighting )
        return;
    
    NSTextStorage * ts = [text_view textStorage];
    if( [ts length] > 0 )
        [syntax_highlighter colorString:ts 
                                  range:NSMakeRange( 0, [ts length] ) 
                                colorer:colorer];
    
    NSString * bg_color_hex = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:IDEKit_TextColorsPrefKey] objectForKey:IDEKit_NameForColor( IDEKit_kLangColor_Background )];
    if( bg_color_hex )
    {
        NSColor * bg_color = [NSColor colorWithHTML:bg_color_hex];
        [text_view setBackgroundColor:bg_color];
        if( [bg_color brightnessComponent] < .5 )
            [text_view setInsertionPointColor:[NSColor whiteColor]];
        if( [bg_color brightnessComponent] >= .5 )
            [text_view setInsertionPointColor:[NSColor blackColor]];
    }
}

- (void)editingPreferencesChanged:(NSNotification *)n
{
    [self reloadUserDefaults];
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if( enable_smart_indentation && aSelector == @selector(insertNewline:) )
    {
        [text_view insertNewline:self];
        
        // handle tab level auto indentation
        unsigned line_end = [text_view selectedRange].location - 1;
        NSMutableString * indentation = [self indentationForLineAfterLineEndingAtIndex:line_end];
        
        if( [indentation length] )
        {
            NSTextStorage * ts = [text_view textStorage];

            // register text change undo operation with undo system
            [[[text_view undoManager] prepareWithInvocationTarget:ts]
                    replaceCharactersInRange:NSMakeRange( line_end + 1,
                                                          [indentation length] )
                                  withString:@""];
            [[text_view undoManager] setActionName:@"Smart Indentation"];
            
            // do the edit
            [ts beginEditing];
            [ts replaceCharactersInRange:NSMakeRange( line_end + 1, 0 )
                              withString:indentation];
            [ts endEditing];
        }
        
        return YES;
    }
    
    else if( tab_key_smart_indents && aSelector == @selector(insertTab:) )
    {
        NSRange selected_range = [text_view selectedRange];
        
        if( selected_range.length == 0 )
            // no selection--just indent current line
            [self indentLineOfIndex:selected_range.location];
        
        else
            // multiple selected lines -- indent each one
        {
            [[text_view undoManager] beginUndoGrouping];
                        
            /*NSString * text = [text_view string];
            unsigned previous_text_length = [text length];
            
            for( int i = 1; i < selected_range.length; i++ )
            {
                if( [text characterAtIndex:selected_range.location + i] == '\n' )
                {
                    [self indentLineOfIndex:selected_range.location + i];
                    selected_range.length += [text length] - previous_text_length;
                    i += [text length] - previous_text_length;
                    previous_text_length = [text length];
                }
            }
            
            [self indentLineOfIndex:selected_range.location + selected_range.length - 1];
            
            [[text_view undoManager] endUndoGrouping];*/
            
            [text_view setSelectedRange:[self indentNewlinesInRange:selected_range]];
            
            [[text_view undoManager] endUndoGrouping];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)enableLineNumbers:(BOOL)enable
{
    if( enable )
        margin_width = MARGIN_WIDTH;
    
    else
        margin_width = 0;
    
    drawLineNumbers = enable;
    NSRect r = NSMakeRect( margin_width, 0, [self frame].size.width - margin_width, [self frame].size.height );
    [[text_view enclosingScrollView] setFrame:r];
    [self updateMargin];
}

- (void)setErrorLine:(unsigned)line
{
    error_line = line;
    if( shows_error_line )
        [self updateMargin];
}

- (void)setShowsErrorLine:(BOOL)show
{
    if( shows_error_line != show )
        [self updateMargin];
    shows_error_line = show;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [marginAttributes release];
    if( syntax_highlighter )
        [syntax_highlighter release];
    
    [smart_indentation_triggers release];
    
    [magic_words_parens release];
    [okay_before_parens release];
    [okay_after_parens release];
    [needed_after_parens release];
    
    [magic_words_no_parens release];
    [okay_before_no_parens release];
    [okay_after_no_parens release];
    
    [super dealloc];
}

- (void)drawRect:(NSRect)aRect
{
    NSRect margin_rect = NSIntersectionRect( aRect, [self marginRect] );
    if( !NSIsEmptyRect( margin_rect ) )
    {
        [self drawEmptyMargin:margin_rect];
        
        if( drawNumbersInMargin )
        {
            [self drawNumbersInMargin:margin_rect];
        }
    }
    
    NSRect scroll_view_rect = NSIntersectionRect( aRect, [[text_view enclosingScrollView] frame] );
    if( !NSIsEmptyRect( scroll_view_rect ) )
    {
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:scroll_view_rect];
    }
    
    [super drawRect:aRect];    
}

- (void)boundsDidChange:(NSNotification *)notification
{
    [self updateMargin];
}

- (void)updateLayout
{
    [self updateMargin];
}


-(void)updateMargin
{
    [self setNeedsDisplayInRect:[self marginRect]];
}

-(NSRect)marginRect
{
    NSRect  r;
    
    r = [self bounds];
    r.size.width = margin_width;

    return r;
}

-(void)drawEmptyMargin:(NSRect)aRect
{
    /*
     These values control the color of our margin. Giving the rect the 'clear' 
     background color is accomplished using the windowBackgroundColor.  Change 
     the color here to anything you like to alter margin contents.
     */
    [[NSColor controlColor] set];
    [NSBezierPath fillRect:aRect]; 
    
    // These points should be set to the left margin width.
    NSPoint top = NSMakePoint(aRect.size.width, [self bounds].size.height);
    NSPoint bottom = NSMakePoint(aRect.size.width, 0);
    
    // This draws the dark line separating the margin from the text area.
    [[NSColor grayColor] set];
    [NSBezierPath setDefaultLineWidth:0.75];
    [NSBezierPath strokeLineFromPoint:top toPoint:bottom];
}

-(void) drawNumbersInMargin:(NSRect)aRect;
{
    UInt32 index, lineNumber;
    NSRange lineRange;
    NSRect lineRect;
    
    NSLayoutManager * layoutManager = [text_view layoutManager];
    NSTextContainer * textContainer = [text_view textContainer];

    // Only get the visible part of the scroller view
    NSRect documentVisibleRect = [[text_view enclosingScrollView] documentVisibleRect];
    if( [[text_view enclosingScrollView] hasHorizontalScroller] )
        documentVisibleRect.size.height += [NSScroller scrollerWidth];

    // Find the glyph range for the visible glyphs
    NSRange glyphRange = [layoutManager glyphRangeForBoundingRect: documentVisibleRect inTextContainer: textContainer];

    // Calculate the start and end indexes for the glyphs   
    unsigned start_index = glyphRange.location;
    unsigned end_index = glyphRange.location + glyphRange.length;
 
    index = 0;
    lineNumber = 1;

    // Skip all lines that are visible at the top of the text view (if any)
    while (index < start_index)
    {
        lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange( lineRange );
        ++lineNumber;
    }

    for ( index = start_index; index < end_index; lineNumber++ )
    {
        lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange( lineRange );
        [self drawOneNumberInMargin:lineNumber inRect:lineRect];
    }
    
    lineRect = [layoutManager extraLineFragmentRect];
    if( lineRect.size.width != 0 && lineRect.size.height != 0 )
        [self drawOneNumberInMargin:lineNumber inRect:lineRect];
}


-(void)drawOneNumberInMargin:(unsigned) aNumber inRect:(NSRect)r
{
    NSString * s;
    NSSize stringSize;
    NSRect visible_rect = [[text_view enclosingScrollView] documentVisibleRect];
    
    if( shows_error_line && aNumber == error_line )
    {
        [marginAttributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
    }
    
    s = [NSString stringWithFormat:@"%d", aNumber, nil];
    stringSize = [s sizeWithAttributes:marginAttributes];
    
    NSPoint p = NSMakePoint( MARGIN_WIDTH - stringSize.width - 1.0, 
                             [self frame].size.height - r.origin.y - 
                             r.size.height / 2 - stringSize.height / 3 + 
                             visible_rect.origin.y );
    
    [s drawAtPoint:p withAttributes:marginAttributes];
    
    if( shows_error_line && aNumber == error_line )
    {
        [marginAttributes setObject:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName];
    }
}


- ( mATextView * )textView
{
    return text_view;
}

@end

@implementation NumberedTextView (Private)

- (NSRange)indentNewlinesInRange:(NSRange)range
{
    [[text_view undoManager] beginUndoGrouping];
    
    NSString * text = [text_view string];
    unsigned previous_text_length = [text length];
    
    for( int i = 0; i < range.length; i++ )
    {
        if( [text characterAtIndex:range.location + i] == '\n' )
        {
            [self indentLineOfIndex:range.location + i];
            range.length += [text length] - previous_text_length;
            i += [text length] - previous_text_length;
            previous_text_length = [text length];
        }
    }
    
    if( range.location + range.length > 0 )
        [self indentLineOfIndex:range.location + range.length - 1];
    
    [[text_view undoManager] endUndoGrouping];
    
    return range;
}

- (NSMutableString *)indentationOfLineEndingAtIndex:(unsigned)i
{
    NSTextStorage * ts = [text_view textStorage];
    NSString * text = [ts string];
    NSRange range;
    NSMutableString * indentation = [[[NSMutableString alloc] init] autorelease];
    unsigned line_start = 0, tab_level_end = 0, line_end = i;

    if( line_end == 0 )
        // previous line is the first line, and has no characters
        return indentation;
    
    // first find the beginning of the preceding line
    range = [text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]
                                  options:NSBackwardsSearch
                                    range:NSMakeRange( 0, line_end )];
    line_start = ( range.location == NSNotFound ? 0 : range.location + 1 );
    
    if( line_start == line_end )
        // previous line has no characters and thus no indentation
        return indentation;
    
    // now find the first non-whitespace character on the line
    range = [text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                  options:0
                                    range:NSMakeRange( line_start, line_end - line_start )];
    if( range.location == NSNotFound )
        tab_level_end = line_end;
    else
        tab_level_end = range.location;
    
    if( tab_level_end == line_start )
        // previous line has no indentation
        return indentation;
    
    // we have indices for the start of the previous line and the 
    // end of its indentation; lets actually get that indentation 
    indentation = [[NSMutableString alloc] initWithString:[[ts attributedSubstringFromRange:NSMakeRange( line_start, tab_level_end - line_start )] string]];
    [indentation autorelease];
    
    return indentation;
}

- (NSMutableString *)indentationForLineAfterLineEndingAtIndex:(unsigned)i

/*******************************************************************************
 
on newline:
search backwards for first non-whitespace character

- if {, indent +1

- if ), search backwards for matching ( 
- - if if|else if|for|while|until|repeat( found, indent 1
- - else keep searching backwards

- if ;
- - search backwards for previous ;
- - - if found, search characters in between for else|do
- - search backwards for a newline preceded by whitespace and )
- - - if found, search backwards for matching (
- - - - if if|else if|for|while|until|repeat( found, indent -1
                                                                                                                                     
- if else|do, indent +1
                                                                                                                                     
- if something else, keep same indent                                                                                                                                     
                                                                                                                                     
*******************************************************************************/

{
    NSTextStorage * ts = [text_view textStorage];
    NSString * text = [ts string];
    NSRange range;
    NSMutableString * indentation = [self indentationOfLineEndingAtIndex:i];

    int indentation_change = 0;
    
    NSCharacterSet * wsnl = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet * nonwhitespace = [[NSCharacterSet whitespaceCharacterSet] invertedSet];
    NSCharacterSet * nonwsnl = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    NSCharacterSet * nlcomments = [NSCharacterSet characterSetWithCharactersInString:@"/\n"];
    NSCharacterSet * parens = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    NSCharacterSet * control_break = [NSCharacterSet characterSetWithCharactersInString:@"(){};\n"];
    
    range = [text rangeOfCharacterFromSet:nonwhitespace
                                  options:NSBackwardsSearch | NSLiteralSearch
                                    range:NSMakeRange( 0, i )];
    
    if( range.location == NSNotFound )
        // no newlines or anything found -- return the current indentation
        return indentation;
    if( range.location == i - 1 && 
        [text characterAtIndex:range.location] == '\r' )
    {
        // search again if the nonwhitespace character is a carriage return
        range = [text rangeOfCharacterFromSet:nonwhitespace
                                      options:NSBackwardsSearch | NSLiteralSearch
                                        range:NSMakeRange( 0, i - 1 )];
        
        if( range.location == NSNotFound )
            // no newlines or anything found -- return the current indentation
            return indentation;
    }
    
    /* check for comments
       - scan to previous newline
       - if a // is found, use the first nonwhitespace character before it
       - if a * / is found, take the first nonwhitespace character before the 
         matching / * */
       
    NSRange range2 = [text rangeOfCharacterFromSet:nlcomments
                                           options:NSBackwardsSearch | NSLiteralSearch
                                             range:NSMakeRange( 0, range.location + 1 )];
    if( range2.location != NSNotFound )
    {
        if( [text characterAtIndex:range2.location] == '/' )
        {
            if( range2.location > 0 && 
                [text characterAtIndex:range2.location - 1] == '/' )
            {
                // this line does have a line comment on it
                // find the first nonwhitespace character before the line comment
                range = [text rangeOfCharacterFromSet:nonwhitespace
                                              options:NSBackwardsSearch | NSLiteralSearch
                                                range:NSMakeRange( 0, range2.location - 1 )];
                
                if( range.location == NSNotFound )
                    // no newlines or anything found -- return the current indentation
                    return indentation;
            }
            
            else if( range2.location == range.location && range2.location > 0 && 
                     [text characterAtIndex:range2.location - 1] == '*' )
            {
                // line ends with a block comment endpoint delimiter
                range2 = [text rangeOfString:@"/*" /* comment here to workaround Xcode formatting bug */
                                    options:NSBackwardsSearch | NSLiteralSearch
                                      range:NSMakeRange( 0, range2.location - 1 )];
                
                if( range2.location == NSNotFound || range2.location < 1 )
                    return indentation;
                
                // find the first nonwhitespace character before the block comment
                range = [text rangeOfCharacterFromSet:nonwhitespace
                                              options:NSBackwardsSearch | NSLiteralSearch
                                                range:NSMakeRange( 0, range2.location - 1 )];
                
                if( range.location == NSNotFound )
                    // no newlines or anything found -- return the current indentation
                    return indentation;
            }
            
            else if( [text characterAtIndex:range2.location + 1] == '*' )
            {
                // line contains a block comment beginpoint delimiter
                return indentation;
            }
        }
    }
    
    unichar c = [text characterAtIndex:range.location];
    
    if( c == '{' )
        indentation_change++;

    else if( c == ')' )
    {
        int paren_count = 1;
        while( paren_count )
        {
            range = [text rangeOfCharacterFromSet:parens
                                          options:NSBackwardsSearch
                                            range:NSMakeRange( 0, range.location )];
            
            if( range.location == NSNotFound || range.location == 0 )
                break;
            
            if( [text characterAtIndex:range.location] == ')' )
                paren_count++;
            
            else
                paren_count--;
        }
        
        if( paren_count == 0 )
        {
            range = [text rangeOfCharacterFromSet:nonwsnl
                                          options:NSBackwardsSearch | NSLiteralSearch
                                            range:NSMakeRange( 0, range.location )];
            if( range.location != NSNotFound )
            {
                range.location += 1;
                
                NSEnumerator * word_enum = [magic_words_parens objectEnumerator];
                NSString * word;
                
                while( word = [word_enum nextObject] )
                {
                    unsigned len = [word length];
                    
                    if( len > range.location )
                        continue;
                    
                    if( [text compare:word options:NSLiteralSearch 
                                range:NSMakeRange( range.location - len, len )] 
                        == 0 )
                    {
                        if( range.location - len == 0 ||
                            [okay_before_parens characterIsMember:[text characterAtIndex:range.location - len - 1]] )
                            indentation_change++;
                        break;
                    }
                }
            }            
        }
    }
    
    else if( c == ';' )
    {
        NSRange old_range = range;
        int found_newline = 0, paren_count = 0;
        unsigned start = 0, end = range.location;
        unichar c;
        
        while( true )
            // infinite loop -- scary
        {
            range = [text rangeOfCharacterFromSet:control_break
                                          options:NSBackwardsSearch
                                            range:NSMakeRange( 0, range.location )];
            
            if( range.location == NSNotFound )
                break;
            
            c = [text characterAtIndex:range.location];
            
            if( c == '\n' )
                found_newline++;
            else if( c == '(' )
                paren_count++;
            else if( c == ')' )
                paren_count--;
            else if( !( c == ';' && paren_count != 0 ) )
                break;
        }
        
        int last_word_was_else = 0;
        start = range.location != NSNotFound ? range.location : 0;
        
        for( unsigned i = start; i < end; i++ )
        {
            c = [text characterAtIndex:i];
            
            if( last_word_was_else && ![wsnl characterIsMember:c] )
                last_word_was_else = 1;
            
            if( [okay_before_parens characterIsMember:c] || i == start )
            {
                unsigned old_i = i;
                
                if( [okay_before_parens characterIsMember:c] )
                    i++;
                
                int found_word = 0;
                
                NSEnumerator * mwp_enum = [magic_words_no_parens objectEnumerator];
                NSString * magic_word;
                
                while( magic_word = [mwp_enum nextObject] )
                {
                    unsigned word_length = [magic_word length];
                    
                    if( i + word_length > end )
                        continue;
                    
                    if( [text compare:magic_word options:NSLiteralSearch
                                range:NSMakeRange( i, word_length )] == 0 )
                    {
                        i += word_length;
                        found_word = 1;
                                                
                        if( [okay_after_no_parens characterIsMember:[text characterAtIndex:i]] )
                        {
                            // only change the indentation if there is a newline between
                            // the control flow head and the body statement(s)
                            NSRange newline_range = [text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]
                                                                          options:NSLiteralSearch
                                                                            range:NSMakeRange( i, old_range.location - i )];
                            if( newline_range.location != NSNotFound )
                                indentation_change -= 1;
                            if( [magic_word isEqualToString:@"else"] )
                                last_word_was_else = 1;
                        }
                    }

                    if( found_word )
                        break;
                }
                
                if( !found_word )
                {
                    mwp_enum = [magic_words_parens objectEnumerator];
                    
                    while( magic_word = [mwp_enum nextObject] )
                    {
                        unsigned word_length = [magic_word length];
                        
                        if( i + word_length > end )
                            continue;
                        
                        if( [text compare:magic_word options:NSLiteralSearch
                                    range:NSMakeRange( i, word_length )] == 0 )
                        {
                            i += word_length;
                            found_word = 1;
                            
                            int paren_count = 0;
                            unichar c;
                            
                            for( ; i < end; i++ )
                            {
                                c = [text characterAtIndex:i];
                                
                                if( c == '(' )
                                {
                                    paren_count++;
                                    i++;
                                    break;
                                }
                                
                                if( ![wsnl characterIsMember:c] )
                                {
                                    i++;
                                    break;
                                }
                            }
                            
                            if( paren_count > 0 )
                            {
                                for( ; i < end && paren_count > 0; i++ )
                                {
                                    c = [text characterAtIndex:i];
                                    
                                    if( c == '(' )
                                        paren_count++;
                                    else if( c == ')' )
                                        paren_count--;
                                }
                                
                                // only change the indentation if there is a newline between
                                // the control flow head and the body statement(s)
                                NSRange newline_range = [text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]
                                                                              options:NSLiteralSearch
                                                                                range:NSMakeRange( i, old_range.location - i )];

                                if( paren_count == 0 && newline_range.location != NSNotFound)
                                    indentation_change--;
                            }
                                
                        }
                        
                        if( found_word )
                            break;
                    }
                }
                
                if( !found_word )
                    i = old_i;
            }
        }
    }
    
    else
    {
        NSEnumerator * word_enum = [magic_words_no_parens objectEnumerator];
        NSString * word;
        
        range.location += 1;
        
        while( word = [word_enum nextObject] )
        {
            unsigned len = [word length];
            
            if( len > range.location )
                continue;
            
            if( [text compare:word options:NSLiteralSearch 
                        range:NSMakeRange( range.location - len, len )] 
                == 0 )
            {
                if( range.location - len == 0 ||
                    [okay_before_no_parens characterIsMember:[text characterAtIndex:range.location - len - 1]] )
                    indentation_change++;
                break;
            }
        }
    }
    
    // add a tab for each open bracket in excess of close brackets
    if( indentation_change > 0 )
    {
        // our tab
        NSString * tab;
        
        if( use_tabs )
            // real tab
            tab = @"\t";
        else
        {
            // fake tab (spaces)
            NSMutableString * space_tab = [[[NSMutableString alloc] init] autorelease];
            for( int i = 0; i < tab_width; i++ )
            {
                [space_tab appendString:@" "];
            }
            tab = space_tab;
        }
        
        // repeat it
        for( int i = 0; i < indentation_change; i++ )
            [indentation appendString:tab];
    }
    
    // remove a tab for each close bracket in excess of open brackets
    else if( indentation_change < 0 )
    {
        indentation_change = -indentation_change;
        for( int i = 0; i < indentation_change; i++ )
        {
            // delete characters until we have deleted 1 tab or 4 spaces
            NSRange delete_range = NSMakeRange( 0, 0 );
            for( int j = 0; j < tab_width && j < [indentation length]; j++ )
            {
                delete_range.length++;
                if( [indentation characterAtIndex:j] == '\t' )
                    break;
            }
            [indentation deleteCharactersInRange:delete_range];            
        }
    }
    
    if( use_tabs )
    {
        // fake tab (spaces)
        NSMutableString * space_tab = [[[NSMutableString alloc] init] autorelease];
        for( int i = 0; i < tab_width; i++ )
        {
            [space_tab appendString:@" "];
        }
        
        [indentation replaceOccurrencesOfString:space_tab withString:@"\t"
                                        options:0
                                          range:NSMakeRange( 0, [indentation length] )];
    }
    
    else
    {
        // fake tab (spaces)
        NSMutableString * space_tab = [[[NSMutableString alloc] init] autorelease];
        for( int i = 0; i < tab_width; i++ )
        {
            [space_tab appendString:@" "];
        }
        
        [indentation replaceOccurrencesOfString:@"\t" withString:space_tab
                                        options:0
                                          range:NSMakeRange( 0, [indentation length] )];
    }
    
    return indentation;
}

- (void)indentLineOfIndex:(unsigned)i
{
    NSString * text = [text_view string];
    NSRange range;
    
    unsigned line_start = 0, indentation_end = 0, line_end = 0;
    
    // find end of line
    
    if( i >= [text length] )
        // index is at end of buffer
        line_end = i;
    else
    {
        range = [text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]
                                      options:0
                                        range:NSMakeRange( i, [text length] - i )];
        line_end = range.location == NSNotFound ? [text length] : range.location;
    }
    
    // find beginning of line
    range = [text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]
                                  options:NSBackwardsSearch | NSLiteralSearch
                                    range:NSMakeRange( 0, line_end )];
    line_start = range.location == NSNotFound ? 0 : range.location + 1;
    
    // find end of indentation
    range = [text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                  options:0
                                    range:NSMakeRange( line_start, line_end - line_start )];
    indentation_end = range.location == NSNotFound ? line_end : range.location;
    
    // get indentation, given previous line
    NSMutableString * indentation = [[NSMutableString new] autorelease];
    if( line_start )
        indentation = [self indentationForLineAfterLineEndingAtIndex:line_start - 1];
    
    // see if first character is an close bracket 
    // (decrease indentation if so)
    if( indentation_end < [text length] )
    {
        if( [text characterAtIndex:indentation_end] == '}' )
        {
            // TODO: make multiple consecutive close brackets decrease indentation dynamically?
            
            // delete characters until we have deleted 1 tab or 4 spaces
            NSRange delete_range = NSMakeRange( 0, 0 );
            for( int j = 0; j < tab_width && j < [indentation length]; j++ )
            {
                delete_range.length++;
                if( [indentation characterAtIndex:j] == '\t' )
                    break;
            }
            
            [indentation deleteCharactersInRange:delete_range];
        }
        
        else if( [text characterAtIndex:indentation_end] == '{' )
        {
/*            // delete characters until we have deleted 1 tab or 4 spaces
            NSRange delete_range = NSMakeRange( 0, 0 );
            for( int j = 0; j < tab_width && j < [indentation length]; j++ )
            {
                delete_range.length++;
                if( [indentation characterAtIndex:j] == '\t' )
                    break;
            }
            
            [indentation deleteCharactersInRange:delete_range];
*/
            indentation = [self indentationOfLineEndingAtIndex:line_start - 1];
        }
    }
    
    NSTextStorage * ts = [text_view textStorage];
    
    // register text change undo operation with undo system
    [[[text_view undoManager] prepareWithInvocationTarget:ts]
                    replaceCharactersInRange:NSMakeRange( line_start,
                                                          [indentation length] )
                        withAttributedString:[ts attributedSubstringFromRange:NSMakeRange( line_start,
                                                                                           indentation_end - line_start )]];
    [[text_view undoManager] setActionName:@"Smart Indentation"];
    
    // do the change
    [ts beginEditing];
    [ts replaceCharactersInRange:NSMakeRange( line_start, indentation_end - line_start )
                      withString:indentation];
    [ts endEditing];
    
    //[self indentNewlinesInRange:NSMakeRange( line_start, line_end - line_start + [indentation length] )];
}

@end



