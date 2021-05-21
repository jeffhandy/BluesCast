//
//  TopicsViewController.h
//  SpeakHere
//
//  Created by Jeff H on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "FavoritesTableController.h"
//#import "Player.h"
#import "SpeakHereAppDelegate.h"
#import "InformationController.h"
#import "StreamEditorViewController.h"
#import "SimpleInterfaceViewController.h"


@interface TopicsViewController : UIViewController <UINavigationControllerDelegate> {
	IBOutlet RootViewController *rootViewController;
	UINavigationController *navigationController;
	UIToolbar *toolbar;
	UIBarButtonItem *postButtonItem;
	SpeakHereAppDelegate *appDelegate;
	NSString *currentCategory;
	NSString *currentThread;
	NSString *postTitle;
	


}
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *postButtonItem;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) NSString *currentThread;
@property (nonatomic, retain) NSString *postTitle;


@end
