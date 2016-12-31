//
//  mAUtil.h
//  miniAudicle
//
//  Created by Spencer Salazar on 12/30/16.
//
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

void delayAnd(CFTimeInterval delay, void (^block)());

#ifdef __cplusplus
}
#endif
