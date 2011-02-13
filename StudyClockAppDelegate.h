//
//  StudyClockAppDelegate.h
//  StudyClock
//
//  Created by 黒澤 隆之 on 10/10/31.
//  Copyright 2010 Renesas Technology Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClockView.h"

@interface StudyClockAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSButton* sec_up;
	IBOutlet NSButton* sec_down;
	IBOutlet ClockView* clockview;
}
-(IBAction)toggleSec: (id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
