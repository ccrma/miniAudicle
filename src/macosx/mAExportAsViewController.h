//
//  mAExportAsViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 6/11/13.
//
//

#import <Cocoa/Cocoa.h>

@interface mAExportAsViewController : NSViewController
{
    BOOL limitDuration;
    CGFloat duration;
}

@property (nonatomic) BOOL limitDuration;
@property (nonatomic) CGFloat duration;

@end
