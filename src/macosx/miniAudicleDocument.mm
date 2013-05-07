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
#import "miniAudicle.h"
#import "chuck_parse.h"
#import "util_string.h"
#import "NSString+STLString.h"
#import "mADocumentViewController.h"
#import "mAMultiDocWindowController.h"


@implementation miniAudicleDocument

@synthesize data;

- (id)init
{
    if( self = [super init] )
    {
        ma = nil;
        
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
    [argument_text retain];
    [status_text retain];
}

- (void)dealloc
{
    [text_view release];
    [toolbar release];
    [status_text release];
    [data release];
    if( ma != nil )
        ma->free_document_id( docid );
    
    [argument_text release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];

//    window = [windowController window];
    
//    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//    [mac setLastWindowTopLeftCorner:[window cascadeTopLeftFromPoint:[mac lastWindowTopLeftCorner]]];
//
//    // set text view syntax highlighter
//    [text_view setSyntaxHighlighter:[mac syntaxHighlighter] colorer:mac];
//    if( data != nil )
//    {
//        BOOL esi = [text_view smartIndentationEnabled];
//        [text_view setSmartIndentationEnabled:NO];
//        [[text_view textView] setString:data];
//        [text_view setSmartIndentationEnabled:esi];
//    }
    
//    // build the toolbar
//    toolbar = [[NSToolbar alloc] initWithIdentifier:@"miniAudicle"];
//    [toolbar setVisible:YES];
//    [toolbar setDelegate:self];
//    
//    // add toolbar to the window
//    [window setToolbar:toolbar];
//    
//    NSButton * toolbar_pill = [window standardWindowButton:NSWindowToolbarButton];
//    [toolbar_pill setTarget:self];
//    [toolbar_pill setAction:@selector( toggleToolbar: )];
//    
//    [window makeFirstResponder:text_view];
    
    [self userDefaultsDidChange:nil];
}

//- (NSString * )windowNibName
//{
//    return @"miniAudicleDocument";
//}

-(void)makeWindowControllers
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:DocumentNeedWindowNotification object:self];
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    [[mac topWindowController] addDocument:self];
    [[[mac topWindowController] window] makeKeyAndOrderFront:self];
}

- (NSString *)windowNibName
{
    assert(false);
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"";
}

-(NSViewController *)newPrimaryViewController
{
    mADocumentViewController* ctrl = [[mADocumentViewController alloc] initWithNibName:@"mADocumentView" bundle:nil];
    ctrl.document = self;
    
    // other initialization if needed
    return ctrl;
}

//+ (BOOL)autosavesInPlace
//{
//    return YES;
//}


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
    
    string filepath;
    if([self fileURL] && [[self fileURL] isFileURL])
        filepath = [[[self fileURL] path] stlString];
    else
        filepath = "";
    
    t_OTF_RESULT otf_result = ma->run_code( code, code_name, argv, filepath, 
                                            docid, shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        [[text_view textView] animateAdd];
        [text_view setShowsErrorLine:NO];
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
    
    string filepath;
    if([self fileURL] && [[self fileURL] isFileURL])
        filepath = [[[self fileURL] path] stlString];
    else
        filepath = "";

    t_OTF_RESULT otf_result = ma->replace_code( code, code_name, argv, filepath,
                                                docid, shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        [[text_view textView] animateReplace];
        [text_view setShowsErrorLine:NO];
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
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove Shred"];
        [toolbar_item setAction:@selector(remove:)];
        [toolbar_item setImage:[NSImage imageNamed:@"remove.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"replace"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Replace Shred"];
        [toolbar_item setAction:@selector(replace:)];
        [toolbar_item setImage:[NSImage imageNamed:@"replace.png"]];
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
            [argument_text removeFromSuperview];
            
            NSRect frame_rect = [text_view frame];
            frame_rect.size.height += __MA_ARGUMENTS_TEXT_HEIGHT__;
            //frame_rect.origin.y += __MA_ARGUMENTS_TEXT_HEIGHT__;
            [text_view setFrame:frame_rect];
        }
    
        else
        {
            //printf( "showing arguments\n" );
            NSRect frame_rect = [text_view frame];
            frame_rect.size.height -= __MA_ARGUMENTS_TEXT_HEIGHT__;
            //frame_rect.origin.y -= __MA_ARGUMENTS_TEXT_HEIGHT__;
            [text_view setFrame:frame_rect];
            
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
            
            NSRect frame_rect = [text_view frame];
            frame_rect.origin.y -= [status_text frame].size.height;
            frame_rect.size.height += [status_text frame].size.height;
            [text_view setFrame:frame_rect];
        }
        
        else
        {
            NSRect frame_rect = [text_view frame];
            frame_rect.origin.y += [status_text frame].size.height;
            frame_rect.size.height -= [status_text frame].size.height;
            [text_view setFrame:frame_rect];
            
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
            [arguments addObject:[NSString stringWithUTF8String:iter->c_str()]];
    }
}

- (void)controlTextDidBeginEditing:(NSNotification *)n
{
    reject_argument_edits = NO;
}

@end
