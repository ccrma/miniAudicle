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
@class mAScriptPlayerTab;

@interface mAPlayerViewController : UIViewController < mADetailClient, UIPopoverControllerDelegate >
{
    IBOutlet UIView *_fieldView;
}

@property (strong, nonatomic) UIBarButtonItem *titleButton;
@property (strong, nonatomic) IBOutlet mAEditorViewController *editor;

- (void)addScript:(mADetailItem *)script;
- (void)showEditorForScriptPlayer:(mAScriptPlayer *)player;
- (void)playerTabMoved:(mAScriptPlayerTab *)playerTab;



@end

