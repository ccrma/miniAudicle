/*----------------------------------------------------------------------------
 miniAudicle iOS
 iOS GUI to chuck audio programming environment
 
 Copyright (c) 2005-2012 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>

#import "mATitleEditorController.h"
#import "mAKeyboardAccessoryViewController.h"
#import "mAConsoleMonitorController.h"
#import "mAVMMonitorController.h"
#import "mASyntaxHighlighter.h"
#import "mAInteractionModeController.h"


@class mADetailItem;
@class mAFileViewController;
@class mAVMMonitorController;
@class mAEditorViewController;
@class mAPlayerViewController;


enum mAInteractionMode
{
    MA_IM_NONE,
    MA_IM_EDIT,
    MA_IM_PLAY,
};


@protocol mADetailClient <NSObject>

- (UIBarButtonItem *)titleButton;

@end


@interface mADetailViewController : UIViewController 
< UISplitViewControllerDelegate, 
  UIPopoverControllerDelegate,
  mAConsoleMonitorDelegate,
  mAVMMonitorDelegate,
  UIActionSheetDelegate>
{
    IBOutlet UIView *_clientView;
    IBOutlet UIToolbar * _toolbar;
    
    IBOutlet mAVMMonitorController * _vmMonitor;
    IBOutlet mAConsoleMonitorController * _consoleMonitor;
}

@property (strong, nonatomic) UIViewController *clientViewController;
//@property (assign, nonatomic) mAFileViewController * fileViewController;
@property (strong, nonatomic) IBOutlet mAEditorViewController * editor;
@property (strong, nonatomic) IBOutlet mAPlayerViewController * player;
@property (nonatomic) mAInteractionMode interactionMode;

- (id<mAInteractionModeController>)currentInteractionModeController;

- (void)showMasterPopover;
- (void)dismissMasterPopover;
- (void)setClientViewController:(UIViewController *)viewController;

- (void)showDetailItem:(mADetailItem *)item;
- (void)editItem:(mADetailItem *)item;

- (IBAction)showVMMonitor:(id)sender;
- (IBAction)showConsoleMonitor:(id)sender;

@end
