//
//  mAVMMonitorController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 12/22/11.
//  Copyright (c) 2011 Spencer Salazar. All rights reserved.
//

#import "mAVMMonitorController.h"

#import "mAChucKController.h"
#import "miniAudicle.h"

@interface mAVMMonitorController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSTimer * updateTimer;


- (void)startUpdating;
- (void)stopUpdating;
- (void)update:(id)data;

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
        // Custom initialization
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
    NSLog(@"startUpdating");
    if(!isUpdating)
    {
        status_buffers = new Chuck_VM_Status[2];
        most_recent_status = status_buffers;
        which_status_buffer = 0;
        
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.075
                                                            target:self
                                                          selector:@selector(update:)
                                                          userInfo:self
                                                           repeats:YES];
        
        isUpdating = YES;
    }
}


- (void)stopUpdating
{
    NSLog(@"stopUpdating");
    if(isUpdating)
    {
        SAFE_DELETE_ARRAY(status_buffers);
        most_recent_status = nil;
        status_buffers = nil;
        
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        
        isUpdating = NO;
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
    
    // reload the whole table if the two VM status structures are significantly
    // different
    if( compare_shred_vectors( status_buffers[0].list, status_buffers[1].list ) )
    {
        [self.tableView reloadData];
//        [shreds_text setStringValue:[NSString stringWithFormat:@"%u", 
//                                     most_recent_status->list.size()]];
    }
    
    // otherwise, just update the shred time column
    else
    {
        
        [self.tableView reloadData];
//        [shred_table setNeedsDisplayInRect:[shred_table rectOfColumn:[shred_table columnWithIdentifier:time_column_id]]];
    }
    
//    time_t current_time = ( time_t ) ( most_recent_status->now_system / most_recent_status->srate );
//    [running_time_text setStringValue:[NSString stringWithFormat:@"%u:%.2u.%.5u", 
//                                       current_time / 60, current_time % 60, ( t_CKUINT ) fmod( most_recent_status->now_system, most_recent_status->srate ) ]];
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
    [self startUpdating];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopUpdating];
}


#pragma mark UITableViewDataSource interface

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    if(most_recent_status != nil)
        return most_recent_status->list.size();
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mAVMMonitorController_Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:CellIdentifier];
    }
    
    if(most_recent_status != nil)
    {
        int index = indexPath.row;
        cell.detailTextLabel.text = [NSString stringWithUTF8String:most_recent_status->list[index]->name.c_str()];
        
        time_t shred_running_time = rint( ( most_recent_status->now_system -  most_recent_status->list[index]->start ) / most_recent_status->srate );
        
        if( shred_running_time < 0 )
            shred_running_time = 0;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%u:%02u", shred_running_time / 60, shred_running_time % 60];
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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


