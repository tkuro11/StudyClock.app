//
//  StudyClockAppDelegate.m
//  StudyClock
//
//  Created by 黒澤 隆之 on 10/10/31.
//  Copyright 2010 Renesas Technology Corp. All rights reserved.
//

#import "StudyClockAppDelegate.h"

@implementation StudyClockAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(IBAction)toggleSec: (id)sender {
	[clockview togglesec:sender];
	int state = [sender state];
	if (state == NO) {
		[sec_up setHidden:YES];
		[sec_down setHidden:YES];
	} else {
		[sec_up setHidden:NO];
		[sec_down setHidden:NO];
	}
}

@end
