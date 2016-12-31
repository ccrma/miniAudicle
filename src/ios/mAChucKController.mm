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

#import "mADetailItem.h"
#import "mAPreferences.h"
#import "mAAnalytics.h"

#import "miniAudicle.h"
#import "ulib_motion.h"

#import "util_buffers.h"
#import "chuck_compile.h"
#import "chuck_globals.h"

#import <vector>

CK_DLL_QUERY_STATIC(ABSaturator);
CK_DLL_QUERY_STATIC(Bitcrusher);
CK_DLL_QUERY_STATIC(Elliptic);
CK_DLL_QUERY_STATIC(ExpDelay);
CK_DLL_QUERY_STATIC(FIR);
CK_DLL_QUERY_STATIC(FoldbackSaturator);
CK_DLL_QUERY_STATIC(GVerb);
CK_DLL_QUERY_STATIC(KasFilter);
CK_DLL_QUERY_STATIC(MagicSine);
CK_DLL_QUERY_STATIC(Mesh2D);
CK_DLL_QUERY_STATIC(Multicomb);
CK_DLL_QUERY_STATIC(Overdrive);
CK_DLL_QUERY_STATIC(PanN);
CK_DLL_QUERY_STATIC(PitchTrack);
CK_DLL_QUERY_STATIC(PowerADSR);
CK_DLL_QUERY_STATIC(Sigmund);
CK_DLL_QUERY_STATIC(Spectacle);
CK_DLL_QUERY_STATIC(WinFuncEnv);
CK_DLL_QUERY_STATIC(WPDiodeLadder);
CK_DLL_QUERY_STATIC(WPKorg35);
CK_DLL_QUERY_STATIC(chugl);

static mAChucKController * g_chuckController = nil;

@interface mAChucKController ()
{
    miniAudicle * ma;

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

- (void)applicationWillEnterForeground:(NSNotification *)n;
- (void)applicationDidEnterBackground:(NSNotification *)n;

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
        self.bufferSize = (int) [[NSUserDefaults standardUserDefaults] integerForKey:mAAudioBufferSizePreference];
        self.adaptiveBuffering = [[NSUserDefaults standardUserDefaults] boolForKey:mAAudioAdaptiveBufferingPreference];
        self.sampleRate = 44100;
        self.backgroundAudio = [[NSUserDefaults standardUserDefaults] boolForKey:mAAudioBackgroundAudioPreference];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)_startVM
{
    self.audioController.preferredBufferDuration = self.bufferSize/((float) self.sampleRate);
    
    ma->set_sample_rate(self.sampleRate);
    ma->set_buffer_size((int) (self.audioController.currentBufferDuration*self.sampleRate));
    
    ma->add_query_func(motion_query);
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(ABSaturator), "ABSaturator");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Bitcrusher), "Bitcrusher");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Elliptic), "Elliptic");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(ExpDelay), "ExpDelay");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(FIR), "FIR");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(FoldbackSaturator), "FoldbackSaturator");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(GVerb), "GVerb");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(KasFilter), "KasFilter");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(MagicSine), "MagicSine");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Mesh2D), "Mesh2D");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Multicomb), "Multicomb");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Overdrive), "Overdrive");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(PanN), "PanN");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(PitchTrack), "PitchTrack");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(PowerADSR), "PowerADSR");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Sigmund), "Sigmund");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(Spectacle), "Spectacle");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(WinFuncEnv), "WinFuncEnv");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(WPDiodeLadder), "WPDiodeLadder");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(WPKorg35), "WPKorg35");
    ma->add_query_func(CK_DLL_QUERY_STATIC_NAME(chugl), "chugl");
    
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
    if(self.audioController == nil)
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
        self.audioController.allowMixingWithOtherApps = NO;
    }
    
    self.audioController.preferredBufferDuration = self.bufferSize/((float) self.sampleRate);
    
    [self _updateAudioChannel];
    
    NSError *error;
    [self.audioController start:&error];
    mAAnalyticsLogError(error);
}

- (void)start
{
    [self _startAudioIO];
    [self _startVM];
    
    _running = YES;
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

- (BOOL)chuckCodeCompiles:(mADetailItem *)item error:(NSString **)error;
{
    Chuck_Compiler *compiler = g_compiler;
    
    // compile
    if(!compiler->go([item.title UTF8String], NULL, [item.text UTF8String], [item.path UTF8String]))
    {
        if(error)
            *error = [NSString stringWithUTF8String:EM_lasterror()];
        
        return NO;
    }
    
    return YES;
}

#pragma mark Application state handling

- (void)applicationWillEnterForeground:(NSNotification *)n
{
    if(self.running)
    {
        NSError *error;
        [self.audioController start:&error];
        mAAnalyticsLogError(error);
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)n
{
    if(self.running)
    {
        if(!self.backgroundAudio)
        {
            [self.audioController stop];
        }
    }
}

#pragma mark Audio I/O integration

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
                    NSLog(@"miniAudicle: warning: received error %i generating audio input", (int)status);
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
