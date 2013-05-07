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
#import "miniAudicle.h"
#import "chuck_parse.h"
#import "util_string.h"
#import "NSString+STLString.h"

using namespace std;


@implementation mADocumentViewController

@synthesize document = _document;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Initialization code here.
        arguments = [NSMutableArray new];
    }
    
    return self;
}

-(void)dealloc
{
    [arguments release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//    [mac setLastWindowTopLeftCorner:[window cascadeTopLeftFromPoint:[mac lastWindowTopLeftCorner]]];

    // set text view syntax highlighter
    [text_view setSyntaxHighlighter:[mac syntaxHighlighter] colorer:mac];
    if( self.document.data != nil )
    {
        BOOL esi = [text_view smartIndentationEnabled];
        [text_view setSmartIndentationEnabled:NO];
        [[text_view textView] setString:self.document.data];
        [text_view setSmartIndentationEnabled:esi];
    }
}


- (void)activate
{
    [[self.view window] makeFirstResponder:text_view];
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


@end
