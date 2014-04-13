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
class Chuck_VM_Status;

@interface mAScriptPlayer : UIViewController
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet mAScriptPlayerTab *_playerTabView;
}

@property (strong, nonatomic) mADetailItem *detailItem;
@property (weak, nonatomic) mAPlayerViewController *playerViewController;

- (IBAction)addShred:(id)sender;
- (IBAction)replaceShred:(id)sender;
- (IBAction)removeShred:(id)sender;
- (IBAction)edit:(id)sender;

- (void)updateWithStatus:(Chuck_VM_Status *)status;

- (UIView *)viewForEditorPopover;

@end
