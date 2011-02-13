//
//  ClockView.m
//
//  Created by 黒澤 隆之 on 10/10/31.
//  Copyright 2010 Renesas Technology Corp.. All rights reserved.
//

#import "ClockView.h"
#import "clock.h"
#import "SayKana.h"

#import "dictateTime.h"

@implementation ClockView

inline static int min(int a,int b)
{
	return a < b ? a : b;
}

-(void)dictate:(id)sender
{
	[SayKana saykana_word:reading.stringValue];
}

-(id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
	hour = 12;
	[self setNeedsDisplay:YES];
	return self;
}


-(void)drawHand: (double)percent withLength: (int)diameter withThickness:(double)thick withGap: (int) gap
{
	double rad = 2*M_PI* percent;
	double rad_p = rad + thick;
	double rad_m = rad - thick;
	double 
		cs   = sin(rad  ), sn   = cos(rad  ),
		cs_p = sin(rad_p), sn_p = cos(rad_p),
		cs_m = sin(rad_m), sn_m = cos(rad_m);
	double edgex = diameter*cs;
	double edgey = diameter*sn;
	double rightx = diameter/4*cs_p;
	double righty = diameter/4*sn_p;
	double leftx = diameter/4*cs_m;
	double lefty = diameter/4*sn_m;

	NSBezierPath *hourhand = [NSBezierPath bezierPath];
	NSPoint p = center;
	p.x += gap;
	[hourhand moveToPoint:p];

	[hourhand lineToPoint:NSMakePoint(p.x+(int)rightx, p.y+(int)righty)];
	[hourhand lineToPoint:NSMakePoint(p.x+(int)edgex, p.y+(int)edgey)];
	[hourhand lineToPoint:NSMakePoint(p.x+(int)leftx, p.y+(int)lefty)];

	[hourhand closePath];
	[hourhand fill];
}

-(void)drawBoard
{
	NSRect bounds = [self bounds];
	bounds.origin.x +=10; bounds.origin.y +=10;
	bounds.size.width -=20;	bounds.size.height -=20;
	NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:bounds];

	for (int i = 0; i<= 22; i++) {
		bounds.origin.x +=1; bounds.origin.y +=1;
		bounds.size.width -=2;	bounds.size.height -=2;
		NSBezierPath* fill = [NSBezierPath bezierPathWithOvalInRect:bounds];
		float f = (float)i/22.0*0.5+0.5;
		[[NSColor colorWithDeviceRed:f green:f blue:f alpha:1.0] set];
		[fill fill];
	}


	[path setLineWidth:20.0];
	[[NSColor orangeColor] set];
	[path stroke];
	
	NSDictionary *normal = 
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSFont boldSystemFontOfSize:40*size.width/640], NSFontAttributeName, nil];
	NSDictionary *large = 
	[NSDictionary dictionaryWithObjectsAndKeys:
	 [NSFont boldSystemFontOfSize:60*size.width/640], NSFontAttributeName, nil];
	
	for (int i = 1; i<= 12; i++) {
		NSString* str = [NSString stringWithFormat:@"%d", i];
		double r  = size.width/2*0.8, rh = size.height/2*0.8;
		double xx = r*sin(M_PI*2*i/12), yy = rh*cos(M_PI*2*i/12);

		NSPoint p = NSMakePoint(center.x + (int)xx-size.width/30, center.y + (int)yy-size.height/30);
		if (i % 3 == 0) {
			p.x -=10; p.y -= 5;
			[str drawAtPoint:p withAttributes:large];
		} else
			[str drawAtPoint:p withAttributes:normal];
	}
	
	[path setLineWidth:20.0];
	[[NSColor orangeColor] set];
	[path stroke];
}

-(IBAction)now: (id) sender
{
	NSDate* today = [NSDate date];
	NSCalendar* cal = [NSCalendar currentCalendar];
	NSDateComponents* comp = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
									fromDate:today];
	hour = [comp hour];
	minute = [comp minute];
	second = [comp second];

	[self setNeedsDisplay:TRUE];
}

-(void)awakeFromNib
{
	//[self resizeWithOldSuperviewSize:size];
		size   = [self bounds].size;
		center = NSMakePoint(size.width/2, size.height/2);	
}

-(IBAction)toggle_now:(NSMenuItem*) sender
{
	[sender setAlternate:TRUE];
}


-(NSPoint)getvector:(NSEvent *)theEvent
{
	NSPoint p = [self convertPoint: theEvent.locationInWindow fromView:nil];
	p = NSMakePoint(p.x - center.x, p.y - center.y);

	return p;
}


inline static double innerProduct(NSPoint p1, NSPoint p2)
{
	return p1.x*p2.x + p1.y*p2.y;
}

-(void)mouseUp:(NSEvent *)theEvent
{
	[reading setStringValue:[dictateTime dictateHour:hour Minute:minute Second:second]];
}

-(void)mouseDown:(NSEvent *)theEvent
{
	NSPoint v = [self getvector:theEvent];

	if (v.x == 0 && v.y == 0) return;	
	
	double rad_hour = 2*M_PI*(hour/12.0);
	double rad_min  = 2*M_PI*(minute/60.0);
	double rad_sec  = 2*M_PI*(second/60.0);
	NSPoint v_hour = NSMakePoint(sin(rad_hour), cos(rad_hour));
	NSPoint v_min  = NSMakePoint(sin(rad_min), cos(rad_min));
	NSPoint v_sec  = NSMakePoint(sin(rad_sec), cos(rad_sec));
	
	double p_hour = innerProduct(v, v_hour);
	double p_min = innerProduct(v, v_min);
	double p_sec = innerProduct(v, v_sec);
	
	if (p_hour > p_min)
		if (p_hour >= p_sec) 
			hands = HOUR; // p_hour > p_sec && p_min > p_sec
		else 
			hands = SEC;  // p_hour > p_min && p_sec >= p_hour
	else if (p_min >= p_sec) 
		hands = MIN;   // p_min > p_hour && p_min > p_sec 
	else 
		hands = SEC;   // p_min > p_hour && p_sec >= p_min
}

int findSection(NSPoint v, int div)
{
	int max=0;
	int i, section;
	NSPoint cand;
	int p;

	for (i = 0; i< div; i++) {
		cand.x = sin(2*M_PI*i/div);
		cand.y = cos(2*M_PI*i/div);
		
		p = innerProduct(v, cand);
		if (p > max) { max = p; section = i; }
	}
	return section;
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint v = [self getvector:theEvent];
	switch (hands) {
		case HOUR:
			hour = findSection(v, 12);
			if (!enable24 && hour == 0) hour = 12;
			break;
		case MIN:
			minute = findSection(v, 60);
			if (prev_minute > 40 && minute < 20) 
				[self hourUp:nil];
			else if (prev_minute < 20 && minute > 40) 
				[self hourDown:nil];
			prev_minute = minute;
			break;
		case SEC:
			second = findSection(v, 60);
			if (prev_second > 40 && second < 20) 
				[self minUp:nil];
			else if (prev_second < 20 && second > 40)
				[self minDown:nil];
			prev_second = second;
			break;
		default:
			break;
	}
	[self setNeedsDisplay:TRUE];
}

-(void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
	[super resizeWithOldSuperviewSize:oldSize];
	size   = [self bounds].size;
	center = NSMakePoint(size.width/2, size.height/2);	
}

-(void)drawRect:(NSRect)dirtyRect
{
	double rad;
	
	[self drawBoard];

	if (enablesec) {
		// second hand
		rad = second/60.0;
		[[NSColor grayColor] set];
		[self drawHand:rad withLength:min(center.x, center.y)-20 withThickness:0.05 withGap: 0];
	}

	// hour hand (shadow)
	rad = hour/12.0+minute/60.0/12.0+second/60.0/60.0/12.0;
	for (int i = 0; i< 4; i++) {
		float f = 1.0 -(i/3.0)*0.3;
		[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:f/20] set];
		[self drawHand:rad withLength: min(center.x, center.y)/2 withThickness:0.2+f*0.5-0.35 withGap: 6];
	}
	// min hand  (shadow)
	rad = minute/60.0 +second/60.0/60.0;
	for (int i = 0; i< 4; i++) {
		float f = 1.0 -(i/3.0)*0.3;
		[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:f/20] set];
		[self drawHand:rad withLength:min(center.x, center.y)-50 withThickness:0.11+f*0.5-0.35 withGap: 6];
	}
	// center pin(shadow)
	NSRect cc = {center.x+8-15, center.y-8-15, 37, 34};
	for (int i = 0; i< 8; i++) {
		float f = 1.0 -(i/7.0)*0.3;
		cc.origin.x-=1; cc.origin.y+=1;
		--cc.size.width; --cc.size.height;
		
		[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:f/40] set];
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:cc];
		[path fill];
	}

	// hour hand
	rad = hour/12.0+minute/60.0/12.0+second/60.0/60.0/12.0;
	[[NSColor blueColor] set];
	[self drawHand:rad withLength: min(center.x, center.y)/2 withThickness:0.2 withGap: 0];

	// min hand
	rad = minute/60.0 +second/60.0/60.0;
	[[NSColor redColor] set];
	[self drawHand:rad withLength:min(center.x, center.y)-50 withThickness:0.11 withGap: 0];
	
	[[NSColor colorWithDeviceRed:0.3 green:0.5 blue:0.7 alpha:1.0] set];
	NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:cc];
	[path fill];
	
	if (enablesec) {
		[reading setStringValue:[dictateTime dictateHour:hour Minute:minute Second:second]];
		[digital setStringValue: [NSString stringWithFormat: @"%02d:%02d:%02d", hour, minute, second]]; 
	} else {
		[reading setStringValue:[dictateTime dictateHour:hour Minute:minute Second:0]];
		[digital setStringValue: [NSString stringWithFormat: @"%02d:%02d", hour, minute, second]];
	}

}

-(IBAction)toggle24hour:(id) sender
{
	if (enable24) {
		[sender setState:NO];
		enable24= false;
	} else {
		if (hour > 12) hour -= 12;
		else if (hour == 0) hour = 12;
		[sender setState:YES];
		enable24= true;
	}
	[self setNeedsDisplay:YES];
}

-(IBAction)togglesec:(id) sender
{
	if (enablesec) {
		[sender setState:NO];
		enablesec= false;
	} else {
		[sender setState:YES];
		enablesec= true;
	}
	[self setNeedsDisplay:YES];
}


-(IBAction)hourUp:(id) sender
{
	if (enable24) {
		if (++hour > 23) hour = 0;
	} else {
		if (++hour > 12) hour = 1;
	}

	[self setNeedsDisplay:TRUE];
}

-(IBAction)hourDown:(id) sender
{
	if (enable24) {
		if (--hour < 0) hour = 23;
	} else {
		if (--hour < 1) hour = 12;
	}

	[self setNeedsDisplay:TRUE];
}

-(IBAction)minUp:(id) sender
{
	if (++minute > 59) {
		minute = 0;
		[self hourUp:self];
	}
	[self setNeedsDisplay:TRUE];
}

-(IBAction)minDown:(id) sender
{
	if (--minute < 0) {
		minute = 59;
		[self hourDown: self];
	}
	[self setNeedsDisplay:TRUE];
}

-(IBAction)secUp:(id) sender
{
	if (++second > 59) {
		second = 0;
		[self minUp:self];
	}
	[self setNeedsDisplay:TRUE];
}

-(IBAction)secDown:(id) sender
{
	if (--second < 0) {
		second = 59;
		[self minDown:self];
	}
	[self setNeedsDisplay:TRUE];
}

@end