//
//  mAScriptPlayer.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

@class mADetailItem;
@class mAPlayerViewController;
@class mAScriptPlayerTab;
@class mAOTFButton;
@class mARoundedRectButton;
class Chuck_VM_Status;

@interface mAScriptPlayer : UIViewController
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_usernameLabel;
    IBOutlet mAScriptPlayerTab *_playerTabView;
    
    IBOutlet mAOTFButton *_addButton;
    IBOutlet mAOTFButton *_loopButton;
    IBOutlet mAOTFButton *_loopNButton;
    IBOutlet mAOTFButton *_sequenceButton;
    IBOutlet mARoundedRectButton *_replaceButton;
    IBOutlet mARoundedRectButton *_removeButton;
}

@property (strong, nonatomic) mADetailItem *detailItem;
@property (copy, nonatomic) NSString *codeID;
@property (weak, nonatomic) mAPlayerViewController *playerViewController;

- (IBAction)addShred:(id)sender;
- (IBAction)loopShred:(id)sender;
- (IBAction)loopNShred:(id)sender;
- (IBAction)sequenceShred:(id)sender;
- (IBAction)replaceShred:(id)sender;
- (IBAction)removeShred:(id)sender;
- (IBAction)edit:(id)sender;

- (void)removePlayer:(id)sender;

- (void)makeRemote;

- (void)updateWithStatus:(Chuck_VM_Status *)status;

- (UIView *)viewForEditorPopover;

@end
