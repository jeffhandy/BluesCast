//
//  WebViewController.h
//  BluesCast
//
//  Created by Jeff H on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	IBOutlet UIWebView *webView;
	NSInteger CurrentLevel;
	NSString *webURLString;
}
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, readwrite) NSInteger CurrentLevel;
@end
