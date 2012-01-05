//
//  mAConsoleMonitor.m
//  miniAudicle
//
//  Created by Spencer Salazar on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mAConsoleMonitorController.h"
#import "chuck_errmsg.h"


@interface mAConsoleMonitorController ()

@property (strong, nonatomic) UITextView * textView;

- (void)setupIO;
- (void)readData:(NSData *)data;

@end


@implementation mAConsoleMonitorController

@synthesize textView = _textView;

- (id)initWithCoder:(NSCoder *)c
{
    if(self = [super initWithCoder:c])
    {
        [self setupIO];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self setupIO];
    }
    
    return self;
}

- (void)setupIO
{
    int fd[2];
    //#ifndef __CK_DEBUG__
    if( pipe( fd ) )
    {
        //unable to create the pipe!
        return;
    }
    
    dup2( fd[1], STDOUT_FILENO );
    
    std_out = [[NSFileHandle alloc] initWithFileDescriptor:fd[0]];
    [std_out waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:std_out];
    
    if(setlinebuf(stdout))
    {
        EM_log(CK_LOG_SYSTEM, "(miniAudicle): unable to set chout buffering to line-based");
    }
    
    //#endif
    if( pipe( fd ) )
    {
        //unable to create the pipe!
        return;
    }
    
    dup2( fd[1], STDERR_FILENO );
    
    std_err = [[NSFileHandle alloc] initWithFileDescriptor:fd[0]];
    [std_err waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:std_err];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textView.text = @"";
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


- (void)readData:(NSNotification *)n
{
    NSString * d = [[NSString alloc] initWithData:[[n object] availableData]
                                                encoding:NSUTF8StringEncoding];
        
    [[n object] waitForDataInBackgroundAndNotify];
    
    self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, d];
}


- (CGSize)contentSizeForViewInPopover
{
    CGSize s = [super contentSizeForViewInPopover];
    s.width = 600;
    return s;
}

@end
