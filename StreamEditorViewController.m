//
//  StreamEditorViewController.m
//  BluesCast
//
//  Created by Jeff H on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StreamEditorViewController.h"


@implementation StreamEditorViewController


@synthesize CurrentLevel;
@synthesize streamer;
@synthesize bufferStatusView;
//@synthesize selectedTableRow;



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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*- (void)viewDidLoad {
    [super viewDidLoad];
	
	//stationURLField.delegate = self;
	//stationURLField.returnKeyType = UIReturnKeyDone;


}*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) testLink:(id)sender {
	
}

- (IBAction) cancelChanges:(id)sender {
	//stop the stream if was started
	[self stopAll];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];
	self.view.alpha = 0.0;
	[UIView commitAnimations];
		
}

- (IBAction)submitChanges:(id)sender {
	//stop the stream if was started
	[self stopAll];
	
	//NSString *text = [stationURLField text];
	//NSLog(@"field = %@", stationURLField.text);
	[self saveStationURL];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];
	self.view.alpha = 0.0;
	[UIView commitAnimations];
	
}

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder]; 
    return YES;
}


-(void) finishedFading {
	
	[[self view] removeFromSuperview];
	
}

-(void) saveStationURL {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [[NSString alloc] initWithString: @"datacopy.plist"];
	NSString* copyPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	// randomize the array
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:copyPath];
	
	
	if(exists) {
	     SpeakHereAppDelegate *appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSMutableArray *data = appDelegate.data;
		
	    // add stationURL to plist
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		// grab field value
		NSString *urlText = [stationURLField text];
		NSString *titleText = [stationTitleField text];
		
		NSInteger selectedType = [streamTypeSegmentedControl selectedSegmentIndex];
		NSString *type;
		/*if(selectedType == 0) {
			type = [[NSString alloc] initWithString:@"Auto"];
		} else if(selectedType == 1) {
			type = [[NSString alloc] initWithString:@"MP3"];
		} else if(selectedType == 2) {
			type = [[NSString alloc] initWithString:@"AAC"];
		} else if(selectedType == 3) {
			type = [[NSString alloc] initWithString:@"AAC+"];
		} */
		
		if(selectedType == 0) {
			type = [[NSString alloc] initWithString:@"MP3"];
		} else if(selectedType == 1) {
			type = [[NSString alloc] initWithString:@"AAC"];
		} 
		
		NSInteger selectedRate = [streamRateSegmentedControl selectedSegmentIndex];
		NSString *rate;
		/*if(selectedRate == 0) {
			rate = [[NSString alloc] initWithString:@"Auto"];
		} else if(selectedRate == 1) {
			rate = [[NSString alloc] initWithString:@"128"];
		} else if(selectedRate == 2) {
			rate = [[NSString alloc] initWithString:@"92"];
		} else if(selectedRate == 3) {
			rate = [[NSString alloc] initWithString:@"64"];
		} else if(selectedRate == 4) {
			rate = [[NSString alloc] initWithString:@"32"];
		}*/
		
		
		if(selectedRate == 0) {
			rate = [[NSString alloc] initWithString:@"128"];
		} else if(selectedRate == 1) {
			rate = [[NSString alloc] initWithString:@"92"];
		} else if(selectedRate == 2) {
			rate = [[NSString alloc] initWithString:@"64"];
		} else if(selectedRate == 3) {
			rate = [[NSString alloc] initWithString:@"32"];
		} 
		
		
		
		[dictionary setValue:(id)urlText forKey:@"URL"];
		[dictionary setValue:(id)titleText forKey:@"Title"];
		[dictionary setValue:(id)rate forKey:@"RATE"];
		[dictionary setValue:(id)type forKey:@"STREAM"];
		[dictionary setValue:(id)@"0" forKey:@"FAVORITE"];
		
		[data addObject:dictionary];
		
		[type release];
		[rate release];
		[dictionary release];
		
		BOOL success = [data writeToFile:copyPath atomically:YES];
		if (success == NO)
		{
			NSLog(@"failed adding stationURL");
			
		} else {
			NSLog(@"success adding stationURL");
		}
		
		//NSMutableArray *table = [[[appDelegate topicsController] rootViewController] tableDataSource];
		//table = appDelegate.data;
		[[[[appDelegate topicsController] rootViewController] tableView] reloadData];
		
	} else {
		NSLog(@"Error: datacopy.plist doesn't exist!!");
	}
	
	/*NSMutableArray *data = appDelegate.data;
	 
	 NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[data objectAtIndex:[[appDelegate controller] selectedTableRow]]];
	 [dictionary setValue:@"1" forKey:@"FAVORITE"];
	 
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *documentsDirectory = [paths objectAtIndex:0];
	 
	 NSString *fileName = [[NSString alloc] initWithString: @"datacopy.plist"];
	 NSString* fileLocation = [documentsDirectory stringByAppendingPathComponent:fileName];
	 
	 
	 //[copyData replaceObjectAtIndex: [controller selectedTableRow] withObject:dictionary];
	 [data replaceObjectAtIndex: [[appDelegate controller] selectedTableRow] withObject:dictionary];
*/	 
	
}

/*******************************************************/
// streamer related classes
/*******************************************************/


- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	if (!image)
	{
		[button setImage:[UIImage imageNamed:@"playbutton.png"] forState:0];
	}
	else
	{
		[button setImage:image forState:0];
		
		if ([button.currentImage isEqual:[UIImage imageNamed:@"loadingbutton.png"]])
		{
			[self spinButton];
		}
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		
		NSLog(@"streamer active!");
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CurrentLevel = 1; // used to identify this view in navcontroller
	
	[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	//[self buttonPressed:nil];
}

- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
	
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

- (IBAction)buttonPressed:(id)sender
{
	NSString *testStationURL = [stationURLField text];
	if([testStationURL isEqualToString:@"http://"] || [testStationURL length] < 8) {
		return;
	}
	  
	if (!streamer) 
	{
		/////[textField resignFirstResponder];
		NSString *testStationURL = [stationURLField text];
		
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)testStationURL,
															 NULL,
															 NULL,
															 kCFStringEncodingUTF8)
		 autorelease];
		
		NSURL *url = [NSURL URLWithString:escapedValue];
		[[[[UIApplication sharedApplication] delegate] streamer] stop];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[[[UIApplication sharedApplication] delegate] setStreamer: streamer];
		// set the delegate!!!!!
		[streamer setDelegate:self];
		
		[streamer
		 addObserver:self
		 forKeyPath:@"isPlaying"
		 options:0
		 context:nil];
		[streamer start];
		//[[streamer audioQueue] setKAudioQueueProperty_EnableLevelMetering: YES];
		
		
		//[lvlMeter_in setAq: [streamer audioQueue] ];
		//UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
		//[lvlMeter_in setBackgroundColor:bgColor];
		//[lvlMeter_in setBorderColor:bgColor];
		//[bgColor release];
		
		
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		
		[self spinButton];
	}
	else
	{
		[button.layer removeAllAnimations];
		[streamer stop];
		[bufferStatusView setProgress:0];
	}
}

-(void) stopAll {
	
    [button.layer removeAllAnimations];
    [streamer stop];
	
	//this was cusing an error where streamer was released but we were trying to 
	// release observer after new streamer instantiated 
	//////////[streamer removeObserver:self forKeyPath:@"isPlaying"];
	//[streamer release];
	//streamer = nil;
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			[self
			 performSelector:@selector(setButtonImage:)
			 onThread:[NSThread mainThread]
			 withObject:[UIImage imageNamed:@"stopbutton.png"]
			 waitUntilDone:NO];
		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			[self
			 performSelector:@selector(setButtonImage:)
			 onThread:[NSThread mainThread]
			 withObject:[UIImage imageNamed:@"playbutton.png"]
			 waitUntilDone:NO];
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}

-(void) bufferStatus:(NSNumber *)buffersPercent {
	
	
	//NSLog(@"header Name: %@", data);
	
	[bufferStatusView setProgress:[buffersPercent floatValue]];
	
	
}


-(void) streamError {
	
	
	//NSLog(@"stream error!");
	
	//[self buttonPressed:nil];
	//[self stopAll];
	
	NSString* msg =[[NSString alloc] initWithString: 
					@"Server does not exist, or incorrectly entered URL."
					];
	//[rateTimer invalidate];
	//[bufferTimer invalidate];
	AlertRun* alert = [[AlertRun alloc] initWithTitle:@"Connection Failed" message:msg delegate:self cancelButtonTitle:@"OK" callBack:@selector(dataFailed)];
	//AlertRun* alert = [[AlertRun alloc] initWithTitle:@"Connecion Too Slow" message:msg delegate:self cancelButtonTitle:@"OK" callBack:nil];
	
	[alert show];
	[msg release];
	[alert release];
	
	
	//[self destroyStreamer];
	
	
}

-(void) dataFailed {
	//NSLog(@"data failed!");
	
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	
	
	if (buttonIndex == [alertView cancelButtonIndex])
	{
		
		
		SEL mySelector = [(AlertRun*)alertView callBack];
		//SEL mySelector = [UIAlertView callBack];
		
		
		if(mySelector == nil) return;
		
		
		// create a signature from the selector
		//NSMethodSignature* sig = nil;
		NSMethodSignature* sig = [[self class] instanceMethodSignatureForSelector:mySelector];
		
		NSInvocation*  myInvocation = nil;
		myInvocation = [NSInvocation invocationWithMethodSignature:sig];
		[myInvocation setTarget:self];
		[myInvocation setSelector:mySelector];
		[myInvocation invoke];
		
		
	} else {
		
		//quit game
		exit(0);
		
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
	
	[self stopAll];
	[self destroyStreamer];
	
}


@end
