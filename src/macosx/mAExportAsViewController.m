//
//  mAExportAsViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/11/13.
//
//

#import "mAExportAsViewController.h"

@interface mAExportAsViewController ()

@end

@implementation mAExportAsViewController

@synthesize limitDuration, duration;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Initialization code here.
        self.limitDuration = NO;
        self.duration = 30.0;
    }
    
    return self;
}

@end
