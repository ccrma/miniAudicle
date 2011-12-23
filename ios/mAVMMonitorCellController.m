//
//  mAVMMonitorCellController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "mAVMMonitorCellController.h"


@implementation mAVMMonitorCell

@synthesize controller;

@end


@implementation mAVMMonitorCellController

@synthesize idLabel, titleLabel, timeLabel, removeButton;

+ (mAVMMonitorCell *)cell
{
    mAVMMonitorCellController * filesOwner = [mAVMMonitorCellController new];
    
    NSArray * objects = [[NSBundle mainBundle] loadNibNamed:@"mAVMMonitorCell" 
                                                      owner:filesOwner 
                                                    options:[NSDictionary dictionary]];
    
    return [objects objectAtIndex:0];
}

- (IBAction)remove:(id)sender
{
    
}

@end
