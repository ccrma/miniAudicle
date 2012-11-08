/* mABrowserController */

#import <Cocoa/Cocoa.h>
#import <vector>

using namespace std;

@interface mABrowserController : NSObject
{
    NSWindow * window;
    NSPopUpButton * source;
    NSOutlineView * ov;
    
    NSMutableArray * root;
    NSMutableArray * audio;
    NSMutableArray * midi;
    NSMutableArray * hid;
    
    BOOL vm_on;
}

- (void)changeSource:(id)sender;

@end
