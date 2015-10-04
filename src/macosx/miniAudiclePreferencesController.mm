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
// file: miniAudiclePreferencesController.m
// desc: controller class for miniAudicle GUI
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Spring 2006
//-----------------------------------------------------------------------------

#import "miniAudiclePreferencesController.h"
#import "miniAudicleController.h"
#import "miniAudicle.h"
#import "mASyntaxHighlighter.h"

#import "chuck_dl.h"
#import "util_string.h"


static int sh_tokens[] = 
{ 
    IDEKit_kLangColor_NormalText, 
    IDEKit_kLangColor_Keywords,
    IDEKit_kLangColor_Classes,
    IDEKit_kLangColor_OtherSymbol1,
    IDEKit_kLangColor_Comments,
    IDEKit_kLangColor_Strings,
    IDEKit_kLangColor_Numbers,
    IDEKit_kLangColor_Background,
    IDEKit_kLangColor_End
};

NSString * mAPreferencesEnableAudio = @"EnableAudio";
NSString * mAPreferencesAcceptsNetworkCommands = @"AcceptsNetworkCommands";
NSString * mAPreferencesEnableCallback = @"EnableCallback";
NSString * mAPreferencesEnableBlocking = @"EnableBlocking";
NSString * mAPreferencesEnableStdSystem = @"EnableStdSystem";
NSString * mAPreferencesAudioOutput = @"AudioOutput";
NSString * mAPreferencesAudioInput = @"AudioInput";
NSString * mAPreferencesInputChannels = @"NumberOfInputChannels";
NSString * mAPreferencesOutputChannels = @"NumberOfOutputChannels";
NSString * mAPreferencesSampleRate = @"SampleRate";
NSString * mAPreferencesBufferSize = @"BufferSize";
NSString * mAPreferencesVMStallTimeout = @"VMStallTimeout";

NSString * mAPreferencesDefaultFont = @"DefaultFont";
NSString * mAPreferencesEnableSyntaxHighlighting = @"EnableSyntaxHighlighting";
NSString * mAPreferencesTabUsesTab = @"TabUsesTab";
NSString * mAPreferencesTabWidth = @"TabWidth";
NSString * mAPreferencesEnableSmartIndentation = @"EnableSmartIndentation";
NSString * mAPreferencesTabKeySmartIndents = @"TabKeySmartIndents";

NSString * mAPreferencesAutoOpenConsoleMonitor = @"OpenConsoleMonitor";
NSString * mAPreferencesScrollbackBufferSize = @"ScrollbackBufferSize";
NSString * mAPreferencesEnableChucKShell = @"EnableChucKShell";
NSString * mAPreferencesDisplayLineNumbers = @"ShowLineNumbers";
NSString * mAPreferencesShowArguments = @"ShowArguments";
NSString * mAPreferencesShowToolbar = @"ShowToolbar";
NSString * mAPreferencesShowStatusBar = @"ShowStatusBar";
NSString * mAPreferencesShowTabBar = @"ShowTabBar";
NSString * mAPreferencesEnableOTFVisuals = @"EnableOTFVisuals";
NSString * mAPreferencesLogLevel = @"LogLevel";
NSString * mAPreferencesSoundfilesDirectory = @"SoundfilesDirectory";
NSString * mAPreferencesOpenDocumentsInNewTab = @"OpenDocumentsInNewTab";
NSString * mAPreferencesBackupSuffix = @"BackupSuffix";
NSString * mAPreferencesUseCustomConsoleMonitor = @"UseCustomConsoleMonitor";

NSString * mAPreferencesEnableChugins = @"EnableChugins";
NSString * mAPreferencesLibraryPath = @"LibraryPath";
NSString * mAPreferencesChuginPaths = @"ChuginPaths";

NSString * mASyntaxColoringChangedNotification = @"mASyntaxColoringChanged";
NSString * mAPreferencesChangedNotification = @"mAPreferencesChanged";


t_CKINT g_rtaudio_blacklist_size = 1;
std::string g_rtaudio_blacklist[] = { "Apple Inc.: AirPlay" };



@implementation miniAudiclePreferencesController

- (id)init
{
    if( self = [super init] )
    {
        [[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately:NO];
        
        NSMutableDictionary * defaults = [[[NSMutableDictionary alloc] init] autorelease];
        
        [defaults setObject:[NSNumber numberWithInt:NSOnState] forKey:mAPreferencesEnableAudio];
        [defaults setObject:[NSNumber numberWithInt:-1] forKey:mAPreferencesAudioInput];
        [defaults setObject:[NSNumber numberWithInt:-1] forKey:mAPreferencesAudioOutput];
        
        // -1 means the maximum number of channels available
        [defaults setObject:[NSNumber numberWithInt:2] forKey:mAPreferencesInputChannels];
        [defaults setObject:[NSNumber numberWithInt:2] forKey:mAPreferencesOutputChannels];
        
        [defaults setObject:[NSNumber numberWithInt:44100] forKey:mAPreferencesSampleRate];
        [defaults setObject:[NSNumber numberWithInt:256] forKey:mAPreferencesBufferSize];
        
        [defaults setObject:[NSNumber numberWithFloat:2.0] forKey:mAPreferencesVMStallTimeout];
        
        [defaults setObject:[NSNumber numberWithInt:2] forKey:mAPreferencesLogLevel];
        [defaults setObject:[NSNumber numberWithInt:100000] forKey:mAPreferencesScrollbackBufferSize];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesAutoOpenConsoleMonitor];
        [defaults setObject:[@"~/" stringByExpandingTildeInPath] forKey:mAPreferencesSoundfilesDirectory];
        [defaults setObject:[NSNumber numberWithInt:NSOffState] forKey:mAPreferencesAcceptsNetworkCommands];
        [defaults setObject:@"-backup" forKey:mAPreferencesBackupSuffix];
        if(NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max)
            // OS X 10.11 and greater
            [defaults setObject:[NSNumber numberWithBool:NO] forKey:mAPreferencesUseCustomConsoleMonitor];
        else
            [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesUseCustomConsoleMonitor];
        
        /* set up default syntax highlighting */
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesEnableSyntaxHighlighting];
        NSMutableDictionary * default_sh = [[[NSMutableDictionary alloc] init] autorelease];
        [default_sh setObject:@"#ffffff" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Background )];
        [default_sh setObject:@"#000000" forKey:IDEKit_NameForColor( IDEKit_kLangColor_NormalText )];
        [default_sh setObject:@"#0000ff" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Keywords )];
        [default_sh setObject:@"#800023" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Classes )];
        [default_sh setObject:@"#A200EC" forKey:IDEKit_NameForColor( IDEKit_kLangColor_OtherSymbol1 )];
        [default_sh setObject:@"#609010" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Comments )];
        [default_sh setObject:@"#404040" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Strings )];
        [default_sh setObject:@"#D48010" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Numbers )];
        [defaults setObject:default_sh forKey:IDEKit_TextColorsPrefKey];
        
        NSArchiver * ar = [[[NSArchiver alloc] initForWritingWithMutableData:[[NSMutableData new] autorelease]] autorelease];
        default_font_font = [[NSFont fontWithName:@"Monaco" size:13] retain];
        [default_font_font encodeWithCoder:ar];
        [defaults setObject:[ar archiverData] forKey:mAPreferencesDefaultFont];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:mAPreferencesTabUsesTab];
        [defaults setObject:[NSNumber numberWithInt:4] forKey:mAPreferencesTabWidth];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesEnableSmartIndentation];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesTabKeySmartIndents];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesDisplayLineNumbers];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesShowArguments];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesShowToolbar];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesShowStatusBar];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesEnableOTFVisuals];
        
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesShowTabBar];
        [defaults setObject:[NSNumber numberWithInt:0] forKey:mAPreferencesOpenDocumentsInNewTab];
        
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesEnableChugins];
        
        std::list<std::string> default_chugin_pathv;
        std::string path_list = g_default_chugin_path;
        parse_path_list(path_list, default_chugin_pathv);
        NSMutableArray * chugin_path_array = [NSMutableArray arrayWithCapacity:default_chugin_pathv.size()];
        for(std::list<std::string>::iterator i = default_chugin_pathv.begin();
            i != default_chugin_pathv.end(); i++)
        {
            [chugin_path_array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithUTF8String:i->c_str()], @"location", 
                                          @"folder", @"type", nil]];
        }
        
        [defaults setObject:chugin_path_array forKey:mAPreferencesChuginPaths];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        
        // spencer: 0.2.3: add extra syntax color keys if missing
        NSDictionary * actualSH = [[NSUserDefaults standardUserDefaults] objectForKey:IDEKit_TextColorsPrefKey];
        NSMutableDictionary * newSH = nil;
        if([actualSH objectForKey:IDEKit_NameForColor( IDEKit_kLangColor_Classes )] == nil)
        {
            if(newSH == nil) newSH = [NSMutableDictionary dictionaryWithDictionary:actualSH];
            [newSH setObject:@"#800023" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Classes )];
        }
        if([actualSH objectForKey:IDEKit_NameForColor( IDEKit_kLangColor_OtherSymbol1 )] == nil)
        {
            if(newSH == nil) newSH = [NSMutableDictionary dictionaryWithDictionary:actualSH];
            [newSH setObject:@"#A200EC" forKey:IDEKit_NameForColor( IDEKit_kLangColor_OtherSymbol1 )];
        }
        if(newSH != nil)
            [[NSUserDefaults standardUserDefaults] setObject:newSH forKey:IDEKit_TextColorsPrefKey];
        
        // TODO: apparently this needs to happen before awakeFromNib
        [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
        
        /*  miniAudicle 0.1.3.0 and below accidentally set the default background 
            color to black; since the background wasnt actually colored in these 
            versions, this got through to releases.  Now, in version 0.1.3.3 and 
            above, the background is colored.  So, later versions of miniAudicle
            will have this code to wipe out the background color setting if and only 
            if the miniAudicle.plist settings have a value for the background color, 
            but not the class color.  The class color key was introduced in 0.1.3.3,
            so its non-existence indicates that the most recent version of 
            miniAudicle before may have been 0.1.3.0 or below, and thus may have a 
            black background color.  
            
            Essentially, if the following few lines were not included, people 
            upgrading from 0.1.3.2 and below to 0.1.3.3 and above could get black
            document windows by default when they first start up the new version. */
        
        NSDictionary * user_sh = [[NSUserDefaults standardUserDefaults] objectForKey:IDEKit_TextColorsPrefKey];
        NSString * class_color = [user_sh objectForKey:IDEKit_NameForColor( IDEKit_kLangColor_Classes )];
        if( !class_color )
        {
            NSMutableDictionary * new_sh = [[[NSMutableDictionary alloc] init] autorelease];
            [new_sh addEntriesFromDictionary:user_sh];
            [new_sh setObject:@"ffffff" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Background )];
            [[NSUserDefaults standardUserDefaults] setObject:new_sh forKey:IDEKit_TextColorsPrefKey];
        }
    }
    
    return self;
}
    
- (void)loadGUIFromDefaults
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSUnarchiver * uar = [[[NSUnarchiver alloc] initForReadingWithData:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesDefaultFont]] autorelease];
    [default_font_font release];
    default_font_font = [[NSFont alloc] initWithCoder:uar];

    [enable_audio setState:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableAudio] intValue]];
    [output_channels setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesOutputChannels] intValue]];
    [input_channels setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesInputChannels] intValue]];
    [accept_network_commands setState:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAcceptsNetworkCommands] intValue]];
    [buffer_size selectItemAtIndex:[buffer_size indexOfItemWithTag:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesBufferSize] intValue]]];
    
    [log_level selectItemAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesLogLevel] intValue]];
    [auto_open_console_monitor setState:( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAutoOpenConsoleMonitor] boolValue] ) ? NSOnState : NSOffState];
    [scrollback_buffer_size setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesScrollbackBufferSize] intValue]];
    [soundfiles_directory setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSoundfilesDirectory]];
    
    [default_font setStringValue:[NSString stringWithFormat:@"%s - %.1f pt", 
        [[default_font_font displayName] UTF8String], [default_font_font pointSize]]];
    [tab_uses_tab setState:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesTabUsesTab] boolValue]];
    [tab_width setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesTabWidth] intValue]];
    [enable_smart_indentation setState:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableSmartIndentation] boolValue]];
    [tab_key_smart_indents setState:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesTabKeySmartIndents] boolValue]];
    
    [t_sh_prefs setDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:IDEKit_TextColorsPrefKey]];
    [self syntaxTokenTypeChanged:[syntax_token_type selectedItem]];
    [enable_syntax_highlighting setState:[[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableSyntaxHighlighting] boolValue]];
    [self enableSyntaxHighlightingChanged:nil];
    
    [enable_chugins setState:[[defaults objectForKey:mAPreferencesEnableChugins] boolValue] ? NSOnState : NSOffState];
    
    [chugin_paths release];
    chugin_paths = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:mAPreferencesChuginPaths]];
    [chugin_table reloadData];
    
    [self probeAudioInterfaces:nil];
}

- (void)loadMiniAudicleFromGUI
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    // enable audio
    if( [enable_audio state] != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableAudio] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[enable_audio state]
                                                   forKey:mAPreferencesEnableAudio];
        [mac miniAudicle]->set_enable_audio( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableAudio] intValue] == NSOnState );
    }
    
    // dac
    [[NSUserDefaults standardUserDefaults] setInteger:[[audio_output selectedItem] tag]
                                               forKey:mAPreferencesAudioOutput];
    [mac miniAudicle]->set_dac( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioOutput] intValue] + 1 );
    
    // adc
    [[NSUserDefaults standardUserDefaults] setInteger:[[audio_input selectedItem] tag]
                                               forKey:mAPreferencesAudioInput];
    [mac miniAudicle]->set_adc( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioInput] intValue] + 1 );
    
    // output channels
    [[NSUserDefaults standardUserDefaults] setInteger:[output_channels indexOfSelectedItem] + 1
                                               forKey:mAPreferencesOutputChannels];
    [mac miniAudicle]->set_num_outputs( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesOutputChannels] intValue] );
    
    // input channels
    [[NSUserDefaults standardUserDefaults] setInteger:[input_channels indexOfSelectedItem] + 1
                                               forKey:mAPreferencesInputChannels];
    [mac miniAudicle]->set_num_inputs( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesInputChannels] intValue] );
    
    // sample rate
    [[NSUserDefaults standardUserDefaults] setInteger:[[sample_rate titleOfSelectedItem] intValue]
                                               forKey:mAPreferencesSampleRate];
    [mac miniAudicle]->set_sample_rate( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSampleRate] intValue] );
    
    // audio buffer size
    [[NSUserDefaults standardUserDefaults] setInteger:[[buffer_size selectedItem] tag]
                                               forKey:mAPreferencesBufferSize];
    [mac miniAudicle]->set_buffer_size( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesBufferSize] intValue] );
    
    // log level
    if( [log_level indexOfSelectedItem] != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesLogLevel] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[log_level indexOfSelectedItem] 
                                                   forKey:mAPreferencesLogLevel];
        [mac miniAudicle]->set_log_level( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesLogLevel] intValue] );
    }
    
    // scrollback buffer size
    if( [scrollback_buffer_size intValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesScrollbackBufferSize] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[scrollback_buffer_size intValue] 
                                                   forKey:mAPreferencesScrollbackBufferSize];
    }
    
    // console monitor auto-open
    if( [auto_open_console_monitor state] != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAutoOpenConsoleMonitor] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:( [auto_open_console_monitor state] == NSOnState)
                                                forKey:mAPreferencesAutoOpenConsoleMonitor];
    }
    
    // network thread
    if( [accept_network_commands state] != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAcceptsNetworkCommands] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[accept_network_commands state]
                                                   forKey:mAPreferencesAcceptsNetworkCommands];
        [mac miniAudicle]->set_enable_network_thread( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAcceptsNetworkCommands] intValue] == NSOnState );
    }
    
    // tab uses tabs
    if( ( [tab_uses_tab state] == NSOnState )!= [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesTabUsesTab] boolValue] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:( [tab_uses_tab state] == NSOnState )
                                                forKey:mAPreferencesTabUsesTab];
    }
    
    // tab width
    if( [tab_width intValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesTabWidth] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[tab_width intValue]
                                                   forKey:mAPreferencesTabWidth];
    }
    
    // smart indentation
    if( ( [enable_smart_indentation state] == NSOnState )!= [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableSmartIndentation] boolValue] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:( [enable_smart_indentation state] == NSOnState )
                                                forKey:mAPreferencesEnableSmartIndentation];
    }
    
    // tab key smart indents
    if( ( [tab_key_smart_indents state] == NSOnState )!= [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesTabKeySmartIndents] boolValue] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:( [tab_key_smart_indents state] == NSOnState )
                                                forKey:mAPreferencesTabKeySmartIndents];
    }
        
    // current directory
    // dont compare the current default to the new default; save a string comparison
    [[NSUserDefaults standardUserDefaults] setObject:[[soundfiles_directory stringValue] stringByExpandingTildeInPath] forKey:mAPreferencesSoundfilesDirectory];
    chdir( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSoundfilesDirectory] UTF8String] );        
    
    // default font
    // dont compare the new default to the old default; that takes too long
    NSArchiver * ar = [[[NSArchiver alloc] initForWritingWithMutableData:[[NSMutableData new] autorelease]] autorelease];
    [default_font_font encodeWithCoder:ar];
    [[NSUserDefaults standardUserDefaults] setObject:[ar archiverData] forKey:mAPreferencesDefaultFont];
    
    // enable syntax coloring
    if( ( [enable_syntax_highlighting state] == NSOnState ) != [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableSyntaxHighlighting] intValue] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:( [enable_syntax_highlighting state] == NSOnState )
                                                forKey:mAPreferencesEnableSyntaxHighlighting];
    }
    
    // syntax colors
    [[NSUserDefaults standardUserDefaults] setObject:t_sh_prefs forKey:IDEKit_TextColorsPrefKey];
    
    //*/
    
    [defaults setObject:[NSNumber numberWithBool:([enable_chugins state] == NSOnState ? YES : NO)]
                 forKey:mAPreferencesEnableChugins];
    
    [defaults setObject:chugin_paths forKey:mAPreferencesChuginPaths];
    
    list<string> library_paths;
    list<string> named_chugins;
    if([[defaults objectForKey:mAPreferencesEnableChugins] boolValue])
    {
        NSArray * obj_library_paths = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesChuginPaths];
        for(int i = 0; i < [obj_library_paths count]; i++)
        {
            NSDictionary * path = [obj_library_paths objectAtIndex:i];
            if([[path objectForKey:@"type"] isEqualToString:@"chugin"])
                named_chugins.push_back([[path objectForKey:@"location"] UTF8String]);
            else if([[path objectForKey:@"type"] isEqualToString:@"folder"])
                library_paths.push_back([[path objectForKey:@"location"] UTF8String]);
        }
        
        // add bundle chugin path
        NSString * bundle_chugin_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ChuGins"];
        library_paths.push_back([bundle_chugin_path UTF8String]);
    }
    // load empty chugin lists to disable chugins
    
    [mac miniAudicle]->set_library_paths(library_paths);
    [mac miniAudicle]->set_named_chugins(named_chugins);
                         
    [[NSNotificationCenter defaultCenter] postNotificationName:mAPreferencesChangedNotification
                                                        object:self];

}

- (void)awakeFromNib
{
    NSMenuItem * mi;
    int i;

    [syntax_token_type removeAllItems];
    
    for( i = 0; sh_tokens[i] != IDEKit_kLangColor_End; i++ )
    {
        mi = [[NSMenuItem alloc] initWithTitle:IDEKit_NameForColor( sh_tokens[i] )
                                         action:@selector( syntaxTokenTypeChanged: )
                                  keyEquivalent:@""];
        [mi autorelease];
        [mi setTarget:self];
        [mi setTag:sh_tokens[i]];
        [[syntax_token_type menu] addItem:mi];
    }
        
    t_sh_prefs = [[NSMutableDictionary alloc] init];
    sc_options_changed = NO;
    
    [preferences_window center];
    [preferences_tab_view selectFirstTabViewItem:self];
    
    //[keybindings_table setAutoresizesOutlineColumn:NO];
    
    [self initDefaults];
}

- (void)dealloc
{
    [t_sh_prefs release];
    [default_font_font release];
    [keybindings_field_editor release];
    [keybindings release];
    [chugin_paths release];
    [super dealloc];
}

- (void)initDefaults
// TODO: verify audio interface defaults to make sure they are still valid
{    
    /* set miniAudicle parameters */
    
    miniAudicle * ma = [mac miniAudicle];
    ma->set_log_level( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesLogLevel] intValue] );
    ma->set_dac( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioOutput] intValue] + 1 );
    ma->set_adc( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioInput] intValue] + 1 );
    ma->set_num_inputs( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesInputChannels] intValue] );
    ma->set_num_outputs( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesOutputChannels] intValue] );
    ma->set_sample_rate( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSampleRate] intValue] );    
    ma->set_buffer_size( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesBufferSize] intValue] );
    ma->set_enable_audio( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableAudio] intValue] == NSOnState);
    ma->set_enable_network_thread( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAcceptsNetworkCommands] intValue] == NSOnState );
    chdir( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSoundfilesDirectory] cString] );
    
    list< string > library_paths;
    list< string > named_chugins;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableChugins] boolValue])
    {
        NSArray * obj_library_paths = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesChuginPaths];
        for(int i = 0; i < [obj_library_paths count]; i++)
        {
            NSDictionary * path = [obj_library_paths objectAtIndex:i];
            if([[path objectForKey:@"type"] isEqualToString:@"chugin"])
                named_chugins.push_back([[path objectForKey:@"location"] UTF8String]);
            else if([[path objectForKey:@"type"] isEqualToString:@"folder"])
                library_paths.push_back([[path objectForKey:@"location"] UTF8String]);
        }
        
        NSString * bundle_chugin_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ChuGins"];
        library_paths.push_back([bundle_chugin_path UTF8String]);
    }

    ma->set_library_paths(library_paths);
    ma->set_named_chugins(named_chugins);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mAPreferencesChangedNotification
                                                        object:self];
}

- (void)cancel:(id)sender
{
    [chugin_paths autorelease];
    chugin_paths = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:mAPreferencesChuginPaths]];
    [chugin_table reloadData];
    
    [preferences_window close];
    [[NSFontPanel sharedFontPanel] close];
    [[NSColorPanel sharedColorPanel] close];
        
    [[NSUserDefaultsController sharedUserDefaultsController] revert:sender];
}

- (void)confirm:(id)sender
{    
    [preferences_window close];
    [[NSFontPanel sharedFontPanel] close];
    [[NSColorPanel sharedColorPanel] close];
    
    [self loadMiniAudicleFromGUI];
    
    if( sc_options_changed )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:mASyntaxColoringChangedNotification
                                                            object:self];
        sc_options_changed = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mAPreferencesChangedNotification
                                                        object:self];
    
    [( NSUserDefaultsController * )[NSUserDefaultsController sharedUserDefaultsController] save:sender];
}

- (void)restoreDefaults:(id)sender
{
    [[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:sender];
    [( NSUserDefaultsController * )[NSUserDefaultsController sharedUserDefaultsController] save:sender];

    [preferences_window makeFirstResponder:preferences_window];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"org.miniAudicle.miniAudicle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self syntaxTokenTypeChanged:[syntax_token_type selectedItem]];
    [self loadGUIFromDefaults];
    [self loadMiniAudicleFromGUI];
    sc_options_changed = YES;
}

- (void)run:(id)sender
{
    [self loadGUIFromDefaults];
    [preferences_window makeKeyAndOrderFront:nil];
}

- (void)setDefaultFont:(id)sender
{
    [[NSFontPanel sharedFontPanel] setPanelFont:default_font_font isMultiple:NO];
    [[NSFontPanel sharedFontPanel] makeKeyAndOrderFront:sender];
}

- (void)changeFont:(id)sender
{
    //NSUnarchiver * uar = [[[NSUnarchiver alloc] initForReadingWithData:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesDefaultFont]] autorelease];
    //NSFont * f = [[[NSFont alloc] initWithCoder:uar] autorelease];
    default_font_font = [[sender convertFont:[default_font_font autorelease]] retain];
    [default_font setStringValue:[NSString stringWithFormat:@"%s - %.1f pt", 
        [[default_font_font displayName] UTF8String], [default_font_font pointSize]]];
}

- (void)selectSoundfilesDirectory:(id)sender
{
    NSOpenPanel * op = [NSOpenPanel openPanel];
    [op setCanChooseFiles:NO];
    [op setCanChooseDirectories:YES];
    [op setCanCreateDirectories:YES];
    [op setAllowsMultipleSelection:NO];
    
    [op beginSheetForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSoundfilesDirectory]
                          file:nil types:nil
                modalForWindow:preferences_window
                 modalDelegate:self
                didEndSelector:@selector( openPanelDidEnd:returnCode:contextInfo: )
                   contextInfo:( void * ) 1];
}

- (void)openPanelDidEnd:(NSOpenPanel *)op
             returnCode:(int)returnCode
            contextInfo:(void *)contextInfo
{
    // 1.2.2: changed (int) to (long)
    if( (long)contextInfo == 1 && returnCode == NSOKButton )
    {
        NSString * filename = [op filename];
        if( filename != nil )
            [soundfiles_directory setStringValue:[filename stringByExpandingTildeInPath]];
    }
}

- (void)vmOptionChanged:(id)sender
{
    //[vm_changes_text setHidden:FALSE];
}

- (void)syntaxTokenTypeChanged:(id)sender
{
    [syntax_color setColor:[NSColor colorWithHTML:[t_sh_prefs objectForKey:IDEKit_NameForColor( [sender tag] )]]];
}

- (void)syntaxColorChanged:(id)sender
{
    [t_sh_prefs setObject:[[sender color] htmlString]
                   forKey:IDEKit_NameForColor( [[syntax_token_type selectedItem] tag] )];
    
    sc_options_changed = YES;
}

- (void)enableSyntaxHighlightingChanged:(id)sender
{
    sc_options_changed = YES;
    
    if( [enable_syntax_highlighting state] == NSOffState )
    {
        [syntax_token_type setEnabled:NO];
        [syntax_color setEnabled:NO];
    }
    
    else
    {
        [syntax_token_type setEnabled:YES];
        [syntax_color setEnabled:YES];
    }
}

- (void)probeAudioInterfaces:(id)sender
{
    [mac miniAudicle]->probe();
    
    const vector< RtAudio::DeviceInfo > & interfaces = [mac miniAudicle]->get_interfaces();
    vector< RtAudio::DeviceInfo >::size_type i, len = interfaces.size();
    
    [audio_output removeAllItems];
    [audio_input removeAllItems];

    int dac = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioOutput] intValue];
    int adc = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioInput] intValue];
    
    // load available audio I/O interfaces into the pop up menus
    for( i = 0; i < len; i++ )
    {
        t_CKBOOL blacklist = FALSE;
        
        for(int j = 0; j < g_rtaudio_blacklist_size; j++)
        {
            if(interfaces[i].name == g_rtaudio_blacklist[j])
            {
                blacklist = TRUE;
                break;
            }
        }
        
        if(!blacklist)
        {
            if( interfaces[i].outputChannels > 0 || interfaces[i].duplexChannels > 0 )
            {
                [audio_output addItemWithTitle:[NSString stringWithUTF8String:interfaces[i].name.c_str()]];
                [[audio_output lastItem] setTag:i];
                if( i == dac )
                    [audio_output selectItem:[audio_output lastItem]];
            }
            
            if( interfaces[i].inputChannels > 0 || interfaces[i].duplexChannels > 0 )
            {
                [audio_input addItemWithTitle:[NSString stringWithUTF8String:interfaces[i].name.c_str()]];
                [[audio_input lastItem] setTag:i];
                if( i == adc )
                    [audio_input selectItem:[audio_input lastItem]];
            }
        }
    }
    
    [self selectedAudioOutputChanged:nil];
    [self selectedAudioInputChanged:nil];
}

- (void)selectedAudioOutputChanged:(id)sender
{
    const vector< RtAudio::DeviceInfo > & interfaces = [mac miniAudicle]->get_interfaces();

    vector< RtAudio::DeviceInfo >::size_type selected_output = [[audio_output selectedItem] tag];
    
    vector< int >::size_type j, sr_len = interfaces[selected_output].sampleRates.size();
    
    [output_channels removeAllItems];    
    [sample_rate removeAllItems];
    
    // load available sample rates into the pop up menu
    int default_sample_rate = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSampleRate] intValue];
    for( j = 0; j < sr_len; j++ )
    {
        [sample_rate addItemWithTitle:[NSString stringWithFormat:@"%i", 
            interfaces[selected_output].sampleRates[j] ]];
        
        // select the default sample rate
        if( interfaces[selected_output].sampleRates[j] == default_sample_rate )
            [sample_rate selectItem:[sample_rate lastItem]];
    }
    
    // load available numbers of channels into respective pop up buttons
    int k, num_channels;
    
    num_channels = interfaces[selected_output].outputChannels;
    for( k = 0; k < num_channels; k++ )
        [output_channels addItemWithTitle:[NSString stringWithFormat:@"%i", k + 1]];
    
    int default_output_channels = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesOutputChannels] intValue];
    if( default_output_channels == -1 || default_output_channels > num_channels )
        /* default is to use as many channels as possible */
        [output_channels selectItem:[output_channels lastItem]];
    else
        [output_channels selectItemAtIndex:( default_output_channels - 1 )];
}

- (void)selectedAudioInputChanged:(id)sender
{
    const vector< RtAudio::DeviceInfo > & interfaces = [mac miniAudicle]->get_interfaces();
    
    vector< RtAudio::DeviceInfo >::size_type selected_input = [[audio_input selectedItem] tag];
    
    [input_channels removeAllItems];
    
    // load available numbers of channels into respective pop up buttons
    int k, num_channels;
    
    num_channels = interfaces[selected_input].inputChannels;
    for( k = 0; k < num_channels; k++ )
        [input_channels addItemWithTitle:[NSString stringWithFormat:@"%i", k + 1]];
    
    int default_input_channels = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesInputChannels] intValue];
    if( default_input_channels == -1 || default_input_channels > num_channels )
        /* default is to use as many channels as possible */
        [input_channels selectItem:[input_channels lastItem]];
    else
        [input_channels selectItemAtIndex:( default_input_channels - 1 )];
}

- (id)windowWillReturnFieldEditor:(NSWindow *)w toObject:(id)object
{
    
    if( [object tag] == 1 )
        return keybindings_field_editor;
    else
        return nil;
}


- (IBAction)addChuginPath:(id)sender
{
    [chugin_paths addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"", @"location", 
                             @"", @"type", 
                             nil]];
 
    [chugin_table reloadData];
    
    [chugin_table editColumn:1
                         row:[chugin_paths count]-1
                   withEvent:nil
                      select:YES];
}


- (IBAction)deleteChuginPath:(id)sender
{
    NSIndexSet *selected = [chugin_table selectedRowIndexes];
    NSUInteger i = [selected lastIndex];
    do
    {
        [chugin_table deselectRow:i];
        [[[chugin_paths objectAtIndex:i] retain] autorelease];
        [chugin_paths removeObjectAtIndex:i];
    }
    while((i = [selected indexLessThanIndex:i]) != NSNotFound);
    
    [chugin_table reloadData];
}


/* NSOutlineViewDataSource implementation */
#pragma mark NSOutlineViewDataSource implementation

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if(item == nil)
    {
        return [chugin_paths objectAtIndex:index];
    }
        
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(item == nil)
        return [chugin_paths count];
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    if([[tableColumn identifier] isEqualToString:@"type"])
    {
        if([[item objectForKey:@"type"] isEqualToString:@"folder"])
            return [NSImage imageNamed:@"folder"];
        else if([[item objectForKey:@"type"] isEqualToString:@"chugin"])
            return [NSImage imageNamed:@"chugin-mini.png"];
        else 
            return nil;
    }
    else if([[tableColumn identifier] isEqualToString:@"location"])
    {
        return [item objectForKey:@"location"];
    }
    
    return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn
               item:(id)item
{
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object 
     forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    [outlineView deselectRow:[outlineView rowForItem:item]];
    
    if([[tableColumn identifier] isEqualToString:@"location"])
    {
        if(![object isEqualToString:@""])
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            BOOL isDirectory = NO;
            BOOL exists = [fileManager fileExistsAtPath:object 
                                            isDirectory:&isDirectory];
            if(!exists) isDirectory = NO;
            
            if(isDirectory || (!exists && ![[object pathExtension] isEqualToString:@"chug"]))
            {
                [item setObject:@"folder" forKey:@"type"];
            }
            else
            {
                [item setObject:@"chugin" forKey:@"type"];
            }
            
            [item setObject:object forKey:@"location"];
        }
        
        if([[item objectForKey:@"location"] isEqualToString:@""])
        {
            [chugin_paths removeObject:item];
        }        
        
        [chugin_table reloadData];
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return YES;
}


@end
