//
//  mAAudioFileTableViewCell.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/29/16.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class mADetailItem;

@interface mAAudioFileTableViewCell : UITableViewCell<AVAudioPlayerDelegate>
{
    IBOutlet UIProgressView *_playbackProgress;
    IBOutlet UILabel *_playbackTimeLabel;
    IBOutlet UIButton *_playButton;
    
    BOOL _active;
}

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *timer;

- (void)playDetailItem:(mADetailItem *)item;

- (void)loadFile:(NSString *)path;
- (void)play;
- (void)stop;

- (void)activate;
- (void)deactivate;
- (void)updatePlaybackTime:(NSTimeInterval)playbackTime;
- (void)updatePlaybackPercent:(float)playbackPct;

- (IBAction)togglePlay:(id)sender;

@end

