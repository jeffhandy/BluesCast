//
//  PreferencesViewController.m
//  BluesCast
//
//  Created by Jeff H on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferencesViewController.h"


@implementation PreferencesViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)submitChanges:(id)sender {

	// get shuffleStationSwitch state
	if (shuffleStationsSwitch.on) {
		//(SpeakHereAppDelegate *)appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];
	    //[appDelegate setShuffleMode: YES];

		[[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"shuffleMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		//[appDelegate setShuffleMode: NO];
		[[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"shuffleMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// get carModeSwitch state
	if (carModeSwitch.on) {
	    //[appDelegate setCarMode: YES];
		[[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"carMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];

	} else {
		//[appDelegate setCarMode: NO];
		[[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"carMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];

	}

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
