/*----------------------------------------------------------------------------
 miniAudicle iOS
 iOS GUI to chuck audio programming environment
 
 Copyright (c) 2005-2012 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

#import "mAVMMonitorController.h"

#import "mAChucKController.h"
#import "mAVMMonitorCellController.h"

#import "miniAudicle.h"
#import "chuck_def.h"


NSString * const mAVMMonitorControllerStatusUpdateNotification = @"mAVMMonitorControllerStatusUpdateNotification";


@interface mAVMMonitorController ()
{
    IBOutlet UITableView * _tableView;
    
    Chuck_VM_Status * most_recent_status;
    Chuck_VM_Status * status_buffers;
    int which_status_buffer;
    
    BOOL isUpdating;
    
    t_CKUINT docid;
    
    NSInteger _nShreds;
}

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSTimer * updateTimer;


- (void)startUpdating;
- (void)stopUpdating;
- (void)update:(id)data;

- (void)removeShred:(id)sender;

@end


@implementation mAVMMonitorController


@synthesize tableView = _tableView;
@synthesize updateTimer = _updateTimer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        isUpdating = NO;
        docid = [mAChucKController chuckController].ma->allocate_document_id();
        status_buffers = new Chuck_VM_Status[2];
        most_recent_status = NULL;
        _nShreds = 0;

        [self startUpdating];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        isUpdating = NO;
        docid = [mAChucKController chuckController].ma->allocate_document_id();
        status_buffers = new Chuck_VM_Status[2];
        most_recent_status = NULL;
        _nShreds = 0;
        
        [self startUpdating];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)startUpdating
{
    if(!isUpdating)
    {
        most_recent_status = status_buffers;
        which_status_buffer = 0;
        
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.075
//        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                            target:self
                                                          selector:@selector(update:)
                                                          userInfo:self
                                                           repeats:YES];
        
        isUpdating = YES;
        
        [self update:self];
    }
}


- (void)stopUpdating
{
    if(isUpdating)
    {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        
        isUpdating = NO;
        
        SAFE_DELETE_ARRAY(status_buffers);
        status_buffers = NULL;

        most_recent_status = NULL;
        
        [self.tableView reloadData];
    }
}


- (void)update:(id)data
{
    if(!isUpdating)
        return;
    
    // select which buffer to write the VM status to
    most_recent_status = status_buffers + which_status_buffer;
    which_status_buffer = ( which_status_buffer + 1 ) % 2;
    
    // get status
    [mAChucKController chuckController].ma->status( most_recent_status );
    
//    if( status_buffers[0].now_system - status_buffers[1].now_system < 0.5 )
//    {
//        vm_stall_count++;
//        
//        if( vm_stall_count >= vm_max_stalls && ![controller isInLockdown] )
//            [controller setLockdown:YES];
//    }
//    
//    else if( vm_stall_count )
//    {
//        vm_stall_count = 0;
//        if( [controller isInLockdown] )
//            [controller setLockdown:NO];
//    }
    
    if(self.tableView)
    {
        // reload the whole table if the two VM status structures are significantly
        // different
        if( compare_shred_vectors( status_buffers[0].list, status_buffers[1].list ) )
        {
            [self.tableView reloadData];
        }
        
        // otherwise, just update the shred time column
        //    else
        {
            for(mAVMMonitorCell * cell in [self.tableView visibleCells])
            {
                [cell updateShredStatus:most_recent_status];
            }
        }
    }
    
    if(most_recent_status->list.size() != _nShreds)
    {
        _nShreds = most_recent_status->list.size();
        [self.delegate vmMonitor:self isShowingNumberOfShreds:_nShreds];
    }
    
//    time_t current_time = ( time_t ) ( most_recent_status->now_system / most_recent_status->srate );
//    [running_time_text setStringValue:[NSString stringWithFormat:@"%u:%.2u.%.5u", 
//                                       current_time / 60, current_time % 60, ( t_CKUINT ) fmod( most_recent_status->now_system, most_recent_status->srate ) ]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mAVMMonitorControllerStatusUpdateNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSValue valueWithPointer:most_recent_status], @"status",
                                                                nil]];
//    if(most_recent_status->list.size())
//        most_recent_status->list[0] = NULL;
}


- (void)removeShred:(id)sender
{
    t_CKUINT shred_id = [sender tag];
    std::string output;
    
    [mAChucKController chuckController].ma->remove_shred(docid, 
                                                         shred_id, 
                                                         output);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self startUpdating];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [self stopUpdating];
}


#pragma mark UITableViewDataSource interface

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    if(most_recent_status != NULL)
        return most_recent_status->list.size();
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mAVMMonitorController_Cell";
    
    mAVMMonitorCell * cell = (mAVMMonitorCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [mAVMMonitorCell cell];
    }
    
    if(most_recent_status != nil)
    {
        NSInteger index = indexPath.row;
        
        Chuck_VM_Shred_Status * shred = most_recent_status->list[index];
        
        cell.idLabel.text = [NSString stringWithFormat:@"%lu", shred->xid];
        
        cell.titleLabel.text = [NSString stringWithUTF8String:shred->name.c_str()];
        
        time_t shred_running_time = rint( ( most_recent_status->now_system -  shred->start ) / most_recent_status->srate );
        
        if( shred_running_time < 0 )
            shred_running_time = 0;
        
        cell.timeLabel.text = [NSString stringWithFormat:@"%ld:%02ld", shred_running_time / 60, shred_running_time % 60];
        
        [cell.removeButton addTarget:self
                              action:@selector(removeShred:)
                    forControlEvents:UIControlEventTouchUpInside];
        cell.removeButton.tag = shred->xid;
        
        cell.shred_start_time = shred->start;
    }
    
    return cell;
}


#pragma mark UITableViewDelegate interface

- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    t_CKUINT shred_id = most_recent_status->list[[indexPath row]]->xid;
    std::string output;

    [mAChucKController chuckController].ma->remove_shred(docid, 
                                                         shred_id, 
                                                         output);
}

@end


