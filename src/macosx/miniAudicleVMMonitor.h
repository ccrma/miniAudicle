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
// file: miniAudicleVMMonitor.h
// desc: controller class for floating Virtual Machine monitor panel
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#ifndef __MINIAUDICLEVMMONITOR_H__
#define __MINIAUDICLEVMMONITOR_H__

#import <Cocoa/Cocoa.h>
#import <vector>
#import "chuck_def.h"

class Chuck_VM_Status;

using namespace std;

struct mAShredOptimizationMetadata
{
    mAShredOptimizationMetadata()
    {
        minute_string = 0;
        last_string = 0;
        last_time = -1;
    }
    
    NSString * minute_string;
    NSString * last_string;
    time_t last_time;
};

@interface miniAudicleVMMonitor : NSObject 
{
    // miniAudicleController
    id controller;
    
    // GUI information
    NSWindow * panel;
    NSTextField * running_time_text;
    NSTableView * shred_table;
    NSTextField * shreds_text;
    NSButton * removeall_button;
    NSButton * removelast_button;
    NSButton * vm_toggle_button;
    NSMenu * header_menu;

    NSTimer * timer;

    NSTableColumn * shred_column;
    unsigned shred_column_number;
    NSTableColumn * name_column;
    unsigned name_column_number;
    NSTableColumn * time_column;
    unsigned time_column_number;
    NSTableColumn * remove_column;
    unsigned remove_column_number;
    
    // VM status information
    Chuck_VM_Status * most_recent_status;
    Chuck_VM_Status * status_buffers;
    int which_status_buffer;
    BOOL vm_on;
    vector< mAShredOptimizationMetadata > * omd;
    
    t_CKUINT docid;
    t_CKUINT vm_stall_count;
    t_CKUINT vm_max_stalls;
    t_CKFLOAT refresh_rate;
}

- (id)init;
- (void)update:(id)data;
- (void)activateMonitor:(id)sender;
- (void)toggleVM:(id)sender;
- (void)vm_starting;
- (void)vm_on;
- (void)vm_off;
- (void)removeShred:(id)sender;
- (void)removeShredTableColumn:(id)sender;

// table data source functions
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;


@end

#endif
