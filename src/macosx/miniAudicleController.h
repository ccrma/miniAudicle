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

//-----------------------------------------------------------------------------
// file: miniAudicleController.h
// desc: controller class for miniAudicle GUI
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#ifndef __MINIAUDICLECONTROLLER_H__
#define __MINIAUDICLECONTROLLER_H__

#import <Cocoa/Cocoa.h>
#import "chuck_def.h"

class miniAudicle;
@class miniAudicleVMMonitor;
@class miniAudicleConsoleMonitor;
@class miniAudiclePreferencesController;
@class IDEKit_LexParser;
@class miniAudicleDocument;
@class mARecordSessionController;
@class mAMultiDocWindowController;

extern NSString * const mAVirtualMachineDidTurnOnNotification;
extern NSString * const mAVirtualMachineDidTurnOffNotification;

@interface miniAudicleController : NSDocumentController
{
    miniAudicle * ma;
    t_CKUINT docid;
    NSMutableArray * madv;
    IBOutlet miniAudicleVMMonitor * vm_monitor;
    IBOutlet miniAudicleConsoleMonitor * console_monitor;
    NSPoint last_window_tlc;
    //NSWindow * chuck_shell_window;
    NSDrawer * document_drawer;
    NSTextField * about_text;
    IBOutlet miniAudiclePreferencesController * mapc;
    mARecordSessionController * m_recordSessionController;
    
    miniAudicleDocument * main_document;
    
    mAMultiDocWindowController * _topWindowController;
    NSMutableArray * _windowControllers;
    
    NSWindow * remote_vm_dialog;
    NSTextField * remote_vm_host;
    NSTextField * remote_vm_port;
    
    IDEKit_LexParser * syntax_highlighter;
    NSMutableDictionary * class_names;
    
    BOOL vm_on;
    BOOL vm_starting;
    
    BOOL in_lockdown;
    
    BOOL _forceDocumentInTab, _forceDocumentInWindow;
    
    IBOutlet NSMenuItem *startVMMenuItem;
    IBOutlet NSMenuItem *closeWindowMenuItem;
    IBOutlet NSMenuItem *closeTabMenuItem;
    
    IBOutlet NSMenuItem *newWindowMenuItem;
    IBOutlet NSMenuItem *newTabMenuItem;
    
    BOOL _didCloseAll;
}

// static/non-static initializers
- (id)init;
- (void)dealloc;

// no op function, to instantiate empty NSThread
- (void)nop:(id)sender;

// miniAudicle accessor
- (miniAudicle *)miniAudicle;

- (mAMultiDocWindowController *)windowControllerForNewDocument;
- (mAMultiDocWindowController *)topWindowController;
- (mAMultiDocWindowController *)newWindowController;
- (void)windowDidCloseForController:(mAMultiDocWindowController *)controller;

// overridden NSDocumentController functions
- (void)addDocument:(NSDocument *)doc;
- (void)removeDocument:(NSDocument *)doc;

// syntax highlighting
- (IDEKit_LexParser *)syntaxHighlighter;
- (void)updateSyntaxHighlighting;
- (NSColor *)colorForIdentifier: (NSString *)ident;

// convenience function so miniAudicleDocument can cascade correctly
- (NSPoint)lastWindowTopLeftCorner;
- (void)setLastWindowTopLeftCorner:(NSPoint)p;

// UI callbacks
- (IBAction)openDocumentInTab:(id)sender;
- (IBAction)newWindow:(id)sender;
- (IBAction)newTab:(id)sender;
- (IBAction)addShred:(id)sender;
- (IBAction)removeShred:(id)sender;
- (IBAction)replaceShred:(id)sender;
- (IBAction)addOpenDocuments:(id)sender;
- (IBAction)replaceOpenDocuments:(id)sender;
- (IBAction)removeOpenDocuments:(id)sender;
- (IBAction)removeAllShreds:(id)sender;
- (IBAction)removeLastShred:(id)sender;
- (IBAction)setLogLevel:(id)sender;
- (IBAction)openMiniAudicleWebsite:(id)sender;
- (IBAction)hideToolbar:(id)sender;
- (IBAction)hideAllToolbars:(id)sender;
- (IBAction)hideArguments:(id)sender;
- (IBAction)hideAllArguments:(id)sender;
- (IBAction)hideLineNumbers:(id)sender;
- (IBAction)hideAllLineNumbers:(id)sender;
- (IBAction)hideStatusBar:(id)sender;
- (IBAction)hideAllStatusBars:(id)sender;
- (IBAction)tileDocumentWindows:(id)sender;
- (IBAction)doConnectToRemoteVMDialog:(id)sender;
- (IBAction)connectToRemoteVM:(id)sender;
- (IBAction)connectToLocalVM:(id)sender;
- (IBAction)toggleVM:(id)sender;
- (IBAction)setLockdown:(BOOL)_lockdown;
- (BOOL)isInLockdown;
- (IBAction)recordSession:(id)sender;

- (BOOL)validateMenuItem:(NSMenuItem *)menu_item;

@end

#endif // __MINIAUDICLECONTROLLER_H__


