//
//  mAKeyboardAccessoryViewViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@protocol mAKeyboardAccessoryDelegate

- (void)keyPressed:(NSString *)chars;

@end

@interface mAKeyboardAccessoryViewController : UIViewController

@property (weak, nonatomic) id<mAKeyboardAccessoryDelegate> delegate;

- (IBAction)keyPressed:(id)sender;

@end
