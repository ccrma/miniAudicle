//
//  mAExportAsViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 6/11/13.
//
//

#import <Cocoa/Cocoa.h>

@interface mAExportAsViewController : NSViewController
{
    BOOL limitDuration;
    CGFloat duration;
    
    IBOutlet NSTextField * _durationTextField;
}

@property (nonatomic) BOOL limitDuration;
@property (nonatomic) CGFloat duration;

@property (nonatomic) BOOL exportWAV;
@property (nonatomic) BOOL exportOgg;
@property (nonatomic) BOOL exportM4A;
@property (nonatomic) BOOL exportMP3;

@property (nonatomic) BOOL enableMP3;

- (void)saveSettings;

@end
