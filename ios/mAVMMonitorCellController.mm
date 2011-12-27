//
//  mAVMMonitorCellController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "mAVMMonitorCellController.h"


@implementation mAVMMonitorCell

@synthesize shred_start_time;
@synthesize idLabel, titleLabel, timeLabel, removeButton;

+ (mAVMMonitorCell *)cell
{
    NSArray * objects = [[NSBundle mainBundle] loadNibNamed:@"mAVMMonitorCell" 
                                                      owner:nil 
                                                    options:[NSDictionary dictionary]];
    
    return [objects objectAtIndex:0];
}

- (void)updateShredStatus:(Chuck_VM_Status *)most_recent_status
{
    time_t shred_running_time = rint( ( most_recent_status->now_system - shred_start_time ) / most_recent_status->srate );
    
    if( shred_running_time < 0 )
        shred_running_time = 0;
    
    if(shred_running_time != last_time)
    {
        timeLabel.text = [NSString stringWithFormat:@"%u:%02u", shred_running_time / 60, shred_running_time % 60];
        last_time = shred_running_time;
    }
}

@end
