//
//  mAPlayerViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "mADetailViewController.h"
#import "mAConnectViewController.h"

@class mAEditorViewController;
@class mAConnectViewController;
@class mAActivityViewController;
@class mAScriptPlayer;
@class mAScriptPlayerTab;
@class mANetworkRoomMember;

@interface mAPlayerViewController : UIViewController < mADetailClient, UIPopoverControllerDelegate, mAConnectViewControllerDelegate >
{
    IBOutlet UIView *_fieldView;
}

@property (strong, nonatomic) UIBarButtonItem *titleButton;
@property (strong, nonatomic) IBOutlet mAEditorViewController *editor;
@property (strong, nonatomic) IBOutlet mAConnectViewController *connectViewController;
@property (strong, nonatomic) IBOutlet mAActivityViewController *activityViewController;

- (void)addScript:(mADetailItem *)script;
- (void)removeScriptPlayer:(mAScriptPlayer *)player;
- (void)removeAllScriptPlayers;
- (void)showEditorForScriptPlayer:(mAScriptPlayer *)player;
- (void)playerTabMoved:(mAScriptPlayerTab *)playerTab;

- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;

// stuff for network actions
- (mAScriptPlayer *)scriptPlayerForRemoteUUID:(NSString *)uuid;
- (void)memberJoined:(mANetworkRoomMember *)member;
- (void)memberLeft:(mANetworkRoomMember *)member;

@end

