//
//  mARecordSessionController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/29/13.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface mARecordSessionController : NSWindowController
{
    IBOutlet NSLevelIndicator * rightChannel;
    IBOutlet NSLevelIndicator * leftChannel;
    IBOutlet NSTextField * fileName;
    IBOutlet NSTextField * saveLocation;
}

- (IBAction)editFileName:(id)sender;
- (IBAction)changeSaveLocation:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)stop:(id)sender;

@end
