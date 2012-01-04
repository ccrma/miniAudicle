//
//  mAConsoleMonitor.h
//  miniAudicle
//
//  Created by Spencer Salazar on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mAConsoleMonitorController : UIViewController
{
    IBOutlet UITextView * _textView;
    
    NSFileHandle * std_out; // encapsulation of piped stdout
    NSFileHandle * std_err; //encapsulation of piped stderr
}

@end
