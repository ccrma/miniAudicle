//
//  UIBarButtonItem+Spacers.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/31/16.
//
//

#import "UIBarButtonItem+Spacers.h"

@implementation UIBarButtonItem (Spacers)

+ (instancetype)flexibleSpace
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:nil action:nil];
}

+ (instancetype)fixedSpaceOfWidth:(CGFloat)width
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                          target:nil action:nil];
    item.width = width;
    return item;
}

@end
