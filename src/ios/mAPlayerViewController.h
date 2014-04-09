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
@class mAScriptPlayer;

@interface mAPlayerViewController : UIViewController < mADetailClient, UIPopoverControllerDelegate >

@property (strong, nonatomic) UIBarButtonItem *titleButton;
@property (strong, nonatomic) IBOutlet mAEditorViewController *editor;

- (void)addScript:(mADetailItem *)script;
- (void)showEditorForScriptPlayer:(mAScriptPlayer *)player;

@end
