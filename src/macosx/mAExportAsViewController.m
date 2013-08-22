//
//  mAExportAsViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/11/13.
//
//

#import "mAExportAsViewController.h"

NSString * const mAExportAsLimitDuration = @"mAExportAsLimitDuration";
NSString * const mAExportAsDuration = @"mAExportAsDuration";
NSString * const mAExportAsExportWAV = @"mAExportAsExportWAV";
NSString * const mAExportAsExportOgg = @"mAExportAsExportOgg";
NSString * const mAExportAsExportM4A = @"mAExportAsExportM4A";
NSString * const mAExportAsExportMP3 = @"mAExportAsExportMP3";

static BOOL g_lameAvailable = NO;

@interface mAExportAsViewController ()

@end

@implementation mAExportAsViewController

@synthesize limitDuration, duration;

+ (void)initialize
{
    g_lameAvailable = (system("which -s lame") == 0);
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                    mAExportAsLimitDuration: @NO,
                                         mAExportAsDuration: @30.0,
                                        mAExportAsExportWAV: @YES,
                                        mAExportAsExportOgg: @NO,
                                        mAExportAsExportM4A: @NO,
                                        mAExportAsExportMP3: @NO,
     }];
}

- (CGFloat)duration
{
    duration = [_durationTextField doubleValue];
    return duration;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.limitDuration = [defaults boolForKey:mAExportAsLimitDuration];
    self.duration = [defaults floatForKey:mAExportAsDuration];
    
    self.exportWAV = [defaults boolForKey:mAExportAsExportWAV];
    self.exportOgg = [defaults boolForKey:mAExportAsExportOgg];
    self.exportM4A = [defaults boolForKey:mAExportAsExportM4A];
    self.exportMP3 = [defaults boolForKey:mAExportAsExportMP3];
    
    self.enableMP3 = g_lameAvailable;
}

- (void)saveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.limitDuration forKey:mAExportAsLimitDuration];
    [defaults setFloat:self.duration forKey:mAExportAsDuration];
    [defaults setBool:self.exportWAV forKey:mAExportAsExportWAV];
    [defaults setBool:self.exportOgg forKey:mAExportAsExportOgg];
    [defaults setBool:self.exportM4A forKey:mAExportAsExportM4A];
    [defaults setBool:self.exportMP3 forKey:mAExportAsExportMP3];
}

@end
