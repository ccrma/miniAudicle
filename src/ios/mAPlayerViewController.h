//
//  mAPlayerViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "mADetailViewController.h"

@class mAEditorViewController;
@class mAConnectViewController;
@class mAScriptPlayer;
@class mAScriptPlayerTab;

@interface mAPlayerViewController : UIViewController < mADetailClient, UIPopoverControllerDelegate >
{
    IBOutlet UIView *_fieldView;
}

@property (strong, nonatomic) UIBarButtonItem *titleButton;
@property (strong, nonatomic) IBOutlet mAEditorViewController *editor;
@property (strong, nonatomic) IBOutlet mAConnectViewController *connectViewController;

- (void)addScript:(mADetailItem *)script;
- (void)showEditorForScriptPlayer:(mAScriptPlayer *)player;
- (void)playerTabMoved:(mAScriptPlayerTab *)playerTab;

- (IBAction)connect:(id)sender;

- (mAScriptPlayer *)scriptPlayerForRemoteUUID:(NSString *)uuid;

@end

