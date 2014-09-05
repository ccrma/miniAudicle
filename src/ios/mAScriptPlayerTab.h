//
//  mAScriptPlayerTab.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

@class mAPlayerViewController;
@class mAScriptPlayer;

@interface mAScriptPlayerTab : UIView

@property (weak, nonatomic) mAPlayerViewController *playerViewController;
@property (weak, nonatomic) mAScriptPlayer *scriptPlayer;

@end
