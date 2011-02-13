//
//  saykana.m
//  StudyClock
//
//  Created by 黒澤 隆之 on 10/11/03.
//  Copyright 2010 Renesas Technology Corp. All rights reserved.
//

#import "saykana.h"

static NSString* path = @"/usr/local/bin/saykana";

@implementation SayKana
@synthesize saykana_path;

+(void)saykana_word:(NSString*)phrase
{
	const char *c = [[NSString stringWithFormat:@"%@ '%@　です'", path, 
					  phrase, nil] UTF8String];
	system(c);	
}

@end
