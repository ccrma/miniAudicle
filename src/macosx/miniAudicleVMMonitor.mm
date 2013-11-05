/*----------------------------------------------------------------------------
miniAudicle
Cocoa GUI to chuck audio programming environment

Copyright (c) 2005-2013 Spencer Salazar.  All rights reserved.
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

//-----------------------------------------------------------------------------
// file: miniAudicleVMMonitor.mm
// desc: controller class for floating Virtual Machine monitor panel
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import "miniAudicleVMMonitor.h"
#import "miniAudicleController.h"
#import "miniAudiclePreferencesController.h"
#import "miniAudicle.h"
#import "chuck_vm.h"

static NSString * const shred_column_id = @"1";
static NSString * const name_column_id = @"2";
static NSString * const time_column_id = @"3";
static NSString * const remove_column_id = @"4";


@implementation miniAudicleVMMonitor

- (id)init
{
    if( self = [super init] )
    {
        //status_buffers = new Chuck_VM_Status[2];
        omd = new vector< mAShredOptimizationMetadata >( 30 );
        most_recent_status = status_buffers;
        which_status_buffer = 0;
        [running_time_text setStringValue:@""];
        [shreds_text setStringValue:@""];
        refresh_rate = 0.075;
        vm_max_stalls = 1.0 / refresh_rate;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [[shred_table headerView] setMenu:header_menu];
    shred_column = [[shred_table tableColumnWithIdentifier:@"shred"] retain];
    name_column = [[shred_table tableColumnWithIdentifier:@"name"] retain];
    time_column = [[shred_table tableColumnWithIdentifier:@"time"] retain];
    remove_column = [[shred_table tableColumnWithIdentifier:@"remove"] retain];
    
    NSCell * dataCell = [name_column dataCell];
    [dataCell setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [name_column setDataCell:dataCell];
    
    [shred_column setIdentifier:shred_column_id];
    [name_column setIdentifier:name_column_id];
    [time_column setIdentifier:time_column_id];
    [remove_column setIdentifier:remove_column_id];
    
    [removeall_button setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    [removeall_button setBezelStyle:NSShadowlessSquareBezelStyle];
    [removeall_button setEnabled:NO];

    [removelast_button setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    [removelast_button setBezelStyle:NSShadowlessSquareBezelStyle];
    [removelast_button setEnabled:NO];
    
    docid = [controller miniAudicle]->allocate_document_id();
}

- (void)dealloc
{
    [controller miniAudicle]->free_document_id( docid );
    
    //delete[] status_buffers;
    
    delete omd;
    
    [super dealloc];
}

- (void)activateMonitor:(id)sender
{
    if( [panel isKeyWindow] )
        [panel close];
    
    else
        [panel makeKeyAndOrderFront:sender];
}

- (void)update:(id)data
{
    // select which buffer to write the VM status to
    most_recent_status = status_buffers + which_status_buffer;
    which_status_buffer = ( which_status_buffer + 1 ) % 2;
    
    // get status
    [controller miniAudicle]->status( most_recent_status );
    
    if( status_buffers[0].now_system - status_buffers[1].now_system < 0.5 )
    {
        vm_stall_count++;
        
        if( vm_stall_count >= vm_max_stalls && ![controller isInLockdown] )
            [controller setLockdown:YES];
    }
    
    else if( vm_stall_count )
    {
        vm_stall_count = 0;
        if( [controller isInLockdown] )
            [controller setLockdown:NO];
    }
    
    // reload the whole table if the two VM status structures are significantly
    // different
    if( compare_shred_vectors( status_buffers[0].list, status_buffers[1].list ) )
    {
        [shred_table reloadData];
        [shreds_text setStringValue:[NSString stringWithFormat:@"%lu",
            most_recent_status->list.size()]];
    }
    
    // otherwise, just update the shred time column
    else
    {
        [shred_table setNeedsDisplayInRect:[shred_table rectOfColumn:[shred_table columnWithIdentifier:time_column_id]]];
    }
    
    time_t current_time = ( time_t ) ( most_recent_status->now_system / most_recent_status->srate );
    [running_time_text setStringValue:[NSString stringWithFormat:@"%lu:%.2lu.%.5lu", 
        current_time / 60, current_time % 60, ( t_CKUINT ) fmod( most_recent_status->now_system, most_recent_status->srate ) ]];
}

- (void)toggleVM:(id)sender
{
    [controller toggleVM:sender];
}

- (void)vm_starting
{
    [vm_toggle_button setTitle:@"Starting Virtual Machine"];
    [vm_toggle_button setEnabled:NO];
    [removeall_button setEnabled:NO];
    [removelast_button setEnabled:NO];
}

- (void)vm_on
// TODO: account for vm_on failure
{
    status_buffers = new Chuck_VM_Status[2];
    most_recent_status = status_buffers;
    which_status_buffer = 0;
    vm_max_stalls = [[NSUserDefaults standardUserDefaults] floatForKey:mAPreferencesVMStallTimeout] / refresh_rate;
    vm_stall_count = 0;
    
    [vm_toggle_button setTitle:@"Stop Virtual Machine"];
    [vm_toggle_button setEnabled:YES];
    [removeall_button setEnabled:YES];
    [removelast_button setEnabled:YES];
    
    vm_on = YES;

    timer = [NSTimer timerWithTimeInterval:refresh_rate
                                    target:self 
                                  selector:@selector(update:)
                                  userInfo:nil
                                   repeats:YES];
    [timer retain];
    NSRunLoop * run_loop = [NSRunLoop currentRunLoop];
    [run_loop addTimer:timer forMode:NSDefaultRunLoopMode]; 
    [run_loop addTimer:timer forMode:NSConnectionReplyMode];    
    [run_loop addTimer:timer forMode:NSModalPanelRunLoopMode];  
    [run_loop addTimer:timer forMode:NSEventTrackingRunLoopMode];   
    [controller miniAudicle]->status( most_recent_status );
    
    [shreds_text setStringValue:@"0"];
}

- (void)vm_off
{
    delete[] status_buffers;
    most_recent_status = nil;
    status_buffers = nil;
    
    [timer invalidate];
    [timer release];
    [vm_toggle_button setTitle:@"Start Virtual Machine"];
    [vm_toggle_button setEnabled:YES];
    [removeall_button setEnabled:NO];
    [removelast_button setEnabled:NO];
    vm_on = NO;
    [shred_table reloadData];
    [running_time_text setStringValue:@""];
    [shreds_text setStringValue:@""];
}

// table data source functions
- (int)numberOfRowsInTableView:(NSTableView *)table_view
{
    if( vm_on )
    {
        int s = most_recent_status->list.size();
        if( s >= omd->size() )
            omd->resize( s * 2 );
        
        return s;
    }
    
    else
        return 0;
}

- (id)tableView:(NSTableView *)table_view 
objectValueForTableColumn:(NSTableColumn *)table_column
            row:(int)rowIndex
{
    if( most_recent_status == nil || rowIndex < 0 || rowIndex >= most_recent_status->list.size())
        return @"";
    
    if( [table_column identifier] == shred_column_id )
        return [NSNumber numberWithInt:most_recent_status->list[rowIndex]->xid];
    
    else if( [table_column identifier] == name_column_id )
        return [NSString stringWithUTF8String:most_recent_status->list[rowIndex]->name.c_str()];
    
    else if( [table_column identifier] == time_column_id )
    {
        time_t shred_running_time = rint( ( most_recent_status->now_system -  most_recent_status->list[rowIndex]->start ) / most_recent_status->srate );
        
        if( shred_running_time < 0 )
            shred_running_time = 0;
        
        if( rowIndex < omd->size() && shred_running_time != (*omd)[rowIndex].last_time )
        {
            [(*omd)[rowIndex].last_string autorelease];
            (*omd)[rowIndex].last_string = [[NSString stringWithFormat:@"%lu:%02lu", shred_running_time / 60, shred_running_time % 60] retain];
            (*omd)[rowIndex].last_time = shred_running_time;
        }
        
        return (*omd)[rowIndex].last_string;
    }
    
    else if( [table_column identifier] == remove_column_id )//*/
        return @"-";
    
    return @"";
}

- (void)removeShred:(id)sender
{
    string result;
    [controller miniAudicle]->remove_shred( docid,
                                            most_recent_status->list[[sender clickedRow]]->xid, 
                                            result );
}

- (void)removeShredTableColumn:(id)sender
{
    if( [sender tag] == 0 )
    {
        if( [sender state] == NSOnState )
        {
            shred_column_number = [shred_table columnWithIdentifier:@"shred"];
            [shred_table removeTableColumn:[shred_table tableColumnWithIdentifier:@"shred"]];
            [sender setState:NSOffState];
        }
        
        else
        {
            [shred_table addTableColumn:shred_column];
            [shred_table moveColumn:[shred_table columnWithIdentifier:@"shred"] toColumn:shred_column_number];
            [sender setState:NSOnState];
        }
    }
    
    else if( [sender tag] == 1 )
    {
        if( [sender state] == NSOnState )
        {
            name_column_number = [shred_table columnWithIdentifier:@"name"];
            [shred_table removeTableColumn:[shred_table tableColumnWithIdentifier:@"name"]];
            [sender setState:NSOffState];
        }
        
        else
        {
            [shred_table addTableColumn:name_column];
            [shred_table moveColumn:[shred_table columnWithIdentifier:@"name"] toColumn:name_column_number];
            [sender setState:NSOnState];
        }
    }

    else if( [sender tag] == 2 )
    {
        if( [sender state] == NSOnState )
        {
            time_column_number = [shred_table columnWithIdentifier:@"time"];
            [shred_table removeTableColumn:[shred_table tableColumnWithIdentifier:@"time"]];
            [sender setState:NSOffState];
        }
        
        else
        {
            [shred_table addTableColumn:time_column];
            [shred_table moveColumn:[shred_table columnWithIdentifier:@"time"] toColumn:time_column_number];
            [sender setState:NSOnState];
        }
    }

    else if( [sender tag] == 3 )
    {
        if( [sender state] == NSOnState )
        {
            remove_column_number = [shred_table columnWithIdentifier:@"remove"];
            [shred_table removeTableColumn:[shred_table tableColumnWithIdentifier:@"remove"]];
            [sender setState:NSOffState];
        }
        
        else
        {
            [shred_table addTableColumn:remove_column];
            [shred_table moveColumn:[shred_table columnWithIdentifier:@"remove"] toColumn:remove_column_number];
            [sender setState:NSOnState];
        }
    }
}

@end
