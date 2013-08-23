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
// file: miniAudicleDocument.mm
// desc: Document class, creates a new window for each new document and manages
//       document-level connections to miniAudicle
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
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
#import "UKFSEventsWatcher.h"
#import "mAExportAsViewController.h"

#import <objc/message.h>


@interface miniAudicleDocument ()

@property (nonatomic, strong) mADocumentExporter * exporter;

@end


@implementation miniAudicleDocument

@synthesize data;
@synthesize viewController = _viewController;
@synthesize windowController = _windowController;
@synthesize readOnly;

@synthesize exporter;

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
        
//        fsEventsWatcher = [UKFSEventsWatcher new];
//        fsEventsWatcher.delegate = self;
        
        self.readOnly = NO;
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
    
//    [fsEventsWatcher release];
    
    [super dealloc];
}

- (void)makeWindowControllers
{
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    mAMultiDocWindowController *_wc = [mac windowControllerForNewDocument];
    [_wc addDocument:self];
    [[_wc window] makeKeyAndOrderFront:self];
//    self.windowController = [mac topWindowController];
}

//- (NSArray *)windowControllers
//{
//    if(_windowController != nil)
//        return @[_windowController];
//    else
//        return @[];
//}
//
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

- (void)saveDocument:(id)sender
{
    if(self.readOnly)
    {
        NSAlert * alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"The document '%@' is read-only.",
                                                         [self displayName]]
                                          defaultButton:@"Save As..."
                                        alternateButton:@"Cancel"
                                            otherButton:nil
                              informativeTextWithFormat:@"Click Save As to save the document to a different file. Click Cancel to cancel the save operation."];
        
        [alert beginSheetModalForWindow:[_windowController window]
                          modalDelegate:self
                         didEndSelector:@selector(documentIsReadOnlyAlertEnded:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    else
    {
        [super saveDocument:sender];
    }
}

- (void)documentIsReadOnlyAlertEnded:(NSAlert *)alert
                          returnCode:(NSInteger)returnCode
                         contextInfo:(void *)contextInfo
{
    if(returnCode == NSAlertDefaultReturn)
    {
        [[alert window] close];
        
        [self saveDocumentAs:self];
    }
    else if(returnCode == NSAlertAlternateReturn)
    {
    }
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
    BOOL r = [super prepareSavePanel:savePanel];
    
    if(self.readOnly)
        savePanel.directory = NSHomeDirectory();
    
    return r;
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

- (void)setFileURL:(NSURL *)url
{
    [super setFileURL:url];
    
//    [fsEventsWatcher removeAllPaths];
//    [fsEventsWatcher addPath:[url path]];
}

- (BOOL)isEmpty
{
    return [self.viewController isEmpty] && ![self isDocumentEdited] && [self fileURL] == nil;
}

/* override to set edited/unedited state in window/view controllers */
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

///* override to avoid spurious "save changes?" panel when closing the window */
//- (void)shouldCloseWindowController:(NSWindowController *)windowController
//                           delegate:(id)delegate
//                shouldCloseSelector:(SEL)shouldCloseSelector
//                        contextInfo:(void *)contextInfo
//{
//    objc_msgSend(delegate, shouldCloseSelector, self, YES, contextInfo);
//}

- (NSWindow * )windowForSheet
{
    return _windowController.window;
}


- (void)setMiniAudicle:(miniAudicle *)t_ma
{
    ma = t_ma;
    docid = ma->allocate_document_id();
}


#pragma mark Exporting

- (IBAction)exportAsWAV:(id)sender
{
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"wav"]];
    [savePanel setTitle:@"Export as WAV"];
    [savePanel setNameFieldLabel:@"Export to:"];
    [savePanel setPrompt:@"Export"];
    
    NSString * filename;
    NSString * directory;
    
    if([self fileURL] != nil)
    {
        filename = [[[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
        directory = [[[self fileURL] path] stringByDeletingLastPathComponent];
    }
    else
    {
        filename = [[self displayName] stringByAppendingPathExtension:@"wav"];
        directory = [[NSDocumentController sharedDocumentController] currentDirectory];
    }
    
    if([savePanel respondsToSelector:@selector(setNameFieldStringValue:)])
        [savePanel setNameFieldStringValue:filename];
    [savePanel setDirectory:directory];
    
    [savePanel setExtensionHidden:NO];
    
    mAExportAsViewController * viewController = [[mAExportAsViewController alloc] initWithNibName:@"mAExportAs" bundle:nil];
    [savePanel setAccessoryView:viewController.view];

    [savePanel beginSheetForDirectory:directory
                                 file:filename
                       modalForWindow:[self.windowController window]
                        modalDelegate:self
                       didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
                          contextInfo:viewController];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet
             returnCode:(int)returnCode
            contextInfo:(void *)contextInfo;
{
    [sheet orderOut:self];
    
    mAExportAsViewController * viewController = (mAExportAsViewController *) contextInfo;
    NSSavePanel * savePanel = (NSSavePanel *) sheet;
    
    if(returnCode == NSOKButton)
    {
        [viewController saveSettings];
        
        self.exporter = [[mADocumentExporter alloc] initWithDocument:self
                                                     destinationPath:[[savePanel URL] path]];
        
        self.exporter.limitDuration = viewController.limitDuration;
        self.exporter.duration = viewController.duration;
        self.exporter.exportWAV = viewController.exportWAV;
        self.exporter.exportOgg = viewController.exportOgg;
        self.exporter.exportM4A = viewController.exportM4A;
        self.exporter.exportMP3 = viewController.exportMP3;
        
        [self.exporter startExportWithDelegate:self];
    }
    
    [viewController release];
}


#pragma mark UKFileWatcherDelegate

- (void)watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)nm forPath:(NSString*)fpath
{
//    if([nm isEqualToString:UKFileWatcherWriteNotification])
//    {
//        if([self isDocumentEdited])
//        {
//            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"The document \"%@\" has been changed by another application.",
//                                                            [self displayName]]
//                                             defaultButton:@"Save Anyway"
//                                           alternateButton:@"Revert"
//                                               otherButton:@""
//                                 informativeTextWithFormat:@"Click Save Anyway to overwrite these changes and save your changes. Click Revert to discard your changes and keep the changes from the other appliction."];
//            [alert beginSheetModalForWindow:[_windowController window]
//                              modalDelegate:self
//                             didEndSelector:@selector(documentChangedByAnotherApplictionAlertDidEnd:returnCode:contextInfo:)
//                                contextInfo:nil];
//        }
//        else
//        {
//            NSError *error;
//            if(![self revertToContentsOfURL:[self fileURL] ofType:[self fileType] error:&error])
//                [[NSAlert alertWithError:error] beginSheetModalForWindow:[_windowController window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
//        }
//    }
}

- (void)documentChangedByAnotherApplictionAlertDidEnd:(NSAlert *)alert
                                           returnCode:(NSInteger)returnCode
                                          contextInfo:(void *)contextInfo
{
    if(returnCode == NSAlertDefaultReturn)
    {
        NSError *error;
        if(![self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSSaveOperation error:&error])
            [[NSAlert alertWithError:error] beginSheetModalForWindow:[_windowController window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
    else if(returnCode == NSAlertAlternateReturn)
    {
        NSError *error;
        if(![self revertToContentsOfURL:[self fileURL] ofType:[self fileType] error:&error])
            [[NSAlert alertWithError:error] beginSheetModalForWindow:[_windowController window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
}



@end
