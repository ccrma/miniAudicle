//
//  NSString+NSString_Lines.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import "NSString+NSString_Lines.h"

@implementation NSString (NSString_Lines)

- (NSRange)rangeOfLine:(NSInteger)lineNumber
{
    unsigned length = [self length];
    unsigned lineStart = 0, lineEnd = 0, contentsEnd = 0;
    int line = 0;
    NSRange currentRange;

    while(lineEnd < length && line < lineNumber)
    {
        [self getLineStart:&lineStart end:&lineEnd
               contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
        currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
        
        line++;
    }
    
    if(line == lineNumber)
        return currentRange;
    else
        return NSMakeRange(NSNotFound, 0);
}

- (NSInteger)indexOfPreviousNewline:(NSInteger)index
{
    for(int i = index-1; i >= 0; i--)
    {
        unichar c = [self characterAtIndex:i];
        if(c == '\n' || c == '\r')
            return i;
    }
    
    return -1;
}

@end
