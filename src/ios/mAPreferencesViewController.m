//
//  mAPreferencesViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/28/16.
//
//

#import "mAPreferencesViewController.h"

#import "mAChucKController.h"
#import "UIAlert.h"

@interface mAPreferencesViewController ()
{
    BOOL _updateVM;
    
    IBOutlet UISwitch *_enableInputSwitch;
    IBOutlet UIButton *_bufferSizeButton;
    IBOutlet UISwitch *_adaptiveBufferingSwitch;
    IBOutlet UISwitch *_backgroundAudioSwitch;
    
    int _bufferSize;
    BOOL _adaptiveBuffering;
    int _sampleRate;
}

@end

@implementation mAPreferencesViewController

- (void)viewWillAppear:(BOOL)animated
{
    _updateVM = NO;
    
    _enableInputSwitch.on = [mAChucKController chuckController].enableInput;
    
    _bufferSize = [mAChucKController chuckController].bufferSize;
    _bufferSizeButton.titleLabel.text = [NSString stringWithFormat:@"%i", _bufferSize];
    
    _adaptiveBuffering = [mAChucKController chuckController].adaptiveBuffering;
    _adaptiveBufferingSwitch.on = _adaptiveBuffering;
    
    _backgroundAudioSwitch.on = [mAChucKController chuckController].backgroundAudio;
}

- (IBAction)audioInputChanged:(id)sender
{
    [mAChucKController chuckController].enableInput = _enableInputSwitch.on;
}

- (IBAction)openBufferSize:(id)sender
{
    
}

- (IBAction)adaptiveBufferingChanged:(id)sender
{
    [mAChucKController chuckController].adaptiveBuffering = _adaptiveBufferingSwitch.on;
    _updateVM = YES;
}

- (IBAction)backgroundAudioChanged:(id)sender
{
    [mAChucKController chuckController].backgroundAudio = _backgroundAudioSwitch.on;
}

- (IBAction)done:(id)sender
{
    if(_updateVM)
    {
        UIAlertMessage2(@"Some of the modified settings require restarting the ChucK Virtual Machine. This will stop any currently running ChucK programs. Restart the Virtual Machine?",
                        @"Cancel", ^{
                            [self.popoverController dismissPopoverAnimated:YES];
                        },
                        @"Restart", ^{
                            [[mAChucKController chuckController] restart];
                            [self.popoverController dismissPopoverAnimated:YES];
                        });
    }
    else
    {
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

@end
