//
//  mACGContext.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#ifndef __miniAudicle__mACGContext__
#define __miniAudicle__mACGContext__

#import <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
    
void CGContextAddRoundedRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius);
void CGContextStrokeRoundedRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus
    
#endif /* defined(__miniAudicle__mACGContext__) */
