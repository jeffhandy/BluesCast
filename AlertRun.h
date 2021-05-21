//
//  AlertRun.h
//  MM3
//
//  Created by Jeff H on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertRun : UIAlertView 
{
    //id* callBackObject;
	SEL   callBack;
}
//@property (nonatomic, readwrite) id* callBackObject;
@property (nonatomic, readwrite) SEL callBack;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle callBack:(SEL)cb;

@end
