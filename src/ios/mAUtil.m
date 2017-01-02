//
//  mAUtil.m
//  miniAudicle
//
//  Created by Spencer Salazar on 12/30/16.
//
//

#import "mAUtil.h"

void delayAnd(CFTimeInterval delay, void (^block)())
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_after(time, queue, block);
}

NSString *documentPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

NSString *libraryPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
