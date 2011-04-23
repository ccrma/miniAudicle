/*----------------------------------------------------------------------------
miniAudicle
Cocoa GUI to chuck audio programming environment

Copyright (c) 2005 Spencer Salazar.  All rights reserved.
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
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Spring 2006
//-----------------------------------------------------------------------------

#import "miniAudiclePreferencesController.h"
#import "miniAudicleController.h"
#import "miniAudicle.h"
#import "mASyntaxHighlighter.h"

static int sh_tokens[] = 
{ 
    IDEKit_kLangColor_NormalText, 
    IDEKit_kLangColor_Keywords,
//    IDEKit_kLangColor_Classes,
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
NSString * mAPreferencesEnableOTFVisuals = @"EnableOTFVisuals";
NSString * mAPreferencesLogLevel = @"LogLevel";
NSString * mAPreferencesSoundfilesDirectory = @"SoundfilesDirectory";
NSString * mAPreferencesBackupSuffix = @"BackupSuffix";

NSString * mAPreferencesLibraryPath = @"LibraryPath";
NSString * mAPreferencesChuginPaths = @"ChuginPaths";

NSString * mASyntaxColoringChangedNotification = @"mASyntaxColoringChanged";
NSString * mAPreferencesChangedNotification = @"mAPreferencesChanged";

@interface mAKeyBindingsRecord : NSObject
{
    NSMenuItem * menu_item;
    NSString * title;
    NSString * printed_key_equivalent;
    NSArray * children;
}

+ (NSArray *)createFromMainMenu;
- (id)initWithMenuItem:(NSMenuItem *)mi;
- (id)initWithMenuItem:(NSMenuItem *)mi
  printedKeyEquivalent:(NSString *)pke
              children:(NSArray *)c;
- (NSMenuItem *)menuItem;
- (NSString *)title;
- (NSString *)printedKeyEquivalent;
- (int)numberOfChildren;
- (mAKeyBindingsRecord *)childAtIndex:(int)index;

@end

@implementation mAKeyBindingsRecord

+ (NSArray *)createFromMainMenu
{
    NSMutableArray * c = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray * submenu_items = [[NSApp mainMenu] itemArray];
    for( int i = 0; i < [submenu_items count]; i++ )
    {
        NSMenuItem * child = [submenu_items objectAtIndex:i];
        if( ![child isSeparatorItem] )
            [c addObject:[[[mAKeyBindingsRecord alloc] initWithMenuItem:child] autorelease]];
    }
    
    return [NSArray arrayWithArray:c];
}

- (id)initWithMenuItem:(NSMenuItem *)mi
{
    if( self = [super init] )
    {
        menu_item = [mi retain];
        
        if( [menu_item menu] == [NSApp mainMenu] &&
            [[menu_item title] isEqualToString:@""] )
            // application menu
            title = [@"miniAudicle" retain];
        else
            title = [[menu_item title] retain];
        
        if( [[menu_item keyEquivalent] isEqualToString:@""] )
            printed_key_equivalent = [@"" retain];
        else
        {
            NSMutableString * pke = [[[NSMutableString alloc] init] autorelease];
            if( [menu_item keyEquivalentModifierMask] & NSCommandKeyMask )
                [pke appendString:[NSString stringWithUTF8String:"\u2318"]];
            if( [menu_item keyEquivalentModifierMask] & NSAlternateKeyMask )
                [pke appendString:[NSString stringWithUTF8String:"\u2325"]];
            if( [menu_item keyEquivalentModifierMask] & NSControlKeyMask )
                [pke appendString:[NSString stringWithUTF8String:"\u2303"]];
            if( [menu_item keyEquivalentModifierMask] & NSShiftKeyMask )
                [pke appendString:[NSString stringWithUTF8String:"\u21E7"]];
            
            NSString * key_equivalent = [menu_item keyEquivalent];
            if( [key_equivalent rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound )
                [pke appendString:[NSString stringWithUTF8String:"\u21E7"]];
            
            [pke appendString:[key_equivalent uppercaseString]];
            printed_key_equivalent = [[NSString stringWithString:pke] retain];
        }
            
        if( [menu_item hasSubmenu] )
        {
            NSMutableArray * c = [[[NSMutableArray alloc] init] autorelease];
            NSArray * submenu_items = [[menu_item submenu] itemArray];
            for( int i = 0; i < [submenu_items count]; i++ )
            {
                NSMenuItem * child = [submenu_items objectAtIndex:i];
                if( ![child isSeparatorItem] )
                    [c addObject:[[[mAKeyBindingsRecord alloc] initWithMenuItem:child] autorelease]];
            }
            
            children = [[NSArray arrayWithArray:c] retain];
        }
    }
    
    return self;
}

- (id)initWithMenuItem:(NSMenuItem *)mi
  printedKeyEquivalent:(NSString *)pke
              children:(NSArray *)c
{
    if( self = [super init] )
    {
        menu_item = [mi retain];
        printed_key_equivalent = [pke retain];
        if( c != nil )
            children = [c retain];
        else
            children = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [menu_item release];
    [title release];
    [printed_key_equivalent release];
    if( children != nil )
        [children release];
    
    [super dealloc];
}

- (NSMenuItem *)menuItem
{
    return menu_item;
}

- (NSString *)title
{
    return title;
}

- (NSString *)printedKeyEquivalent
{
    return printed_key_equivalent;
}

- (int)numberOfChildren
{
    if( children == nil )
        return 0;
    else
        return [children count];
}

- (mAKeyBindingsRecord *)childAtIndex:(int)index
{
    if( children != nil )
        return [children objectAtIndex:index];
    else
        return nil;
}

@end

@interface mAKeyBindingsFieldEditor : NSTextView
{
    NSCharacterSet * newlines;
    BOOL ignoreFlagsChanged;
}

@end

@implementation mAKeyBindingsFieldEditor

- (void)becomeFirstResponder
{
    ignoreFlagsChanged = NO;
}

- (void)adjustTextFromEvent:(NSEvent *)e
{
    BOOL command_key = NO,
        alt_key = NO,
        control_key = NO,
        shift_key = NO;
    
    if( [e modifierFlags] & NSCommandKeyMask )
        command_key = YES;
    if( [e modifierFlags] & NSAlternateKeyMask )
        alt_key = YES;
    if( [e modifierFlags] & NSControlKeyMask )
        control_key = YES;
    if( [e modifierFlags] & NSShiftKeyMask )
        shift_key = YES;
    
    NSString * key = nil;
    
    if( [e type] == NSKeyDown )
    {
        NSString * key_equivalent = [e charactersIgnoringModifiers];
        
        if( [key_equivalent rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound )
            shift_key = YES;
        else if( [key_equivalent rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound )
            shift_key = NO;
        
        key = [key_equivalent uppercaseString];
        ignoreFlagsChanged = YES;
        
        [self selectAll:nil];
    }
    
    NSMutableString * pke = [[[NSMutableString alloc] init] autorelease];
    
    if( command_key )
        [pke appendString:[NSString stringWithUTF8String:"\u2318"]];
    if( alt_key )
        [pke appendString:[NSString stringWithUTF8String:"\u2325"]];
    if( control_key )
        [pke appendString:[NSString stringWithUTF8String:"\u2303"]];
    if( shift_key )
        [pke appendString:[NSString stringWithUTF8String:"\u21E7"]];
    if( key != nil )
        [pke appendString:key];
    
    [self setString:pke];
}

- (void)keyDown:(NSEvent *)e
{
    if( [[e characters] characterAtIndex:0] == NSNewlineCharacter || 
        [[e characters] characterAtIndex:0] == NSEnterCharacter )
        [[self window] makeFirstResponder:nil];
    else
        [self adjustTextFromEvent:e];
}

- (void)keyUp:(NSEvent *)e
{
    
}

- (void)flagsChanged:(NSEvent *)e
{
    if( !ignoreFlagsChanged )
        [self adjustTextFromEvent:e];
    if( ( [e modifierFlags] & ( NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask ) ) == 0 )
        ignoreFlagsChanged = NO;
}

- (BOOL)performKeyEquivalent:(NSEvent *)e
{
    if( [[e characters] characterAtIndex:0] == NSNewlineCharacter || 
        [[e characters] characterAtIndex:0] == NSEnterCharacter )
        [[self window] makeFirstResponder:nil];
    else
        [self adjustTextFromEvent:e];

    return YES;
}

@end

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
        
        [defaults setObject:[NSNumber numberWithFloat:1.0] forKey:mAPreferencesVMStallTimeout];
        
        [defaults setObject:[NSNumber numberWithInt:2] forKey:mAPreferencesLogLevel];
        [defaults setObject:[NSNumber numberWithInt:100000] forKey:mAPreferencesScrollbackBufferSize];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesAutoOpenConsoleMonitor];
        [defaults setObject:[@"~/" stringByExpandingTildeInPath] forKey:mAPreferencesSoundfilesDirectory];
        [defaults setObject:[NSNumber numberWithInt:NSOffState] forKey:mAPreferencesAcceptsNetworkCommands];
        [defaults setObject:@"-backup" forKey:mAPreferencesBackupSuffix];
        
        /* set up default syntax highlighting */
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:mAPreferencesEnableSyntaxHighlighting];
        NSMutableDictionary * default_sh = [[[NSMutableDictionary alloc] init] autorelease];
        [default_sh setObject:@"#ffffff" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Background )];
        [default_sh setObject:@"#000000" forKey:IDEKit_NameForColor( IDEKit_kLangColor_NormalText )];
        [default_sh setObject:@"#0000ff" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Keywords )];
        [default_sh setObject:@"#009900" forKey:IDEKit_NameForColor( IDEKit_kLangColor_Classes )];
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
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:mAPreferencesEnableOTFVisuals];
        
        [defaults setObject:[NSArray arrayWithObjects:
                             [NSDictionary dictionaryWithObjectsAndKeys:@"/usr/lib/chuck", @"location", @"folder", @"type", nil],
                             nil] forKey:mAPreferencesChuginPaths];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        
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
        
        keybindings_field_editor = [[mAKeyBindingsFieldEditor alloc] init];
    }
    
    return self;
}
    
- (void)loadGUIFromDefaults
{
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
    
    //if( keybindings != nil )
    //    [keybindings release];
    //keybindings = [[mAKeyBindingsRecord createFromMainMenu] retain];
    //[keybindings_table reloadData];
    
    [chugin_paths release];
    chugin_paths = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:mAPreferencesChuginPaths]];
    [chugin_table reloadData];
    
    [self probeAudioInterfaces:nil];
}

- (void)loadMiniAudicleFromGUI
{
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
    chdir( [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesSoundfilesDirectory] cString] );        
    
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mAPreferencesChangedNotification
                                                        object:self];
    //*/
    
    [[NSUserDefaults standardUserDefaults] setObject:chugin_paths forKey:mAPreferencesChuginPaths];
    
    //TODO: set chugin paths in miniAudicle
//    vector< string > library_paths;
//    NSArray * obj_library_paths = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesLibraryPath];
//    for(int i = 0; i < [obj_library_paths count]; i++)
//    {
//        NSString * path = [obj_library_paths objectAtIndex:i];
//        library_paths.push_back([path UTF8String]);
//    }
//    [mac miniAudicle]->set_library_paths(library_paths);    
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
    
    //[preferences_tab_view removeTabViewItem:[preferences_tab_view tabViewItemAtIndex:[preferences_tab_view indexOfTabViewItemWithIdentifier:@"Key Bindings"]]];
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
    
//    vector< string > library_paths;
//    NSArray * obj_library_paths = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesLibraryPath];
//    for(int i = 0; i < [obj_library_paths count]; i++)
//    {
//        NSString * path = [obj_library_paths objectAtIndex:i];
//        library_paths.push_back([path UTF8String]);
//    }
//    ma->set_library_paths(library_paths);
    
//    [self loadGUIFromDefaults];
//    [self loadMiniAudicleFromGUI];

    [[NSNotificationCenter defaultCenter] postNotificationName:mAPreferencesChangedNotification
                                                        object:self];
}

- (void)cancel:(id)sender
{
    [chugin_paths release];
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
    if( ( int ) contextInfo == 1 && returnCode == NSOKButton )
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
    
    const vector< RtAudioDeviceInfo > & interfaces = [mac miniAudicle]->get_interfaces();
    vector< RtAudioDeviceInfo >::size_type i, len = interfaces.size();
    
    [audio_output removeAllItems];
    [audio_input removeAllItems];

    int dac = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioOutput] intValue];
    int adc = [[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesAudioInput] intValue];
    
    // load available audio I/O interfaces into the pop up menus
    for( i = 0; i < len; i++ )
    {
        if( interfaces[i].outputChannels > 0 || interfaces[i].duplexChannels > 0 )
        {
            [audio_output addItemWithTitle:[NSString stringWithCString:interfaces[i].name.c_str()]];
            [[audio_output lastItem] setTag:i];
            if( i == dac )
                [audio_output selectItem:[audio_output lastItem]];
        }

        if( interfaces[i].inputChannels > 0 || interfaces[i].duplexChannels > 0 )
        {
            [audio_input addItemWithTitle:[NSString stringWithCString:interfaces[i].name.c_str()]];
            [[audio_input lastItem] setTag:i];
            if( i == adc )
                [audio_input selectItem:[audio_input lastItem]];
        }
    }
    
    [self selectedAudioOutputChanged:nil];
    [self selectedAudioInputChanged:nil];
}

- (void)selectedAudioOutputChanged:(id)sender
{
    const vector< RtAudioDeviceInfo > & interfaces = [mac miniAudicle]->get_interfaces();

    vector< RtAudioDeviceInfo >::size_type selected_output = [[audio_output selectedItem] tag];
    
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
    const vector< RtAudioDeviceInfo > & interfaces = [mac miniAudicle]->get_interfaces();
    
    vector< RtAudioDeviceInfo >::size_type selected_input = [[audio_input selectedItem] tag];
    
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
    
}


- (IBAction)deleteChuginPath:(id)sender
{
    
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
            return [NSImage imageNamed:@"chugin"];
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
    if([[tableColumn identifier] isEqualToString:@"location"])
    {
        [item setObject:object forKey:@"location"];
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return YES;
}


@end
