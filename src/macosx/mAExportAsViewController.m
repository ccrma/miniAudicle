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
//  mAExportAsViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/11/13.
//
//

#import "mAExportAsViewController.h"
#import "mADocumentExporter.h"
#import "NSPanel+ButtonTag.h"

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

@synthesize savePanel;
@synthesize exportButtonTag;
@synthesize numSelectedFileTypes;

@synthesize limitDuration, duration;
@synthesize exportWAV, exportOgg, exportM4A, exportMP3;
@synthesize enableMP3;

+ (void)initialize
{
	g_lameAvailable = (which(@"lame") != nil);
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
															  mAExportAsLimitDuration: @NO,
															  mAExportAsDuration: @30.0,
															  mAExportAsExportWAV: @YES,
															  mAExportAsExportOgg: @NO,
															  mAExportAsExportM4A: @NO,
															  mAExportAsExportMP3: @NO,
															  }];
    
    // unremark to set defaults for testing //
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:mAExportAsExportWAV];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:mAExportAsExportOgg];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:mAExportAsExportM4A];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:mAExportAsExportMP3];
    // end unremark to set defaults for testing //
}

- (int)numSelectedFileTypes
{
	int selectedFileTypeCount =
	(self.exportWAV ? 1 : 0) +
	(self.exportOgg ? 1 : 0) +
	(self.exportM4A ? 1 : 0) +
	(self.exportMP3 ? 1 : 0);
	
	return selectedFileTypeCount;
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

/*
 NOTE: as of Jan 2017, mADocumentExporter.mm is deleting the extension
 before re-adding the correct one based on the selected export types.
 Therefore, this action is only to ensure correct display of the
 extension in the entered file name while the save panel is active.
 */
- (IBAction)formatButtonClick:(id)sender
{
    switch (self.numSelectedFileTypes) {
		case 0:
			[savePanel setAllowedFileTypes:@[@""]];
            [savePanel disableButtonWithTag:exportButtonTag];
            savePanel.message = @"REQUIRED: select a format for the export.";
			break;
			
		case 1:
            [savePanel enableButtonWithTag:exportButtonTag];
			if (self.exportWAV) {
				[savePanel setAllowedFileTypes:@[@"wav"]];
			}
			else if (self.exportOgg) {
				[savePanel setAllowedFileTypes:@[@"ogg"]];
			}
			else if (self.exportM4A) {
				[savePanel setAllowedFileTypes:@[@"m4a"]];
			}
			else if (self.exportMP3) {
				[savePanel setAllowedFileTypes:@[@"mp3"]];
			}
            savePanel.message = @"";
			break;
			
		default:
            [savePanel enableButtonWithTag:exportButtonTag];
			[savePanel setAllowedFileTypes:@[@"*"]];
            savePanel.message = @"";
			break;
	}
}

- (void)saveSettings
{
	/*
	 NOTE: as of Jan 2017, mADocumentExporter.mm is deleting
	 the extension before re-adding a correct one based on the
	 selected export types. Therefore, we can reset the extension
	 to the default "wav" before moving on - AND, if no other file
	 types are selected, we'll select "wav" for the defaults save
	 as well.
	 */
	
	[savePanel setAllowedFileTypes:@[@"wav"]];
	
	if (self.numSelectedFileTypes == 0) {
		self.exportWAV = YES;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:self.limitDuration forKey:mAExportAsLimitDuration];
	[defaults setFloat:self.duration forKey:mAExportAsDuration];
	[defaults setBool:self.exportWAV forKey:mAExportAsExportWAV];
	[defaults setBool:self.exportOgg forKey:mAExportAsExportOgg];
	[defaults setBool:self.exportM4A forKey:mAExportAsExportM4A];
	[defaults setBool:self.exportMP3 forKey:mAExportAsExportMP3];
}

@end
