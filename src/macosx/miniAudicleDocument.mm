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
@synthesize viewController = _viewController;
@synthesize windowController = _windowController;

- (id)init
{
    if( self = [super init] )
    {
        ma = nil;
        
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
}

- (void)dealloc
{
    [data release];
    data = nil;
    
    if( ma != nil )
    {
        ma->free_document_id( docid );
        docid = 0;
        ma = nil;
    }
    
    _viewController.document = nil;
    [_viewController release];
    _viewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];

    [self userDefaultsDidChange:nil];
}

-(void)makeWindowControllers
{
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    mAMultiDocWindowController *_wc = [mac windowControllerForNewDocument];
    [_wc addDocument:self];
    [[_wc window] makeKeyAndOrderFront:self];
//    self.windowController = [mac topWindowController];
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
    [ctrl setMiniAudicle:ma];
    _viewController = ctrl;
    
    return ctrl;
}

- (NSData *)dataRepresentationOfType:(NSString *)type
{
    return [[_viewController content] dataUsingEncoding:NSASCIIStringEncoding
                                   allowLossyConversion:YES];
}

- (BOOL)loadDataRepresentation:(NSData *)_data ofType:(NSString *)type
{
    data = [[NSString alloc] initWithData:_data encoding:NSASCIIStringEncoding];
    [_viewController setContent:data];
    
    return YES;
}

- (BOOL)isEmpty
{
    return [self.viewController isEmpty] && ![self isDocumentEdited] && [self fileURL] == nil;
}

- (void)updateChangeCount:(NSDocumentChangeType)changeType
{
    [super updateChangeCount:changeType];
    
    if(changeType == NSChangeCleared)
    {
        _viewController.isEdited = NO;
        [_windowController document:self wasEdited:NO];
        [_windowController updateTitles];
    }
    else
    {
        _viewController.isEdited = YES;
        [_windowController document:self wasEdited:YES];
    }
}

- (void)userDefaultsDidChange:(NSNotification *)n
{
    if( !has_customized_appearance )
    {
//        [self setShowsArguments:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowArguments]];
//        [self setShowsLineNumbers:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesDisplayLineNumbers]];
//        [self setShowsToolbar:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowToolbar]];
//        [self setShowsStatusBar:[[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowStatusBar]];
        has_customized_appearance = NO;
    }
}

- (void)setMiniAudicle:(miniAudicle *)t_ma
{
    ma = t_ma;
    docid = ma->allocate_document_id();
}

//- (void)setLockEditing:(BOOL)lock
//{
//    [[text_view textView] setEditable:!lock];
//}
//
//- (BOOL)lockEditing
//{
//    return ![[text_view textView] isEditable];
//}
//
//- (void)commentOut:(id)sender
//{
//    
//}
//
//- (void)saveBackup:(id)sender
//{
//    //NSString * backup_name = [[NSUserDefaults standardUserDefaults] stringForKey:];
//}
//
//#define __MA_ARGUMENTS_TEXT_HEIGHT__ 24
//- (void)setShowsArguments:(BOOL)_shows_arguments
//{
//    if( _shows_arguments != shows_arguments )
//    {
//        if( !_shows_arguments )
//        {
//            //printf( "hiding arguments\n" );
//            [argument_text removeFromSuperview];
//            
//            NSRect frame_rect = [text_view frame];
//            frame_rect.size.height += __MA_ARGUMENTS_TEXT_HEIGHT__;
//            //frame_rect.origin.y += __MA_ARGUMENTS_TEXT_HEIGHT__;
//            [text_view setFrame:frame_rect];
//        }
//    
//        else
//        {
//            //printf( "showing arguments\n" );
//            NSRect frame_rect = [text_view frame];
//            frame_rect.size.height -= __MA_ARGUMENTS_TEXT_HEIGHT__;
//            //frame_rect.origin.y -= __MA_ARGUMENTS_TEXT_HEIGHT__;
//            [text_view setFrame:frame_rect];
//            
//            [[window contentView] addSubview:argument_text];
//            
//            // redisplay the arguments bar area
//            [[window contentView] setNeedsDisplayInRect:NSMakeRect( 0, frame_rect.size.height, 
//                                                                    frame_rect.size.width,
//                                                                    frame_rect.size.height - __MA_ARGUMENTS_TEXT_HEIGHT__ )];
//        }
//        
//        shows_arguments = _shows_arguments;
//    }
//}
//
//- (BOOL)showsArguments
//{
//    return shows_arguments;
//}
//
//
//
//- (void)setShowsToolbar:(BOOL)_shows_toolbar
//{
//    if( shows_toolbar != _shows_toolbar )
//    {
//        [toolbar setVisible:_shows_toolbar];
//        shows_toolbar = _shows_toolbar;
//    }
//    
//    //has_customized_appearance = YES;
//}
//
//- (BOOL)showsToolbar
//{
//    return shows_toolbar;
//}
//
//- (void)setShowsLineNumbers:(BOOL)_shows_line_numbers
//{
//    if( shows_line_numbers != _shows_line_numbers )
//    {
//        [text_view enableLineNumbers:_shows_line_numbers];
//        shows_line_numbers = _shows_line_numbers;
//    }
//    
//    //has_customized_appearance = YES;
//}
//
//- (BOOL)showsLineNumbers
//{
//    return shows_line_numbers;
//}
//
//
//- (void)setShowsStatusBar:(BOOL)_shows_status_bar
//{
//    if( shows_status_bar != _shows_status_bar )
//    {
//        if( !_shows_status_bar )
//        {
//            [status_text removeFromSuperview];
//            
//            NSRect frame_rect = [text_view frame];
//            frame_rect.origin.y -= [status_text frame].size.height;
//            frame_rect.size.height += [status_text frame].size.height;
//            [text_view setFrame:frame_rect];
//        }
//        
//        else
//        {
//            NSRect frame_rect = [text_view frame];
//            frame_rect.origin.y += [status_text frame].size.height;
//            frame_rect.size.height -= [status_text frame].size.height;
//            [text_view setFrame:frame_rect];
//            
//            [[window contentView] addSubview:status_text];
//            
//            // redisplay the arguments bar area
//            [[window contentView] setNeedsDisplayInRect:NSMakeRect( 0, 0, 
//                                                                    frame_rect.size.width,
//                                                                    frame_rect.size.height - [status_text frame].size.height )];
//        }
//        
//        shows_status_bar = _shows_status_bar;
//    }
//    
//    //has_customized_appearance = YES;
//}
//
//- (BOOL)showsStatusBar
//{
//    return shows_status_bar;
//}

@end
