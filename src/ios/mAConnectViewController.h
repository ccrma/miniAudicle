//
//  mAConnectViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/4/14.
//
//

#import <UIKit/UIKit.h>

@class mAConnectViewController;
@class mANetworkRoom;

@protocol mAConnectViewControllerDelegate <NSObject>

- (void)connectViewController:(mAConnectViewController *)cvc selectedRoom:(mANetworkRoom *)room username:(NSString *)username;
- (void)connectViewControllerDidCancel:(mAConnectViewController *)cvc;

@end

@interface mAConnectViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate >

@property (weak, nonatomic) IBOutlet id<mAConnectViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)createNew:(id)sender;

@end
