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
// file: miniAudicleView.mm
// desc: view class for miniAudicle, for displaying ChucK source files
//
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import "miniAudicleView.h"
#import "miniAudicleController.h"
#include <string>

@implementation miniAudicleView

- (id)initWithFile:(NSString *)file withController:(id)c
{
    if( self = [super init] )
    {
        NSDocumentController * doc_controller = [NSDocumentController sharedDocumentController];
        NSDocument * doc = [[NSDocument alloc] initWithContentsOfFile:file ofType:NSPlainFileType];
        [doc_controller addDocument:doc];
        controller = c;
        filename = [file retain];
        cid = -1;
        vid = vid;
        vm_on = NO;
        
        NSRect content_rect = { { 10, 10 }, { 600, 600 } };
        unsigned int style = NSTitledWindowMask | NSClosableWindowMask | 
            NSResizableWindowMask | NSMiniaturizableWindowMask;
        window = [[NSWindow alloc] initWithContentRect:content_rect
                                             styleMask:style
                                               backing:NSBackingStoreBuffered
                                                 defer:YES];
        
        [window center];
        
        if( file != nil )
        {
            // set the window title to the last component of the file path, ie 
            // the filename
            NSArray * t_array = [file pathComponents];
            short_filename = [t_array objectAtIndex:( [t_array count] - 1 )];
            [short_filename retain];
        }
        else
            // use the default file name
            short_filename = @"miniAudicle";
        
        [window setTitle:short_filename];
        
        // retrieve the frame of the content area in the window
        content_rect = [[window contentView] frame];
        
        NSView * content_view = [[NSView alloc] initWithFrame:content_rect];
        
        content_rect.origin.y += 20;
        content_rect.size.height -= 20;
        
        // initialize a view to display text
        text = [[NSTextView alloc] initWithFrame:content_rect];
        
        // set the text data to the contents of the file, if specified
        //if( file != nil )
        //  [text setString:[NSString stringWithContentsOfFile:file]];
        
        // set various text view properties
        [text setEditable:YES];
        [text setAllowsUndo:YES];
        [text setUsesFindPanel:YES]; // only in Mac OS X v10.3 +
        [text setHorizontallyResizable:YES];
        [text setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        [text setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [[text textContainer] setWidthTracksTextView:NO];
        [[text textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];

        [text setFont:[NSFont fontWithName:@"Monaco" size:10]];
        
        // initialize a scrolling view
        NSScrollView * scroll_view = [[NSScrollView alloc] initWithFrame:content_rect];
        
        // embed the text view in the scrolling view
        [scroll_view setDocumentView:text];
        
        // set scroll view properties
        [scroll_view setHasVerticalScroller:YES];
        [scroll_view setHasHorizontalScroller:YES];
        [scroll_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        // embed the scroll view in the content area
        [content_view addSubview:scroll_view];
        
        content_rect = NSMakeRect( 0, 0, 600, 20 );
        
        // make status text view 
        status_text = [[NSTextField alloc] initWithFrame:content_rect];
        
        [status_text setBackgroundColor:[NSColor gridColor]];
        [status_text setAutoresizingMask:NSViewWidthSizable];
        [status_text setBezeled:NO];
        [status_text setEditable:NO];
        [status_text setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        
        [content_view addSubview:status_text];
        
        // embed primary view in the window's content area
        [window setContentView:content_view];
        
        [window makeFirstResponder:text];
        
        // build the toolbar
        NSToolbar * toolbar = [[NSToolbar alloc] initWithIdentifier:@"miniAudicle"];
        [toolbar setVisible:YES];
        [toolbar setDelegate:self];
        
        // add toolbar to the window
        [window setToolbar:toolbar];
        
        // move window to the front
        [window makeKeyAndOrderFront:self];
        
        [doc addWindowController:[[NSWindowController alloc] initWithWindow:window]];
        
        // set this instance as the delegate class
        [window setDelegate:self];
        
        // tell the miniAudicleController that this is the main window right now
        if( [window isMainWindow] )
            [controller setMainMiniAudicleView:self];
    }
    
    return self;
}

- (void)dealloc
{
    if( filename != nil )
    {
        [filename release];
        [short_filename release];
    }
    
    [super dealloc];
}

- (BOOL)save
{
    if( filename != nil )
    {
        [[text string] writeToFile:filename atomically:YES];
        return YES;
    }
    
    else
        return NO;
}

- (void)saveAs:(NSString *)file
{
    if( filename != nil )
    {
        [filename release];
        [short_filename release];
    }
    
    filename = [file retain];
    
    // rename the parent window
    NSArray * t_array = [file pathComponents];
    short_filename = [[t_array objectAtIndex:( [t_array count] - 1 )] retain];
    [window setTitle:short_filename];
    
    [self save];
}

- (void)add:(id)sender
{
    string result;
    string code_name;
    if( filename == nil )
        code_name = "untitled";
    else
        code_name = [short_filename cString];
    string code = [[text string] cString];
    
    [controller miniAudicle]->run_code( code, code_name, cid, result ); 
    
    [status_text setStringValue:[NSString stringWithCString:result.c_str()]];
}

- (void)remove:(id)sender
{
    string result;
    [controller miniAudicle]->remove_code( cid, result );
    [status_text setStringValue:[NSString stringWithCString:result.c_str()]];
}

- (void)replace:(id)sender
{
    if( cid == -1 )
        [self add:sender];
    else
    {
        string result;
        string code = [[text string] cString];
        [controller miniAudicle]->replace_code( code, cid, result );
        [status_text setStringValue:[NSString stringWithCString:result.c_str()]];
    }
}

- (void)removeall:(id)sender
{
    string result;
    [controller miniAudicle]->removeall( result );
    [status_text setStringValue:[NSString stringWithCString:result.c_str()]];
}

- (void)removelast:(id)sender
{
    string result;
    [controller miniAudicle]->removelast( result );
    [status_text setStringValue:[NSString stringWithCString:result.c_str()]];
}

- (void)vm_on
{
    vm_on = YES;
        
    NSArray * toolbar_items = [[window toolbar] items];
    
    int i = 0, len = [toolbar_items count];
    for( ; i < len; i++ )
    {
        [[toolbar_items objectAtIndex:i] setEnabled:YES];
    }   
}

- (void)vm_off
{
    vm_on = NO;

    NSArray * toolbar_items = [[window toolbar] items];
    
    int i = 0, len = [toolbar_items count];
    for( ; i < len; i++ )
    {
        [[toolbar_items objectAtIndex:i] setEnabled:NO];
    }
}

- (void)windowDidBecomeMain:(NSNotification *)n
{
    [controller setMainMiniAudicleView:self];
}

- (void)windowWillClose:(NSNotification *)n
{
    [[window toolbar] autorelease];
    [[[window contentView] subviews] makeObjectsPerformSelector:@selector(autorelease)];
    
    // the windows contentView is released by the OS automatically--keep the next line commented out
    // [[window contentView] autorelease];
    
    [text autorelease];
    
    // the window is released by the OS automatically--keep the next line commented out
    //[window autorelease];
    
    [controller removeMiniAudicleView:self];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSString *)itemIdentifier 
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem * toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [toolbar_item autorelease];
    
    if( [itemIdentifier isEqual:@"add"] )
    {
        [toolbar_item setLabel:@"Add Shred"];
        [toolbar_item setAction:@selector(add:)];
        [toolbar_item setImage:[NSImage imageNamed:@"add.tiff"]];
    }
    
    else if( [itemIdentifier isEqual:@"remove"] )
    {
        [toolbar_item setLabel:@"Remove Shred"];
        [toolbar_item setAction:@selector(remove:)];
        [toolbar_item setImage:[NSImage imageNamed:@"remove.tiff"]];
    }
    
    else if( [itemIdentifier isEqual:@"replace"] )
    {
        [toolbar_item setLabel:@"Replace Shred"];
        [toolbar_item setAction:@selector(replace:)];
        [toolbar_item setImage:[NSImage imageNamed:@"replace.tiff"]];
    }
    
    else if( [itemIdentifier isEqual:@"removeall"] )
    {
        [toolbar_item setLabel:@"Remove All"];
        [toolbar_item setAction:@selector(removeall:)];
        [toolbar_item setImage:[NSImage imageNamed:@"removeall.tiff"]];
    }
    
    else if( [itemIdentifier isEqual:@"removelast"] )
    {
        [toolbar_item setLabel:@"Remove Last"];
        [toolbar_item setAction:@selector(removelast:)];
        [toolbar_item setImage:[NSImage imageNamed:@"removelast.tiff"]];
    }
    
    if( !vm_on )
        [toolbar_item setEnabled:NO];
    
    [toolbar_item setTag:1];
    [toolbar_item setTarget:self];
    
    return toolbar_item;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"add", @"remove", @"removelast", 
        @"removeall", NSToolbarFlexibleSpaceItemIdentifier, @"replace", nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"add", @"replace", @"remove", 
        NSToolbarFlexibleSpaceItemIdentifier, @"removelast", @"removeall", nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbar_item
{
    if( !vm_on && [toolbar_item tag] == 1 )
        return NO;
    else
        return YES;
}



@end


