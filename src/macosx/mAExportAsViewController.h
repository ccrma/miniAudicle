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
	
	BOOL exportWAV, exportOgg, exportM4A, exportMP3;
	BOOL enableMP3;
	
	IBOutlet NSTextField * _durationTextField;
}

@property (nonatomic, assign) NSSavePanel * savePanel;
@property (nonatomic) int exportButtonTag;
@property (nonatomic, readonly) NSString * noSelectedFormatsMessage;

@property (nonatomic, readonly) int numSelectedFileTypes;

@property (nonatomic) BOOL limitDuration;
@property (nonatomic) CGFloat duration;

@property (nonatomic) BOOL exportWAV;
@property (nonatomic) BOOL exportOgg;
@property (nonatomic) BOOL exportM4A;
@property (nonatomic) BOOL exportMP3;

@property (nonatomic) BOOL enableMP3;

- (IBAction)formatButtonClick:(id)sender;
- (void)saveSettings;

@end
