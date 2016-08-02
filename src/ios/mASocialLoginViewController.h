//
//  mASocialLoginViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import <UIKit/UIKit.h>

@interface mASocialLoginViewController : UIViewController

@property (strong, nonatomic) void (^onCompletion)();

- (void)clearFields;

@end
