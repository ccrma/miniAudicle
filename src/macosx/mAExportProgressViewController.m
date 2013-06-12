//
//  mAExportProgressViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/12/13.
//
//

#import "mAExportProgressViewController.h"

@interface mAExportProgressViewController ()

@end

@implementation mAExportProgressViewController

@synthesize delegate;

- (id)initWithWindowNibName:(NSString *)nibNameOrNil
{
    self = [super initWithWindowNibName:nibNameOrNil];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    [progressIndicator startAnimation:self];
}

- (IBAction)cancel:(id)sender
{
    [delegate exportProgressDidCancel];
}

@end
