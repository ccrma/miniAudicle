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

@interface mABufferSizeSelectorViewController : UIViewController

@property (strong) void (^didSelectBufferSize)(int bufferSize);

@end


@interface mAPreferencesViewController ()
{
    BOOL _updateVM;
    
    IBOutlet UISwitch *_enableInputSwitch;
    IBOutlet UISwitch *_adaptiveBufferingSwitch;
    IBOutlet UISwitch *_backgroundAudioSwitch;
    
    int _bufferSize;
    BOOL _adaptiveBuffering;
    int _sampleRate;
}

@property (strong) IBOutlet mABufferSizeSelectorViewController *bufferSizeSelector;
@property int bufferSize;
@property (strong) IBOutlet UIButton *bufferSizeButton;

@end

@implementation mAPreferencesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _updateVM = NO;
    
    _enableInputSwitch.on = [mAChucKController chuckController].enableInput;
    
    _bufferSize = [mAChucKController chuckController].bufferSize;
    [self.bufferSizeButton setTitle:[NSString stringWithFormat:@"%i", _bufferSize] forState:UIControlStateNormal];
    
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
    __weak typeof(self) weakSelf = self;
    self.bufferSizeSelector.didSelectBufferSize = ^(int bufferSize) {
        NSLog(@"didSelectBufferSize %i", bufferSize);
        assert(bufferSize > 0);
        
        weakSelf.bufferSize = bufferSize;
        [weakSelf.bufferSizeButton setTitle:[NSString stringWithFormat:@"%i", bufferSize] forState:UIControlStateNormal];
    };

    [self presentViewController:self.bufferSizeSelector animated:YES completion:^{}];
    
    UIPopoverPresentationController *popoverController = self.bufferSizeSelector.popoverPresentationController;
    popoverController.sourceView = _bufferSizeButton.superview;
    popoverController.sourceRect = _bufferSizeButton.frame;
}

- (IBAction)adaptiveBufferingChanged:(id)sender
{
}

- (IBAction)backgroundAudioChanged:(id)sender
{
    [mAChucKController chuckController].backgroundAudio = _backgroundAudioSwitch.on;
}

- (IBAction)done:(id)sender
{
    _updateVM = NO;
    
    if(_adaptiveBufferingSwitch.on != [mAChucKController chuckController].adaptiveBuffering)
        _updateVM = YES;
    if(_bufferSize != [mAChucKController chuckController].bufferSize)
        _updateVM = YES;
    
    if(_updateVM)
    {
        UIAlertMessage2(@"Some of the modified settings require restarting the ChucK Virtual Machine. This will stop any currently running ChucK programs. Restart the Virtual Machine?",
                        @"Cancel", ^{
                            [self.popoverController dismissPopoverAnimated:YES];
                        },
                        @"Restart", ^{
                            [mAChucKController chuckController].adaptiveBuffering = _adaptiveBufferingSwitch.on;
                            [mAChucKController chuckController].bufferSize = _bufferSize;

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



@implementation mABufferSizeSelectorViewController

- (void)viewDidLoad
{
    self.modalPresentationStyle = UIModalPresentationPopover;
}

- (IBAction)selectBufferSize:(id)sender
{
    int bufferSize = [sender tag];
    if(self.didSelectBufferSize)
        self.didSelectBufferSize(bufferSize);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end


