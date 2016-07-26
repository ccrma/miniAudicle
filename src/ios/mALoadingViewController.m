//
//  mALoadingViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mALoadingViewController.h"

@interface mALoadingViewController ()
{
    IBOutlet UILabel *_statusLabel;
    IBOutlet UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation mALoadingViewController

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if(loading)
        [_activityIndicator startAnimating];
    else
        [_activityIndicator stopAnimating];
}

- (void)setStatus:(NSString *)status
{
    _status = status;
    _statusLabel.text = status;
}

- (id)init
{
    // convenience init method calls with default nib
    if(self = [self initWithNibName:@"mALoadingView" bundle:nil]) { }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.alpha = 0.0;
    self.loading = YES;
    self.status = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.alpha = 1.0;
                     }];
}

- (void)hide
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.alpha = 0.0;
                     }];
}

- (void)fit
{
    if(self.view.superview)
        self.view.frame = self.view.superview.bounds;
}

@end
