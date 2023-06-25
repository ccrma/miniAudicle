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
// file: miniAudiclePreferencesController.h
// desc: controller class for miniAudicle GUI
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Spring 2006
//-----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class miniAudicleController;

extern NSString * mAPreferencesVersion;

extern NSString * mAPreferencesEnableAudio;
extern NSString * mAPreferencesEnableCallback;
extern NSString * mAPreferencesEnableBlocking;
extern NSString * mAPreferencesEnableStdSystem;
extern NSString * mAPreferencesAudioDriver;
extern NSString * mAPreferencesAudioOutput;
extern NSString * mAPreferencesAudioInput;
extern NSString * mAPreferencesInputChannels; /* -1 indicates highest possible */
extern NSString * mAPreferencesOutputChannels; /* -1 indicates highest possible */
extern NSString * mAPreferencesSampleRate;
extern NSString * mAPreferencesBufferSize;
extern NSString * mAPreferencesVMStallTimeout;

extern NSString * mAPreferencesDefaultFont;
extern NSString * mAPreferencesEnableSyntaxHighlighting;
extern NSString * mAPreferencesTabUsesTab;
extern NSString * mAPreferencesTabWidth;
extern NSString * mAPreferencesEnableSmartIndentation;
extern NSString * mAPreferencesTabKeySmartIndents;

extern NSString * mAPreferencesAutoOpenConsoleMonitor;
extern NSString * mAPreferencesScrollbackBufferSize;
extern NSString * mAPreferencesLogLevel;
extern NSString * mAPreferencesEnableChucKShell;
extern NSString * mAPreferencesDisplayLineNumbers;
extern NSString * mAPreferencesShowArguments;
extern NSString * mAPreferencesShowToolbar;
extern NSString * mAPreferencesShowStatusBar;
extern NSString * mAPreferencesShowTabBar;
extern NSString * mAPreferencesEnableOTFVisuals;
extern NSString * mAPreferencesSoundfilesDirectory;
extern NSString * mAPreferencesOpenDocumentsInNewTab;
extern NSString * mAPreferencesBackupSuffix;
extern NSString * mAPreferencesUseCustomConsoleMonitor;

extern NSString * mAPreferencesLibraryPath;
extern NSString * mAPreferencesChuginPaths;

extern NSString * mASyntaxColoringChangedNotification;
extern NSString * mAPreferencesChangedNotification;

@interface miniAudiclePreferencesController : NSObject
{
    id enable_chuck_shell;
    id log_level;
    id auto_open_console_monitor;
    id scrollback_buffer_size;
    id soundfiles_directory;
    
    id default_font;
    NSFont * default_font_font;
    id enable_syntax_highlighting;
    id syntax_token_type;
    id syntax_color;
    id tab_uses_tab;
    id tab_width;
    id enable_smart_indentation;
    id tab_key_smart_indents;
    
    id enable_audio;
    id accept_network_commands;
    id audio_driver;
    id audio_output;
    id audio_input;
    id output_channels;
    id input_channels;
    id sample_rate;
    id buffer_size;

    id keybindings_table;
    
    id chugin_table;
    
    id preferences_window;
    
    NSMutableDictionary * t_sh_prefs;
    
    NSWindow * warning_dialog;
    
    miniAudicleController * mac;
    
    BOOL vm_options_changed;
    BOOL sc_options_changed;
    
    NSTabView * preferences_tab_view;
    NSText * keybindings_field_editor;
    NSArray * keybindings;
    
    IBOutlet NSButton * enable_chugins;
    NSMutableArray * chugin_paths;
}

- (void)awakeFromNib;
- (void)initDefaults;
- (void)rebuildAudioDriverGUI;
- (void)cancel:(id)sender;
- (void)confirm:(id)sender;
- (void)restoreDefaults:(id)sender;
- (void)run:(id)sender;
- (void)setDefaultFont:(id)sender;
- (void)selectSoundfilesDirectory:(id)sender;
- (void)vmOptionChanged:(id)sender;
- (void)syntaxTokenTypeChanged:(id)sender;
- (void)syntaxColorChanged:(id)sender;
- (void)enableSyntaxHighlightingChanged:(id)sender;
- (void)probeAudioInterfaces:(id)sender;
- (void)selectedAudioDriverChanged:(id)sender;
- (void)selectedAudioOutputChanged:(id)sender;
- (void)selectedAudioInputChanged:(id)sender;

- (IBAction)addChuginPath:(id)sender;
- (IBAction)deleteChuginPath:(id)sender;

@end


