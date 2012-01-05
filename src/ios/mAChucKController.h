//
//  mAChucKController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class miniAudicle;


@interface mAChucKController : NSObject
{
    miniAudicle * ma;
}

@property (nonatomic) miniAudicle * ma;

+ (mAChucKController *)chuckController;

@end
