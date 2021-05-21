//
//  FavoritesTableController.m
//  BluesCast
//
//  Created by Jeff H on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FavoritesTableController.h"
#import "SpeakHereAppDelegate.h"


@implementation FavoritesTableController

@synthesize tableDataSource, CurrentLevel;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		
		appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];
        CurrentLevel = 1;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//self.tableDataSource =
	//NSArray *data = [appDelegate.data objectForKey:@"Rows"];
	NSArray *data = appDelegate.data;
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	for (NSDictionary *dict in data) {
		NSString *value  = [dict objectForKey:@"FAVORITE"];
	    if([value compare:@"1"] == NSOrderedSame) {
			
			[tempArray addObject:dict];
		}
	}
	
	self.tableDataSource = tempArray;
	[tempArray release];
	
	self.navigationItem.title = @"Favorites";
	
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	
	self.editing = NO; // Initially displays an Edit button and noneditable view
	
			
	
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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [self.tableDataSource count];
    //return 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Table view called");
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		//[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
	
		NSDictionary *selectedDict = [self.tableDataSource objectAtIndex:indexPath.row];
		
		
		
		
		NSMutableArray *data = appDelegate.data;
		//for(NSDictionary *dict in data) {
		//	if([dict objectForKey:@"Title"] 
		
		
		[selectedDict setValue:@"0" forKey:@"FAVORITE"];
		
		
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
		
		
		[self.tableDataSource removeObjectAtIndex:indexPath.row];
		[self.tableView reloadData];
		
	}
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	
	
	NSString *text = [dictionary objectForKey:@"Title"];
	//NSArray *parts = [text componentsSeparatedByString:@":"];
	///cell.textLabel.text = [parts objectAtIndex:0];
	cell.textLabel.text = text;
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	//Get the dictionary of the selected data source.
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	//CurrentTitle = [dictionary objectForKey:@"Title"];
	
	//Get the children of the present item.
	//NSArray *Children = [dictionary objectForKey:@"Children"];
	//NSLog(@"children count: %d", [Children count]);
	
	//if([Children count] == 1) {
	
	//[[appDelegate controller] release];
	[[appDelegate controller] stopAll];
	[appDelegate setController:[[iPhoneStreamingPlayerViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:[NSBundle mainBundle]]];
	
	//NSDictionary *dataDict = [Children objectAtIndex:0];
	////[controller setShoutCastURL:[dataDict objectForKey:@"URL"]];
	[[appDelegate controller] setShoutCastURL:[dictionary objectForKey:@"URL"]];
	[self.navigationController pushViewController:[appDelegate controller] animated:YES];
	
	//////[[controller currentStation] setText:CurrentTitle];
	//[controller release];
	
	//UIBarButtonItem *saveFavoriteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh  target:self action:@selector(saveFavorite)];
	//////UIBarButtonItem *saveFavoriteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(saveFavorite)];
	//UITabBarItem *saveFavoriteItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:0];
	
	//NSArray *topItems = [NSArray arrayWithObjects: saveFavoriteItem,  nil];
	//UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithObjects:topItems];
	
	/*UIImage *img = [UIImage imageNamed:@"gold.png"];
	 
	 self.navigationController.navigationBar.topItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:img
	 style:UIBarButtonItemStylePlain
	 target:self
	 action:@selector(saveFavorite)] autorelease];*/
	/////self.navigationController.navigationBar.topItem.rightBarButtonItem = saveFavoriteItem;
	
	//[controller release];
	
	
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

