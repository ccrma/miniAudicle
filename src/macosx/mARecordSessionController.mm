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

- (void)add:(NSString *)filename;
- (void)updateVU:(NSTimer *)timer;

@end

@implementation mARecordSessionController

@synthesize controller = _controller;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    if(self = [super initWithWindowNibName:windowNibName])
    {
        docid = 0;
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
    
    [self add:@"recordvu.ck"];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                             target:self
                                           selector:@selector(updateVU:)
                                           userInfo:nil
                                            repeats:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(windowDidClose:)
//                                                 name:NSWindowWillCloseNotification
//                                               object:[self window]];
}

- (IBAction)editFileName:(id)sender
{
    
}

- (IBAction)changeSaveLocation:(id)sender
{
    
}

- (IBAction)record:(id)sender
{
    
}

- (IBAction)stop:(id)sender
{
    
}

- (void)add:(NSString *)filename
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
        
        string filepath = [[[NSBundle mainBundle] pathForResource:filename ofType:@""] stlString];
        
        t_OTF_RESULT otf_result = ma->run_code(code, code_name, argv, filepath,
                                               docid, shred_id, result );
        
        if( otf_result == OTF_SUCCESS )
        {
        }
        else if( otf_result == OTF_VM_TIMEOUT )
        {
            [self.controller setLockdown:YES];
        }
        else if( otf_result == OTF_COMPILE_ERROR )
        {
            int error_line;
            if( ma->get_last_result( docid, NULL, NULL, &error_line ) )
            {
            }
        }    
        else
        {
        }
    }
}

- (void)updateVU:(NSTimer *)timer
{
    [leftChannel setFloatValue:marecordsession_leftVU*[leftChannel maxValue]];
    [rightChannel setFloatValue:marecordsession_rightVU*[rightChannel maxValue]];
}

@end
