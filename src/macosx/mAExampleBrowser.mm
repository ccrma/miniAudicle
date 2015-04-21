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
//  mAExampleBrowser.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/13/13.
//
//

#import "mAExampleBrowser.h"
#import "miniAudicleDocument.h"
#import "miniAudicleController.h"


@interface NSFileManager (isDirectory)

- (BOOL)isDirectory:(NSString *)path;

@end

@implementation NSFileManager (isDirectory)

- (BOOL)isDirectory:(NSString *)path
{
    BOOL isDirectory = NO;
    if([self fileExistsAtPath:path isDirectory:&isDirectory])
        return isDirectory;
    else
        return NO;
}


@end


@interface mAExampleBrowser ()

+ (NSString *)examplesPath;

@end

@implementation mAExampleBrowser

+ (NSString *)examplesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    if([paths count])
    {
        // examples in library
        NSString *libraryExamplePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Chuck"] stringByAppendingPathComponent:@"examples"];
        BOOL isDir = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:libraryExamplePath
                                                isDirectory:&isDir] && isDir)
            return libraryExamplePath;
    }
    
    // built-in examples
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"examples"];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [_browser setDoubleAction:@selector(open:)];
    [_browser setTarget:self];
    [_openButton setEnabled:NO];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
//    if([theEvent modifierFlags] & NSAlternateKeyMask)
//        [_openButton setTitle:@"Open in Tab"];
//    else
//        [_openButton setTitle:@"Open"];
    
    [super flagsChanged:theEvent];
}


#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    // clear selection
    [_browser selectRowIndexes:[NSIndexSet indexSet] inColumn:[_browser selectedColumn]];
    // disable open button
    [_openButton setEnabled:NO];
}


#pragma mark IBActions

- (IBAction)open:(id)sender
{
    NSString * examplePath = [mAExampleBrowser examplesPath];
    NSString * columnPath = [examplePath stringByAppendingFormat:@"/%@", [_browser pathToColumn:[_browser selectedColumn]]];
    
//    BOOL inTab = [NSEvent modifierFlags] & NSAlternateKeyMask;
    miniAudicleController * controller = (miniAudicleController *)[NSDocumentController sharedDocumentController];
    
    for(NSBrowserCell * cell in [_browser selectedCells])
    {
        NSString * filePath = [columnPath stringByAppendingPathComponent:[cell title]];
        
        if([[filePath pathExtension] isEqualToString:@"ck"])
        {
            
            miniAudicleDocument * doc;
            
            //        if(inTab)
            //        {
            //            doc = [controller openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filePath]
            //                                                    display:YES
            //                                                      error:nil
            //                                                      inTab:YES];
            //        }
            //        else
            {
                doc = [controller openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                        display:YES
                                                          error:nil];
            }
            
            doc.readOnly = YES;
        }
        else
        {
            [[NSWorkspace sharedWorkspace] openFile:filePath];
        }
    }
    
    [self.window close];
}

- (IBAction)cancel:(id)sender
{
    [self.window close];
}

- (IBAction)select:(id)sender
{
    BOOL enable = NO;
    
    for(NSBrowserCell * cell in [_browser selectedCells])
    {
        if([cell isLeaf])
        {
            enable = YES;
            break;
        }
    }
    
    [_openButton setEnabled:enable];
}


#pragma mark NSBrowserDelegate

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * examplePath = [mAExampleBrowser examplesPath];
    NSString * columnPath = [examplePath stringByAppendingFormat:@"/%@", [sender pathToColumn:column]];
    NSArray * contents = [fileManager contentsOfDirectoryAtPath:columnPath error:nil];
    
    return [contents count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    NSFileManager * fileManager = [NSFileManager defaultManager];

    NSString *examplePath = [mAExampleBrowser examplesPath];
    NSString *columnPath = [examplePath stringByAppendingFormat:@"/%@", [sender pathToColumn:column]];
    NSArray *files= [[fileManager contentsOfDirectoryAtPath:columnPath
                                                      error:nil]
                     sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                         return [obj1 compare:obj2 options:NSNumericSearch|NSForcedOrderingSearch|NSCaseInsensitiveSearch];
                     }];
    NSString * file = [files objectAtIndex:row];
    NSString * fullpath = [columnPath stringByAppendingPathComponent:file];
    
    [cell setTitle:file];
    [cell setEnabled:YES];
    [cell setImage:nil];

    if([fileManager isDirectory:fullpath])
    {
        [cell setImage:[NSImage imageNamed:@"folder.png"]];
        [cell setLeaf:NO];
    }
    else
    {
        NSImage *ckmini = [NSImage imageNamed:@"ckmini.png"];
        if([[file pathExtension] isEqualToString:@"ck"])
            [cell setImage:ckmini];
        else
        {
            NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:fullpath];
            image.size = ckmini.size;
            [cell setImage:image];
        }
        [cell setLeaf:YES];
    }
}

- (CGFloat)browser:(NSBrowser *)browser heightOfRow:(NSInteger)row inColumn:(NSInteger)columnIndex
{
    return 64;
}

@end
