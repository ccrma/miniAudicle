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

#import "mAConsoleMonitorController.h"
#import "chuck_errmsg.h"

#ifdef DEBUG
#define DISABLE_CONSOLE_MONITOR
#endif

@interface mAConsoleMonitorController ()
{
    NSMutableString *_text;
}

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
        _text = [NSMutableString new];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self setupIO];
        _text = [NSMutableString new];
    }
    
    return self;
}

- (void)setupIO
{
#ifndef DISABLE_CONSOLE_MONITOR
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
    
    if(setvbuf(stderr, NULL, _IONBF, 0))
    {
        EM_log(CK_LOG_SYSTEM, "(miniAudicle): unable to set cherr to unbuffered mode");
    }
    
    fflush(stdout);
    fflush(stderr);

#endif // DISABLE_CONSOLE_MONITOR
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
    
    self.textView.text = _text;
    
    CGSize s = self.view.frame.size;
    s.width = 600;
    self.preferredContentSize = s;
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
    
    [_text appendString:d];
    self.textView.text = _text;
    [self.textView scrollRangeToVisible:NSMakeRange(_text.length-1, 1)];
    
    [self.delegate consoleMonitorReceivedNewData];
}


@end
