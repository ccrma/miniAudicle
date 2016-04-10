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
// file: miniAudicleDocument.h
// desc: Document class, creates a new window for each new document and manages
//       document-level connections to miniAudicle
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "chuck_def.h"
#import "mADocumentExporter.h"

class miniAudicle;
@class NumberedTextView;
@class mADocumentViewController;
@class mAMultiDocWindowController;
@class UKFSEventsWatcher;

@interface miniAudicleDocument : NSDocument <NSToolbarDelegate, mADocumentExporterDelegate>
{
    mADocumentViewController * _viewController;
    mAMultiDocWindowController * _windowController;
    
    NSString * data;
    
    miniAudicle * ma;
    t_CKUINT docid;
    BOOL vm_on;
    
    BOOL shows_arguments;
    BOOL shows_toolbar;
    BOOL shows_line_numbers;
    BOOL shows_status_bar;
    
    BOOL has_customized_appearance;
    
    UKFSEventsWatcher *fsEventsWatcher;
    
    mADocumentExporter *exporter;
    
    BOOL readOnly;
}

@property (readonly, strong, nonatomic) NSString * data;
@property (readonly, strong, nonatomic) mADocumentViewController * viewController;
@property (weak, nonatomic) mAMultiDocWindowController * windowController;
@property (nonatomic) BOOL readOnly;

- (id)init;

- (NSViewController *)newPrimaryViewController;

- (NSData *)dataRepresentationOfType:(NSString *)type;
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type;
- (BOOL)isEmpty;

- (void)setMiniAudicle:(miniAudicle *)t_ma;

- (IBAction)exportAsWAV:(id)sender;

@end
