//
//  mAVMMonitorCellController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class mAVMMonitorCellController;


@interface mAVMMonitorCell : UITableViewCell

@property (strong, nonatomic) IBOutlet mAVMMonitorCellController * controller;

@end


@interface mAVMMonitorCellController : NSObject
{
    IBOutlet UILabel * idLabel;
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * timeLabel;
    IBOutlet UIButton * removeButton;
}

@property (strong, nonatomic) UILabel * idLabel, * titleLabel, * timeLabel;
@property (strong, nonatomic) UIButton * removeButton;

+ (mAVMMonitorCell *)cell;
- (IBAction)remove:(id)sender;

@end
