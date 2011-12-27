//
//  mAVMMonitorCellController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "miniAudicle.h"


@interface mAVMMonitorCell : UITableViewCell
{
    t_CKFLOAT shred_start_time;
    time_t last_time;
    
    IBOutlet UILabel * idLabel;
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * timeLabel;
    IBOutlet UIButton * removeButton;
}

@property (nonatomic) t_CKFLOAT shred_start_time;

@property (strong, nonatomic) UILabel * idLabel, * titleLabel, * timeLabel;
@property (strong, nonatomic) UIButton * removeButton;

+ (mAVMMonitorCell *)cell;

- (void)updateShredStatus:(Chuck_VM_Status *)most_recent_status;

@end

