//
//  mAChuginManager.h
//  miniAudicle
//
//  Created by Spencer Salazar on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mAChuginManager : NSObject

+ (mAChuginManager *)chuginManager;

- (BOOL)installChuginForCurrentUser:(NSString *)filepath;
- (BOOL)installChuginForAllUsers:(NSString *)filepath;

@end
