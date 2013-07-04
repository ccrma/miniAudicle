//
//  mAExportProgressViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 6/12/13.
//
//

#import <Cocoa/Cocoa.h>

@protocol mAExportProgressDelegate

- (void)exportProgressDidCancel;

@end

@interface mAExportProgressViewController : NSWindowController
{
    IBOutlet NSProgressIndicator * progressIndicator;
    
    id<mAExportProgressDelegate> delegate;
}

@property (nonatomic, assign) id<mAExportProgressDelegate> delegate;

- (IBAction)cancel:(id)sender;

@end
