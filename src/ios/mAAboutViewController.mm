//
//  mAAboutViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 5/16/16.
//
//

#import "mAAboutViewController.h"

extern const char MA_VERSION[];

@interface mAAboutViewController ()
{
    IBOutlet UILabel *_versionLabel;
}

@end

@implementation mAAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _versionLabel.text = [NSString stringWithFormat:@"version %s", MA_VERSION];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

@end
