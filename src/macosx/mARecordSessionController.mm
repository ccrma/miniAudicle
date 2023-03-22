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

//
//  mARecordSessionController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/29/13.
//
//

#import "mARecordSessionController.h"
#import "miniAudicleController.h"
#import "miniAudicle.h"
#import "NSString+STLString.h"
#import "miniAudicle_import.h"

using namespace std;

NSString * const mARecordSessionFilenameKey = @"mARecordSessionFilenameKey";
NSString * const mARecordSessionSaveToKey = @"mARecordSessionSaveToKey";

@interface mARecordSessionController ()

- (t_CKUINT)add:(NSString *)filename args:(NSArray *)args;
- (void)updateVU:(NSTimer *)timer;
- (void)updateStatus;
- (void)vmDidTurnOn:(NSNotification *)n;
- (void)vmDidTurnOff:(NSNotification *)n;
- (void)showError:(NSString *)description;

@end

@implementation mARecordSessionController

@synthesize controller = _controller;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    if(self = [super initWithWindowNibName:windowNibName])
    {
        fileNameAuto = YES;
        [fileName setStringValue:@"Auto"];
        [saveLocation setStringValue:@"~/Desktop"];
        
        docid = 0;
        vu_shred_id = 0;
        record_shred_id = 0;
        timer = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [timer invalidate];
    
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self window] setDelegate:self];
    
    if(vu_shred_id == 0)
        vu_shred_id = [self add:@"recordvu.ck" args:nil];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                             target:self
                                           selector:@selector(updateVU:)
                                           userInfo:nil
                                            repeats:YES];
    
    [self updateStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vmDidTurnOn:)
                                                 name:mAVirtualMachineDidTurnOnNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vmDidTurnOff:)
                                                 name:mAVirtualMachineDidTurnOnNotification
                                               object:nil];
}

- (IBAction)editFileName:(id)sender
{
    if(fileNameAuto)
        [fileNameEntry setStringValue:@""];
    else
    {
        [fileNameEntry setStringValue:[[fileName stringValue] stringByDeletingPathExtension]];
    }

    [NSApp beginSheet:fileNameSheet
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
    
    [fileNameEntry becomeFirstResponder];
}

- (IBAction)fileNameSheetOK:(id)sender
{
    if([[fileNameEntry stringValue] length] > 0)
    {
        NSString * value = [fileNameEntry stringValue];
        if([[[value pathExtension] lowercaseString] isEqualToString:@"wav"])
            [fileName setStringValue:value];
        else
            [fileName setStringValue:[NSString stringWithFormat:@"%@.wav", value]];
        fileNameAuto = NO;
    }
    
    [NSApp endSheet:fileNameSheet];
}

- (IBAction)fileNameSheetCancel:(id)sender
{
    [NSApp endSheet:fileNameSheet];
}

- (IBAction)fileNameSheetAuto:(id)sender
{
    fileNameAuto = YES;
    [fileName setStringValue:@"Auto"];

    [NSApp endSheet:fileNameSheet];
}


- (IBAction)changeSaveLocation:(id)sender
{
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanCreateDirectories:YES];
    
    [openPanel beginSheetForDirectory:[[saveLocation stringValue] stringByExpandingTildeInPath]
                                 file:nil
                                types:nil
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if(returnCode == NSOKButton)
    {
        NSURL * url = [[panel URLs] objectAtIndex:0];
        [saveLocation setStringValue:[[url path] stringByAbbreviatingWithTildeInPath]];
    }
}

- (IBAction)record:(id)sender
{
    NSString * _sl = [[saveLocation stringValue] stringByExpandingTildeInPath];
    
    BOOL isDirectory = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:_sl isDirectory:&isDirectory] ||
       !isDirectory)
    {
        [self showError:@"The selected directory does not exist, or is not a directory. Please choose a different directory to save the recording. "];
        return;
    }
    
    if(record_shred_id == 0)
    {
        NSString * _fn;
        if(fileNameAuto)
            _fn = @"special:auto";
        else
            _fn = [fileName stringValue];
        record_shred_id = [self add:@"record.ck" args:@[_sl, _fn]];
    }
    
    [self updateStatus];
}

- (IBAction)stop:(id)sender
{
    miniAudicle * ma = [self.controller miniAudicle];
    if(ma->is_on())
    {
        string result_str;
        ma->remove_code(docid, record_shred_id, result_str);
        record_shred_id = 0;
    }
    
    [self updateStatus];
}

- (void)vmDidTurnOn:(NSNotification *)n
{
    vu_shred_id = [self add:@"recordvu.ck" args:nil];
    
    [self updateStatus];
}

- (void)vmDidTurnOff:(NSNotification *)n
{
    marecordsession_leftVU = 0;
    marecordsession_rightVU = 0;
    
    vu_shred_id = 0;
    record_shred_id = 0;
    
    [self updateStatus];
}

- (t_CKUINT)add:(NSString *)filename args:(NSArray *)arguments
{
    miniAudicle * ma = [self.controller miniAudicle];
    
    if(ma->is_on())
    {
        if(docid == 0)
        {
            docid = ma->allocate_document_id();
        }
        
        string result;
        t_CKUINT shred_id;
        string code_name = [filename stlString];
        
        NSStringEncoding enc;
        NSString * code_str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""]
                                                    usedEncoding:&enc
                                                           error:NULL];
        string code = [code_str stlString];
        
        vector< string > argv;
        if(arguments != nil)
        {
            NSEnumerator * args_enum = [arguments objectEnumerator];
            NSString * arg = nil;
            while(arg = [args_enum nextObject])
                argv.push_back([arg stlString]);
        }
        
        string filepath = [[[NSBundle mainBundle] pathForResource:filename ofType:@""] stlString];
        
        t_OTF_RESULT otf_result = ma->run_code(code, code_name, argv, filepath,
                                               docid, shred_id, result);
        
        if( otf_result == OTF_SUCCESS )
        {
            return shred_id;
        }
        else if( otf_result == OTF_VM_TIMEOUT )
        {
            [self.controller setLockdown:YES];
            
            return 0;
        }
        else if( otf_result == OTF_COMPILE_ERROR )
        {
            int error_line;
            string error_text;
            if( ma->get_last_result( docid, NULL, &error_text, &error_line ) )
            {
                [self showError:[NSString stringWithFormat:@"The virtual machine reported a compile error: %s", error_text.c_str()]];
            }
            else
            {
                [self showError:@"The virtual machine reported a compile error."];
            }
            
            return 0;
        }
        else
        {
            [self showError:@"The virtual machine reported an unknown error."];

            return 0;
        }
    }
    
    return 0;
}

- (void)updateVU:(NSTimer *)timer
{
    [leftChannel setFloatValue:[leftChannel minValue] + marecordsession_leftVU*[leftChannel maxValue]];
    [rightChannel setFloatValue:[rightChannel minValue] + marecordsession_rightVU*[rightChannel maxValue]];
}

- (void)updateStatus
{
    miniAudicle * ma = [self.controller miniAudicle];
    
    if(!ma->is_on())
    {
        [status setStringValue:@"Virtual Machine Off"];
        
        [recordButton setEnabled:NO];
        [stopButton setEnabled:NO];
    }
    else if(record_shred_id != 0)
    {
        [status setStringValue:@"Recording"];
        
        [recordButton setEnabled:NO];
        [stopButton setEnabled:YES];
    }
    else
    {
        [status setStringValue:@"Not Recording"];
        
        [recordButton setEnabled:YES];
        [stopButton setEnabled:NO];
    }
}


- (void)showError:(NSString *)description
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"An error occurred."];
    [alert setInformativeText:description];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

@end


