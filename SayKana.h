//
//  saykana.h
//  StudyClock
//
//  Created by 黒澤 隆之 on 10/11/03.
//  Copyright 2010 Renesas Technology Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SayKana : NSObject {
	NSString* saykana_path;
}
@property (readwrite,retain) NSString* saykana_path;

+(void)saykana_word:(NSString*) str;

@end
