//
//  NSPanel+ButtonTag.m
//  miniAudicle
//
//  Created by leanne on 1/11/17.
//


#import "NSPanel+ButtonTag.h"

@implementation NSPanel (ButtonTag)

- (int)tagForButtonWithTitle:(NSString *)title
{
    NSArray *panelLevel1Views = self.contentView.subviews;
    
    for (NSView *level1View in panelLevel1Views) {
        
        NSArray *level2Views = level1View.subviews;
        
        for (NSView *level2View in level2Views) {
            
            if ([level2View isKindOfClass:NSButton.class]) {
                
                NSString *btnTitle = ((NSButton *)level2View).title;
                
                if ([btnTitle  isEqual: title]) {
                    int tag = ((NSButton *)level2View).tag;
                    return tag;
                }
            }
        }
    }
    
    return 0;
}

- (void)setTag:(int)tagValue forButtonWithTitle:(NSString *)title
{
    NSArray *panelLevel1Views = self.contentView.subviews;
    BOOL canStopNow = false;
    
    for (NSView *level1View in panelLevel1Views) {
        
        NSArray *level2Views = level1View.subviews;
        
        for (NSView *level2View in level2Views) {
            
            if ([level2View isKindOfClass:NSButton.class]) {
                
                NSString *btnTitle = ((NSButton *)level2View).title;
                
                if ([btnTitle  isEqual: title]) {
                    [(NSButton *)level2View setTag:tagValue];
                    canStopNow = true;
                    break;
                }
            }
        }
        
        if (canStopNow) { break; }
    }
}

- (void)enableButtonWithTag:(int)tagValue
{
    NSButton *taggedButton = [self.contentView viewWithTag: tagValue];
    BOOL taggedButtonAvailable = (taggedButton != nil);
    
    if (taggedButtonAvailable) { taggedButton.enabled = YES; }

}

- (void)disableButtonWithTag:(int)tagValue
{
    NSButton *taggedButton = [self.contentView viewWithTag: tagValue];
    BOOL taggedButtonAvailable = (taggedButton != nil);
    
    if (taggedButtonAvailable) { taggedButton.enabled = NO; }
    
}

@end
