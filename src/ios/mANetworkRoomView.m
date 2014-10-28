//
//  mANetworkRoomView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/7/14.
//
//

#import "mANetworkRoomView.h"
#import "mANetworkManager.h"
#import "NSMutableArray+MapFilterReduce.h"
#import "mACGContext.h"


static const CGFloat mANetworkRoomView_RoomNameHeight = 36;
static const CGFloat mANetworkRoomView_MemberNameHeight = 36;


@interface mANetworkRoomView ()
{
    NSDictionary *_roomNameAttributes;
    NSDictionary *_memberNameAttributes;
}

@property (strong, nonatomic) NSMutableArray *members;

- (void)adjustSize;

@end


@implementation mANetworkRoomView

- (void)setRoom:(mANetworkRoom *)room
{
    _room = room;
    
    [self adjustSize];
    [self setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.members = [NSMutableArray new];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        _roomNameAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:18],
                                 NSParagraphStyleAttributeName: paragraphStyle };
        
        _memberNameAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:18],
                                   NSParagraphStyleAttributeName: paragraphStyle,
                                   NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bounds = self.bounds;
    
    CGContextAddRoundedRect(ctx, bounds, 8);
    CGContextClip(ctx);
    
    if(self.room)
    {
        CGRect roomNameBounds = bounds;
        roomNameBounds.size.height = mANetworkRoomView_RoomNameHeight;
        CGSize textSize = [self.room.name sizeWithAttributes:_roomNameAttributes];
        
        [[UIColor whiteColor] set];
        CGContextFillRect(ctx, roomNameBounds);
        
        CGRect textRect = roomNameBounds;
        textRect.origin.y += roomNameBounds.size.height/2 - textSize.height/2;
        textRect.size.height -= roomNameBounds.size.height/2 - textSize.height/2;
        [self.room.name drawInRect:textRect withAttributes:_roomNameAttributes];
    }
    
    CGRect memberNameBounds = bounds;
    memberNameBounds.size.height = mANetworkRoomView_MemberNameHeight;
    memberNameBounds.origin.y += mANetworkRoomView_RoomNameHeight;
    
    for(mANetworkRoomMember *member in self.members)
    {
        CGSize textSize = [self.room.name sizeWithAttributes:_memberNameAttributes];
        
        [[UIColor whiteColor] set];
        CGContextMoveToPoint(ctx, memberNameBounds.origin.x+8, memberNameBounds.origin.y-1);
        CGContextAddLineToPoint(ctx, memberNameBounds.origin.x+memberNameBounds.size.width-8, memberNameBounds.origin.y-1);
        CGContextSetLineWidth(ctx, 1);
        CGContextStrokePath(ctx);
        
        [[UIColor colorWithWhite:0.44 alpha:1.0] set];
        CGContextFillRect(ctx, memberNameBounds);
        
        CGRect textRect = memberNameBounds;
        textRect.origin.y += memberNameBounds.size.height/2 - textSize.height/2;
        textRect.size.height -= memberNameBounds.size.height/2 - textSize.height/2;
        [member.name drawInRect:textRect withAttributes:_memberNameAttributes];
        
        memberNameBounds.origin.y += mANetworkRoomView_MemberNameHeight;
    }
}

- (void)addMember:(mANetworkRoomMember *)member
{
    [self.members addObject:member];
    
    [self adjustSize];
    [self setNeedsDisplay];
}

- (void)removeMember:(mANetworkRoomMember *)rmMember
{
    [self.members filter:^BOOL(id object) {
        if([[object uuid] isEqualToString:rmMember.uuid])
            return YES;
        else
            return NO;
    }];
    
    [self adjustSize];
    [self setNeedsDisplay];
}

- (void)adjustSize
{
    CGRect frame = self.frame;
    frame.size.height = mANetworkRoomView_RoomNameHeight + mANetworkRoomView_MemberNameHeight*[self.members count];
    self.frame = frame;
}

@end
