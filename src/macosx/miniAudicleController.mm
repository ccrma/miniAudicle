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
// file: miniAudicleController.mm
// desc: controller class for miniAudicle GUI
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#import "miniAudicleController.h"
#import "miniAudicleVMMonitor.h"
#import "miniAudicleConsoleMonitor.h"
#import "miniAudicleDocument.h"
#import "miniAudiclePreferencesController.h"
#import "mASyntaxHighlighter.h"
#import "mAChuginManager.h"
#import "chuck_shell.h"
#import "miniAudicle.h"
#import "mARecordSessionController.h"
#import "mAMultiDocWindowController.h"
#import "mAExampleBrowser.h"
#import <objc/message.h>


extern const char MA_VERSION[];
extern const char CK_VERSION[];
extern const char MA_ABOUT[];

NSString * const mAVirtualMachineDidTurnOnNotification = @"VirtualMachineDidTurnOnNotification";
NSString * const mAVirtualMachineDidTurnOffNotification = @"VirtualMachineDidTurnOnNotification";

NSString * const mAChuginExtension = @"chug";

const char* const MultiWindowDocumentControllerCloseAllContext = "com.samuelcartwright.MultiWindowDocumentControllerCloseAllContext";

@interface miniAudicleController ()

@property (nonatomic, retain) mAExampleBrowser * exampleBrowser;

- (void)adjustChucKMenuItems;
- (void)applicationWillTerminate:(NSNotification *)n;

- (void)_backgroundVMOn;
- (void)_vmOnFinished;

@end

@implementation miniAudicleController

@synthesize exampleBrowser = _exampleBrowser;

//-----------------------------------------------------------------------------
// name: init
// desc: instance initializer
//-----------------------------------------------------------------------------
- (id)init
{
    if( self = [super init] )
    {
        ma = new miniAudicle();
        docid = ma->allocate_document_id();
        madv = [[NSMutableArray alloc] init];
        class_names = [[NSMutableDictionary alloc] init];
        vm_on = NO;
        in_lockdown = NO;
        NSRect viewable_frame = [[NSScreen mainScreen] frame];
        last_window_tlc = NSMakePoint( viewable_frame.size.width/4, viewable_frame.size.height );
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:NSApp];
        
        m_recordSessionController = [[mARecordSessionController alloc] initWithWindowNibName:@"mARecordSession"];
        m_recordSessionController.controller = self;
        
        self.exampleBrowser = [[[mAExampleBrowser alloc] initWithWindowNibName:@"mAExampleBrowser"] autorelease];
        
        _windowControllers = [NSMutableArray new];
        
        // initialize syntax highlighting
        syntax_highlighter = [[IDEKit_LexParser alloc] init];
        
        [syntax_highlighter addKeyword:@"int" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"float" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"time" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"dur" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"void" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"same" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addKeyword:@"if" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"else" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"while" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"do" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"until" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"for" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"break" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"continue" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"return" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"switch" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"repeat" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addKeyword:@"class" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"extends" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"public" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"static" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"pure" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"this" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"super" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"interface" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"implements" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"protected" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"private" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addKeyword:@"function" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"fun" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"spork" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"const" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"new" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addKeyword:@"now" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"true" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"false" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"maybe" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"null" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"NULL" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"me" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"pi" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addKeyword:@"samp" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"ms" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"second" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"minute" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"hour" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"day" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"week" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addKeyword:@"dac" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"adc" color:IDEKit_kLangColor_Keywords lexID:0];
        [syntax_highlighter addKeyword:@"blackhole" color:IDEKit_kLangColor_Keywords lexID:0];
        
        [syntax_highlighter addStringStart: @"\"" end: @"\""];
        [syntax_highlighter addCommentStart: @"/*" end: @"*/"];
        [syntax_highlighter addSingleComment: @"//"];        
        [syntax_highlighter addSingleComment: @"<--"];        
        
        [syntax_highlighter setIdentifierChars:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        
        for(id class_name in [mASyntaxHighlighting defaultClasses])
        {
            [syntax_highlighter addKeyword:class_name color:IDEKit_kLangColor_Classes lexID:0];
        }
        
        for(id ugen_name in [mASyntaxHighlighting defaultUGens])
        {
            [syntax_highlighter addKeyword:ugen_name color:IDEKit_kLangColor_OtherSymbol1 lexID:0];
        }
        
        // detach one empty NSThread to put Cocoa into multithreaded mode
        [NSThread detachNewThreadSelector:@selector(nop:) 
                                 toTarget:self withObject:nil];
        
        [self adjustChucKMenuItems];        
    }
    
    return self;
}

//-----------------------------------------------------------------------------
// name: dealloc
// desc: destructor
//-----------------------------------------------------------------------------
- (void)dealloc
{
    if( ma )
    {
        ma->free_document_id( docid );
        delete ma;
    }
    
    [syntax_highlighter release];
    [class_names release];
    [madv autorelease];
    m_recordSessionController.controller = nil;
    [m_recordSessionController release];
    [_windowControllers release];
    
    self.exampleBrowser = nil;
    
    [[NSUserDefaultsController sharedUserDefaultsController]
     removeObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesOpenDocumentsInNewTab]];
    
    [super dealloc];
}

- (void)nop:(id)sender
{
}

//-----------------------------------------------------------------------------
// name: awakeFromNib
// desc: called after all of the InterfaceBuilder connections are made
//-----------------------------------------------------------------------------
- (void)awakeFromNib
{
    // format/set the about box text
    NSString * t_string = [[[NSString alloc] initWithFormat:[NSString stringWithUTF8String:MA_ABOUT], MA_VERSION, CK_VERSION, sizeof(void*)*8] autorelease];
    [about_text setStringValue:t_string];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeKey:)
                                                 name:NSWindowDidBecomeKeyNotification
                                               object:nil];
    
    [[NSUserDefaultsController sharedUserDefaultsController]
     addObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesOpenDocumentsInNewTab]
     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
     context:nil];
    
    // init preferences
    // [mapc initDefaults];
    [self newDocument:self];
}

//-----------------------------------------------------------------------------
// name: miniAudicle
// desc: returns the global miniAudicle
//-----------------------------------------------------------------------------
- (miniAudicle *)miniAudicle
{
    return ma;
}


- (mAMultiDocWindowController *)windowControllerForNewDocument
{
    mAMultiDocWindowController * _wc;
    BOOL openDocsInNewTab = [[NSUserDefaults standardUserDefaults] integerForKey:mAPreferencesOpenDocumentsInNewTab];
    
    if(_forceDocumentInTab)
        _wc = [self topWindowController];
    else if(_forceDocumentInWindow)
        _wc = [self newWindowController];
    else
    {
        if(openDocsInNewTab)
            _wc = [self topWindowController];
        else
            _wc = [self newWindowController];
    }
    
//    _forceDocumentInWindow = NO;
//    _forceDocumentInTab = NO;
    
    return _wc;
}

- (mAMultiDocWindowController *)topWindowController
{
    if(_topWindowController == nil)
        _topWindowController = [self newWindowController];
    return _topWindowController;
}


- (mAMultiDocWindowController *)newWindowController
{
    mAMultiDocWindowController * windowController = [[[mAMultiDocWindowController alloc] initWithWindowNibName:@"mADocumentWindow"] autorelease];
    [_windowControllers addObject:windowController];
    if(vm_on)
        [windowController vm_on];
    return windowController;
}

- (void)windowDidCloseForController:(mAMultiDocWindowController *)controller
{
    [_windowControllers removeObject:controller];
    if(controller == _topWindowController)
        _topWindowController = nil;
}


#pragma mark NSDocument Delegate

// We want a custom subclass of NSDocumentController to handle document closure.
// The object is instantiated in Window.xib and becomes the application-global document
// controller, overriding NSDocumentController‘s default instance.

- (void)document:(NSDocument *)doc shouldClose:(BOOL)shouldClose contextInfo:(void  *)contextInfo
{
    if (contextInfo == MultiWindowDocumentControllerCloseAllContext) {
//        NSLog(@"in close all. should close: %@",@(shouldClose));
        if (shouldClose) {
            // work on a copy of the window controllers array so that the doc can mutate its own array.
            NSArray* windowCtrls = [doc.windowControllers copy];
            for (NSWindowController* windowCtrl in windowCtrls) {
                if ([windowCtrl respondsToSelector:@selector(removeDocument:)]) {
                    [(id)windowCtrl removeDocument:doc];
                }
            }
            
            [windowCtrls release];
            [doc close];
            [self removeDocument:doc];
        } else {
            _didCloseAll = NO;
        }
    }
}


#pragma mark NSDocumentController

- (void)closeAllDocumentsWithDelegate:(id)delegate didCloseAllSelector:(SEL)didCloseAllSelector contextInfo:(void *)contextInfo
{
//    NSLog(@"Closing all documents");
    _didCloseAll = YES;
    for (NSDocument* currentDocument in self.documents) {
        [currentDocument canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:(void*)MultiWindowDocumentControllerCloseAllContext];
    }
    
    objc_msgSend(delegate,didCloseAllSelector,self,_didCloseAll,contextInfo);
}

- (void)addDocument:(NSDocument *)doc
{
    [doc retain];
    [(miniAudicleDocument *)doc setMiniAudicle:ma];
    [madv addObject:doc];
    
    [super addDocument:doc];
}

- (void)removeDocument:(NSDocument *)doc
{
    [super removeDocument:doc];

    [madv removeObject:doc];
    
    mAMultiDocWindowController * windowController = (mAMultiDocWindowController *)[(miniAudicleDocument *)doc windowController];
    [windowController removeDocument:doc];
    if([windowController numberOfTabs] == 0)
    {
        [self windowDidCloseForController:windowController];
        [[windowController window] close];
    }
}


- (id)openDocumentWithContentsOfURL:(NSURL *)absoluteURL
                            display:(BOOL)displayDocument
                              error:(NSError **)outError
{
    NSDocument * docToClose = nil;
    
    if([[self currentDocument] isEmpty])
        docToClose = [self currentDocument];
    
    id r = [super openDocumentWithContentsOfURL:absoluteURL
                                        display:displayDocument
                                          error:outError];
    
    if(docToClose && r)
        [docToClose close];
    
    return r;
}


- (BOOL)application:(NSApplication *)theApplication
           openFile:(NSString *)filename
{
    if([[filename pathExtension] isEqualToString:mAChuginExtension])
    {
        NSString * chuginName = [filename lastPathComponent];
        NSAlert * chuginAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Do you want to install the ChuGin '%@'?", chuginName]
                                                defaultButton:@"Install for all users"
                                              alternateButton:@"Cancel"
                                                  otherButton:@"Install for just this user"
                                    informativeTextWithFormat:@"If you install for all users, you must authenticate as an administrator."];
        
        int result = [chuginAlert runModal];
        
        if(result == NSAlertDefaultReturn)
        {
            [[mAChuginManager chuginManager] installChuginForAllUsers:filename];
        }
        else if(result == NSAlertOtherReturn)
        {
            [[mAChuginManager chuginManager] installChuginForCurrentUser:filename];
        }
        else
        {
            
        }
        
        return YES;
    }
    
    return NO;
}


//-----------------------------------------------------------------------------
// name: lastWindowTopLeftCorner
// desc: returns the last top-left corner that a new document window was created
//       in.  Used to figure out how to cascade new document windows.  
//-----------------------------------------------------------------------------
- (NSPoint)lastWindowTopLeftCorner
{
    return last_window_tlc;
}

//-----------------------------------------------------------------------------
// name: setLastWindowTopLeftCorner
// desc: ...
//-----------------------------------------------------------------------------
- (void)setLastWindowTopLeftCorner:(NSPoint)p
{
    last_window_tlc = p;
}

- (void)windowDidBecomeKey:(NSNotification *)n
{
    NSWindow * window = [n object];
    
    if([window windowController] != nil &&
       [[window windowController] isKindOfClass:[mAMultiDocWindowController class]])
    {
        _topWindowController = [window windowController];
        
        if( vm_on )
        {
            NSMenu * ckmenu = [[[NSApp mainMenu] itemWithTitle:@"ChucK"] submenu];
            
            NSEnumerator * menu_items = [[ckmenu itemArray] objectEnumerator];
            NSMenuItem * mi;
            while( mi = [menu_items nextObject] )
                if( [mi tag] & 2 )
                    [mi setEnabled:YES];
        }
        
        main_document = [[window windowController] document];
        
        [closeTabMenuItem setKeyEquivalent:@"w"];
        [closeTabMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        [closeWindowMenuItem setKeyEquivalent:@"w"];
        [closeWindowMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSShiftKeyMask];
        
//        NSMenu * edit_menu = [[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu];
//        if( [main_document lockEditing] )
//            [[edit_menu itemWithTag:2] setTitle:@"Unlock Editing"];
//        else
//            [[edit_menu itemWithTag:2] setTitle:@"Lock Editing"];
        
//        NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
//        [[view_menu itemWithTag:100] setTitle: [main_document showsToolbar] ? @"Hide Toolbar" : @"Show Toolbar" ];
//        [[view_menu itemWithTag:101] setTitle: [main_document showsToolbar] ? @"Hide All Toolbars" : @"Show All Toolbars" ];
//        [[view_menu itemWithTag:102] setTitle: [main_document showsArguments] ? @"Hide Arguments" : @"Show Arguments" ];
//        [[view_menu itemWithTag:103] setTitle: [main_document showsArguments] ? @"Hide All Arguments" : @"Show All Arguments" ];
//        [[view_menu itemWithTag:104] setTitle: [main_document showsLineNumbers] ? @"Hide Line Numbers" : @"Show Line Numbers" ];
//        [[view_menu itemWithTag:105] setTitle: [main_document showsLineNumbers] ? @"Hide All Line Numbers" : @"Show All Line Numbers" ];
//        [[view_menu itemWithTag:106] setTitle: [main_document showsStatusBar] ? @"Hide Status Bar" : @"Show Status Bar" ];
//        [[view_menu itemWithTag:107] setTitle: [main_document showsStatusBar] ? @"Hide All Status Bars" : @"Show All Status Bars" ];
    }
    else
    {
        if( vm_on )
        {
            NSMenu * ckmenu = [[[NSApp mainMenu] itemWithTitle:@"ChucK"] submenu];
            
            NSEnumerator * menu_items = [[ckmenu itemArray] objectEnumerator];
            NSMenuItem * mi;
            while( mi = [menu_items nextObject] )
                if( [mi tag] & 2 )
                    [mi setEnabled:NO];
        }
        
        NSMenu * edit_menu = [[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu];
        [[edit_menu itemWithTag:2] setTitle:@"Lock Editing"];
        [[edit_menu itemWithTag:2] setEnabled:NO];
        
        [closeTabMenuItem setKeyEquivalent:@""];
        [closeWindowMenuItem setKeyEquivalent:@"w"];
        [closeWindowMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    }
}

//-----------------------------------------------------------------------------
// name: syntaxHighlighter
// desc: retrieve global syntax highlighter
//-----------------------------------------------------------------------------
- ( IDEKit_LexParser * )syntaxHighlighter
{
    return syntax_highlighter;
}

//-----------------------------------------------------------------------------
// name: syntaxHighlighter
// desc: retrieve global syntax highlighter
//-----------------------------------------------------------------------------
- (void)updateSyntaxHighlighting
{
    vector< string > new_names;
    ma->get_new_class_names( new_names );
    
    int i, len = new_names.size();
    for( i = 0; i < len; i++ )
    {
        //[syntax_highlighter addKeyword:[NSString stringWithCString:new_names[i].c_str()] 
        //                         color:IDEKit_kLangColor_Classes lexID:1];
        [class_names setObject:[NSNumber numberWithInt:1]
                        forKey:[NSString stringWithUTF8String:new_names[i].c_str()]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mASyntaxColoringChangedNotification
                                                        object:self];
}

- (NSColor *)colorForIdentifier:(NSString *)ident
{
    if( [class_names objectForKey:ident] )
        return [NSColor colorWithHTML:[[[NSUserDefaults standardUserDefaults] objectForKey:IDEKit_TextColorsPrefKey] objectForKey:IDEKit_NameForColor( IDEKit_kLangColor_Classes )]];
    
    return nil;//[NSColor redColor];
}


#pragma mark IBActions

- (IBAction)openDocumentInTab:(id)sender
{
    _forceDocumentInWindow = NO;
    _forceDocumentInTab = YES;
    
    //[self openDocument:sender];
    NSArray *urls = [self URLsFromRunningOpenPanel];
    for(NSURL * url in urls)
    {
        // TODO: result?
        NSError * error;
        id result = [self openDocumentWithContentsOfURL:url
                                                display:YES
                                                  error:&error];
    }
    
    _forceDocumentInWindow = NO;
    _forceDocumentInTab = NO;
}


- (IBAction)newWindow:(id)sender
{
    _forceDocumentInWindow = YES;
    _forceDocumentInTab = NO;
    
    [self newDocument:sender];
    
    _forceDocumentInWindow = NO;
    _forceDocumentInTab = NO;
}

- (IBAction)newTab:(id)sender
{
    _forceDocumentInWindow = NO;
    _forceDocumentInTab = YES;
    
    [self newDocument:sender];
    
    _forceDocumentInWindow = NO;
    _forceDocumentInTab = NO;
}

- (void)lockEditing:(id)sender
{
//    miniAudicleDocument * doc = [self currentDocument];
//    
//    [doc setLockEditing:![doc lockEditing]];
//    
//    if( [doc lockEditing] )
//        [sender setTitle:@"Unlock Editing"];
//    else
//        [sender setTitle:@"Lock Editing"];
}

//-----------------------------------------------------------------------------
// name: addShred
// desc: called by the GUI.  connected to the "Add shred" menu item
//-----------------------------------------------------------------------------
- (void)addShred:(id)sender
{
    [[(id)[self currentDocument] viewController] add:sender];
}

//-----------------------------------------------------------------------------
// name: removeShred
// desc: called by the GUI.  connected to the "Remove shred" menu item
//-----------------------------------------------------------------------------
- (void)removeShred:(id)sender
{
    [[(id)[self currentDocument] viewController] remove:sender];
}

//-----------------------------------------------------------------------------
// name: replaceShred
// desc: called by the GUI.  connected to the "Replace shred" menu item
//-----------------------------------------------------------------------------
- (void)replaceShred:(id)sender
{
    [[(id)[self currentDocument] viewController] replace:sender];
}

//-----------------------------------------------------------------------------
// name: addOpenDocuments
// desc: called by the GUI.  connected to "Add All Open Documents" menu item
//-----------------------------------------------------------------------------
- (void)addOpenDocuments:(id)sender
{
    for(NSDocument * doc in madv)
    {
        [[(id)doc viewController] add:sender];
    }
}

//-----------------------------------------------------------------------------
// name: replaceOpenDocuments
// desc: called by the GUI.  connected to "Replace All Open Documents" menu item
//-----------------------------------------------------------------------------
- (void)replaceOpenDocuments:(id)sender
{
    for(NSDocument * doc in madv)
    {
        [[(id)doc viewController] replace:sender];
    }
}

//-----------------------------------------------------------------------------
// name: removeOpenDocuments
// desc: called by the GUI.  connected to "Remove All Open Documents" menu item
//-----------------------------------------------------------------------------
- (void)removeOpenDocuments:(id)sender
{
    for(NSDocument * doc in madv)
    {
        [[(id)doc viewController] remove:sender];
    }
}

//-----------------------------------------------------------------------------
// name: removeAllShreds
// desc: called by the GUI.  connected to the "Remove All Shreds" menu item
//-----------------------------------------------------------------------------
- (void)removeAllShreds:(id)sender
{
//    if( [self currentDocument] )
//        [[self currentDocument] removeall:sender];
//    else
//    {
    string result;
    ma->removeall( docid, result );
//    }
}

- (void)commentOut:(id)sender
{
    if( [self currentDocument] )
        [[self currentDocument] commentOut:sender];
}

- (void)removeLastShred:(id)sender
{
//    if( [self currentDocument] )
//        [[self currentDocument] removelast:sender];
//    else
//    {
    string result;
    ma->removelast( docid, result );
//    }
}

- (void)abortCurrentShred:(id)sender
{
    ma->abort_current_shred();
}

- (void)setLogLevel:(id)sender
{
    // uncheck the menu item of the original log state
    [[[sender menu] itemWithTag:( ma->get_log_level() + 100 )] setState:NSOffState];
    
    // check the menu item of the new log state
    [sender setState:NSOnState];
    
    // set the log level
    ma->set_log_level( [sender tag] - 100 );
}

- (void)openMiniAudicleWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://audicle.cs.princeton.edu/mini/mac/doc/"]];
}

- (void)saveACopyAs:(id)sender
{
    if( [self currentDocument] )
        [[self currentDocument] saveDocumentTo:sender];
}

- (void)saveBackup:(id)sender
{
    if( [self currentDocument] )
        [[self currentDocument] saveBackup:sender];
}

#define HIDE_TOOLBAR_TAG 50
#define HIDE_ALL_TOOLBARS_TAG 52
#define HIDE_ARGUMENTS_TAG 54
#define HIDE_ALL_ARGUMENTS_TAG 56
#define HIDE_LINE_NUMBERS_TAG 58
#define HIDE_ALL_LINE_NUMBERS_TAG 60
#define HIDE_STATUS_BAR_TAG 62
#define HIDE_ALL_STATUS_BARS_TAG 64

- (void)hideToolbar:(id)sender
{
    miniAudicleDocument * doc = [self currentDocument];
    if( !doc )
        return;

//    [doc setShowsToolbar:![doc showsToolbar]];
//    
//    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
//    [[view_menu itemWithTag:HIDE_TOOLBAR_TAG] setTitle: [doc showsToolbar] ? @"Hide Toolbar" : @"Show Toolbar" ];
//    [[view_menu itemWithTag:HIDE_ALL_TOOLBARS_TAG] setTitle: [doc showsToolbar] ? @"Hide All Toolbars" : @"Show All Toolbars" ];
}

- (void)hideAllToolbars:(id)sender
{
    if( [madv count] == 0 )
        return;
    
    BOOL hide;
    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
    NSMenuItem * item = [view_menu itemWithTag:HIDE_ALL_TOOLBARS_TAG];
    
    if( [[item title] isEqualToString:@"Hide All Toolbars"] )
        hide = YES;
    else
        hide = NO;
    
//    NSEnumerator * doc_enum = [madv objectEnumerator];
//    miniAudicleDocument * doc;
//    while( doc = [doc_enum nextObject] )
//        [doc setShowsToolbar:!hide];
    
    [[view_menu itemWithTag:HIDE_TOOLBAR_TAG] setTitle: !hide ? @"Hide Toolbar" : @"Show Toolbar" ];
    [item setTitle: !hide ? @"Hide All Toolbars" : @"Show All Toolbars" ];
}

- (void)hideArguments:(id)sender
{
    miniAudicleDocument * doc = [self currentDocument];
    if( !doc )
        return;

//    [doc setShowsArguments:![doc showsArguments]];
//    
//    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
//    [[view_menu itemWithTag:HIDE_ARGUMENTS_TAG] setTitle: [doc showsArguments] ? @"Hide Arguments" : @"Show Arguments" ];
//    [[view_menu itemWithTag:HIDE_ALL_ARGUMENTS_TAG] setTitle: [doc showsArguments] ? @"Hide All Arguments" : @"Show All Arguments" ];
}

- (void)hideAllArguments:(id)sender
{
    if( [madv count] == 0 )
        return;
    
    BOOL hide;
    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
    NSMenuItem * item = [view_menu itemWithTag:HIDE_ALL_ARGUMENTS_TAG];
    
    if( [[item title] isEqualToString:@"Hide All Arguments"] )
        hide = YES;
    else
        hide = NO;
    
//    NSEnumerator * doc_enum = [madv objectEnumerator];
//    miniAudicleDocument * doc;
//    while( doc = [doc_enum nextObject] )
//        [doc setShowsArguments:!hide];
    
    [[view_menu itemWithTag:HIDE_ARGUMENTS_TAG] setTitle: !hide ? @"Hide Arguments" : @"Show Arguments" ];
    [item setTitle: !hide ? @"Hide All Arguments" : @"Show All Arguments" ];
}

- (void)hideLineNumbers:(id)sender
{
    miniAudicleDocument * doc = [self currentDocument];
    if( !doc )
        return;
    
//    [doc setShowsLineNumbers:![doc showsLineNumbers]];
//    
//    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
//    [[view_menu itemWithTag:HIDE_LINE_NUMBERS_TAG] setTitle: [doc showsLineNumbers] ? @"Hide Line Numbers" : @"Show Line Numbers" ];
//    [[view_menu itemWithTag:HIDE_ALL_LINE_NUMBERS_TAG] setTitle: [doc showsLineNumbers] ? @"Hide All Line Numbers" : @"Show All Line Numbers" ];
}

- (void)hideAllLineNumbers:(id)sender
{
    if( [madv count] == 0 )
        return;
    
    BOOL hide;
    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
    NSMenuItem * item = [view_menu itemWithTag:HIDE_ALL_LINE_NUMBERS_TAG];
    
    if( [[item title] isEqualToString:@"Hide All Line Numbers"] )
        hide = YES;
    else
        hide = NO;
    
//    NSEnumerator * doc_enum = [madv objectEnumerator];
//    miniAudicleDocument * doc;
//    while( doc = [doc_enum nextObject] )
//        [doc setShowsLineNumbers:!hide];
    
    [[view_menu itemWithTag:HIDE_LINE_NUMBERS_TAG] setTitle: !hide ? @"Hide Line Numbers" : @"Show Line Numbers" ];
    [item setTitle: !hide ? @"Hide All Line Numbers" : @"Show All Line Numbers" ];
}

- (void)hideStatusBar:(id)sender
{
    miniAudicleDocument * doc = [self currentDocument];
    if( !doc )
        return;
    
//    [doc setShowsStatusBar:![doc showsStatusBar]];
//    
//    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
//    [[view_menu itemWithTag:HIDE_STATUS_BAR_TAG] setTitle: [doc showsStatusBar] ? @"Hide Status Bar" : @"Show Status Bar" ];
//    [[view_menu itemWithTag:HIDE_ALL_STATUS_BARS_TAG] setTitle: [doc showsStatusBar] ? @"Hide All Status Bars" : @"Show All Status Bars" ];
}

- (void)hideAllStatusBars:(id)sender
{
    if( [madv count] == 0 )
        return;
    
    BOOL hide;
    NSMenu * view_menu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
    NSMenuItem * item = [view_menu itemWithTag:HIDE_ALL_STATUS_BARS_TAG];
    
    if( [[item title] isEqualToString:@"Hide All Status Bars"] )
        hide = YES;
    else
        hide = NO;
    
//    NSEnumerator * doc_enum = [madv objectEnumerator];
//    miniAudicleDocument * doc;
//    while( doc = [doc_enum nextObject] )
//        [doc setShowsStatusBar:!hide];
    
    [[view_menu itemWithTag:HIDE_STATUS_BAR_TAG] setTitle: !hide ? @"Hide Status Bar" : @"Show Status Bar" ];
    [item setTitle: !hide ? @"Hide All Status Bars" : @"Show All Status Bars" ];
}

static struct tile_dimension
{
    unsigned width;
    unsigned height;
} default_tile_dimensions[] =
{
    { 0, 0 }, // 0
    { 1, 1 }, // 1
    { 2, 1 }, // 2
    { 3, 1 }, // 3
    { 2, 2 }, // 4
    { 3, 2 }, // 5
    { 3, 2 }, // 6
    { 4, 2 }, // 7
    { 4, 2 }, // 8
    { 3, 3 }, // 9
    { 5, 2 }, // 10
    { 4, 3 }, // 11
    { 4, 3 }, // 12
    { 5, 3 }, // 13
    { 5, 3 }, // 14
    { 5, 3 }, // 15
    { 4, 4 }, // 16
    { 5, 4 }, // 17
    { 5, 4 }, // 18
    { 5, 4 }, // 19
    { 5, 4 }, // 20
    { 6, 4 }, // 21
    { 6, 4 }, // 22
    { 6, 4 }, // 23
    { 6, 4 }, // 24
    { 5, 5 }  // 25
};

const static size_t num_default_tile_dimensions = sizeof( default_tile_dimensions ) / sizeof( tile_dimension );

- (void)tileDocumentWindows:(id)sender
{
    unsigned window_count = [madv count];
    if( window_count == 0 )
        return;
    if( window_count >= num_default_tile_dimensions )
        window_count = num_default_tile_dimensions - 1;
    
    tile_dimension td = default_tile_dimensions[window_count];
    
    NSRect screen = [[NSScreen mainScreen] visibleFrame];
    
    for( unsigned i = 0; i < window_count; i++ )
    {
        NSRect window_rect = NSMakeRect( screen.origin.x + screen.size.width / td.width * ( i % td.width ),
                                         screen.origin.y + screen.size.height - screen.size.height / td.height * ( i / td.width ) - screen.size.height / td.height,
                                         screen.size.width / td.width, 
                                         screen.size.height / td.height );
        /*fprintf( stderr, "window rect for %s (%i): %f %f / %f %f\n", 
                 [[[madv objectAtIndex:i] displayName] cString], i, 
                 window_rect.origin.x, window_rect.origin.y,
                 window_rect.size.width, window_rect.size.height );*/
        [[[[[madv objectAtIndex:i] windowControllers] objectAtIndex:0] window] setFrame:window_rect
                                                                                display:YES];
    }
}

- (void)doConnectToRemoteVMDialog:(id)sender
{
    
}

- (void)connectToRemoteVM:(id)sender
{
    
}

- (void)connectToLocalVM:(id)sender
{
    
}

- (void)toggleVM:(id)sender
{
    if( vm_on )
    {
//        [madv makeObjectsPerformSelector:@selector(vm_off)];
        [vm_monitor vm_off];
        [_windowControllers makeObjectsPerformSelector:@selector(vm_off)];
        
        vm_on = NO;

        [self adjustChucKMenuItems];
        
        ma->stop_vm();
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mAVirtualMachineDidTurnOffNotification
                                                            object:self];
    }
    
    else
    {
        t_CKBOOL enable_std_system = FALSE;
        id enable_std_system_obj = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableStdSystem];
        if( enable_std_system_obj )
            enable_std_system = [enable_std_system_obj boolValue];
        ma->set_enable_std_system(enable_std_system);
        
        t_CKBOOL enable_block = FALSE;
        id enable_block_obj = [[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesEnableBlocking];
        if( enable_block_obj )
            enable_block = [enable_block_obj boolValue];
        ma->set_blocking(enable_block);
        
        vm_starting = YES;
        
        [self adjustChucKMenuItems];
        [vm_monitor vm_starting];
        
        if([self respondsToSelector:@selector(performSelectorInBackground:withObject:)])
        {
            [self performSelectorInBackground:@selector(_backgroundVMOn)
                                   withObject:nil];
        }
        else
        {
            [self _backgroundVMOn];
        }

        
        //[self updateSyntaxHighlighting];
    }
}

- (void)setLockdown:(BOOL)_lockdown
{
    in_lockdown = _lockdown;
    
    if( in_lockdown )
    {
        NSAlert * alert = [NSAlert alertWithMessageText:@"The Virtual Machine appears to be hanging."
                                          defaultButton:@"Abort"
                                        alternateButton:@"Cancel"
                                            otherButton:nil
                              informativeTextWithFormat:@"This is typically caused by a shred running in an infinite loop, or it may simply be a shred performing a finite amount of heavy processing.  If you would like to abort the current shred and unhang the virtual machine, click \"Abort.\"  To leave the current shred running, click \"Cancel.\"  If you choose to leave the current shred running, execution of on-the-fly programming commands may be delayed."];
        
        if( [alert runModal] == NSAlertDefaultReturn )
            ma->abort_current_shred();
    }
}

- (BOOL)isInLockdown
{
    return in_lockdown;
}


- (IBAction)recordSession:(id)sender
{
    [[m_recordSessionController window] makeKeyAndOrderFront:sender];
}

- (IBAction)openExample:(id)sender
{
    [[self.exampleBrowser window] makeKeyAndOrderFront:sender];
}


- (BOOL)validateMenuItem:(NSMenuItem *)menu_item
{
    BOOL r = YES;
    
    if( [menu_item tag] >= 100 )
        return YES;
    
    if( [menu_item tag] & 1 )
        r = r && vm_on;
    
    if( [menu_item tag] & 2 )
    {
        NSWindow * window = [NSApp mainWindow];
        r = r && [window windowController] != nil &&
            [[window windowController] document] != nil;
    }
    
    return r;
}


#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    //    NSLog(@"observeValueForKeyPath %@", keyPath);
    if([keyPath isEqualToString:[@"values." stringByAppendingString:mAPreferencesOpenDocumentsInNewTab]])
    {
        bool openInNewTab = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesOpenDocumentsInNewTab];
        if(openInNewTab)
        {
            [newTabMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
            [newWindowMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
        }
        else
        {
            [newTabMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
            [newWindowMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)adjustChucKMenuItems
{
    BOOL enable, enable_vm_ui;
    NSString * old_text, * new_text;
    
    if( vm_starting )
    {
        enable = NO;
        enable_vm_ui = NO;
        
        new_text = @"Starting Virtual Machine";
        old_text = @"Start Virtual Machine";
    }
    else if( vm_on )
    {
        enable = YES;
        enable_vm_ui = YES;
        
        new_text = @"Stop Virtual Machine";
        old_text = @"Start Virtual Machine";
    }
    else
    {
        enable = NO;
        enable_vm_ui = YES;
        
        new_text = @"Start Virtual Machine";
        old_text = @"Stop Virtual Machine";
    }
    
    NSMenu * tmenu = [NSApp mainMenu];
    int i = [tmenu indexOfItemWithTitle:@"ChucK"];
    
    tmenu = [[tmenu itemAtIndex:i] submenu];
    
    NSArray * menu_items = [tmenu itemArray];
    int len = [menu_items count];
    for( i = 0; i < len; i++ )
        if( [[tmenu itemAtIndex:i] tag] & 1 )
            [[tmenu itemAtIndex:i] setEnabled:enable];
    
//    i = [tmenu indexOfItemWithTitle:old_text];
//    if( i >= 0 )
//    {
//       [[tmenu itemAtIndex:i] setTitle:new_text];
//    }
    
    [startVMMenuItem setTitle:new_text];
    [startVMMenuItem setEnabled:enable_vm_ui];
}

- (void)applicationWillTerminate:(NSNotification *)n
{
    if( vm_on )
        [self toggleVM:nil];
}


- (void)_backgroundVMOn
{
    ma->start_vm();
    
    if([self respondsToSelector:@selector(performSelectorInBackground:withObject:)])
    {
        // in other words, this is happening in the background
        [self performSelectorOnMainThread:@selector(_vmOnFinished)
                               withObject:nil
                            waitUntilDone:NO];
    }
    else
    {
        [self _vmOnFinished];
    }

}

- (void)_vmOnFinished
{
    [self setLockdown:NO];
    
//    [madv makeObjectsPerformSelector:@selector(vm_on)];
    [_windowControllers makeObjectsPerformSelector:@selector(vm_on)];
    [vm_monitor vm_on];
    [[NSNotificationCenter defaultCenter] postNotificationName:mAVirtualMachineDidTurnOnNotification
                                                        object:self];
    if( [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesAutoOpenConsoleMonitor] == YES)
        [console_monitor activateMonitor];
    
    vm_starting = NO;
    vm_on = YES;
    
    [self adjustChucKMenuItems];
}

@end





