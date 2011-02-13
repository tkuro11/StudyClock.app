//
//  dictateTime.m
//  StudyClock
//
//  Created by 黒澤 隆之 on 10/11/03.
//  Copyright 2010 Renesas Technology Corp. All rights reserved.
//

#import "dictateTime.h"
#import "clock.h"


NSString* tensign[]  = {@"れい",@"いち",@"に",@"さん",@"よん",@"ご",@"ろく",@"なな",@"はち",@"きゅう"};
NSString* secsign[]  = {@"れい",@"いち",@"に",@"さん",@"よん",@"ご",@"ろく",@"なな",@"はち",@"きゅう"};
NSString* minsign[]  = {@"れい",@"いっ",@"に",@"さん",@"よん",@"ご",@"ろっ",@"なな",@"はっ",@"きゅう"};
NSString* hoursign[] = {@"れい",@"いち",@"に",@"さん",@"よ",@"ご",@"ろく",@"ひち",@"はち",@"く"};

static inline BOOL min_special(int digit)
{
	switch (digit) {
		case 1:
		case 3:
		case 4: // very irresolute... 
		case 6:
		case 8:
			return TRUE;
		default:
			return FALSE;
	}
}

static inline NSString* convert(int digit, int mode)
{
	BOOL from10or20;
	BOOL just_m10;
	NSString* head = @"";
	NSString* ten = @"";
	NSString* body = @"";
	NSString* tail;  // timedigit consists of  <head> <ten> <body> <tail>

	if (digit==0 && mode == MIN) return @"";
	if (digit==0 && mode == SEC) return @"";

	from10or20 = (20 == digit || digit == 10);
	just_m10   = (digit >0 && digit % 10 == 0);

	
	if (digit>=10) {
		ten = (mode == MIN && just_m10)? @"じゅっ": @"じゅう";
		if (digit >= 20) head = tensign[digit/10];
		digit %= 10;
	}
										 
	switch (mode) {
		case HOUR:
			if (!from10or20) {
				body = hoursign[digit];
			}
			tail = @"じ";
			break;
		case MIN:
			body = just_m10?@"":minsign[digit];
			tail = (just_m10 || min_special(digit))? @"ぷん": @"ふん";
			break;
		case SEC:
			if (just_m10) {
				body = @"";
				tail = @"";
			} else {
				body = secsign[digit];
			}
			tail = @"びょう";
			break;
		default:
			break;
	}
	return [NSString stringWithFormat:@"%@%@%@%@", head, ten, body, tail, nil];
	
}

@implementation dictateTime
+(NSString*)dictateHour:(int)hour Minute:(int)minute Second:(int)second
{
	return [NSString stringWithFormat:@"%@ %@ %@", convert(hour, HOUR), convert(minute, MIN), convert(second, SEC), nil];
}

@end
