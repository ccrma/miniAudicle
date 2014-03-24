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

#import "chuck_def.h"
#import "mATitleEditorController.h"
#import "mAKeyboardAccessoryViewController.h"
#import "mAConsoleMonitorController.h"
#import "mASyntaxHighlighter.h"

@class mAMasterViewController;
@class mAVMMonitorController;

@interface mADetailItem : NSObject

@property (nonatomic) BOOL isUser;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;
@property (nonatomic) BOOL isFolder;
@property (strong, nonatomic) NSMutableArray *folderItems;
@property (strong, nonatomic) NSString *path;

+ (mADetailItem *)detailItemFromDictionary:(NSDictionary *)dictionary;
+ (mADetailItem *)folderDetailItemWithTitle:(NSString *)title
                                      items:(NSMutableArray *)items
                                     isUser:(BOOL)user;
- (NSDictionary *)dictionary;

@end

@interface mADetailViewController : UIViewController 
< UISplitViewControllerDelegate, 
  mATitleEditorControllerDelegate,
  UIPopoverControllerDelegate,
  mAKeyboardAccessoryDelegate,
  mAConsoleMonitorDelegate >
{
    IBOutlet UITextView * _textView;
    IBOutlet UIBarButtonItem * _titleButton;
    IBOutlet UIToolbar * _toolbar;
//    IBOutlet UINavigationItem * _titleButton;
    
    IBOutlet mATitleEditorController * _titleEditor;
    
    IBOutlet mAVMMonitorController * _vmMonitor;
    IBOutlet mAConsoleMonitorController * _consoleMonitor;
}

@property (assign, nonatomic) mAMasterViewController * masterViewController;
@property (strong, nonatomic) mADetailItem * detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet mAKeyboardAccessoryViewController *keyboardAccessory;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *consoleMonitorButton;

- (void)saveScript;

- (IBAction)newScript:(id)sender;

- (IBAction)addShred;
- (IBAction)replaceShred;
- (IBAction)removeShred;

- (IBAction)editTitle:(id)sender;
- (IBAction)showVMMonitor:(id)sender;
- (IBAction)showConsoleMonitor:(id)sender;

@end
