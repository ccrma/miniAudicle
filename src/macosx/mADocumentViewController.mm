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

/* Based in part on: */
//
//  DocumentViewController.m
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import "mADocumentViewController.h"
#import "NumberedTextView.h"
#import "miniAudicleDocument.h"
#import "miniAudicleController.h"
#import "NSString+STLString.h"
#import "miniAudiclePreferencesController.h"
#import "mAMultiDocWindowController.h"

#import "miniAudicle.h"
#import "chuck_parse.h"
#import "util_string.h"

using namespace std;


@implementation mADocumentViewController

@synthesize isEdited = _edited;
@synthesize document = _document;
@synthesize windowController = _windowController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Initialization code here.
        arguments = [NSMutableArray new];
        self.isEdited = NO;
        _showsLineNumbers = YES;
        _showsArguments = YES;
        _showsStatusBar = YES;
    }
    
    return self;
}

-(void)dealloc
{
    [arguments release];
    
    [[NSUserDefaultsController sharedUserDefaultsController]
     removeObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesShowStatusBar]];
    [[NSUserDefaultsController sharedUserDefaultsController]
     removeObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesDisplayLineNumbers]];
    [[NSUserDefaultsController sharedUserDefaultsController]
     removeObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesShowArguments]];

    [super dealloc];
}

- (void)awakeFromNib
{
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//    [mac setLastWindowTopLeftCorner:[window cascadeTopLeftFromPoint:[mac lastWindowTopLeftCorner]]];
    
    _argumentsViewFrame = argument_view.frame;
    _statusBarViewFrame = status_text.frame;

    // set text view syntax highlighter
    [text_view setSyntaxHighlighter:[mac syntaxHighlighter] colorer:mac];
    if( self.document.data != nil )
    {
        BOOL esi = [text_view smartIndentationEnabled];
        [text_view setSmartIndentationEnabled:NO];
        [[text_view textView] setString:self.document.data];
        [text_view setSmartIndentationEnabled:esi];
    }
    
    [[NSUserDefaultsController sharedUserDefaultsController]
     addObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesShowStatusBar]
     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
     context:nil];
    [[NSUserDefaultsController sharedUserDefaultsController]
     addObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesDisplayLineNumbers]
     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
     context:nil];
    [[NSUserDefaultsController sharedUserDefaultsController]
     addObserver:self
     forKeyPath:[@"values." stringByAppendingString:mAPreferencesShowArguments]
     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
     context:nil];
}


- (void)activate
{
    [[self.view window] makeFirstResponder:[text_view textView]];
}


- (void)setMiniAudicle:(miniAudicle *)_ma
{
    ma = _ma;
    docid = ma->allocate_document_id();
}

- (BOOL)isEmpty
{
    return [[[text_view textView] textStorage] length] == 0;
}

- (NSString *)content
{
    return [[text_view textView] string];
}

- (void)setContent:(NSString *)_content
{
    BOOL esi = [text_view smartIndentationEnabled];
    [text_view setSmartIndentationEnabled:NO];
    [[text_view textView] setString:_content];
    [text_view setSmartIndentationEnabled:esi];
}

- (void)handleArgumentText:(id)sender
{
    NSMutableString * arg_text = [NSMutableString stringWithString:[sender stringValue]];
    [arg_text insertString:@"filename:" atIndex:0];
    string filename;
    vector< string > argv;
    if( extract_args( [arg_text stlString], filename, argv ) )
    {
        [arguments removeAllObjects];
        
        vector< string >::const_iterator iter = argv.begin(), end = argv.end();
        for( ; iter != end; iter++ )
            [arguments addObject:[NSString stringWithUTF8String:iter->c_str()]];
    }
}


#pragma mark OTF commands

- (void)add:(id)sender
{
    [self handleArgumentText:argument_text];
    
    string result;
    t_CKUINT shred_id;
    string code_name = string( [[self.document displayName] stlString] );
    
    string code = [[[text_view textView] string] stlString];
    
    vector< string > argv;
    NSEnumerator * args_enum = [arguments objectEnumerator];
    NSString * arg = nil;
    while( arg = [args_enum nextObject] )
        argv.push_back( [arg stlString] );
    
    [text_view setShowsErrorLine:NO];
    
    string filepath;
    if([self.document fileURL] && [[self.document fileURL] isFileURL])
        filepath = [[[self.document fileURL] path] stlString];
    else
        filepath = "";
    
    t_OTF_RESULT otf_result = ma->run_code( code, code_name, argv, filepath,
                                            docid, shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateAdd];
        [text_view setShowsErrorLine:NO];
    }
    
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        [mac setLockdown:YES];
    }
    
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        if( ma->get_last_result( docid, NULL, NULL, &error_line ) )
        {
            [text_view setShowsErrorLine:YES];
            [text_view setErrorLine:error_line];
        }
        
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateError];
        
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    
    else
    {
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateError];
        
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    //miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    //[mac updateSyntaxHighlighting];
}

- (void)replace:(id)sender
{
    [self handleArgumentText:argument_text];
    
    string result;
    t_CKUINT shred_id;
    string code = [[[text_view textView] string] stlString];
    string code_name = [[self.document displayName] stlString];
    
    vector< string > argv;
    NSEnumerator * args_enum = [arguments objectEnumerator];
    NSString * arg = nil;
    while( arg = [args_enum nextObject] )
        argv.push_back( [arg stlString] );
    
    string filepath;
    if([self.document fileURL] && [[self.document fileURL] isFileURL])
        filepath = [[[self.document fileURL] path] stlString];
    else
        filepath = "";
    
    t_OTF_RESULT otf_result = ma->replace_code( code, code_name, argv, filepath,
                                               docid, shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateReplace];
        [text_view setShowsErrorLine:NO];
    }
    
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        [mac setLockdown:YES];
    }
    
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        if( ma->get_last_result( docid, NULL, NULL, &error_line ) )
        {
            [text_view setShowsErrorLine:YES];
            [text_view setErrorLine:error_line];
        }
        
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateError];
        
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    
    else
    {
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateError];
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    
    //miniAudicleController * mac = [NSDocumentController sharedDocumentController];
    //[mac updateSyntaxHighlighting];
}

- (void)remove:(id)sender
{
    string result;
    t_CKUINT shred_id;
    
    t_OTF_RESULT otf_result = ma->remove_code( docid, shred_id, result );
    
    if( otf_result == OTF_SUCCESS )
    {
        [status_text setStringValue:@""];
        
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateRemove];
        [text_view setShowsErrorLine:NO];
    }
    
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        [mac setLockdown:YES];
    }
    
    else
    {
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateError];
        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
}

- (void)removeall:(id)sender
{
    string result;
    if( !ma->removeall( docid, result ) )
    {
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateRemoveAll];
        [text_view setShowsErrorLine:NO];
    }
    
    [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
}

- (void)removelast:(id)sender
{
    string result;
    if( !ma->removelast( docid, result ) )
    {
        if([self.windowController currentViewController] == self)
            [[text_view textView] animateRemoveLast];
        [text_view setShowsErrorLine:NO];
    }
    
    [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
}


#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    NSLog(@"observeValueForKeyPath %@", keyPath);

    if([keyPath isEqualToString:[@"values." stringByAppendingString:mAPreferencesDisplayLineNumbers]])
    {
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesDisplayLineNumbers];
        [self setShowsLineNumbers:show];
    }
    else if([keyPath isEqualToString:[@"values." stringByAppendingString:mAPreferencesShowArguments]])
    {
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowArguments];
        [self setShowsArguments:show];
    }
    else if([keyPath isEqualToString:[@"values." stringByAppendingString:mAPreferencesShowStatusBar]])
    {
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowStatusBar];
        [self setShowsStatusBar:show];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setShowsArguments:(BOOL)_sa
{
    _showsArguments = _sa;
    
    if(_showsArguments)
    {
        if(argument_view.frame.size.height == 0)
        {
            _argumentsViewFrame.size.width = self.view.bounds.size.width;
            _argumentsViewFrame.origin.y = self.view.bounds.origin.y + self.view.bounds.size.height;
            argument_view.frame = _argumentsViewFrame;
            
            NSRect textViewFrame = text_view.frame;
            textViewFrame.size.height -= _argumentsViewFrame.size.height;
            text_view.frame = textViewFrame;
        }
    }
    else
    {
        if(argument_view.frame.size.height > 0)
        {
            // cache original size
            _argumentsViewFrame = argument_view.frame;
            // collapse vertical dimension
            argument_view.frame = NSMakeRect(_argumentsViewFrame.origin.x, _argumentsViewFrame.origin.y,
                                             _argumentsViewFrame.size.width, 0);
            
            // expand in vertical direction
            NSRect textViewFrame = text_view.frame;
            textViewFrame.size.height += _argumentsViewFrame.size.height;
            text_view.frame = textViewFrame;
        }
    }
}

- (BOOL)showsArguments
{
    return _showsArguments;
}

- (void)setShowsLineNumbers:(BOOL)_sln
{
    _showsLineNumbers = _sln;
    [text_view enableLineNumbers:_sln];
}

- (BOOL)showsLineNumbers
{
    return _showsLineNumbers;
}

- (void)setShowsStatusBar:(BOOL)_ssb
{
    _showsStatusBar = _ssb;
    
    if(_showsStatusBar)
    {
        if(status_text.frame.size.height == 0)
        {
            _statusBarViewFrame.size.width = self.view.bounds.size.width;
            _statusBarViewFrame.origin.y = self.view.bounds.origin.y;
            status_text.frame = _statusBarViewFrame;
            
            NSRect textViewFrame = text_view.frame;
            textViewFrame.size.height -= _statusBarViewFrame.size.height;
            textViewFrame.origin.y = _statusBarViewFrame.origin.y + _statusBarViewFrame.size.height;
            text_view.frame = textViewFrame;
        }
    }
    else
    {
        if(status_text.frame.size.height > 0)
        {
            // cache original size
            _statusBarViewFrame = status_text.frame;
            // collapse vertical dimension
            status_text.frame = NSMakeRect(_statusBarViewFrame.origin.x, _statusBarViewFrame.origin.y,
                                           _statusBarViewFrame.size.width, 0);
            
            // expand in vertical direction
            NSRect textViewFrame = text_view.frame;
            textViewFrame.size.height += _statusBarViewFrame.size.height;
            textViewFrame.origin.y = _statusBarViewFrame.origin.y;
            text_view.frame = textViewFrame;
        }
    }
}

- (BOOL)showsStatusBar
{
    return _showsStatusBar;
}


@end
