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

//
//  mARecordSessionController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/29/13.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include "chuck_def.h"

@class miniAudicleController;

@interface mARecordSessionController : NSWindowController<NSWindowDelegate, NSOpenSavePanelDelegate>
{
    IBOutlet NSLevelIndicator * rightChannel;
    IBOutlet NSLevelIndicator * leftChannel;
    IBOutlet NSTextField * saveLocation;
    IBOutlet NSTextField * status;
    
    IBOutlet NSButton * recordButton;
    IBOutlet NSButton * stopButton;
    
    IBOutlet NSTextField * fileName;
    IBOutlet NSWindow * fileNameSheet;
    IBOutlet NSTextField * fileNameEntry;
    BOOL fileNameAuto;
    
    miniAudicleController * _controller;
    
    t_CKUINT docid;
    t_CKUINT vu_shred_id;
    t_CKUINT record_shred_id;
    NSTimer * timer;
}

@property (assign, nonatomic) miniAudicleController * controller;

- (IBAction)editFileName:(id)sender;
- (IBAction)changeSaveLocation:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)fileNameSheetOK:(id)sender;
- (IBAction)fileNameSheetCancel:(id)sender;
- (IBAction)fileNameSheetAuto:(id)sender;

@end
