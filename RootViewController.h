//
//  RootViewController.h
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>
//#import "Player.h";
@class SpeakHereAppDelegate;
@class iPhoneStreamingPlayerViewController;
#import "FavoritesTableController.h"

@interface RootViewController : UITableViewController {
	
	NSMutableArray *tableDataSource;
	NSString *CurrentTitle;
	NSInteger CurrentLevel;
	NSInteger tableDepth;
	SpeakHereAppDelegate *appDelegate;
	//UIToolbar *toolbar;
	UIBarButtonItem *postButtonItem;
	iPhoneStreamingPlayerViewController *controller;
	
}

@property (nonatomic, retain) NSMutableArray *tableDataSource;
@property (nonatomic, retain) NSString *CurrentTitle;

@property (nonatomic, readwrite) NSInteger CurrentLevel;
//@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, assign) UIBarButtonItem *postButtonItem;



@end
