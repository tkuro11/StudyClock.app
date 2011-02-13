//
//  ClockView.h
//
//  Created by 黒澤 隆之 on 10/10/31.
//  Copyright 2010 Renesas Technology Corp.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ClockView : NSView {
	int hour, minute, second;
	int prev_minute, prev_second;
	IBOutlet NSTextField* digital;
	IBOutlet NSTextField* reading;
	IBOutlet NSTimer* timer;
	NSPoint center;
	NSSize  size;
	int    hands;
	bool   enable24;
	bool   enablesec;
}
-(IBAction)hourUp: (id)sender;
-(IBAction)hourDown: (id)sender;
-(IBAction)minUp: (id)sender;
-(IBAction)minDown: (id)sender;
-(IBAction)secUp: (id)sender;
-(IBAction)secDown: (id)sender;
-(IBAction)now: (id)sender;
-(IBAction)toggle_now:(id) sender;
-(IBAction)dictate:(id) sender;
-(IBAction)toggle24hour:(id) sender;
-(IBAction)togglesec:(id) sender;

@end
