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
// file: mASyntaxHighlighter.mm
// desc: Syntax highlighting module.  Based heavily on Glenn Andreas' IDEKit,
// but there are modifications.  
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#import "Cocoa/Cocoa.h"
#import "mASyntaxHighlighter.h"

static const NSString * mALexerStateAttributeName = @"mALexerStateAttribute";
static const NSString * mAUserStyledAttributeName = @"mAUserStyledAttribute";

static mASyntaxDefinition * g_master_definition;

@implementation mASyntaxDefinition

+ (void)initialize
{
    g_master_definition = [[mASyntaxDefinition alloc] init];
    
    // keywords
    // see http://chuck.cs.princeton.edu/doc/language/overview.html#reserve
    [g_master_definition addKeyword:@"int"];
    [g_master_definition addKeyword:@"float"];
    [g_master_definition addKeyword:@"time"];
    [g_master_definition addKeyword:@"dur"];
    [g_master_definition addKeyword:@"void"];
    [g_master_definition addKeyword:@"same"];
    
    [g_master_definition addKeyword:@"if"];
    [g_master_definition addKeyword:@"else"];
    [g_master_definition addKeyword:@"while"];
    [g_master_definition addKeyword:@"until"];
    [g_master_definition addKeyword:@"for"];
    [g_master_definition addKeyword:@"repeat"];
    [g_master_definition addKeyword:@"break"];
    [g_master_definition addKeyword:@"continue"];
    [g_master_definition addKeyword:@"return"];
    [g_master_definition addKeyword:@"switch"];
    [g_master_definition addKeyword:@"repeat"];
    
    [g_master_definition addKeyword:@"class"];
    [g_master_definition addKeyword:@"extends"];
    [g_master_definition addKeyword:@"public"];
    [g_master_definition addKeyword:@"static"];
    [g_master_definition addKeyword:@"pure"];
    [g_master_definition addKeyword:@"this"];
    [g_master_definition addKeyword:@"super"];
    [g_master_definition addKeyword:@"interface"];
    [g_master_definition addKeyword:@"implements"];
    [g_master_definition addKeyword:@"protected"];
    [g_master_definition addKeyword:@"private"];

    [g_master_definition addKeyword:@"function"];
    [g_master_definition addKeyword:@"fun"];
    [g_master_definition addKeyword:@"spork"];
    [g_master_definition addKeyword:@"const"];
    [g_master_definition addKeyword:@"new"];
    
    [g_master_definition addKeyword:@"now"];
    [g_master_definition addKeyword:@"true"];
    [g_master_definition addKeyword:@"false"];
    [g_master_definition addKeyword:@"maybe"];
    [g_master_definition addKeyword:@"null"];
    [g_master_definition addKeyword:@"NULL"];
    [g_master_definition addKeyword:@"me"];
    [g_master_definition addKeyword:@"pi"];
    
    [g_master_definition addKeyword:@"samp"];
    [g_master_definition addKeyword:@"ms"];
    [g_master_definition addKeyword:@"second"];
    [g_master_definition addKeyword:@"minute"];
    [g_master_definition addKeyword:@"hour"];
    [g_master_definition addKeyword:@"day"];
    [g_master_definition addKeyword:@"week"];

    [g_master_definition addKeyword:@"dac"];
    [g_master_definition addKeyword:@"adc"];
    [g_master_definition addKeyword:@"blackhole"];
    
    // operators
    // see http://chuck.cs.princeton.edu/doc/language/oper.html
    [g_master_definition addOperator:@"=>"];
    [g_master_definition addOperator:@"=<"];
    [g_master_definition addOperator:@"@=>"];    
    
    [g_master_definition addOperator:@"+"];
    [g_master_definition addOperator:@"++"];
    [g_master_definition addOperator:@"-"];
    [g_master_definition addOperator:@"--"];
    [g_master_definition addOperator:@"*"];
    [g_master_definition addOperator:@"/"];
    [g_master_definition addOperator:@"%"];
    [g_master_definition addOperator:@"+=>"];
    [g_master_definition addOperator:@"-=>"];
    [g_master_definition addOperator:@"*=>"];
    [g_master_definition addOperator:@"/=>"];
    [g_master_definition addOperator:@"%=>"];

    [g_master_definition addOperator:@"=="];
    [g_master_definition addOperator:@"!="];
    [g_master_definition addOperator:@"<"];
    [g_master_definition addOperator:@">"];
    [g_master_definition addOperator:@"<="];
    [g_master_definition addOperator:@">="];
    [g_master_definition addOperator:@"&&"];
    [g_master_definition addOperator:@"||"];

    [g_master_definition addOperator:@"<<"];
    [g_master_definition addOperator:@">>"];
    [g_master_definition addOperator:@"&"];
    [g_master_definition addOperator:@"|"];
    [g_master_definition addOperator:@"^"];

    [g_master_definition addOperator:@"$"];
    [g_master_definition addOperator:@"::"];

    [g_master_definition addOperator:@"<<<"];
    [g_master_definition addOperator:@">>>"];
}

+ (mASyntaxDefinition *)masterDefinition
{
    return g_master_definition;
}

- (id)init
{
    if( self = [super init] )
    {
        keywords = [NSMutableDictionary new];
        operators = [NSMutableDictionary new];
        classes = [NSMutableDictionary new];
        user1 = [NSMutableDictionary new];

        for( int i = 0; i < MA_LS_COUNT; i++ )
        {
            attributes[i].text = [[NSColor blackColor] retain];
            attributes[i].background = [[NSColor whiteColor] retain];
            attributes[i].font = [[NSFont fontWithName:@"Monaco" size:10] retain];
        }
    }
    
    return self;
}

- (void)addKeyword:(NSString *)s
{
    [keywords setObject:s forKey:s];
}

- (void)addOperator:(NSString *)s
{
    [operators setObject:s forKey:s];
}

- (void)addClass:(NSString *)s
{
    [classes setObject:s forKey:s];
}

- (void)addUser1Keyword:(NSString *)s
{
    [user1 setObject:s forKey:s];
}

- (void)setStyleForLexerState:(mALexerState)state 
                    textColor:(NSColor *)text
              backgroundColor:(NSColor *)background
                         font:(NSFont *)f
{
    if( state < 0 || state > MA_LS_COUNT )
        return;
    
    if( text != nil )
    {
        [attributes[state].text release];
        attributes[state].text = [text retain];
    }
    
    if( background != nil )
    {
        [attributes[state].background release];
        attributes[state].background = [background retain];
    }
    
    if( f != nil )
    {
        [attributes[state].font release];
        attributes[state].font = [f retain];
    }
}

- (BOOL)isKeyword:(NSString *)s
{
    return [keywords objectForKey:s] != nil;
}

- (BOOL)isOperator:(NSString *)s
{
    return [operators objectForKey:s] != nil;
}

@end

@interface mASyntaxHighlighter (Private)

- (void)textStorageDidProcessEditing:(NSNotification *)notification;
- (void)highlightRange:(NSRange)range previousState:(mALexerState)previous_state;
- (BOOL)parseSymbols:(NSRange)range previousState:(mALexerState)previous_state;
- (void)setState:(mALexerState)state forRange:(NSRange)range;

@end

@implementation mASyntaxHighlighter

- (id)initWithTextStorage:(NSTextStorage *)str
{
    if( self = [super init] )
    {
        s = str;
        [s setDelegate:self];
        def = [mASyntaxDefinition masterDefinition];
        
        NSMutableCharacterSet * _idchars = [[NSMutableCharacterSet new] autorelease];
        [_idchars formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        [_idchars addCharactersInString:@"_"];
        idchars = [[NSCharacterSet characterSetWithBitmapRepresentation:[_idchars bitmapRepresentation]] retain];
        
        NSMutableCharacterSet * _fidchars = [[NSMutableCharacterSet new] autorelease];
        [_fidchars formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
        [_fidchars addCharactersInString:@"_"];
        fidchars = [[NSCharacterSet characterSetWithBitmapRepresentation:[_fidchars bitmapRepresentation]] retain];
        
        nonidchars = [[idchars invertedSet] retain];
        
        whitespace = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];        
    }
    
    return self;
}

@end

/********
 
 Model
 
 
 
 
 *******/


@implementation mASyntaxHighlighter (Private)

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
    if ( [s editedMask] == NSTextStorageEditedAttributes )
        return;
    
    NSRange edited_range = [s editedRange];
    
    fprintf( stderr, "er: %i %i\n", edited_range.location, edited_range.length );
    
    //if( edited_range.length < 1 )
    //    return;
    
    // determine the preceding lexer state
    mALexerState previous_state;
    if( edited_range.location > 0 )
    {
        NSNumber * num = [s attribute:mALexerStateAttributeName
                              atIndex:( edited_range.location - 1 )
                       effectiveRange:NULL];
        if( num == nil )
        {
            previous_state = MA_LS_DEFAULT;
            edited_range.location--;
            edited_range.length++;
        }
        else
            previous_state = [num intValue];
    }
    
    else
        previous_state = MA_LS_DEFAULT;
    
    // determine the range of characters that we have to highlight
    NSString * str = [s string];
    NSRange highlight_range;
    NSRange search_range, found_range;
    unsigned min, max, length;
    
    switch( previous_state )
    {
        case MA_LS_COMMENT:
            search_range = NSMakeRange( edited_range.location - 1, edited_range.length + 1 );
            found_range = [[s string] rangeOfString:@"*/" 
                                             options:NSLiteralSearch
                                               range:search_range];
            if( found_range.location != NSNotFound && 
                [[s string] characterAtIndex:found_range.location - 1] != '/' )
            {
                int pre_commentend_length = found_range.location - edited_range.location;
                if( pre_commentend_length > 0 )
                    [self setState:MA_LS_COMMENT forRange:NSMakeRange( edited_range.location, pre_commentend_length )];
                [self setState:MA_LS_COMMENT_END forRange:found_range];
                highlight_range = NSMakeRange( found_range.location + found_range.length, 
                                               [s length] - ( found_range.location + found_range.length ) );
            }
            
            else
            {
                search_range = NSMakeRange( edited_range.location, 
                                            [s length] - edited_range.location );
                while( true )
                {
                    found_range = [[s string] rangeOfString:@"*/" 
                                                    options:NSLiteralSearch
                                                      range:search_range];
                    
                    if( found_range.location == NSNotFound )
                    {
                        [self setState:MA_LS_COMMENT forRange:search_range];
                        break;
                    }
                    
                    else if( [[s string] characterAtIndex:found_range.location - 1] != '/' )
                    {
                        [self setState:MA_LS_COMMENT forRange:NSMakeRange( search_range.location, 
                                                                           found_range.location - search_range.location )];
                        [self setState:MA_LS_COMMENT_END forRange:found_range];
                        break;
                    }
                    
                    else
                    {
                        [self setState:MA_LS_COMMENT forRange:NSMakeRange( search_range.location, 
                                                                           found_range.location - search_range.location + found_range.length )];
                        search_range = NSMakeRange( found_range.location + found_range.length, 
                                                    [s length] - ( found_range.location + found_range.length ) );
                    }
                }
                
                return;
            }
            /*
            else
            {
                [self setState:MA_LS_COMMENT forRange:edited_range];
                return;
            }
            */
            break;
                        
        case MA_LS_COMMENT_START:
            if( edited_range.length > 0 )
            {
                [self setState:MA_LS_COMMENT forRange:edited_range];
                return;
            }
            // else do the default thing, because a delimiter was probably deleted
            
        case MA_LS_DEFAULT:
        default:
            /* by default, we only have to highlight from the beginning of the 
            first word that lies in the edited range to the end of the last word
            that lies in the edited range. */
            min = edited_range.location;
            max = edited_range.location + edited_range.length;
            length = [s length];
            
            if( min >= length && min > 0 )
                min--;
                
            while( min > 0 && 
                   ![whitespace characterIsMember:[str characterAtIndex:min]] )
            min--;
            if( min < length && [whitespace characterIsMember:[str characterAtIndex:min]] )
                min++;
                        
            while( max < length && 
                   ![whitespace characterIsMember:[str characterAtIndex:max]] )
                max++;
                            
            if( max < min )
                max = min;
                                
            highlight_range = NSMakeRange( min, max - min );
            
            break;
    }
    
    [self highlightRange:highlight_range previousState:previous_state];
}

- (void)highlightRange:(NSRange)highlight_range 
         previousState:(mALexerState)previous_state
{
    NSString * str = [s string];

    fprintf( stderr, "hr: %i %i\n", highlight_range.location, highlight_range.length );
    
    fprintf( stderr, "'%s'\n", [[str substringWithRange:highlight_range] cString] );
    
    // now determine the lexer state and highlight color
    NSRange token_range, t_range;
    BOOL is_symbol = NO;
    while( highlight_range.length )
    {
        
        if( [fidchars characterIsMember:[str characterAtIndex:highlight_range.location]] )
        {
            t_range = [str rangeOfCharacterFromSet:nonidchars options:0
                                             range:NSMakeRange( highlight_range.location + 1,
                                                                highlight_range.length - 1 )];
            is_symbol = NO;
        }
        else
        {
            t_range = [str rangeOfCharacterFromSet:fidchars options:0
                                             range:highlight_range];
            is_symbol = YES;
        }
        
        if( t_range.location == NSNotFound )
            token_range = highlight_range;
        else
            token_range = NSMakeRange( highlight_range.location, 
                                       t_range.location - highlight_range.location );
        
        highlight_range.location += token_range.length;
        highlight_range.length -= token_range.length;
        
        NSString * token_string = [str substringWithRange:token_range];
        
        if( is_symbol )
        {
            if( [self parseSymbols:token_range previousState:previous_state] )
                break;
        }
        
        else
        {
            if( [def isKeyword:token_string] )
                [self setState:MA_LS_KEYWORD forRange:token_range];
            else
                [self setState:MA_LS_DEFAULT forRange:token_range];
        }
        
        fprintf( stderr, "'%s'\n", [token_string cString] );
    }
}

//------------------------------------------------------------------------------
// name: parseSymbols 
// desc: iterates through the symbols within token_range. breaks symbols up into
// chunks as large as possible, except when those chunks are /*, */, or // 
// comment delimiters
//------------------------------------------------------------------------------
- (BOOL)parseSymbols:(NSRange)token_range 
       previousState:(mALexerState)previous_state
{
/*    NSString * str = [s string];
    NSString * token_string = [str substringWithRange:token_range];
    NSString * sub_string;
    NSRange sub_range;
    NSRange t_range;

    while( token_range.length )
    {
        
        
        sub_string = [str substringWithRange:sub_range];
        
        if( [sub_string isEqualToString:@"\/\*"] )
        {
            // t_range2 - from token_range.location to the end of the text
            NSRange t_range2 = NSMakeRange( token_range.location, 
                                            [str length] - token_range.location );
            
            // t_range - the location/length of the comment end delimiter
            t_range = [str rangeOfString:@"\*\/" options:0
                                   range:t_range2];
            if( t_range.location == NSNotFound )
                token_range.length = [str length] - token_range.location;
            else
                token_range.length = t_range.location + 2;
            [self setState:MA_LS_COMMENT forRange:token_range];
        }
        
        else if( [def isOperator:token_string] )
            [self setState:MA_LS_OPERATOR forRange:token_range];
        
        else
            [self setState:MA_LS_DEFAULT forRange:token_range];
    }*/
    
    // see if theres a comment delimiter somewhere in there
    NSString * str = [s string];
    NSRange comment_range = [str rangeOfString:@"\/\*" options:0
                                         range:token_range];
    if( comment_range.location == NSNotFound )
        // for now, just set everything thats not a comment to operator
    {
        [self setState:MA_LS_OPERATOR forRange:token_range];
        return NO;
    }
    
    // set everything up to the comment as an operator
    NSRange t_range = NSMakeRange( token_range.location, 
                                   comment_range.location - token_range.location );
    if( t_range.length > 0 )
        [self setState:MA_LS_OPERATOR forRange:t_range];
    
    t_range = NSMakeRange( token_range.location, 2 );
    [self setState:MA_LS_COMMENT_START forRange:t_range];
    token_range.location++;
    
    // t_range2 - everything from comment start delimiter to buffer end
    NSRange t_range2 = NSMakeRange( comment_range.location, 
                                    [str length] - comment_range.location );
    
    // t_range - the location/length of the comment end delimiter
    t_range = [str rangeOfString:@"\*\/" options:0
                           range:t_range2];
    
    if( t_range.location == NSNotFound )
        token_range.length = [str length] - token_range.location;
    else
    {
        token_range.length = t_range.location - token_range.location - 2;
        [self setState:MA_LS_COMMENT_END forRange:t_range];
    }
    
    [self setState:MA_LS_COMMENT forRange:token_range];
    
    return YES;
}

- (void)setState:(mALexerState)state forRange:(NSRange)range
{
    if( state == MA_LS_KEYWORD )
    {
        [s addAttribute:NSForegroundColorAttributeName 
                  value:[NSColor blueColor]
                  range:range];
    }
    
    else if( state == MA_LS_OPERATOR )
    {
        [s addAttribute:NSForegroundColorAttributeName 
                  value:[NSColor greenColor]
                  range:range];
    }
    
    else if( state == MA_LS_COMMENT )
    {
        [s addAttribute:NSForegroundColorAttributeName 
                  value:[NSColor redColor]
                  range:range];
    }
    
    else if( state == MA_LS_COMMENT_START || state == MA_LS_COMMENT_END )
    {
        [s addAttribute:NSForegroundColorAttributeName 
                  value:[NSColor redColor]
                  range:range];
    }
    
    else if( state == MA_LS_DEFAULT )
    {
        [s addAttribute:NSForegroundColorAttributeName 
                  value:[NSColor blackColor]
                  range:range];
    }
    
    [s addAttribute:mALexerStateAttributeName 
              value:[NSNumber numberWithInt:state]
              range:range];
}

@end

//
//  IDEKit_LexParser.mm
//  IDEKit
//
//  Created by Glenn Andreas on Mon May 26 2003.
//  Copyright (c) 2003, 2004 by Glenn Andreas
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License 
//  as published by the Free Software Foundation; either
//  version 2 of the License, or (at your option) any later version.
//  
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//  
//  You should have received a copy of the GNU General Public
//  License along with this library; if not, write to the Free
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

#import "mASyntaxHighlighter.h"

NSString *IDEKit_LexIDKey = @"IDEKit_LexIDKey";
NSString *IDEKit_LexColorKey = @"IDEKit_LexColorKey";

NSString *IDEKit_LexParserStartState = @"IDEKit_LexParserStartState";
enum {
    IDEKit_kLexStateNormal = 0,
    IDEKit_kLexStateNormalWS,
    IDEKit_kLexStateMatching,
    IDEKit_kLexStatePrePro0,
    IDEKit_kLexStatePrePro,
    IDEKit_kLexStateIdentifier,
    IDEKit_kLexStateNumber,
    IDEKit_kLexStateMarkupContent,
    IDEKit_kLexStateCount
};

#define IGNORE  myCurLoc++; mySubStart = myCurLoc; goto endLoop
#define APPEND  myCurLoc++; goto endLoop
#define APPENDTO(x) myCurLoc++; myCurState = x; goto endLoop
#define TO(x)   myCurState = x; goto endLoop
#define REJECT  myCurState = IDEKit_kLexStateNormal; [self color:xstring from: mySubStart to: mySubStart+1 as: IDEKit_TextColorForColor(IDEKit_kLangColor_NormalText)]; myCurLoc = mySubStart+1; mySubStart = myCurLoc; goto endLoop
#define ACCEPT(x) myCurState = IDEKit_kLexStateNormal; [self color:xstring from: mySubStart to: myCurLoc as: IDEKit_TextColorForColor(x)]; mySubStart = myCurLoc;  goto endLoop
#define ACCEPTC(x) myCurState = IDEKit_kLexStateNormal; [self color:xstring from: mySubStart to: myCurLoc as: x]; mySubStart = myCurLoc;  goto endLoop
#define CONSUME(n) myCurLoc += n;
#define TOKEN [string substringWithRange: NSIntersectionRange(NSMakeRange(0,strLength),NSMakeRange(mySubStart,myCurLoc-mySubStart))]


@implementation IDEKit_LexParser
- (id) init
{
    self = [super  init];
    if (self) {
        myKeywords = [[NSMutableDictionary dictionary] retain];
        myOperators = [[NSMutableDictionary dictionary] retain];
        myPreProStart = NULL;
        myPreProcessor = [[NSMutableArray array] retain];
        myStrings = [[NSMutableArray array] retain];
        myCharacters = [[NSMutableArray array] retain];
        myMultiComments = [[NSMutableArray array] retain];
        mySingleComments = [[NSMutableArray array] retain];
        myIdentifierChars = NULL;
        myFirstIdentifierChars = NULL;
        myCaseSensitive = YES;
        myMarkupStart = NULL;
        myMarkupEnd = NULL;
    }
    return self;
}
- (void) setCaseSensitive: (BOOL) sensitive
{
    myCaseSensitive = sensitive;
}

- (id) addKeyword: (NSString *)string color: (int) color lexID: (int) lexID
{
    id retval = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: color], IDEKit_LexColorKey, [NSNumber numberWithInt: IDEKit_kLexKindKeyword | lexID], IDEKit_LexIDKey, NULL];
    [myKeywords setObject: retval forKey: string];
    return retval;
}
- (id) addOperator: (NSString *)string lexID: (int) lexID
{
    id retval = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: IDEKit_kLexKindKeyword | lexID], IDEKit_LexIDKey, NULL];
    [myOperators setObject: retval forKey: string];
    return retval;
}
- (void) addStringStart: (NSString *)start end: (NSString *) end
{
    [myStrings addObject: [NSArray arrayWithObjects: start, end, NULL]];
}
- (void) addCharacterStart: (NSString *)start end: (NSString *) end
{
    [myCharacters addObject: [NSArray arrayWithObjects: start, end, NULL]];
}

- (void) addMarkupStart: (NSString *)start end: (NSString *) end
{
    [myMarkupStart release];
    [myMarkupEnd release];
    myMarkupStart = [start retain];
    myMarkupEnd = [end retain];
}

- (void) addCommentStart: (NSString *)start end: (NSString *) end
{
    [myMultiComments addObject: [NSArray arrayWithObjects: start, end, NULL]];
}

- (void) addSingleComment: (NSString *)start
{
    [mySingleComments addObject: start];
}

- (void) setIdentifierChars: (NSCharacterSet *)set
{
    [myIdentifierChars autorelease];
    myIdentifierChars = [set retain];
}

- (void) setFirstIdentifierChars: (NSCharacterSet *)set
{
    [myFirstIdentifierChars autorelease];
    myFirstIdentifierChars = [set retain];
}


- (void) setPreProStart: (NSString *)start
{
    [myPreProStart autorelease];
    myPreProStart = [start retain];
}

- (void) addPreProcessor: (NSString *)token
{
    [myPreProcessor addObject: token];
}

- (BOOL) match: (NSString *) string withPattern: (NSString *)pattern
{
#define PEEK(n) (myCurLoc+n < [string length] ? [string characterAtIndex: myCurLoc+n] : 0)
    if (!pattern || [pattern length] == 0)
        return NO;
    for (unsigned i=0;i<[pattern length];i++) {
        if (PEEK(i) != [pattern characterAtIndex: i])
            return NO;
    }
    //CONSUME([pattern length]);  // don't consume
    //NSLog(@"Matched %@",pattern);
    return YES;
}
- (void) color: (NSMutableAttributedString *)string from: (unsigned) start to: (unsigned) end as: (NSColor *) color
{
    //NSLog(@"Coloring %d-%d with %d (%@)",start,end,color,[[string string] substringWithRange:NSMakeRange(start,end-start)]);
    [string beginEditing];
    [string addAttribute: NSForegroundColorAttributeName value: color range: NSIntersectionRange(NSMakeRange(0,[string length]),NSMakeRange(start,end-start))];
    [string endEditing];
}



- (void) startParsingString: (NSString *)string range: (NSRange) range
{
    [myString autorelease];
    myString = NULL;
    myCurLoc = range.location;
    myStopLoc = range.location + range.length;
    if (myCurLoc >= [string length])
        return; // nothing to color - at end of string
    myString = [string retain];
    myCurState = IDEKit_kLexStateNormal;
    if (myMarkupStart)
        myCurState = IDEKit_kLexStateMarkupContent; // if we are a markup language, start in the content area
    mySubStart = myCurLoc;
    // myCurState will be 0 by default unless we are in a multi line comment, string
    myCloser = NULL;
    mySubColor = 0; mySubLexID = 0;
}

enum {
    IDEKit_kLexActionIgnore =   0x00000000,
    IDEKit_kLexActionAppend =   0x10000000,
    IDEKit_kLexActionReturn =   0x20000000,
    IDEKit_kLexActionAppendTo = 0x30000000,
    IDEKit_kLexActionMask =     0x0fffffff
};

- (int) lexStateNormal: (unichar) peekChar
{
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember: peekChar]) {
        return IDEKit_kLexActionIgnore;
    }
    if ([[NSCharacterSet controlCharacterSet] characterIsMember: peekChar]) {
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexError);
        //IGNORE;
    }
    if ([[NSCharacterSet illegalCharacterSet] characterIsMember: peekChar]) {
        // by default, ignore unknown characters
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexError);
        //IGNORE;
    }
    if (myMarkupStart && [myMarkupStart characterAtIndex: 0] == peekChar) {
        // start of markup (which we actually detected previously, but we returned the content that time)
        myCurLoc++;
        mySubColor = IDEKit_kLangColor_NormalText;
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexMarkupStart);
    }
    if (myMarkupEnd && [myMarkupEnd characterAtIndex: 0] == peekChar) {
        // end of markup, back to content
        myCurLoc++;
        mySubColor = IDEKit_kLangColor_NormalText;
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexMarkupEnd);
    }
    
    if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: peekChar]) {
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateNumber);
    }
    if ([myFirstIdentifierChars characterIsMember: peekChar] || [myIdentifierChars characterIsMember: peekChar] || [[NSCharacterSet letterCharacterSet] characterIsMember: peekChar]) {
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateIdentifier);
    }
    if ([self match: myString withPattern: myPreProStart]) {
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStatePrePro0);
    }
    for (unsigned i=0;i<[myStrings count];i++) {
        if ([self match: myString withPattern: [[myStrings objectAtIndex: i] objectAtIndex: 0]]) {
            myCloser = [[myStrings objectAtIndex: i] objectAtIndex: 1];
            mySubColor = IDEKit_kLangColor_Strings;
            mySubLexID = IDEKit_kLexString;
            return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateMatching);
        }
    }
    for (unsigned i=0;i<[myCharacters count];i++) {
        if ([self match: myString withPattern: [[myCharacters objectAtIndex: i] objectAtIndex: 0]]) {
            myCloser = [[myCharacters objectAtIndex: i] objectAtIndex: 1];
            mySubColor = IDEKit_kLangColor_Constants;
            mySubLexID = IDEKit_kLexCharacter;
            return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateMatching);
        }
    }
    for (unsigned i=0;i<[myMultiComments count];i++) {
        if ([self match: myString withPattern: [[myMultiComments objectAtIndex: i] objectAtIndex: 0]]) {
            myCloser = [[myMultiComments objectAtIndex: i] objectAtIndex: 1];
            mySubColor = IDEKit_kLangColor_Comments;
            mySubLexID = IDEKit_kLexComment;
            return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateMatching);
        }
    }
    for (unsigned i=0;i<[mySingleComments count];i++) {
        if ([self match: myString withPattern: [mySingleComments objectAtIndex: i]]) {
            myCloser = @"\n"; // go to EOL
            mySubColor = IDEKit_kLangColor_Comments;
            mySubLexID = IDEKit_kLexComment;
            return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateMatching);
        }
    }
    // otherwise, it is just some operator that we ignore (for now)
    myCurLoc++;
    mySubColor = IDEKit_kLangColor_NormalText;
    return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & peekChar); // treat operator as the character constant
}

- (int) lexStateNormalWS: (unichar) peekChar
{
    // treat WS special
    if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember: peekChar]) {
        myCurLoc++;
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexWhiteSpace);
    }
    // and EOL
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember: peekChar]) {
        myCurLoc++;
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexEOL);
    }
    return [self lexStateNormal: peekChar];
}

- (int) lexStateIdentifier: (unichar) peekChar
{
    // we've got an identifier, consume the rest of it
    if ([myIdentifierChars characterIsMember: peekChar] || [[NSCharacterSet alphanumericCharacterSet] characterIsMember: peekChar] ) {
        // stay here
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateIdentifier);
    }
    // otherwise we've got an identifier of some sort, possibly a reserved or alt word
    NSString *token = [myString substringWithRange: NSIntersectionRange(NSMakeRange(0,[myString length]),NSMakeRange(mySubStart,myCurLoc-mySubStart))];
    //NSLog(@"Token '%@'",token);
    NSString *utoken = (myCaseSensitive ? token : [token lowercaseString]);
    if ([myKeywords objectForKey: utoken]) {
        id entry = [myKeywords objectForKey: utoken];
        if ([[entry objectForKey: IDEKit_LexIDKey] intValue]) {
            return IDEKit_kLexActionReturn |(IDEKit_kLexActionMask & [[entry objectForKey: IDEKit_LexIDKey] intValue]);
        }
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexToken); // generic token
    }
    return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexIdentifier);
}

- (int) lexStatePrePro0: (unichar) peekChar
{
    // got the "#" of a pre-processor, consume all the white space
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember: peekChar]) {
        return IDEKit_kLexActionAppend;
    }
    if ([myIdentifierChars characterIsMember: peekChar] || [[NSCharacterSet letterCharacterSet] characterIsMember: peekChar]) {
        // we are now in a pre-processor thing (hopefully)
        myTempBackState = myCurLoc;
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStatePrePro);
    }
    //REJECT; // this moves us back to parsing, but after the "#"
    return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexError);
}

- (int) lexStatePrePro: (unichar) peekChar
{
    if ([myIdentifierChars characterIsMember: peekChar] || [[NSCharacterSet letterCharacterSet] characterIsMember: peekChar]) {
        // stay here
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStatePrePro);
    }
    // otherwise, we've got something
    NSString *token = [myString substringWithRange: NSMakeRange(myTempBackState,myCurLoc-myTempBackState)]; // just grab after the ws
                                                                                                            //NSLog(@"Checking pre-pro '%@'",token);
    for (unsigned i=0;i<[myPreProcessor count];i++) {
        if ([token isEqualToString: [myPreProcessor objectAtIndex: i]]) {
            if (peekChar == '\n') {
                myCurLoc++; // we are at the end of it already
                mySubColor = IDEKit_kLangColor_Preprocessor;
                mySubLexID = (IDEKit_kLexKindPrePro | (i+1));
                return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & (IDEKit_kLexKindPrePro | (i+1)) );
            } else {
                myCloser = @"\n"; // go to EOL
                mySubColor = IDEKit_kLangColor_Preprocessor;
                mySubLexID = (IDEKit_kLexKindPrePro | (i+1));
                return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateMatching);
            }
        }
    }
    // this means we didn't get a pre-processor command
    //REJECT;
    return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexError);
}

- (int) lexStateMatching: (unichar) peekChar
{
    // this is used a lot - continue until we get the matching thing (we don't support nesting yet)
    if (peekChar == '\\') {
        myCurLoc += 1; //CONSUME(1);
        return IDEKit_kLexActionAppend; // grab the next thing as an escaped thing
    }
    if ([self match: myString withPattern: myCloser]) {
        // got the end!
        myCurLoc += ([myCloser length]);
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & mySubLexID);
    }
    // otherwise, just stay here in this state
    return IDEKit_kLexActionAppend;
}

- (int) lexStateNumber: (unichar) peekChar
{
    // not quite perfect - only grabs [0-9]+
    if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: peekChar]) {
        return IDEKit_kLexActionAppendTo | (IDEKit_kLexStateNumber);
    }
    return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexNumber);
}

- (int) lexStateMarkupContent: (unichar) peekChar
{
    if (myMarkupStart && [myMarkupStart characterAtIndex: 0] == peekChar) {
        return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexContent); // return body of content as string
                                                                                       // (and as a side effect of "Return" we end up as plain or whitespace mode)
    }
    // otherwise, just stay here in this state
    return IDEKit_kLexActionAppend;
}
- (int) examineCharacter: (unichar) peekChar inState: (int) state
{
    switch (state) {
        case IDEKit_kLexStateNormal:
            return [self lexStateNormal: peekChar];
        case IDEKit_kLexStateNormalWS:
            return [self lexStateNormalWS: peekChar];
        case IDEKit_kLexStateIdentifier:
            return [self lexStateIdentifier: peekChar];
        case IDEKit_kLexStatePrePro0:
            return [self lexStatePrePro0: peekChar];
        case IDEKit_kLexStatePrePro:
            return [self lexStatePrePro: peekChar];
        case IDEKit_kLexStateMatching:
            return [self lexStateMatching: peekChar];
        case IDEKit_kLexStateNumber:
            return [self lexStateNumber: peekChar];
        case IDEKit_kLexStateMarkupContent:
            return [self lexStateMarkupContent: peekChar];
        default:
            NSLog(@"Lex state %d not handled",state);
            
    }
    return IDEKit_kLexActionReturn | (IDEKit_kLexActionMask & IDEKit_kLexError);
}


- (int) parseOneToken: (NSRangePointer) result ignoreWhiteSpace: (BOOL) ignoreWS
{
    if (myString == NULL)
        return IDEKit_kLexEOF;
    int strLength = [myString length];
    if (myCurLoc >= strLength) {
        [myString autorelease];
        myString = NULL;
        return IDEKit_kLexEOF;
    }
    myTempBackState = 0;
    doneWithToken = NO;
    while (myCurLoc <= myStopLoc+1) {
        if (myCurState == IDEKit_kLexStateNormal || myCurState == IDEKit_kLexStateNormalWS) {
            myCurState = ignoreWS ? IDEKit_kLexStateNormal : IDEKit_kLexStateNormalWS;
        }
        unichar peekChar = 0;
        if (myCurLoc < strLength) peekChar = [myString characterAtIndex: myCurLoc];
        int action = [self examineCharacter: peekChar inState: myCurState];
        int actionParam = (action & IDEKit_kLexActionMask);
        action = action & (~IDEKit_kLexActionMask);
        switch (action) {
            case IDEKit_kLexActionIgnore:
                myCurLoc++;
                mySubStart = myCurLoc;
                break;
            case IDEKit_kLexActionAppend:
                myCurLoc++;
                break;
            case IDEKit_kLexActionReturn:
                if (result)
                    *result = NSIntersectionRange(NSMakeRange(0,strLength),NSMakeRange(mySubStart,myCurLoc-mySubStart));
                if (actionParam == IDEKit_kLexError)
                    myCurLoc++; // consume the one thing there
                    mySubStart = myCurLoc;
                if (actionParam == IDEKit_kLexMarkupEnd) {
                    myCurState = IDEKit_kLexStateMarkupContent;
                } else {
                    myCurState = ignoreWS ? IDEKit_kLexStateNormal : IDEKit_kLexStateNormalWS;
                }
                    return actionParam; //(actionParam << 4) >> 4; // sign extend it
            case IDEKit_kLexActionAppendTo:
                myCurLoc++;
                myCurState = actionParam;
                break;
            default:
                NSLog(@"Invalid lexical action %.8X",action | actionParam);
                myCurLoc++;
        }
    }
    return IDEKit_kLexEOF; // we are at the end of the string
}

- (void) colorString: (NSMutableAttributedString *)string range: (NSRange) range colorer: (id) colorer
{
    [self startParsingString: [string string] range: range];
    if (myCurLoc >= [string length])
        return; // nothing to color - at end of string
    while (myCurLoc <= myStopLoc+1) { // make sure to go up to the EOL after the selection, just to be safe
        NSRange tokenRange;
        int nextToken = [self parseOneToken: &tokenRange ignoreWhiteSpace: YES];
        int color = IDEKit_kLangColor_NormalText;
        //NSString *token = [[string string] substringWithRange: tokenRange];
        //NSLog(@"'%@' = %d",token,nextToken);
        NSColor *realColor = NULL;
        switch ((nextToken & IDEKit_kLexKindMask)) {
            case IDEKit_kLexKindSpecial: {
                switch (nextToken) {
                    case IDEKit_kLexEOF:
                        return; // done
                    case IDEKit_kLexError:
                        color = IDEKit_kLangColor_Errors;
                        break;
                    case IDEKit_kLexWhiteSpace:
                        break;
                    case IDEKit_kLexComment:
                        color = IDEKit_kLangColor_Comments;
                        break;
                    case IDEKit_kLexString:
                        color = IDEKit_kLangColor_Strings;
                        break;
                    case IDEKit_kLexCharacter:
                        color = IDEKit_kLangColor_Characters;
                        break;
                    case IDEKit_kLexNumber:
                        color = IDEKit_kLangColor_Numbers;
                        break;
                    case IDEKit_kLexIdentifier:
                        //if (colorer) {
                        //    realColor = [colorer colorForIdentifier: token];
                        //} else {
                            color = IDEKit_kLangColor_NormalText;
                        //}
                        break;
                }
                break;
            }
            case IDEKit_kLexKindOperator:
                color = IDEKit_kLangColor_NormalText;
                break;
            case  IDEKit_kLexKindKeyword:
                color = IDEKit_kLangColor_Keywords;
                break;
            case IDEKit_kLexKindPrePro:
                color = IDEKit_kLangColor_Preprocessor;
                break;
            default:
                color = IDEKit_kLangColor_NormalText; // unknown
        }
        if (!realColor)
            realColor = IDEKit_TextColorForColor(color);
        [self color:string from: tokenRange.location to: tokenRange.location+tokenRange.length as: realColor];
    }
    if (myString) {
        [myString autorelease];
        myString = NULL;
    }
}

@end

//
//  IDEKit_UserSettings.mm
//
//  Created by Glenn Andreas on Sat Mar 22 2003.
//  Copyright (c) 2003, 2004 by Glenn Andreas
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Library General Public
//  License as published by the Free Software Foundation; either
//  version 2 of the License, or (at your option) any later version.
//  
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Library General Public License for more details.
//  
//  You should have received a copy of the GNU Library General Public
//  License along with this library; if not, write to the Free
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

NSString *IDEKit_TextColorsPrefKey = @"IDEKit_TextColors";
NSString *IDEKit_TextColorDefaultStateKey = @"IDEKit_TextColorDefault";
NSString *IDEKit_TextColorDefaultBrowserKey = @"IDEKit_TextColorBrowser";

NSString *IDEKit_TextFontNameKey = @"IDEKit_TextFontNameKey";
NSString *IDEKit_TextFontSizeKey = @"IDEKit_TextFontSizeKey";

NSString *IDEKit_TabStopKey = @"IDEKit_TabStopKey";
NSString *IDEKit_TabStopUnitKey = @"IDEKit_TabStopUnitKey";
NSString *IDEKit_TabSavingKey = @"IDEKit_TabSavingKey";
NSString *IDEKit_TabSizeKey = @"IDEKit_TabSizeKey";
NSString *IDEKit_TabIndentSizeKey = @"IDEKit_TabIndentSizeKey";
NSString *IDEKit_TabAutoConvertKey = @"IDEKit_TabAutoConvertKey";

NSString *IDEKit_TextAutoCloseKey = @"IDEKit_TextAutoCloseKey";

NSString *IDEKit_TemplatesKey = @"IDEKit_TemplatesKey";
NSString *IDEKit_KeyBindingsKey = @"IDEKit_KeyBindingsKey";

NSString *IDEKit_UserPathsKey = @"IDEKit_UserPathsKey";


NSMutableDictionary *IDEKit_DefaultUserSettings()
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: 1],IDEKit_TextColorDefaultStateKey,
        [NSNumber numberWithFloat: 0.5],  IDEKit_TabStopKey, // 1/2
        [NSNumber numberWithInt: 1],  IDEKit_TabStopUnitKey, // inch
        [NSNumber numberWithInt: 1], IDEKit_TabSavingKey, // save tabs
        [NSNumber numberWithInt: 8], IDEKit_TabSizeKey, // 8 spaces per tab
        [NSNumber numberWithInt: 4], IDEKit_TabIndentSizeKey,   // 4 spaces per indent
        [NSNumber numberWithInt: 1],  IDEKit_TabAutoConvertKey, // convert multiple spaces to tab
        [NSNumber numberWithFloat: 10.0], IDEKit_TextFontSizeKey,
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"Copyright $<_YEAR$>$!, $<_USER$>$!$=$|", @"copyright",
            NULL], IDEKit_TemplatesKey,
        [NSDictionary dictionaryWithObjectsAndKeys:
                             @"transposeParameters:",@"^$T",
                                 @"selectParameter:",@"^$P",
                             @"selectNextParameter:",@"^${",
                         @"selectPreviousParameter:",@"^$}",
                                 @"insertPageBreak:",[NSString stringWithFormat: @"^%c",3], // enter + control
            NULL], IDEKit_KeyBindingsKey,
        NULL
        ];
}


NSString *IDEKit_UserSettingsChangedNotification = @"IDEKit_UserSettingsChangedNotification";


/*
 *  IDEKit_TextColors.mm
 *  IDEKit
 *
 *  Created by Glenn Andreas on Wed May 21 2003.
 *  Copyright (c) 2003, 2004 by Glenn Andreas
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *  
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *  
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

static NSColor *IDEKit_PrimativeColorForColor(int color)
{
    switch (color) {
        case IDEKit_kLangColor_Background:
            return [NSColor whiteColor];
        case IDEKit_kLangColor_NormalText:
            return [NSColor blackColor];
        case IDEKit_kLangColor_Invisibles:
            return [NSColor whiteColor];
        case IDEKit_kLangColor_Adorners:
            return [NSColor blackColor];
        case IDEKit_kLangColor_Errors:
            return [NSColor blackColor];
        case IDEKit_kLangColor_OtherInternal2:
        case IDEKit_kLangColor_OtherInternal3:
        case IDEKit_kLangColor_OtherInternal4:
            return [NSColor whiteColor];
            // first the browser symbol coloring
        case IDEKit_kLangColor_Classes:
            return [NSColor magentaColor];
        case IDEKit_kLangColor_Constants:
        case IDEKit_kLangColor_Enums:
        case IDEKit_kLangColor_Functions:
            return [NSColor purpleColor];
        case IDEKit_kLangColor_Globals:
            return [NSColor magentaColor];
        case IDEKit_kLangColor_Macros:
        case IDEKit_kLangColor_Templates:
            return [NSColor redColor];
        case IDEKit_kLangColor_Typedefs:
            return [NSColor greenColor];
        case IDEKit_kLangColor_OtherSymbol1:
        case IDEKit_kLangColor_OtherSymbol2:
        case IDEKit_kLangColor_OtherSymbol3:
        case IDEKit_kLangColor_OtherSymbol4:
            return [NSColor blackColor];
            // more syntax coloring
        case IDEKit_kLangColor_Comments:
        case IDEKit_kLangColor_DocKeywords:
            return [NSColor brownColor];
        case IDEKit_kLangColor_Keywords:
        case IDEKit_kLangColor_AltKeywords:
        case IDEKit_kLangColor_Preprocessor:
            return [NSColor blueColor];
        case IDEKit_kLangColor_Strings:
            return [NSColor darkGrayColor];
        case IDEKit_kLangColor_FieldsBG: // for background completion templates
            return [NSColor yellowColor];
        case IDEKit_kLangColor_Characters:
            return [NSColor darkGrayColor];
        case IDEKit_kLangColor_Numbers:
            return [NSColor blackColor];
        case IDEKit_kLangColor_OtherSyntax6:
        case IDEKit_kLangColor_OtherSyntax7:
        case IDEKit_kLangColor_OtherSyntax8:
            return [NSColor blackColor];
        case IDEKit_kLangColor_UserKeyword1:
        case IDEKit_kLangColor_UserKeyword2:
        case IDEKit_kLangColor_UserKeyword3:
        case IDEKit_kLangColor_UserKeyword4:
            return [NSColor blackColor];
        case IDEKit_kLangColor_End:
            return [NSColor blackColor];
    }
    return [NSColor blackColor];
}
NSString *IDEKit_NameForColor(int color)
{
    switch (color) {
        case IDEKit_kLangColor_Background:
            return @"Background";
        case IDEKit_kLangColor_NormalText:
            return @"Normal Text";
        case IDEKit_kLangColor_Invisibles:
            return @"Invlsible Text";
        case IDEKit_kLangColor_Adorners:
            return @"Adorners";
        case IDEKit_kLangColor_Errors:
            return @"Errors";
            // first the browser symbol coloring
        case IDEKit_kLangColor_Classes:
            return @"Classes";
        case IDEKit_kLangColor_Constants: return @"Constants";
        case IDEKit_kLangColor_Enums: return @"Enums";
        case IDEKit_kLangColor_Functions: return @"Functions";
        case IDEKit_kLangColor_Globals: return @"Globals";
        case IDEKit_kLangColor_Macros: return @"Macros";
        case IDEKit_kLangColor_Templates: return @"Templates";
        case IDEKit_kLangColor_Typedefs: return @"Typedefs";
            // more syntax coloring
        case IDEKit_kLangColor_Comments: return @"Comments";
        case IDEKit_kLangColor_Keywords: return @"Keywords";
        case IDEKit_kLangColor_Preprocessor: return @"Preprocessor";
        case IDEKit_kLangColor_AltKeywords: return @"AltKeywords";
        case IDEKit_kLangColor_DocKeywords: return @"DocKeywords";
        case IDEKit_kLangColor_Strings: return @"Strings";
        case IDEKit_kLangColor_FieldsBG: return @"Field Background";
        case IDEKit_kLangColor_Characters: return @"Characters";
        case IDEKit_kLangColor_Numbers: return @"Numbers";
        case IDEKit_kLangColor_UserKeyword1: return @"User 1";
        case IDEKit_kLangColor_UserKeyword2: return @"User 2";
        case IDEKit_kLangColor_UserKeyword3: return @"User 3";
        case IDEKit_kLangColor_UserKeyword4: return @"User 4";
    }
    return nil;
}
NSColor *IDEKit_TextColorForColor(int color)
{
    id colorObject = [[[NSUserDefaults standardUserDefaults] dictionaryForKey: IDEKit_TextColorsPrefKey] objectForKey: IDEKit_NameForColor(color)];
    if (colorObject) {
        return [NSColor colorWithHTML: colorObject]; // better be a color
    } else {
        return IDEKit_PrimativeColorForColor(color);
    }
}



@implementation NSColor(IDEKit_StringToColors)
+ (NSColor *)colorWithHTML: (NSString *)hex
{
    // for example, string should be "#ffffff"
    NSScanner *scanner = [NSScanner scannerWithString: hex];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString: @" #,$"]];
    [scanner setCaseSensitive: NO];
    unsigned value;
    if ([scanner scanHexInt: &value] == NO) value = 0;
    return [NSColor colorWithCalibratedRed: float((value >> 16) & 0xff) / 255.0 green: float((value >> 8) & 0xff) / 255.0 blue: float((value) & 0xff) / 255.0 alpha: 1.0];
}
+ (NSColor *)colorWithRGB: (NSString *)triplet
{
    NSScanner *scanner = [NSScanner scannerWithString: triplet];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString: @" ()#,$"]];
    [scanner setCaseSensitive: NO];
    int red,green,blue,alpha;
    if ([scanner scanInt: &red] == NO) red = 0;
    if ([scanner scanInt: &green] == NO) green = 0;
    if ([scanner scanInt: &blue] == NO) blue = 0;
    if ([scanner scanInt: &alpha] == NO) alpha = 255;
    return [NSColor colorWithCalibratedRed: float(red) / 255.0 green: float(green) / 255.0 blue: float(blue) / 255.0 alpha: float(alpha) / 255.0];
}
- (NSString *)htmlString
{
    id rgb = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    return [NSString stringWithFormat: @"#%.2X%.2X%.2X", (int)([rgb redComponent] * 255.0),(int)([rgb greenComponent] * 255.0),(int)([rgb blueComponent] * 255.0)];
}
@end

