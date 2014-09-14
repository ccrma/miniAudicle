//
//  mAScriptPlayer.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "mAPlayerContainerView.h"

@class mADetailItem;
@class mAPlayerViewController;
@class mAScriptPlayerTab;
@class mAOTFButton;
@class mARoundedRectButton;
class Chuck_VM_Status;

@interface mAScriptPlayer : UIViewController<mATapOutsideListener>
{
}

@property (strong, nonatomic) mADetailItem *detailItem;
@property (copy, nonatomic) NSString *codeID;
@property (weak, nonatomic) mAPlayerViewController *playerViewController;

- (IBAction)addShred:(id)sender;
- (void)addShredFromSequenceSource:(id)sender;
- (IBAction)loopShred:(id)sender;
- (IBAction)loopNShred:(id)sender;
- (IBAction)sequenceShred:(id)sender;
- (IBAction)replaceShred:(id)sender;
- (IBAction)removeShred:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)deletePlayer:(id)sender;

- (IBAction)showDeleteButton:(id)sender;
- (void)hideDeleteButton;
- (void)tapOutside;

- (void)enterSequenceMode:(mAScriptPlayer *)source;
- (void)exitSequenceMode;
- (void)playerTabEvent:(UIControlEvents)event;
- (void)sequenceTo:(mAScriptPlayer *)dest;

- (void)cleanupForDeletion;

- (void)makeRemote;

- (void)updateWithStatus:(Chuck_VM_Status *)status;

- (UIView *)viewForEditorPopover;
- (void)playerTabFinishedMoving;

@end
