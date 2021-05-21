//
//  AlertRun.m
//  MM3
//
//  Created by Jeff H on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlertRun.h"


@implementation AlertRun

@synthesize callBack;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle callBack:(SEL)cb
{
	
		
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil])
    {
        callBack = cb;
		//callBackObject = object;
		
		//[object release];
    }
    return self;
}
- (void)dealloc
{
    //[callBackObject release];
    [super dealloc];
}
@end