//
//  mASocialShareViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/27/16.
//
//

#import "mASocialShareViewController.h"
#import "mADetailItem.h"
#import "mALoadingViewController.h"

#import "UIAlert.h"

#import "Patch.h"
#import "ChuckPadSocial.h"

@interface mASocialShareViewController ()
{
    mALoadingViewController *_loadingView;
}

- (IBAction)upload:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)_dismiss;
- (void)_showLoading:(BOOL)show;
- (void)_showLoading:(BOOL)show status:(NSString *)status;

@end

@implementation mASocialShareViewController

- (id)init
{
    if(self = [super initWithNibName:@"mASocialShareViewController" bundle:nil])
    {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    return self;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(375, 400);
}


- (void)_showLoading:(BOOL)show
{
    if(show)
    {
        if(_loadingView == nil)
        {
            _loadingView = [mALoadingViewController new];
            [self.view addSubview:_loadingView.view];
            [_loadingView fit];
        }
        
        [_loadingView show];
    }
    else
    {
        [_loadingView hide:^{
            _loadingView = nil;
        }];
    }
}

- (void)_showLoading:(BOOL)show status:(NSString *)status
{
    [self _showLoading:show];
    _loadingView.status = status;
}

- (void)_dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - IBActions

- (IBAction)upload:(id)sender
{
    NSAssert(self.script.type == DETAILITEM_CHUCK_SCRIPT, @"upload on item that is not a script");
    
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    
    NSString *name = self.script.title;
    NSString *filename = [self.script.path  lastPathComponent];
    NSData *fileData = [self.script.text dataUsingEncoding:NSUTF8StringEncoding];
    
    [self _showLoading:YES status:@"Uploading patch"];
    
    [chuckPad uploadPatch:name filename:filename fileData:fileData
                 callback:^(BOOL succeeded, Patch *patch, NSError *error) {
                     if(succeeded)
                     {
                         UIAlertMessage(@"Upload succeeded", ^{});
                         [self _dismiss];
                     }
                     else
                     {
                         NSString *msg;
                         if(error)
                             msg = error.localizedDescription;
                         UIAlertMessage1a(@"Failed to upload patch", error.localizedDescription, ^{});
                     }
                     
                     [self _showLoading:NO];
                 }];
}

- (IBAction)cancel:(id)sender
{
    [self _dismiss];
}

@end
