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

@interface mARecordSessionController ()

- (t_CKUINT)add:(NSString *)filename args:(NSArray *)args;
- (void)updateVU:(NSTimer *)timer;
- (void)updateStatus;
- (void)vmDidTurnOn:(NSNotification *)n;
- (void)vmDidTurnOff:(NSNotification *)n;

@end

@implementation mARecordSessionController

@synthesize controller = _controller;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    if(self = [super initWithWindowNibName:windowNibName])
    {
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
    
}

- (IBAction)changeSaveLocation:(id)sender
{
    
}

- (IBAction)record:(id)sender
{
    if(record_shred_id == 0)
    {
        record_shred_id = [self add:@"record.ck" args:@[[@"~/Desktop" stringByExpandingTildeInPath], @"special:auto"]];
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
            if( ma->get_last_result( docid, NULL, NULL, &error_line ) )
            {
            }
            
            return 0;
        }
        else
        {
            return 0;
        }
    }
    
    return 0;
}

- (void)updateVU:(NSTimer *)timer
{
    [leftChannel setFloatValue:marecordsession_leftVU*[leftChannel maxValue]];
    [rightChannel setFloatValue:marecordsession_rightVU*[rightChannel maxValue]];
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


@end


