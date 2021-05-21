//
//  TopicsViewController.m
//  SpeakHere
//
//  Created by Jeff H on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TopicsViewController.h"


@implementation TopicsViewController

@synthesize navigationController, rootViewController, postButtonItem, currentCategory, currentThread, postTitle;


//  The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
				
    }
    return self;
}*/

/*- (id) init
{
	self = [super init];
	if (self != nil) {
		//<#initializations#>
		
		
		
	}
	return self;
}*/

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	
	//NSLog(@"**** WILL show view called! Level:%d",[viewController CurrentLevel]);
	
	/*if([viewController CurrentLevel] == 0) {
		[viewController  stopAll];
	
	}*/
	
	[self hideToolbar];

	
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	
	///NSLog(@"**** DID show view called! Level:%d",[viewController CurrentLevel]);
	
	if([viewController respondsToSelector:@selector(CurrentLevel)]) {
		if([viewController CurrentLevel] == 0) {
	 //[viewController  stopAll];
		[self showToolbar];
	    } else {
		   [self hideToolbar];
	    }
	} else {
		[self hideToolbar];
	}
	
		
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//NSLog(@"init player");
	
	rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle]];
	
	
	//[[rootViewController view] setFrame: CGRectMake(0,0,436,320)]; 
	
	
	 appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	//[self.view addSubview:rootViewController.view];
	
	//navigationController = [[UINavigationController alloc] init];
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[navigationController setDelegate:self];
	//navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		
	// UITabBarSystemItemTopRated
	//UITabBarItem *saveFavoriteItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated target:self action:@selector(saveFavorite)];
	//UITabBarItem *saveFavoriteItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:0];
	
    //NSMutableArray *barItems = [[NSMutableArray alloc] initWithArray: [navigationController.navigationBar items]];	
	//NSMutableArray *barItems = [[NSMutableArray alloc] init];	
	//[barItems addObject:saveFavoriteItem];
	
	//NSArray *topItems = [NSArray arrayWithObjects: saveFavoriteItem,  nil];

	//[navigationController.navigationBar setItems:barItems];
	//UITabBar *topToolbar = [[UITabBar alloc] init];
	//[topToolbar setItems:topItems];
	
	
	
	//[navigationController.navigationItem setRightBarButtonItem:saveFavoriteItem];
	
	
	//UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithObjects:saveFavoriteItem];
	
	//self.navigationController.title = topToolbar;
	UIColor *col1 = [[UIColor alloc] initWithRed:(26/255.0) green:(54/255.0) blue:(101/255.0) alpha:1];
	navigationController.navigationBar.tintColor = col1;
	navigationController.navigationBar.translucent = YES;
	
	// next line gives error:
	//navigationController.navigationItem.rightBarButtonItem = saveFavoriteItem;
	
	
	
	
	
	
		
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,436,320,44)];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	toolbar.tintColor = col1;
	toolbar.translucent = YES;

	
	//postButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post Message" style:UIBarButtonItemStyleBordered target:self action:@selector(postMessage)];
	//postButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshSongs)];
	//postButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshSongs)];
	
	
	
	//UIBarButtonItem *addStation = [[UIBarButtonItem alloc] initWithTitle:@"Add Station" style:UIBarButtonItemStyleBordered target:self action:@selector(addStation)];
	UIBarButtonItem *addStation = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStation)];
	 
	UIBarButtonItem *viewFiles = [[UIBarButtonItem alloc] initWithTitle:@"View Music" style:UIBarButtonItemStyleBordered target:self action:@selector(viewFiles)];
	
	UIBarButtonItem *chooseFavoriteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showFavorites)];
	
		
	//UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
	//UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	//UIImage *infoImage = [UIImage imageNamed:@"info.png"];
	//UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:infoImage style:UIBarButtonItemStylePlain  target:self action:@selector(showAbout)];
	
	//UIImage *carImage = [UIImage imageNamed:@"clock.png"];
	//UIBarButtonItem *carItem = [[UIBarButtonItem alloc] initWithImage:carImage style:UIBarButtonItemStylePlain  target:self action:@selector(showSimpleInterface)];
	
	UIBarButtonItem *carItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSimpleInterface)];
	
	UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:nil];
	UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:nil];
	
	
	UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithTitle:@"about" style:UIBarButtonItemStyleBordered target:self action:@selector(showAbout)];

	//UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];

	//UIBarButtonItem *flagItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(flag)];
	
	//postButtonItem.enabled = YES;
	chooseFavoriteItem.enabled = YES;
	//flagItem.enabled = NO;
	
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:self action:nil];
	
	NSArray *items = [NSArray arrayWithObjects: chooseFavoriteItem,spacer, spacer, carItem, spacer, spacer, infoItem,  nil];
	toolbar.items = items;
	
	[toolbar sizeToFit];
								   
	//toolbar.topItem.rightBarButtonItem = chooseFavoriteItem;
	[navigationController.view addSubview:toolbar];
	
	self.navigationController.navigationBar.topItem.rightBarButtonItem = chooseFavoriteItem;
	self.navigationController.navigationBar.topItem.leftBarButtonItem = addStation;
		
	
	// add edit button
	//toolbar.topItem.rightBarButtonItem = [self editButtonItem];
	//self.editing = NO; // Initially displays an Edit button and noneditable view
	
	
	
	[self.view addSubview:navigationController.view];
	[navigationController.view addSubview:rootViewController.view];
	
	NSLog(@"loaded rootView");
							
	toolbar.hidden = NO;
	[postButtonItem release];
	[toolbar release];
}

//-(void) saveFavorite {
//	NSLog(@"save favorite station");
//}

-(void) hideToolbar {
	NSLog(@"hiding toolbar");
	toolbar.hidden = YES;
	
	//[navigationController setToolbarHidden:TRUE animated:TRUE];
}

-(void) showToolbar {
	NSLog(@"showing toolbar");
	toolbar.hidden = NO;
}

-(void) showFavorites {
	NSLog(@"showing favorite station");
	
	FavoritesTableController *tableController = [[FavoritesTableController alloc] init];
	
	//[navigationController.view addSubview:tableController.view];
	[navigationController pushViewController:tableController animated:YES];

}
-(void) showSimpleInterface {
	
	[[[[UIApplication sharedApplication] delegate] streamer] stop];
	
	SimpleInterfaceViewController* sic = [[SimpleInterfaceViewController alloc] initWithNibName:@"SimpleInterfaceViewController" bundle:[NSBundle mainBundle]];
	[[self view] addSubview:[sic view]];

	
}


-(IBAction) showAbout {
	
	InformationController* ic = [[InformationController alloc] initWithNibName:@"Information" bundle:[NSBundle mainBundle]];
	[[self view] addSubview:[ic view]];
	
	//[ic release];
}

-(void) chooseFavorite {
	NSLog(@"choosing favorite station");
}

-(void) refreshSongs {
	NSLog(@"refreshing songs");
}

/*-(void) postMessage {
		[[self view] addSubview:[[appDelegate viewController] view]];
	

	
	[[[appDelegate viewController] categoryTextView] setText: currentCategory];
	[[[appDelegate viewController] threadTextView] setText: currentThread];
	//[[[appDelegate viewController] titleTextView] setText: @"my post title"];
	
	[[[appDelegate viewController] view] setNeedsDisplay];
	
}*/



-(void) addStation {
	
	
	StreamEditorViewController* svc = [[StreamEditorViewController alloc] initWithNibName:@"StreamEditorViewController" bundle:[NSBundle mainBundle]];
	[[self view] addSubview:[svc view]];

	
}

-(void) viewFiles {
	
	
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}




- (void)dealloc {
	[rootViewController release];
    [super dealloc];
}


@end
