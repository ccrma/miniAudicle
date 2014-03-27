//
//  mAScriptPlayer.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

@class mADetailItem;

@interface mAScriptPlayer : UIViewController
{
    IBOutlet UILabel *titleLabel;
}

@property (strong, nonatomic) mADetailItem *detailItem;

@end
