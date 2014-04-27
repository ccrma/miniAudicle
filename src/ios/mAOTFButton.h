//
//  mAOTFButton.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/26/14.
//
//

#import <UIKit/UIKit.h>

@interface mAOTFButton : UIControl

@property (strong, nonatomic) UIImage *image;
@property (nonatomic) UIEdgeInsets insets;

@property (copy, nonatomic) NSArray *alternatives;
@property (copy, nonatomic) NSString *text;

@end
