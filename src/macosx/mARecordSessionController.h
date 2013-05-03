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

@interface mARecordSessionController : NSWindowController<NSWindowDelegate>
{
    IBOutlet NSLevelIndicator * rightChannel;
    IBOutlet NSLevelIndicator * leftChannel;
    IBOutlet NSTextField * fileName;
    IBOutlet NSTextField * saveLocation;
    IBOutlet NSTextField * status;
    
    IBOutlet NSButton * recordButton;
    IBOutlet NSButton * stopButton;
    
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

@end
