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
// file: miniAudicleDocument.mm
// desc: Document class, creates a new window for each new document and manages
//       document-level connections to miniAudicle
//
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import "miniAudicleDocument.h"
#import "miniAudicleController.h"
#import "NumberedTextView.h"
#import "miniAudiclePreferencesController.h"
//#import "KBPopUpToolbarItem.h"
#import "RBSplitView.h"
#import "miniAudicle.h"
#import "chuck_parse.h"
#import "util_string.h"

#define USE_POPUP_TOOLBAR_ITEMS 0

@interface mAArgumentsTableView : NSTableView

- (void)keyDown:(NSEvent *)e;

@end

@implementation mAArgumentsTableView

- (void)keyDown:(NSEvent *)e
{
    if( [[e characters] length] > 0 )
    {
        unichar c = [[e characters] characterAtIndex:0];
        
        if ( ( c == NSDeleteFunctionKey || c == NSDeleteCharFunctionKey ||
               c == NSDeleteCharacter || c == NSBackspaceCharacter ) && 
             [[self dataSource] respondsToSelector:@selector( argumentsTableView:deleteRows: )])
        {
            [[self dataSource] argumentsTableView:self 
                                       deleteRows:[self selectedRowIndexes]];
            [self reloadData];
        }
        
        else if( c == NSInsertLineFunctionKey || c == NSNewlineCharacter || 
                 c == NSCarriageReturnCharacter || c == NSEnterCharacter )
        {
            [self editColumn:[self columnWithIdentifier:@"argument"]
                         row:[self selectedRow]
                   withEvent:nil
                      select:YES];
        }
        
        else
            [super keyDown:e];
    }
    
    else 
        [super keyDown:e];
}

@end

@interface NSString ( mADocument )
- (string)stlString;
@end

@implementation NSString ( mADocument )

- (string)stlString
{
    NSData * data = [self dataUsingEncoding:NSASCIIStringEncoding
                       allowLossyConversion:YES];
    return string( ( char * ) [data bytes], [data length] );
}

@end

//@interface mAText

@implementation miniAudicleDocument

- (id)init
{
    if( self = [super init] )
    {
        ma = nil;
        text_view = nil;
        toolbar = nil;
        status_text = nil;
        data = nil;
        
        docid = 0;
        vm_on = FALSE;
        
        arguments = [[NSMutableArray alloc] init];
        reject_argument_edits = YES;
        
        shows_arguments = YES;
        shows_toolbar = YES;
        shows_line_numbers = YES;
        shows_status_bar = YES;
        
        has_customized_appearance = NO;
        
        /*[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector( userDefaultsDidChange: )
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];*/
    }
    
    return self;
}

- (void)awakeFromNib
{
    [toggle_argument_subview setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    [toggle_argument_subview setBezelStyle:NSShadowlessSquareBezelStyle];
    
    [toggle_argument_subview retain];
    [argument_text retain];
    [status_text retain];
    //[toggle_argument_subview setBezelStyle:NSSmallSquareBezelStyle];
}

- (void)dealloc
{
    if( text_view != nil)
        [text_view release];
    if( toolbar != nil )
        [toolbar release];
    if( status_text != nil )
        [status_text release];
    if( data != nil )
        [data release];
    if( ma != nil )
        ma->free_document_id( docid );
    
    if( toggle_argument_subview )
        [toggle_argument_subview release];
    if( argument_text )
        [argument_text release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    window = [windowController window];
    
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    [mac setLastWindowTopLeftCorner:[window cascadeTopLeftFromPoint:[mac lastWindowTopLeftCorner]]];

    // set text view syntax highlighter
    [text_view setSyntaxHighlighter:[mac syntaxHighlighter] colorer:mac];
    if( data != nil )
    {
        BOOL esi = [text_view smartIndentationEnabled];
        [text_view setSmartIndentationEnabled:NO];
        [[text_view textView] setString:data];
        [text_view setSmartIndentationEnabled:esi];
    }
    
    // build the toolbar
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"miniAudicle"];
    [toolbar setVisible:YES];
    [toolbar setDelegate:self];
    
    // add toolbar to the window
    [window setToolbar:toolbar];
    
    NSButton * toolbar_pill = [window standardWindowButton:NSWindowToolbarButton];
    [toolbar_pill setTarget:self];
    [toolbar_pill setAction:@selector( toggleToolbar: )];
    
    [argument_subview collapse];
    
    [window makeFirstResponder:text_view];
    
    [self userDefaultsDidChange:nil];
}

- (NSString * )windowNibName
{
    return @"miniAudicleDocument";
}

- (NSData *)dataRepresentationOfType:(NSString *)type
{
    return [[[text_view textView] string] dataUsingEncoding:NSASCIIStringEncoding
                                       allowLossyConversion:YES];
}

- (BOOL)loadDataRepresentation:(NSData *)t_data ofType:(NSString *)type
{
    data = [[NSString alloc] initWithData:t_data encoding:NSASCIIStringEncoding];
    if( text_view != nil )
    {
        BOOL esi = [text_view smartIndentationEnabled];
        [text_view setSmartIndentationEnabled:NO];
        [[text_view textView] setString:data];
        [text_view setSmartIndentationEnabled:esi];
    }
    
    return YES;
}

- (BOOL)isEmpty
{
    return [[[text_view textView] string] length] == 0 && ![self isDocumentEdited];
}

- (void)userDefaultsDidChange:(NSNotification *)n
{
    if( !has_customized_appearance )
    {
        [self setShowsArguments:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowArguments]];
        [self setShowsLineNumbers:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesDisplayLineNumbers]];
        [self setShowsToolbar:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowToolbar]];
        [self setShowsStatusBar:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowStatusBar]];
        has_customized_appearance = NO;
    }
}

- (void)setMiniAudicle:(miniAudicle *)t_ma
{
    ma = t_ma;
    docid = ma->allocate_document_id();
}

- (void)add:(id)sender
{
    [self handleArgumentText:argument_text];
    
    string result;
    t_CKUINT shred_id;
    string code_name = string( [[self displayName] stlString] );

    string code = [[[text_view textView] string] stlString];
    
    vector< string > argv;
    NSEnumerator * args_enum = [arguments objectEnumerator];
    NSString * arg = nil;
    while( arg = [args_enum nextObject] )
        argv.push_back( [arg stlString] );
    
    [text_view setShowsErrorLine:NO];
    
    t_OTF_RESULT otf_result = ma->run_code( code, code_name, argv, docid, 
                                            shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        [[text_view textView] animateAdd];
        [text_view setShowsErrorLine:NO];
        
#if defined( USE_POPUP_TOOLBAR_ITEMS ) && USE_POPUP_TOOLBAR_ITEMS
        NSString * menu_title = [NSString stringWithFormat:@"%u (%@)", 
            shred_id, [self displayName]];
        NSMenuItem * menu_item = [[NSMenuItem alloc] initWithTitle:menu_title
                                                            action:@selector(removeShred:)
                                                     keyEquivalent:@""];
        [menu_item autorelease];
        [menu_item setTag:shred_id];
        [remove_menu insertItem:menu_item atIndex:( [remove_menu numberOfItems] - 2 )];

        menu_item = [[NSMenuItem alloc] initWithTitle:menu_title
                                               action:@selector(replaceShred:)
                                        keyEquivalent:@""];
        [menu_item autorelease];
        [menu_item setTag:shred_id];
        [replace_menu insertItem:menu_item atIndex:( [replace_menu numberOfItems] - 2 )];
#endif
    }
    
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        [mac setLockdown:YES];
    }
    
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        if( ma->get_last_result( docid, NULL, NULL, &error_line ) )
        {
            [text_view setShowsErrorLine:YES];
            [text_view setErrorLine:error_line];
        }
        
        [[text_view textView] animateError];
        
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    
    else
    {
        [[text_view textView] animateError];
        
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    //miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    //[mac updateSyntaxHighlighting];
}

- (void)replace:(id)sender
{
    [self handleArgumentText:argument_text];
    
    string result;
    t_CKUINT shred_id;
    string code = [[[text_view textView] string] stlString];
    string code_name = [[self displayName] stlString];
    
    vector< string > argv;
    NSEnumerator * args_enum = [arguments objectEnumerator];
    NSString * arg = nil;
    while( arg = [args_enum nextObject] )
        argv.push_back( [arg stlString] );
    
    t_OTF_RESULT otf_result = ma->replace_code( code, code_name, argv, docid, 
                                                shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        [[text_view textView] animateReplace];
        [text_view setShowsErrorLine:NO];
        
#if defined( USE_POPUP_TOOLBAR_ITEMS ) && USE_POPUP_TOOLBAR_ITEMS
        [[remove_menu itemWithTag:shred_id] setTitle:[self displayName]];
        [[replace_menu itemWithTag:shred_id] setTitle:[self displayName]];
#endif
    }
    
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        [mac setLockdown:YES];
    }
    
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        if( ma->get_last_result( docid, NULL, NULL, &error_line ) )
        {
            [text_view setShowsErrorLine:YES];
            [text_view setErrorLine:error_line];
        }
        
        [[text_view textView] animateError];
        
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    
    else
    {
        [[text_view textView] animateError];
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    
    //miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    //[mac updateSyntaxHighlighting];
}

- (void)remove:(id)sender
{
    string result;
    t_CKUINT shred_id;
    
    t_OTF_RESULT otf_result = ma->remove_code( docid, shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        [[text_view textView] animateRemove];
        [text_view setShowsErrorLine:NO];
        
#if defined( USE_POPUP_TOOLBAR_ITEMS ) && USE_POPUP_TOOLBAR_ITEMS
        [remove_menu removeItem:[remove_menu itemWithTag:shred_id]];
        [replace_menu removeItem:[replace_menu itemWithTag:shred_id]];
#endif
    }
    
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        [mac setLockdown:YES];
    }
    
    else
    {
        [[text_view textView] animateError];
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
}

- (void)removeall:(id)sender
{
    string result;
    if( !ma->removeall( docid, result ) )
    {
        [[text_view textView] animateRemoveAll];
        [text_view setShowsErrorLine:NO];
    }
    
    [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
}

- (void)removelast:(id)sender
{
    string result;
    if( !ma->removelast( docid, result ) )
    {
        [[text_view textView] animateRemoveLast];
        [text_view setShowsErrorLine:NO];
    }
    
    [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
}

- (void)removeShred:(id)sender
{
    if( sender && [sender tag] == 0 )
    {
        
    }
    
    else
    {
        
    }
}

- (void)replaceShred:(id)sender
{
    
}

- (void)setLockEditing:(BOOL)lock
{
    [[text_view textView] setEditable:!lock];
}

- (BOOL)lockEditing
{
    return ![[text_view textView] isEditable];
}

- (void)commentOut:(id)sender
{
    
}

- (void)saveBackup:(id)sender
{
    //NSString * backup_name = [[NSUserDefaults standardUserDefaults] stringForKey:];
}

- (void)vm_on
{
    [self setVMOn:YES];
}

- (void)vm_off
{
    [self setVMOn:NO];
}

- (void)setVMOn:(BOOL)t_vm_on
{
    vm_on = t_vm_on;
    
    NSArray * toolbar_items = [toolbar items];
    
    int i = 0, len = [toolbar_items count];
    for( ; i < len; i++ )
    {
        [[toolbar_items objectAtIndex:i] setEnabled:vm_on];
    }
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSString *)itemIdentifier 
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem * toolbar_item;
    
    if( [itemIdentifier isEqual:@"add"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Add Shred"];
        [toolbar_item setAction:@selector(add:)];
        [toolbar_item setImage:[NSImage imageNamed:@"add.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"remove"] )
    {
#if defined( USE_POPUP_TOOLBAR_ITEMS ) && USE_POPUP_TOOLBAR_ITEMS
        KBPopUpToolbarItem * popup_tb_item = [[KBPopUpToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        remove_menu = [[NSMenu new] autorelease];
        [remove_menu addItem:[NSMenuItem separatorItem]];
        NSMenuItem * mi = [[NSMenuItem alloc] initWithTitle:@"Remove All Child Shreds"
                                                     action:@selector(replaceShred:)
                                              keyEquivalent:@""];
        [mi autorelease];
        [mi setTag:0];
        [remove_menu addItem:mi];
        [popup_tb_item setMenu:remove_menu];
        toolbar_item = popup_tb_item;
        [toolbar_item setLabel:@"Remove Shred"];
        [toolbar_item setAction:@selector(remove:)];
        NSImage * remove_image = [NSImage imageNamed:@"remove.png"];
        [remove_image setScalesWhenResized:YES];
        // TODO: scale these in image editor, ditch crappy runtime scaling
        [remove_image setSize:NSMakeSize( 32, 32 )];
        [toolbar_item setImage:remove_image];
#else
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove Shred"];
        [toolbar_item setAction:@selector(remove:)];
        [toolbar_item setImage:[NSImage imageNamed:@"remove.png"]];
#endif
    }
    
    else if( [itemIdentifier isEqual:@"replace"] )
    {
#if defined( USE_POPUP_TOOLBAR_ITEMS ) && USE_POPUP_TOOLBAR_ITEMS
        KBPopUpToolbarItem * popup_tb_item = [[KBPopUpToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        replace_menu = [[NSMenu new] autorelease];
        [replace_menu addItem:[NSMenuItem separatorItem]];
        NSMenuItem * mi = [[NSMenuItem alloc] initWithTitle:@"Replace All Child Shreds"
                                                     action:@selector(replaceShred:)
                                              keyEquivalent:@""];
        [mi autorelease];
        [mi setTag:0];
        [replace_menu addItem:mi];
        [popup_tb_item setMenu:replace_menu];
        toolbar_item = popup_tb_item;
        [toolbar_item setLabel:@"Replace Shred"];
        [toolbar_item setAction:@selector(replace:)];
        NSImage * replace_image = [NSImage imageNamed:@"replace.png"];
        [replace_image setScalesWhenResized:YES];
        // TODO: scale these in image editor, ditch crappy runtime scaling
        [replace_image setSize:NSMakeSize( 32, 32 )];
        [toolbar_item setImage:replace_image];
#else
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Replace Shred"];
        [toolbar_item setAction:@selector(replace:)];
        [toolbar_item setImage:[NSImage imageNamed:@"replace.png"]];
#endif
    }
    
    else if( [itemIdentifier isEqual:@"removeall"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove All Shreds"];
        [toolbar_item setAction:@selector(removeall:)];
        [toolbar_item setImage:[NSImage imageNamed:@"removeall.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"removelast"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove Last Shred"];
        [toolbar_item setAction:@selector(removelast:)];
        [toolbar_item setImage:[NSImage imageNamed:@"removelast.png"]];
    }
    
    [toolbar_item autorelease];

    [toolbar_item setEnabled:vm_on];
    
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
    if( [toolbar_item tag] == 1 )
        return vm_on;
    
    else
        return YES;
}

- (void)toggleToolbar:(id)sender
{
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    [mac hideToolbar:sender];
}

#define __MA_ARGUMENTS_TEXT_HEIGHT__ 24
- (void)setShowsArguments:(BOOL)_shows_arguments
{
    if( _shows_arguments != shows_arguments )
    {
        if( !_shows_arguments )
        {
            //printf( "hiding arguments\n" );
            [toggle_argument_subview removeFromSuperview];
            [argument_text removeFromSuperview];
            
            RBSplitView * view = [argument_subview splitView];
            NSRect frame_rect = [view frame];
            frame_rect.size.height += __MA_ARGUMENTS_TEXT_HEIGHT__;
            //frame_rect.origin.y += __MA_ARGUMENTS_TEXT_HEIGHT__;
            [view setFrame:frame_rect];
        }
    
        else
        {
            //printf( "showing arguments\n" );
            RBSplitView * view = [argument_subview splitView];
            NSRect frame_rect = [view frame];
            frame_rect.size.height -= __MA_ARGUMENTS_TEXT_HEIGHT__;
            //frame_rect.origin.y -= __MA_ARGUMENTS_TEXT_HEIGHT__;
            [view setFrame:frame_rect];
            
            [[window contentView] addSubview:toggle_argument_subview];
            [[window contentView] addSubview:argument_text];
            
            // redisplay the arguments bar area
            [[window contentView] setNeedsDisplayInRect:NSMakeRect( 0, frame_rect.size.height, 
                                                                    frame_rect.size.width,
                                                                    frame_rect.size.height - __MA_ARGUMENTS_TEXT_HEIGHT__ )];
        }
        
        shows_arguments = _shows_arguments;
    }
}

- (BOOL)showsArguments
{
    return shows_arguments;
}



- (void)setShowsToolbar:(BOOL)_shows_toolbar
{
    if( shows_toolbar != _shows_toolbar )
    {
        [toolbar setVisible:_shows_toolbar];
        shows_toolbar = _shows_toolbar;
    }
    
    //has_customized_appearance = YES;
}

- (BOOL)showsToolbar
{
    return shows_toolbar;
}

- (void)setShowsLineNumbers:(BOOL)_shows_line_numbers
{
    if( shows_line_numbers != _shows_line_numbers )
    {
        [text_view enableLineNumbers:_shows_line_numbers];
        shows_line_numbers = _shows_line_numbers;
    }
    
    //has_customized_appearance = YES;
}

- (BOOL)showsLineNumbers
{
    return shows_line_numbers;
}


- (void)setShowsStatusBar:(BOOL)_shows_status_bar
{
    if( shows_status_bar != _shows_status_bar )
    {
        if( !_shows_status_bar )
        {
            [status_text removeFromSuperview];
            
            RBSplitView * view = [argument_subview splitView];
            NSRect frame_rect = [view frame];
            frame_rect.origin.y -= [status_text frame].size.height;
            frame_rect.size.height += [status_text frame].size.height;
            [view setFrame:frame_rect];
        }
        
        else
        {
            RBSplitView * view = [argument_subview splitView];
            NSRect frame_rect = [view frame];
            frame_rect.origin.y += [status_text frame].size.height;
            frame_rect.size.height -= [status_text frame].size.height;
            [view setFrame:frame_rect];
            
            [[window contentView] addSubview:status_text];
            
            // redisplay the arguments bar area
            [[window contentView] setNeedsDisplayInRect:NSMakeRect( 0, 0, 
                                                                    frame_rect.size.width,
                                                                    frame_rect.size.height - [status_text frame].size.height )];
        }
        
        shows_status_bar = _shows_status_bar;
    }
    
    //has_customized_appearance = YES;
}

- (BOOL)showsStatusBar
{
    return shows_status_bar;
}

- (void)handleArgumentText:(id)sender
{
    NSMutableString * arg_text = [NSMutableString stringWithString:[sender stringValue]];
    [arg_text insertString:@"filename:" atIndex:0];
    string filename;
    vector< string > argv;
    if( extract_args( [arg_text stlString], filename, argv ) )
    {
        [arguments removeAllObjects];
        
        vector< string >::const_iterator iter = argv.begin(), end = argv.end();
        for( ; iter != end; iter++ )
            [arguments addObject:[NSString stringWithCString:iter->c_str()]];
        
        [argument_table reloadData];
    }
}

- (void)toggleArguments:(id)sender
{
    if( [sender state] == NSOnState )
    {
        [[argument_subview splitView] setDivider:[NSImage imageNamed:@"Thumb9.png"]];
        [argument_subview expandWithAnimation];
    }
    
    else
    {
        [argument_subview collapseWithAnimation];
    }
}

- (void)splitView:(RBSplitView*)sender didExpand:(RBSplitSubview*)subview
{
    if( subview == argument_subview )
    {
        [toggle_argument_subview setState:NSOnState];
        [sender setDivider:[NSImage imageNamed:@"Thumb9.png"]];
        [window makeFirstResponder:argument_text];
    }
}

- (void)splitView:(RBSplitView*)sender didCollapse:(RBSplitSubview*)subview 
{
    if( subview == argument_subview )
    {
        [toggle_argument_subview setState:NSOffState];
        [sender setDivider:nil];
        [window makeFirstResponder:[text_view textView]];
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)tv
{
    return [arguments count] + 1;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc 
            row:(int)r
{
    if( [[tc identifier] isEqualToString:@"argument"] )
    {
        if( r == [arguments count] )
        {
            NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSColor disabledControlTextColor], NSForegroundColorAttributeName, 
                @"double-click here to add an attribute", NSToolTipAttributeName,
                //[NSNumber numberWithFloat:0.5], NSObliquenessAttributeName, 
                nil];
            return [[[NSAttributedString alloc] initWithString:@"..."
                                                    attributes:attributes]
                autorelease];
        }
        
        else
            return [arguments objectAtIndex:r];
    }
    
    else if( [[tc identifier] isEqualToString:@"number"] )
    {
        if( r == [arguments count] )
            return @"";
        
        else
            return [NSString stringWithFormat:@"%i", r];
    }
    
    return @"error!";
}

- (void)tableView:(NSTableView *)tv
   setObjectValue:(id)v
   forTableColumn:(NSTableColumn *)tc
              row:(int)r
{
    if( reject_argument_edits )
        return;
    
    if( [[tc identifier] isEqualToString:@"argument"] )
    {
        if( r == [arguments count] )
            [arguments addObject:v];
        else
            [arguments replaceObjectAtIndex:r withObject:v];
        
        NSMutableString * new_argument_text = [NSMutableString stringWithString:@""];
        NSEnumerator * args_enum = [arguments objectEnumerator];
        NSString * arg = [args_enum nextObject];
        if( arg )
            [new_argument_text appendString:arg];
        while( arg = [args_enum nextObject] )
        {
            [new_argument_text appendString:@":"];
            [new_argument_text appendString:arg];
        }
        
        [argument_text setStringValue:new_argument_text];
        
        reject_argument_edits = YES;
        
        [tv reloadData];
    }
}

- (void)argumentsTableView:(mAArgumentsTableView *)atv 
                deleteRows:(NSIndexSet *)is
{        
    if( [is containsIndex:[arguments count]] )
    {
        NSMutableIndexSet * mis = [[[NSMutableIndexSet alloc] initWithIndexSet:is] autorelease];
        [mis removeIndex:[arguments count]];
        is = mis;
    }
    
    if( [is count] == 0 )
        NSBeep();
    
    [arguments removeObjectsAtIndexes:is];
    
    NSMutableString * new_argument_text = [NSMutableString stringWithString:@""];
    NSEnumerator * args_enum = [arguments objectEnumerator];
    NSString * arg = [args_enum nextObject];
    if( arg )
        [new_argument_text appendString:arg];
    while( arg = [args_enum nextObject] )
    {
        [new_argument_text appendString:@":"];
        [new_argument_text appendString:arg];
    }
    
    [argument_text setStringValue:new_argument_text];
    
    [atv reloadData];
}

- (void)controlTextDidBeginEditing:(NSNotification *)n
{
    reject_argument_edits = NO;
}

@end
