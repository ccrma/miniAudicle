/*----------------------------------------------------------------------------
 miniAudicle iOS
 iOS GUI to chuck audio programming environment
 
 Copyright (c) 2005-2012 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

#import "mAChucKController.h"

#import "TheAmazingAudioEngine/TheAmazingAudioEngine.h"
#import "Modules/AEPlaythroughChannel.h"

#import "miniAudicle.h"
#import "ulib_motion.h"
#import "mAAnalytics.h"
#import "util_buffers.h"
#import "mAPreferences.h"

#import <vector>



static mAChucKController * g_chuckController = nil;

@interface mAChucKController ()
{
    AEBlockChannel *_outputChannel;
    AEBlockFilter *_inputOutputChannel;
    AEPlaythroughChannel *_playthroughChannel;
    
    std::vector<float> _inputBuffer;
    std::vector<float> _outputBuffer;
    
    BOOL _processAudio;
    
    CircularBuffer<void (^)()> *_audioOperationQueue;
}

@property (strong) AEAudioController *audioController;
@property (readonly) AEBlockChannel *outputChannel;
@property (readonly) AEBlockFilter *inputOutputChannel;
@property (strong) NSCondition *processCondition;

- (void)_updateAudioChannel;
- (void)_startVM;
- (void)_startAudioIO;

@end


@implementation mAChucKController

@synthesize ma;

- (void)setEnableInput:(BOOL)enableInput
{
    _enableInput = enableInput;
    
    if(self.audioController)
    {
        NSError *error = NULL;
        [self.audioController setInputEnabled:_enableInput error:&error];
        mAAnalyticsLogError(error);
        
        [self _updateAudioChannel];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:_enableInput forKey:mAAudioInputEnabledPreference];
}

- (void)setBufferSize:(int)bufferSize
{
    _bufferSize = bufferSize;
    [[NSUserDefaults standardUserDefaults] setInteger:_bufferSize forKey:mAAudioBufferSizePreference];
}

- (void)setAdaptiveBuffering:(BOOL)adaptiveBuffering
{
    _adaptiveBuffering = adaptiveBuffering;
    [[NSUserDefaults standardUserDefaults] setBool:_adaptiveBuffering forKey:mAAudioAdaptiveBufferingPreference];
}

- (void)setBackgroundAudio:(BOOL)backgroundAudio
{
    _backgroundAudio = backgroundAudio;
    [[NSUserDefaults standardUserDefaults] setBool:_backgroundAudio forKey:mAAudioBackgroundAudioPreference];
}
+ (void)initialize
{
    if(g_chuckController == nil)
        g_chuckController = [mAChucKController new];
}

+ (mAChucKController *)chuckController
{
    return g_chuckController;
}

- (id)init
{
    if(self = [super init])
    {
        _audioOperationQueue = new CircularBuffer<void (^)()>(32);
        _processAudio = NO;
        
        ma = new miniAudicle;
        
        self.enableInput = [[NSUserDefaults standardUserDefaults] boolForKey:mAAudioInputEnabledPreference];
        self.bufferSize = [[NSUserDefaults standardUserDefaults] integerForKey:mAAudioBufferSizePreference];
        self.adaptiveBuffering = [[NSUserDefaults standardUserDefaults] boolForKey:mAAudioAdaptiveBufferingPreference];
        self.sampleRate = 44100;
        self.backgroundAudio = [[NSUserDefaults standardUserDefaults] boolForKey:mAAudioBackgroundAudioPreference];
    }
    
    return self;
}

- (void)_startVM
{
    ma->set_sample_rate(self.sampleRate);
    ma->set_buffer_size((int) (self.audioController.currentBufferDuration*self.sampleRate));
    
    ma->add_query_func(motion_query);
    
    ma->set_num_inputs(2);
    ma->set_num_outputs(2);
    ma->set_enable_audio(TRUE);
    ma->set_log_level(5);
    ma->set_client_mode(TRUE);
    if(self.adaptiveBuffering)
        ma->set_adaptive_size(ma->get_buffer_size());
    else
        ma->set_adaptive_size(0);
    
    t_CKBOOL result = ma->start_vm();
    if(!result)
    {
        NSLog(@"miniAudicle: error starting VM");
        return;
    }
    
    _inputBuffer.resize(ma->get_buffer_size()*ma->get_num_inputs());
    _outputBuffer.resize(ma->get_buffer_size()*ma->get_num_outputs());
    
    _processAudio = YES;
}

- (void)_startAudioIO
{
    AudioStreamBasicDescription audioDescription;
    memset(&audioDescription, 0, sizeof(audioDescription));
    audioDescription.mFormatID          = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    audioDescription.mChannelsPerFrame  = 2;
    audioDescription.mBytesPerPacket    = sizeof(float);
    audioDescription.mFramesPerPacket   = 1;
    audioDescription.mBytesPerFrame     = sizeof(float);
    audioDescription.mBitsPerChannel    = 8 * sizeof(float);
    audioDescription.mSampleRate        = self.sampleRate;
    
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:audioDescription inputEnabled:self.enableInput];
    self.audioController.preferredBufferDuration = self.bufferSize/((float) self.sampleRate);
    
    [self _updateAudioChannel];
    
    [self.audioController start:NULL];
}

- (void)start
{
    [self _startAudioIO];
    [self _startVM];
}

- (void)restart
{
    // TODO
    if(self.processCondition == nil)
        self.processCondition = [NSCondition new];
    
    // ensure VM is not locked up
    ma->abort_current_shred();
    
    _processAudio = NO;
    
    // use condition variable to ensure out of audio loop
    [self.processCondition lock];
    
    _audioOperationQueue->put(^{
        [self.processCondition lock];
        [self.processCondition signal];
        [self.processCondition unlock];
    });
    
    [self.processCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    [self.processCondition unlock];
    
    ma->stop_vm();
    
    [self _startVM];
}

- (void)_updateAudioChannel
{
    // remove all channels
    if(_outputChannel)
    {
        [self.audioController removeChannels:@[_outputChannel]];
        _outputChannel = nil;
    }
    if(_inputOutputChannel)
    {
        [self.audioController removeChannels:@[_playthroughChannel]];
        [self.audioController removeFilter:_inputOutputChannel];
        _inputOutputChannel = nil;
        _playthroughChannel = nil;
    }
    
    // add channel according to output or input+output
    if(self.enableInput)
    {
        [self.audioController addFilter:self.inputOutputChannel];
        
        _playthroughChannel = [[AEPlaythroughChannel alloc] init];
        _playthroughChannel.channelIsMuted = YES;
        [self.audioController addInputReceiver:_playthroughChannel];
        [self.audioController addChannels:@[_playthroughChannel]];
    }
    else
    {
        [self.audioController addChannels:@[self.outputChannel]];
    }
}

- (AEBlockChannel *)outputChannel
{
    if(_outputChannel == nil)
    {
        _outputChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time,
                                                            UInt32 frames,
                                                            AudioBufferList *audio) {
            if(_processAudio)
            {
                if(_inputBuffer.size() < frames*ma->get_num_inputs())
                {
                    NSLog(@"miniAudicle: warning: input buffer resized from %li to %li in audio I/O process",
                          _inputBuffer.size(), frames*ma->get_num_inputs());
                    _inputBuffer.resize(frames*ma->get_num_inputs());
                }
                
                if(_outputBuffer.size() < frames*ma->get_num_outputs())
                {
                    NSLog(@"miniAudicle: warning: output buffer resized from %li to %li in audio I/O process",
                          _outputBuffer.size(), frames*ma->get_num_outputs());
                    _outputBuffer.resize(frames*ma->get_num_outputs());
                }
                
                // zero input
                memset(_inputBuffer.data(), 0, sizeof(float)*frames*ma->get_num_outputs());
                
                ma->process_audio(frames, _inputBuffer.data(), _outputBuffer.data());
                
                // deinterleave output
                for(int i = 0; i < frames; i++)
                {
                    ((float*)(audio->mBuffers[0].mData))[i] = _outputBuffer[i*2];
                    ((float*)(audio->mBuffers[1].mData))[i] = _outputBuffer[i*2+1];
                }
            }
            
            void (^audioOperation)();
            while(_audioOperationQueue->get(audioOperation))
                audioOperation();
        }];
    }
    
    return _outputChannel;
}

- (AEBlockFilter *)inputOutputChannel
{
    if(_inputOutputChannel == nil)
    {
        _inputOutputChannel = [AEBlockFilter filterWithBlock:^(AEAudioFilterProducer producer,
                                                               void *producerToken,
                                                               const AudioTimeStamp *time,
                                                               UInt32 frames,
                                                               AudioBufferList *audio) {
            if(_processAudio)
            {
                if(_playthroughChannel.channelIsMuted)
                    _playthroughChannel.channelIsMuted = NO;
                
                if(_inputBuffer.size() < frames*ma->get_num_inputs())
                {
                    NSLog(@"miniAudicle: warning: input buffer resized from %li to %li in audio I/O process",
                          _inputBuffer.size(), frames*ma->get_num_inputs());
                    _inputBuffer.resize(frames*ma->get_num_inputs());
                }
                
                if(_outputBuffer.size() < frames*ma->get_num_outputs())
                {
                    NSLog(@"miniAudicle: warning: output buffer resized from %li to %li in audio I/O process",
                          _outputBuffer.size(), frames*ma->get_num_outputs());
                    _outputBuffer.resize(frames*ma->get_num_outputs());
                }
                
                OSStatus status = producer(producerToken, audio, &frames);
                if(status != noErr)
                {
                    NSLog(@"miniAudicle: warning: received error %li generating audio input", status);
                    memset(_inputBuffer.data(), 0, sizeof(float)*frames*ma->get_num_outputs());
                }
                else
                {
                    // interleave input
                    for(int i = 0; i < frames; i++)
                    {
                        _inputBuffer[i*2] = ((float*)(audio->mBuffers[0].mData))[i];
                        _inputBuffer[i*2+1] = ((float*)(audio->mBuffers[1].mData))[i];
                    }
                }
                
                ma->process_audio(frames, _inputBuffer.data(), _outputBuffer.data());
                
                // deinterleave output
                for(int i = 0; i < frames; i++)
                {
                    ((float*)(audio->mBuffers[0].mData))[i] = _outputBuffer[i*2];
                    ((float*)(audio->mBuffers[1].mData))[i] = _outputBuffer[i*2+1];
                }
            }
            
            void (^audioOperation)();
            while(_audioOperationQueue->get(audioOperation))
                audioOperation();
        }];
    }
    
    return _inputOutputChannel;
}

@end
