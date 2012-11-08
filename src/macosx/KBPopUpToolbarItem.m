//
//  KBPopUpToolbarItem.m
//  --------------------
//
//  Created by Keith Blount on 14/05/2006.
//  Copyright 2006 Keith Blount. All rights reserved.
//

#import "KBPopUpToolbarItem.h"

@interface KBDelayedPopUpButtonCell : NSButtonCell
@end

@implementation KBDelayedPopUpButtonCell

- (NSPoint)menuPositionForFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSPoint result = [controlView convertPoint:cellFrame.origin toView:nil];
    result.x += 1.0;
    result.y -= cellFrame.size.height + 5.5;
    return result;
}

- (void)showMenuForEvent:(NSEvent *)theEvent controlView:(NSView *)controlView cellFrame:(NSRect)cellFrame
{
    NSPoint menuPosition = [self menuPositionForFrame:cellFrame inView:controlView];
    
    // Create event for pop up menu with adjusted mouse position
    NSEvent *menuEvent = [NSEvent mouseEventWithType:[theEvent type]
                                            location:menuPosition
                                       modifierFlags:[theEvent modifierFlags]
                                           timestamp:[theEvent timestamp]
                                        windowNumber:[theEvent windowNumber]
                                             context:[theEvent context]
                                         eventNumber:[theEvent eventNumber]
                                          clickCount:[theEvent clickCount]
                                            pressure:[theEvent pressure]];
    
    [NSMenu popUpContextMenu:[self menu] withEvent:menuEvent forView:controlView];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
    
    BOOL result = NO;
    NSDate *endDate;
    NSPoint currentPoint = [theEvent locationInWindow];
    BOOL done = NO;
    BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];
    
    // Catch next mouse-dragged or mouse-up event until timeout
    BOOL mouseIsUp = NO;
    NSEvent *event;
    while (!done)
    {
        NSPoint lastPoint = currentPoint;
        
        // Set up timer for pop-up menu if we have one
        if ([self menu])
            endDate = [NSDate dateWithTimeIntervalSinceNow:0.6];
        else
            endDate = [NSDate distantFuture];
        
        event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)
                                   untilDate:endDate
                                      inMode:NSEventTrackingRunLoopMode
                                     dequeue:YES];
        
        if (event)  // Mouse event
        {
            currentPoint = [event locationInWindow];
            
            // Send continueTracking.../stopTracking...
            if (trackContinously)
            {
                if (![self continueTracking:lastPoint at:currentPoint inView:controlView])
                {
                    done = YES;
                    [self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
                }
                if ([self isContinuous])
                {
                    [NSApp sendAction:[self action] to:[self target] from:controlView];
                }
            }
            
            mouseIsUp = ([event type] == NSLeftMouseUp);
            done = done || mouseIsUp;
            
            if (untilMouseUp)
            {
                result = mouseIsUp;
            }
            else
            {
                // Check if the mouse left our cell rect
                result = NSPointInRect([controlView convertPoint:currentPoint fromView:nil], cellFrame);
                if (!result)
                    done = YES;
            }
            
            if (done && result && ![self isContinuous])
                [NSApp sendAction:[self action] to:[self target] from:controlView];
        
        }
        else    // Show menu
        {
            done = YES;
            result = YES;
            [self showMenuForEvent:theEvent controlView:controlView cellFrame:cellFrame];
        }
    }
    return result;
}

@end

@interface KBDelayedPopUpButton : NSButton
@end

@implementation KBDelayedPopUpButton

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        if (![[self cell] isKindOfClass:[KBDelayedPopUpButtonCell class]]) {
            NSString *title = [self title];
            if (title == nil) title = @"";          
            [self setCell:[[[KBDelayedPopUpButtonCell alloc] initTextCell:title] autorelease]];
            [[self cell] setControlSize:NSRegularControlSize];
        }
    }
    return self;
}

@end


@implementation KBPopUpToolbarItem

- (id)initWithItemIdentifier:(NSString *)ident
{
    if (self = [super initWithItemIdentifier:ident])
    {
        KBDelayedPopUpButton *button = [[KBDelayedPopUpButton alloc] initWithFrame:NSMakeRect(0,0,32,32)];
        [button setButtonType:NSMomentaryChangeButton];
        [button setBordered:NO];
        [self setView:button];
        [self setMinSize:NSMakeSize(32,32)];
        [self setMaxSize:NSMakeSize(32,32)];
    }
    return self;
}

- (KBDelayedPopUpButtonCell *)popupCell
{
    return [(KBDelayedPopUpButton *)[self view] cell];
}

- (void)setMenu:(NSMenu *)menu
{
    [[self popupCell] setMenu:menu];
}

- (NSMenu *)menu
{
    return [[self popupCell] menu];
}

- (void)setAction:(SEL)aSelector
{
    [[self popupCell] setAction:aSelector];
}

- (SEL)action
{
    return [[self popupCell] action];
}

- (void)setTarget:(id)anObject
{
    [[self popupCell] setTarget:anObject];
}

- (id)target
{
    return [[self popupCell] target];
}

- (void)setImage:(NSImage *)anImage
{
    [[self popupCell] setImage:anImage];
}

- (NSImage *)image
{
    return [[self popupCell] image];
}

- (void)setToolTip:(NSString *)theToolTip
{
    [[self view] setToolTip:theToolTip];
}

- (NSString *)toolTip
{
    return [[self view] toolTip];
}

- (void)validate
{
    [super validate];
    
    if ([[self toolbar] delegate] &&
        [[[self toolbar] delegate] respondsToSelector:@selector(validateToolbarItem:)] &&
        [self target] && [[self target] respondsToSelector:[self action]])
        [self setEnabled:[[[self toolbar] delegate] validateToolbarItem:self]];
}

@end
