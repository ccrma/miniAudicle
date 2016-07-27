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
#import "mAInteractionModeController.h"

@class mAPlayerContainerView;
@class mAEditorViewController;
@class mAConnectViewController;
@class mAActivityViewController;
@class mAScriptPlayer;
@class mAScriptPlayerTab;
@class mANetworkRoomMember;

@interface mAPlayerViewController : UIViewController
< mADetailClient,
  UIPopoverControllerDelegate,
  mAConnectViewControllerDelegate,
  mAInteractionModeController >
{
    IBOutlet UIView *_fieldView;
}

@property (strong, nonatomic) UIBarButtonItem *titleButton;
@property (strong, nonatomic) IBOutlet mAEditorViewController *editor;
@property (strong, nonatomic) IBOutlet mAConnectViewController *connectViewController;
@property (strong, nonatomic) IBOutlet mAActivityViewController *activityViewController;
@property (strong, nonatomic) IBOutlet mAPlayerContainerView *playerContainerView;

- (void)addScript:(mADetailItem *)script;
- (void)deleteScriptPlayer:(mAScriptPlayer *)player;
- (void)deleteAllScriptPlayers;
- (void)showEditorForScriptPlayer:(mAScriptPlayer *)player;
- (void)playerTabMoved:(mAScriptPlayerTab *)playerTab;

- (void)enterSequenceMode:(mAScriptPlayer *)source;
- (void)exitSequenceMode;
- (NSArray *)allPlayers;

- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;

// stuff for network actions
- (mAScriptPlayer *)scriptPlayerForRemoteUUID:(NSString *)uuid;
- (void)memberJoined:(mANetworkRoomMember *)member;
- (void)memberLeft:(mANetworkRoomMember *)member;

@end

