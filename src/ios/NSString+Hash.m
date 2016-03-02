//
//  NSString+Hash.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/1/16.
//
//

#import "NSString+Hash.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Hash)

- (NSData *)sha1
{
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:self.fastestEncoding];
    if(CC_SHA1([data bytes], [data length], hash))
    {
        NSData *sha1 = [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
        return sha1;
    }
    
    return nil;
}

- (NSData *)sha256
{
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:self.fastestEncoding];
    if(CC_SHA256([data bytes], [data length], hash))
    {
        NSData *sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
        return sha256;
    }
    
    return nil;
}

- (NSString *)sha1String
{
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:self.fastestEncoding];
    if(CC_SHA1([data bytes], [data length], hash))
    {
        NSMutableString *sha1Str = [NSMutableString new];
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
            [sha1Str appendFormat:@"%02X", hash[i]];
        
        return sha1Str;
    }
    
    return nil;
}

- (NSString *)sha256String
{
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:self.fastestEncoding];
    if(CC_SHA256([data bytes], [data length], hash))
    {
        NSMutableString *sha256Str = [NSMutableString new];
        for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
            [sha256Str appendFormat:@"%02X", hash[i]];
        
        return sha256Str;
    }
    
    return nil;
}

@end
