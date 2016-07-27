//
//  mALoadingViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import <UIKit/UIKit.h>

@interface mALoadingViewController : UIViewController

@property (strong, nonatomic) NSString *status;
@property (nonatomic) BOOL loading;

- (void)show;
- (void)show:(void (^)())completion;
- (void)hide;
- (void)hide:(void (^)())completion;
- (void)fit;

@end
