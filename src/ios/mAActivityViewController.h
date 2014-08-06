//
//  mAActivityViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/5/14.
//
//

#import <UIKit/UIKit.h>

@interface mAActivityViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) void (^cancelHandler)();

@end
