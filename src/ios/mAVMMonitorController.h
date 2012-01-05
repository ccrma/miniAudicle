//
//  mAVMMonitorController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "chuck_def.h"

class Chuck_VM_Status;

@interface mAVMMonitorController : UIViewController 
< UITableViewDataSource,
 UITableViewDelegate >
{
    IBOutlet UITableView * _tableView;
    
    Chuck_VM_Status * most_recent_status;
    Chuck_VM_Status * status_buffers;
    int which_status_buffer;
    
    BOOL isUpdating;
    
    t_CKUINT docid;
}

@end
