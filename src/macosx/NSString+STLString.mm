//
//  NSObject+STLString.m
//  miniAudicle
//
//  Created by Spencer Salazar on 5/1/13.
//
//

#import "NSString+STLString.h"

using namespace std;

@implementation NSString ( STLString )

- (string)stlString
{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding
                       allowLossyConversion:YES];
    return string( ( char * ) [data bytes], [data length] );
}

@end
