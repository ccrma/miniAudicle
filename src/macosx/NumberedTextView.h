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
// file: NumberedTextView.m
// desc: view class for implementing a text view with scrollers and line numbers
//       Based on Koen van der Drift's MyTextView class.  
//
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Spring 2006
//-----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface mATextView : NSTextView
{
    float animation_ratio;
    NSImage * animation_image;
    
    float string_animation_ratio;
    NSString * animation_string;
    NSMutableDictionary * string_attributes;

    float error_animation_ratio;
}

- (void)animateAdd;
- (void)animateRemove;
- (void)animateReplace;
- (void)animateRemoveLast;
- (void)animateRemoveAll;

- (void)animateString:(NSString *)s;

- (void)animateError;

@end

@class IDEKit_LexParser;

@interface NumberedTextView : NSView < NSTextStorageDelegate, NSTextViewDelegate >
{
    BOOL drawNumbersInMargin;
    BOOL drawLineNumbers;
    int margin_width;
    NSMutableDictionary * marginAttributes;
    unsigned error_line;
    BOOL shows_error_line;
    
    mATextView * text_view;
    
    BOOL enable_syntax_highlighting;
    IDEKit_LexParser * syntax_highlighter;
    id colorer;
    
    // code editor data
    BOOL use_tabs;
    int tab_width;
    BOOL enable_smart_indentation;
    BOOL tab_key_smart_indents;
    
    NSRect last_rect;
    
    NSCharacterSet * smart_indentation_triggers;

    NSArray * magic_words_parens;
    NSArray * magic_words_parens_reverse;
    NSCharacterSet * okay_before_parens;
    NSCharacterSet * okay_after_parens;
    NSCharacterSet * needed_after_parens;
    
    NSArray * magic_words_no_parens;
    NSArray * magic_words_no_parens_reverse;
    NSCharacterSet * okay_before_no_parens;
    NSCharacterSet * okay_after_no_parens;
}

- (void)initLineMargin:(NSRect)frame;

- (void)enableLineNumbers:(BOOL)enable;
- (void)setErrorLine:(unsigned)line;
- (void)setShowsErrorLine:(BOOL)show;

- (void)reloadUserDefaults;

- (void)textStorageWillProcessEditing:(NSNotification *)notification;
- (void)textStorageDidProcessEditing:(NSNotification *)notification;
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector;

- (void)setSmartIndentationEnabled:(BOOL)enable;
- (BOOL)smartIndentationEnabled;

- (void)initSyntaxHighlighting;
- (void)setSyntaxHighlighter:(IDEKit_LexParser *)sh colorer:(id)c;
- (void)syntaxColoringChanged:(NSNotification * )n;

- (void)updateMargin;
- (void)updateLayout;

- (void)drawEmptyMargin:(NSRect)aRect;
- (void)drawNumbersInMargin:(NSRect)aRect;
- (void)drawOneNumberInMargin:(unsigned)aNumber inRect:(NSRect)aRect;

- (NSRect)marginRect;

- (mATextView *)textView;

@end
