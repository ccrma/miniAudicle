//
//  mALoopCountPicker.h
//  miniAudicle
//
//  Created by Spencer Salazar on 5/5/14.
//
//

#import <UIKit/UIKit.h>

@interface mALoopCountPicker : UIViewController
< UITableViewDataSource,
  UITableViewDelegate,
  UIPopoverControllerDelegate >

@property (strong, nonatomic) void (^pickedLoopCount)(NSInteger count);
@property (strong, nonatomic) void (^cancelled)();

@end
