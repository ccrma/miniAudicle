//
//  mASocialEditorViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mASocialEditorViewController.h"
#import "mASocialDetailItem.h"
#import "mALoadingViewController.h"
#import "mASocialLoginViewController.h"
#import "mASocialShareViewController.h"
#import "mAAnalytics.h"

#import "ChuckPadSocial.h"
#import "Patch.h"

#import "UIAlert.h"

@interface mASocialEditorViewController ()

@property (strong, nonatomic) mALoadingViewController *loadingView;

- (void)showLoading:(BOOL)show;
- (void)_report;

@end

@implementation mASocialEditorViewController

- (mALoadingViewController *)loadingView
{
    if(_loadingView == nil)
    {
        _loadingView = [mALoadingViewController new];
        _loadingView.loadingViewStyle = mALoadingViewStyleTransparent;
        [self.view addSubview:_loadingView.view];
        [_loadingView fit];
    }
    
    return _loadingView;
}

- (void)setDetailItem:(mADetailItem *)detailItem
{
    if([detailItem isKindOfClass:[mASocialDetailItem class]])
    {
        mASocialDetailItem *socialItem = (mASocialDetailItem *) detailItem;
        
        // load the remote data first, if necessary
        if([socialItem isLoaded])
        {
            [super setDetailItem:socialItem];
            [self showLoading:NO];
        }
        else
        {
            // clear detail item in superclass
            [super setDetailItem:nil];
            // set title to new patch
            [self configureTitle:socialItem.patch.name editable:NO];
            
            [self showLoading:YES];
            self.loadingView.status = @"Loading script";
            
            void (^loadResource)() = ^{
                [socialItem load:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(success)
                        {
                            [super setDetailItem:socialItem];
                            
                            [self showLoading:NO];
                        }
                        else
                        {
                            mAAnalyticsLogError(error);
                            self.loadingView.loading = NO;
                            self.loadingView.status = @"Failed to load script";
                        }
                    });
                }];
            };
            
            if(socialItem.patch == nil)
            {
                [socialItem loadPatchInfo:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(success)
                        {
                            loadResource();
                        }
                        else
                        {
                            mAAnalyticsLogError(error);
                            self.loadingView.loading = NO;
                            self.loadingView.status = @"Failed to load script";
                        }
                    });
                }];
            }
            else
            {
                loadResource();
            }
        }
    }
    else
    {
        [super setDetailItem:detailItem];
        
        [self showLoading:NO];
    }
}

- (void)showLoading:(BOOL)show
{
    if(show)
    {
        self.loadingView.loading = YES;
        [self.loadingView show];
    }
    else
    {
        [self.loadingView hide];
        self.loadingView.loading = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray<NSString *> *)menuItems
{
    if(![self.detailItem isSocial])
        return [super menuItems];
    
    mASocialDetailItem *socialItem = (mASocialDetailItem *) self.detailItem;
    
    if([socialItem isMyPatch])
        return @[ @"Rename", @"Duplicate", @"Update..." ];
    else
        return @[ @"Duplicate", @"Report as Abusive..." ];
}

- (void)handleMenuItem:(NSInteger)item
{
    if(![self.detailItem isSocial])
    {
        [super handleMenuItem:item];
        return;
    }
        
    NSLog(@"menuItem: %@", self.menuItems[item]);
    
    mASocialDetailItem *socialItem = (mASocialDetailItem *) self.detailItem;
    
    if([socialItem isMyPatch])
    {
        switch(item)
        {
            case 0: // rename
                break;
            case 1: // duplicate
                break;
            case 2: // update
                break;
        }
    }
    else
    {
        switch(item)
        {
            case 0: // duplicate
                break;
            case 1: // report
                [self _report];
                break;
        }
    }
}

- (void)_report
{
    mASocialDetailItem *socialItem = (mASocialDetailItem *) self.detailItem;
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];

    void (^doReport)() = ^{
        UIAlertMessage2a([NSString stringWithFormat:@"Report '%@' as abusive?", socialItem.title], @"",
                         @"Cancel", nil,
                         @"Report as Abusive", ^{
                             [self showLoading:YES];
                             self.loadingView.status = [NSString stringWithFormat:@"Reporting '%@' as abusive...", socialItem.title];

                             [chuckPad reportAbuse:socialItem.patch isAbuse:YES
                                          callback:^(BOOL succeeded, NSError *error) {
                                              [self showLoading:NO];
                                              
                                              if(succeeded)
                                              {
                                                  UIAlertMessage(@"Thank you for your feedback.", ^{});
                                              }
                                              else
                                              {
                                                  mAAnalyticsLogError(error);
                                                  UIAlertMessage1a(@"Failed to report abuse.", error.localizedDescription, ^{});
                                              }
                                          }];
                         });
    };
    
    if([chuckPad isLoggedIn])
    {
        doReport();
    }
    else
    {
        UIAlertMessage2a(@"You must login or create an account to report a script as abusive.", @"",
                         @"Cancel", nil,
                         @"Create Account/Login", ^{
                             mASocialLoginViewController *loginView = [mASocialLoginViewController new];
                             [loginView clearFields];
                             [self presentViewController:loginView animated:YES completion:nil];
                             
                             loginView.onCompletion = ^{
                                 if([chuckPad isLoggedIn])
                                 {
                                     doReport();
                                 }
                             };
                         });
    }
}


@end
