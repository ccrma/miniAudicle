//
//  mAAudioFileTableViewCell.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/29/16.
//
//

#import "mAAudioFileTableViewCell.h"
#import "mADetailItem.h"
#import "mAAnalytics.h"

@implementation mAAudioFileTableViewCell

- (void)awakeFromNib
{
    _active = NO;
    _playbackProgress.alpha = 0;
    _playbackTimeLabel.alpha = 0;
    _playButton.alpha = 0;
    
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)playDetailItem:(mADetailItem *)item
{
    [self loadFile:item.path];
    [self play];
}

- (void)loadFile:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = NULL;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                              error:&error];
    if(error != NULL)
        mAAnalyticsLogError(error);
    
    self.audioPlayer.delegate = self;
}

- (void)play
{
    self.audioPlayer.currentTime = 0;
    [self.audioPlayer play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.011
                                                  target:[NSBlockOperation blockOperationWithBlock:^{
        [self updatePlaybackTime:self.audioPlayer.currentTime];
        [self updatePlaybackPercent:self.audioPlayer.currentTime/self.audioPlayer.duration];
    }]
                                                selector:@selector(main)
                                                userInfo:nil
                                                 repeats:YES];
    
    [_playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    [self.audioPlayer stop];
    
    [self updatePlaybackTime:0.0];
    [self updatePlaybackPercent:0.0];
    
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)activate
{
    if(!_active)
    {
        _active = YES;
        [UIView animateWithDuration:0.1
                         animations:^{
                             _playbackProgress.alpha = 1;
                             _playbackTimeLabel.alpha = 1;
                             _playButton.alpha = 1;
                         }];
    }
}

- (void)deactivate
{
    if(_active)
    {
        _active = NO;
        [UIView animateWithDuration:0.1
                         animations:^{
                             _playbackProgress.alpha = 0;
                             _playbackTimeLabel.alpha = 0;
                             _playButton.alpha = 0;
                         }];
        
        [self stop];
        
        self.audioPlayer = nil;
    }
}

- (void)updatePlaybackTime:(NSTimeInterval)playbackTime
{
    int elapsedSecs = (int)floorf(playbackTime);
    int hrs = elapsedSecs/3600;
    int mins = (elapsedSecs%3600)/60;
    int secs = (elapsedSecs%3600)%60;
    int millis = ((int)floorf(playbackTime*1000.0f))%1000;
    
    if(hrs > 0)
        _playbackTimeLabel.text = [NSString stringWithFormat:@"%i:%02i:%02i", hrs, mins, secs];
    else
        _playbackTimeLabel.text = [NSString stringWithFormat:@"%i:%02i.%03i", mins, secs, millis];
}

- (void)updatePlaybackPercent:(float)playbackPct
{
    _playbackProgress.progress = playbackPct;
}

- (IBAction)togglePlay:(id)sender
{
    if(self.audioPlayer)
    {
        if(self.audioPlayer.isPlaying)
            [self stop];
        else
            [self play];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.timer invalidate];
    self.timer = nil;
    
    [self updatePlaybackTime:self.audioPlayer.duration];
    [self updatePlaybackPercent:1.0];
    
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

@end
