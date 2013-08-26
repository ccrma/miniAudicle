/*----------------------------------------------------------------------------
 miniAudicle
 Cocoa GUI to chuck audio programming environment
 
 Copyright (c) 2005-2013 Spencer Salazar.  All rights reserved.
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

//
//  mADocumentExporter.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/22/13.
//
//

#import "mADocumentExporter.h"
#import "miniAudicleDocument.h"


NSString *tmpFilepath(NSString *base, NSString *extension, NSString *dir, BOOL createEnclosingDirectory);

@interface mADocumentExporter ()

@property (nonatomic, strong) NSTask * exportTask;
@property (nonatomic, strong) mAExportProgressViewController * exportProgress;
@property (nonatomic, strong) NSString * exportTempScriptPath;
@property (nonatomic, strong) NSString * exportWAVPath;
@property (nonatomic, strong) NSString * destinationPath;


- (void)exportProgressDidCancel;
- (void)exportTaskDidTerminate:(NSNotification *)n;
- (void)cleanup;

@end


@implementation mADocumentExporter

@synthesize exportTask;
@synthesize exportProgress;
@synthesize exportTempScriptPath, exportWAVPath;

@synthesize destinationPath;

@synthesize limitDuration, duration;
@synthesize exportWAV, exportMP3, exportOgg, exportM4A;

- (id)initWithDocument:(miniAudicleDocument *)_document
       destinationPath:(NSString *)path
{
    if(self = [super init])
    {
        document = _document;
        self.destinationPath = path;
    }
    
    return self;
}

- (void)startExportWithDelegate:(id<mADocumentExporterDelegate>)delegate
{
    NSString *filePath;
    self.exportTempScriptPath = nil;
    self.exportWAVPath = tmpFilepath([[document displayName] stringByDeletingPathExtension], @"wav", nil, YES);
    
    if([document fileURL] && ![document isDocumentEdited])
    {
        filePath = [[document fileURL] path];
    }
    else
    {
        NSString *dir = nil;
        if([document fileURL])
            dir = [[[document fileURL] path] stringByDeletingLastPathComponent];
        
        filePath = tmpFilepath([[document displayName] stringByDeletingPathExtension], @"ck", dir, YES);
        
        [document writeToURL:[NSURL fileURLWithPath:filePath]
                      ofType:@"ChucK Script"
                       error:NULL];
        
        self.exportTempScriptPath = filePath;
    }
    
    NSString * arg = [NSString stringWithFormat:@"%@:%@:%@:%i:%f",
                      [[NSBundle mainBundle] pathForResource:@"export.ck" ofType:nil],
                      filePath,
                      self.exportWAVPath,
                      self.limitDuration,
                      self.duration];
    
//    NSLog(@"chuck --silent %@", arg);
    
    self.exportTask = [[[NSTask alloc] init] autorelease];
    
    [self.exportTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"chuck" ofType:nil]];
    [self.exportTask setArguments:@[@"--silent", @"--standalone", arg]];
    if([document fileURL])
        [self.exportTask setCurrentDirectoryPath:[[[document fileURL] path] stringByDeletingLastPathComponent]];
    
    [self.exportTask launch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exportTaskDidTerminate:)
                                                 name:NSTaskDidTerminateNotification
                                               object:self.exportTask];
    
    self.exportProgress = [[[mAExportProgressViewController alloc] initWithWindowNibName:@"mAExportProgress"] autorelease];
    self.exportProgress.delegate = self;
    
    [[NSApplication sharedApplication] beginSheet:self.exportProgress.window
                                   modalForWindow:[document.windowController window]
                                    modalDelegate:nil
                                   didEndSelector:nil
                                      contextInfo:nil];
    
    cancelled = NO;
}

- (void)exportProgressDidCancel
{
    //[self.exportTask terminate];
    // use SIGINT to ensure proper cleanup in chuck binary
    kill(self.exportTask.processIdentifier, SIGINT);
    cancelled = YES;
}

- (void)exportTaskDidTerminate:(NSNotification *)n
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTaskDidTerminateNotification
                                                  object:self.exportTask];
    
    if(cancelled)
    {
        [self cleanup];
    }
    else
    {
        if(self.exportWAV)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:[self.destinationPath stringByDeletingLastPathComponent]
                                      withIntermediateDirectories:YES
                                                       attributes:nil error:nil];
            
            [[NSFileManager defaultManager] copyItemAtPath:self.exportWAVPath
                                                    toPath:[[self.destinationPath
                                                             stringByDeletingPathExtension]
                                                            stringByAppendingPathExtension:@"wav"]
                                                     error:NULL];
            
            self.exportWAV = NO;
            
            [self exportTaskDidTerminate:n];
        }
        else if(self.exportM4A)
        {
            self.exportTask = [[[NSTask alloc] init] autorelease];
            
            [self.exportTask setLaunchPath:@"/usr/bin/afconvert"];
            [self.exportTask setArguments:@[
             self.exportWAVPath,
             @"-o", [[self.destinationPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"],
             @"-f", @"m4af", // M4A format
             @"-s", @"3", // VBR mode
             @"-b", @"192000", // 192 Kbps
             ]];
            
            [self.exportTask launch];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(exportTaskDidTerminate:)
                                                         name:NSTaskDidTerminateNotification
                                                       object:self.exportTask];
            
            self.exportM4A = NO;
        }
        else if(self.exportOgg)
        {
            self.exportTask = [[[NSTask alloc] init] autorelease];
            
            [self.exportTask setLaunchPath:@"/usr/local/bin/oggenc"];
            [self.exportTask setArguments:@[
             @"-Q", // silent mode
             @"-o", [[self.destinationPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"ogg"],
             @"-b", @"192", // 192 Kbps
             self.exportWAVPath,
             ]];
            
            [self.exportTask launch];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(exportTaskDidTerminate:)
                                                         name:NSTaskDidTerminateNotification
                                                       object:self.exportTask];
            
            self.exportOgg = NO;
        }
        else if(self.exportMP3)
        {
            self.exportTask = [[[NSTask alloc] init] autorelease];
            
            [self.exportTask setLaunchPath:@"/opt/local/bin/lame"];
            [self.exportTask setArguments:@[
             @"-S", // silent
             @"-v", // VBR
             @"-b", @"192", // 192 Kbps bitrate
             self.exportWAVPath,
             [[self.destinationPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"],
             ]];
            
            [self.exportTask launch];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(exportTaskDidTerminate:)
                                                         name:NSTaskDidTerminateNotification
                                                       object:self.exportTask];

            self.exportMP3 = NO;
        }
        else
        {
            [self cleanup];
        }
    }
}

- (void)cleanup
{
    [[NSApplication sharedApplication] endSheet:self.exportProgress.window];
    [self.exportProgress.window orderOut:self];
    self.exportProgress = nil;
    self.exportTask = nil;
    
    if(self.exportTempScriptPath != nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.exportTempScriptPath error:NULL];
        self.exportTempScriptPath = nil;
    }
    if(self.exportWAVPath != nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.exportWAVPath error:NULL];
        self.exportWAVPath = nil;
    }
}

@end


NSString *tmpFilepath(NSString *base, NSString *extension, NSString *dir, BOOL createEnclosingDirectory)
{
    if(base == nil) base = @"temp";
    
    if(extension == nil) extension = @"";
    else extension = [@"." stringByAppendingString:extension];
    
    NSString * filePath;
    
    if(dir == nil)
    {
        filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@/%@%X%X%@",
                    [[NSBundle mainBundle] bundleIdentifier],
                    base,
                    (int)(CFAbsoluteTimeGetCurrent()),
                    (int)(fmod(CFAbsoluteTimeGetCurrent(),1.0)*1000.0),
                    extension];
    }
    else
    {
        filePath = [dir stringByAppendingFormat:@"/%@%X%X%@",
                    base,
                    (int)(CFAbsoluteTimeGetCurrent()),
                    (int)(fmod(CFAbsoluteTimeGetCurrent(),1.0)*1000.0),
                    extension];
    }
    
    if(createEnclosingDirectory)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    
    return filePath;
}

