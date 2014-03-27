//
//  mACGContext.c
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#include "mACGContext.h"


void CGContextAddRoundedRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius)
{
    CGContextMoveToPoint(ctx, rect.origin.x+cornerRadius, rect.origin.y);
    
    CGContextAddArcToPoint(ctx, rect.origin.x+rect.size.width, rect.origin.y,
                           rect.origin.x+rect.size.width, rect.origin.y+rect.size.height, cornerRadius);
    
    CGContextAddArcToPoint(ctx, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height,
                           rect.origin.x, rect.origin.y+rect.size.height, cornerRadius);
    
    CGContextAddArcToPoint(ctx, rect.origin.x, rect.origin.y+rect.size.height,
                           rect.origin.x, rect.origin.y, cornerRadius);
    
    CGContextAddArcToPoint(ctx, rect.origin.x, rect.origin.y,
                           rect.origin.x+rect.size.width, rect.origin.y, cornerRadius);
}

void CGContextStrokeRoundedRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius)
{
    CGContextAddRoundedRect(ctx, rect, cornerRadius);
    
    CGContextStrokePath(ctx);
}

