//
//  UIBarButtonItem+Spacers.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/31/16.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Spacers)

+ (instancetype)flexibleSpace;
+ (instancetype)fixedSpaceOfWidth:(CGFloat)width;

@end
