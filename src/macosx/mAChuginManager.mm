//
//  mAChuginManager.m
//  miniAudicle
//
//  Created by Spencer Salazar on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mAChuginManager.h"

#import "BLAuthentication.h"


static mAChuginManager * g_chuginManager = nil;


@interface mAChuginManager ()

- (NSString *)currentUserChuginDirectory;
- (NSString *)allUsersChuginDirectory;

@end


@implementation mAChuginManager

+ (void)initialize
{
    if(g_chuginManager == nil)
    {
        g_chuginManager = [mAChuginManager new];
    }
}

+ (mAChuginManager *)chuginManager
{
    return g_chuginManager;
}

- (BOOL)installChuginForCurrentUser:(NSString *)filepath
{    
    return NO;
}

- (BOOL)installChuginForAllUsers:(NSString *)filepath
{
    BLAuthentication * auth = [BLAuthentication sharedInstance];
    
    NSString * destPath = [self allUsersChuginDirectory];
    
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:destPath isDirectory:&isDirectory];
    
    if(fileExists && !isDirectory)
    {
        // error
        return NO;
    }
    
    if(!fileExists)
    {
        /* create directory */
        
        NSString * cmd = @"/bin/mkdir";
        
        if(![auth authenticate:cmd])
        {
            // error
            return NO;
        }
        
        if(![auth executeCommandSynced:cmd
                              withArgs:[NSArray arrayWithObjects:@"-p", destPath, nil]])
        {
            // error
            return NO;
        }
    }
    
    NSString * cmd = @"/bin/cp";
    
    if(![auth authenticate:@"/bin/cp"])
    {
        // error
        return NO;
    }
    
    if(![auth executeCommand:cmd
                    withArgs:[NSArray arrayWithObjects:filepath, destPath, nil]])
    {
        return NO;
    }
    
    return YES;
}


- (NSString *)currentUserChuginDirectory
{
    return [@"~/Application Support/ChucK/ChuGins/" stringByExpandingTildeInPath];
}

- (NSString *)allUsersChuginDirectory
{
    return @"/usr/lib/chuck/";
}

@end
