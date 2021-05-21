//
//  RootViewController.m
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "RootViewController.h"
#import "SpeakHereAppDelegate.h"
//#import "DetailViewController.h"
#import "iPhoneStreamingPlayerViewController.h"

@implementation RootViewController

@synthesize tableDataSource, CurrentTitle, CurrentLevel, postButtonItem;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil depth:(NSInteger)depth {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
 
	//appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];
	tableDepth = depth;

		NSLog(@"depth %d", tableDepth);
		
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	

	NSLog(@"CurrentLevel: %d",CurrentLevel);
	NSLog(@"CurrentDepth: %d",tableDepth);
	appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];

	
    if(CurrentLevel == 0) {
		
		
		
		//Initialize our table data source
		NSArray *tempArray = [[NSArray alloc] init];
		self.tableDataSource = tempArray;
		[tempArray release];
		
		//self.tableDataSource = [appDelegate.data objectForKey:@"Rows"];
		self.tableDataSource = appDelegate.data;
		
		self.navigationItem.title = @"Blues Stations";
		
		self.navigationItem.rightBarButtonItem = [self editButtonItem];
		self.editing = NO; // Initially displays an Edit button and noneditable view
		
		
	
		
	} else {
		self.navigationItem.title = CurrentTitle;
		
		
	}
	
	/*if(tableDepth == 1) {
		//currentCategory = CurrentTitle;
		NSString *newCategory = [[NSString alloc] initWithString:self.navigationItem.title];
		[[AppDelegate topicsController] setCurrentCategory:newCategory];
		[newCategory release];
	} else if(tableDepth == 2) {
		//currentThread = CurrentTitle;
		NSString *newThread = [[NSString alloc] initWithString:self.navigationItem.title];
		[[AppDelegate topicsController] setCurrentThread:newThread];
		[[[AppDelegate topicsController] postButtonItem] setEnabled:YES];
		[newThread release];
		//postButtonItem.enabled = YES;
	} else {
		[[[AppDelegate topicsController] postButtonItem] setEnabled:NO];

		
	}*/
	
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSLog(@"====> count = %d",[self.tableDataSource count]);
    return [self.tableDataSource count];
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Table view commitEditing style  called");
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		//[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		
		NSDictionary *selectedDict = [self.tableDataSource objectAtIndex:indexPath.row];
		
		
		NSMutableArray *data = appDelegate.data;
		//for(NSDictionary *dict in data) {
		//	if([dict objectForKey:@"Title"] 
		
		[selectedDict setValue:@"0" forKey:@"FAVORITE"];
		
		[self.tableDataSource removeObjectAtIndex:indexPath.row];
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *fileName = [[NSString alloc] initWithString: @"datacopy.plist"];
		NSString* fileLocation = [documentsDirectory stringByAppendingPathComponent:fileName];
		
		//[data replaceObjectAtIndex: [controller selectedTableRow] withObject:dictionary];
		
		//BOOL success = [copyData writeToFile:fileLocation atomically:NO];
		BOOL success = [data writeToFile:fileLocation atomically:NO];
		if (success == NO)
		{
			NSLog(@"failed saving the XML plist file");
		} else {
			
			NSLog(@"success saving the XML plist file");
		}
		
		///[fileName release];
		
		[self.tableView reloadData];
		
	}
}


- (void)setEditing:(BOOL)flag animated:(BOOL)animated

{
	
    [super setEditing:flag animated:animated];
	
    if (flag == YES){
		
        // change view to an editable view
		NSLog(@"editing favorites");
		
    }
	
    else {
		
        // save the changes if needed and change view to noneditable
		NSLog(@"saving changes to favorites");
		
    }
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	
	
	CurrentTitle = [dictionary objectForKey:@"Title"];
	
	/*//Get the children of the present item.
	NSArray *Children = [dictionary objectForKey:@"Children"];
	
		
	NSDictionary *dataDict = [Children objectAtIndex:0];
	NSString *URL = [dataDict objectForKey:@"URL"];
	
	NSMutableString *URLPath = [[NSMutableString alloc] initWithString:@"http://www.google.com"];
	[URLPath appendFormat:@"/favicon.ico"];
	
	
	
	NSLog(@"icon: %@",URLPath);*/
	
	
	
	
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
/////	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	//cell.textLabel.text = [dictionary objectForKey:@"Title"];
	NSString *text = [dictionary objectForKey:@"Title"];
	//NSArray *parts = [text componentsSeparatedByString:@":"];
	///cell.textLabel.text = [parts objectAtIndex:0];
	
	NSString *rate = [dictionary objectForKey:@"RATE"];
	//NSInteger rateInt = [[NSInteger alloc] initWithString:rate];
	//if(rateInt < 65) {
		NSString *lowRate = [[NSString alloc] initWithFormat:@"  (%@)", rate];	
		NSMutableString *newString = [[NSMutableString alloc] initWithString: text];
		[newString appendString: lowRate];
		cell.textLabel.text = newString;
	
	[lowRate release];
	[newString release];
	//} else {
	 //   cell.textLabel.text = text;
    //}
	
	
	//UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
	
	//UIImage* image =[UIImage imageNamed:@"pausebutton.png"];
	
	//UIImage *image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"theimagefile" ofType:@"png"]];
   
	
	//UIImage *image = [[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: URLPath]]] retain];
	/*if (img != nil) { // Image was loaded successfully.
	   [imgView setImage:img];
	   [imgView setUserInteractionEnabled:NO];	
	   [img release]; // Release the image now that we have a UIImageView that contains it.
   }*/
	
	
	//UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	
	//[cell.contentView addSubview:imageView];

	
	//NSLog(@"number is %@", [parts objectAtIndex:1]);

	
	//if(CurrentLevel > 0 )
	//cell.textLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
	
	//UILabel *label = [cell textLabel];
	//[label setText:[dictionary objectForKey:@"Title"]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	//Get the dictionary of the selected data source.
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	CurrentTitle = [dictionary objectForKey:@"Title"];
	
	//Get the children of the present item.
	//NSArray *Children = [dictionary objectForKey:@"Children"];
	//NSLog(@"children count: %d", [Children count]);
	
	//if([Children count] == 1) {
		
// don't stop all -- JTH
	NSString *lastURL = [[[UIApplication sharedApplication] delegate] currentURLPlaying];
	NSString *shoutCastURL = [dictionary objectForKey:@"URL"];
	
	//if(![lastURL isEqualToString: shoutCastURL]) {
	[[appDelegate controller] stopAll];
	//}
	
	// hide the toolbar
	//appDelegate = (TopicsViewController *)[[UIApplication sharedApplication] topicsController];
	//[[appDelegate topicsController] hideToolbar];
	///[self.parentViewController hideToolbar];
	//[self.navigationController setToolbarHidden:TRUE animated:TRUE];
	[appDelegate setController:[[iPhoneStreamingPlayerViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:[NSBundle mainBundle]]];
	[[appDelegate controller] setSelectedTableRow:indexPath.row];
		
		//NSDictionary *dataDict = [Children objectAtIndex:0];
		////[controller setShoutCastURL:[dataDict objectForKey:@"URL"]];
	    //[[appDelegate controller] setShoutCastURL:[dictionary objectForKey:@"URL"]];
		[[appDelegate controller] setShoutCastURL: shoutCastURL];

		[self.navigationController pushViewController:[appDelegate controller] animated:YES];
		
		[[[appDelegate controller] currentStation] setText:CurrentTitle];
		//[controller release];
		
		//UIBarButtonItem *saveFavoriteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh  target:self action:@selector(saveFavorite)];
		//UIBarButtonItem *saveFavoriteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(saveFavorite)];
	
	    UIBarButtonItem *saveFavoriteItem = [[UIBarButtonItem alloc] initWithTitle:@"Mark as Favorite" style:UIBarButtonItemStyleBordered target:self action:@selector(saveFavorite)];
	
	
		//UITabBarItem *saveFavoriteItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:0];
		
		//NSArray *topItems = [NSArray arrayWithObjects: saveFavoriteItem,  nil];
		//UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithObjects:topItems];
		
		/*UIImage *img = [UIImage imageNamed:@"gold.png"];
		
		self.navigationController.navigationBar.topItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:img
																								   style:UIBarButtonItemStylePlain
																								  target:self
																								  action:@selector(saveFavorite)] autorelease];*/
		self.navigationController.navigationBar.topItem.rightBarButtonItem = saveFavoriteItem;

		
	
		
		
				
	/*}
	else {
		
		
		//Prepare to tableview.
		RootViewController *rvController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:[NSBundle mainBundle] depth:tableDepth + 1];
		
		//[[rvController view] addSubview:toolbar];
		
		//Increment the Current View
		rvController.CurrentLevel += 1;
		
		//Set the title;
		rvController.CurrentTitle = [dictionary objectForKey:@"Title"];
		
		//Push the new table view on the stack
		[self.navigationController pushViewController:rvController animated:YES];
		
		rvController.tableDataSource = Children;
		
		[rvController release];
	}*/
}



-(void) saveFavorite {
	NSLog(@"saving favorite station!!!!");
	
	//NSMutableArray *copyData = [[NSMutableArray alloc] initWithArray:[appDelegate.data objectForKey:@"Rows"]];
	//NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[copyData objectAtIndex:[controller selectedTableRow]]];
		
	NSMutableArray *data = appDelegate.data;
	
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[data objectAtIndex:[[appDelegate controller] selectedTableRow]]];
	[dictionary setValue:@"1" forKey:@"FAVORITE"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *fileName = [[NSString alloc] initWithString: @"datacopy.plist"];
	NSString* fileLocation = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	
	//[copyData replaceObjectAtIndex: [controller selectedTableRow] withObject:dictionary];
	[data replaceObjectAtIndex: [[appDelegate controller] selectedTableRow] withObject:dictionary];
	
	
	
	//BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fileLocation];
	//if(!exists) {
	//	[self initHighScoresFile];
	//}
	
	//BOOL success = [copyData writeToFile:fileLocation atomically:NO];
	BOOL success = [data writeToFile:fileLocation atomically:NO];
	if (success == NO)
	{
		NSLog(@"failed saving the XML plist file");
	}
	
	[fileName release];
	//[copyData release];
	[dictionary release];
	
	
	FavoritesTableController *tableController = [[FavoritesTableController alloc] init];
		
	//[navigationController.view addSubview:tableController.view];
	[self.navigationController pushViewController:tableController animated:YES];
		
	
	
}

- (void)dealloc {
	//[controller release];
	[CurrentTitle release];
	[tableDataSource release];
    [super dealloc];
}

@end

