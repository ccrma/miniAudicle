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


@class mAMasterViewController;
@class mAVMMonitorController;
@class mAConsoleMonitorController;


@interface mADetailItem : NSObject

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;

+ (mADetailItem *)detailItemFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end

@interface mADetailViewController : UIViewController 
< UISplitViewControllerDelegate, 
mATitleEditorControllerDelegate,
UIPopoverControllerDelegate >
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

- (void)saveScript;

- (IBAction)newScript:(id)sender;

- (IBAction)addShred;
- (IBAction)replaceShred;
- (IBAction)removeShred;

- (IBAction)editTitle:(id)sender;
- (IBAction)showVMMonitor:(id)sender;
- (IBAction)showConsoleMonitor:(id)sender;

@end
