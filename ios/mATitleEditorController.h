//
//  mATitleEditViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class mATitleEditorController;


@protocol mATitleEditorControllerDelegate <NSObject>

- (void)titleEditorDidConfirm:(mATitleEditorController *)titleEditor;
- (void)titleEditorDidCancel:(mATitleEditorController *)titleEditor;

@end


@interface mATitleEditorController : UIViewController
{
    IBOutlet UITextField * _textField;
}

@property (assign, nonatomic) id<mATitleEditorControllerDelegate> delegate;

- (NSString *)editedTitle;
- (void)setEditedTitle:(NSString *)t;

- (IBAction)confirm:(id)sender;
- (IBAction)cancel:(id)sender;

@end
