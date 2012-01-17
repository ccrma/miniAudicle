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
