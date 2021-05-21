//
//  FavoritesTableController.h
//  BluesCast
//
//  Created by Jeff H on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpeakHereAppDelegate;
@class iPhoneStreamingPlayerViewController;


@interface FavoritesTableController : UITableViewController {
	
	NSArray *tableDataSource;
	SpeakHereAppDelegate *appDelegate;
	iPhoneStreamingPlayerViewController *controller;
	
    NSInteger CurrentLevel;
}

@property (nonatomic, retain) NSArray *tableDataSource;
@property (readwrite) NSInteger CurrentLevel;

@end
