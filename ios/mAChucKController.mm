//
//  mAChucKController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 Spencer Salazar. All rights reserved.
//

#import "mAChucKController.h"
#import "miniAudicle.h"


static mAChucKController * g_chuckController = nil;


@implementation mAChucKController

@synthesize ma;

+ (void)initialize
{
    if(g_chuckController == nil)
        g_chuckController = [mAChucKController new];
}

+ (mAChucKController *)chuckController
{
    return g_chuckController;
}

- (id)init
{
    if(self = [super init])
    {
        ma = new miniAudicle;
        
        ma->set_sample_rate(44100);
        ma->set_num_inputs(2);
        ma->set_num_outputs(2);
        ma->set_enable_audio(TRUE);
        ma->set_buffer_size(256);
        ma->set_log_level(2);
    }
    
    return self;
}

@end
