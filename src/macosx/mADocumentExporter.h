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
//  mADocumentExporter.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/22/13.
//
//

#import <Foundation/Foundation.h>

#import "mAExportProgressViewController.h"


#ifdef __cplusplus
extern "C"
{
#endif
NSString *which(NSString *bin);
#ifdef __cplusplus
}
#endif


@class miniAudicleDocument;
@class mADocumentExporter;

@protocol mADocumentExporterDelegate <NSObject>

- (void)documentExporterDidFinish:(mADocumentExporter *)exporter;
- (void)documentExporterDidCancel:(mADocumentExporter *)exporter;

@end

@interface mADocumentExporter : NSObject<mAExportProgressDelegate>
{
    miniAudicleDocument * document;
    
    NSTask * exportTask;
    mAExportProgressViewController * exportProgress;
    NSString *exportTempScriptPath;
    NSString *exportWAVPath;
    
    BOOL limitDuration;
    float duration;

    BOOL exportWAV;
    BOOL exportMP3;
    BOOL exportOgg;
    BOOL exportM4A;
    
    id<mADocumentExporterDelegate> delegate;
    NSString * destinationPath;
    
    BOOL cancelled;
}

@property (nonatomic) BOOL limitDuration;
@property (nonatomic) float duration;

@property (nonatomic) BOOL exportWAV;
@property (nonatomic) BOOL exportMP3;
@property (nonatomic) BOOL exportOgg;
@property (nonatomic) BOOL exportM4A;

- (id)initWithDocument:(miniAudicleDocument *)document
       destinationPath:(NSString *)path;

- (void)startExportWithDelegate:(id<mADocumentExporterDelegate>)delegate;

@end
