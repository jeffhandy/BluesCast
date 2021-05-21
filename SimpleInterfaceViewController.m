//
//  SimpleInterfaceViewController.m
//  BluesCast
//
//  Created by Jeff H on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SimpleInterfaceViewController.h"


@implementation SimpleInterfaceViewController
@synthesize streamer;

@class SpeakHereAppDelegate;


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
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//SpeakHereAppDelegate *appDelegate = (SpeakHereAppDelegate *)[[UIApplication sharedApplication] delegate];
	[self setupSounds];
	
	data = [[[UIApplication sharedApplication] delegate] data];
	currentStationIndex = 0;
}

-(void) setupSounds {
	clickSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"]];
	failedSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bonk" ofType:@"caf"]];
	bufferingSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Select" ofType:@"caf"]];
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


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


- (IBAction)nextStation:(id)sender
{
	
	//NSString *testStationURL = [stationURLField text];
	[bufferStatusView setProgress:0];
	[streamer stop];
	[streamer release];
	streamer = nil;
	
	[clickSound play];
	currentStationIndex++;
	[self  selectStationAtIndex: currentStationIndex];
	
}

- (IBAction)previousStation:(id)sender
{
	
	[bufferStatusView setProgress:0];
	//NSString *testStationURL = [stationURLField text];
	[streamer stop];
	[streamer release];
	streamer = nil;
	
	[clickSound play];
	currentStationIndex--;
	[self  selectStationAtIndex: currentStationIndex];
	
}

-(void) selectStationAtIndex: (int) index {
	
		
	int maxIndex = [data count];
	if(index >= maxIndex) {
		index = 0;
	}
	
	if(index < 0) {
		index = maxIndex -1;
	}
	
	NSDictionary *dictionary = [data objectAtIndex: index];
	NSString *shoutCastURL = [dictionary objectForKey:@"URL"];
		
	
	if (!streamer) 
	{
		/////[textField resignFirstResponder];
		//NSString *testStationURL = [stationURLField text];
		
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)shoutCastURL,
															 NULL,
															 NULL,
															 kCFStringEncodingUTF8)
		 autorelease];
		
		NSURL *url = [NSURL URLWithString:escapedValue];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		// set the delegate!!!!!
		[streamer setDelegate:self];
		
		[streamer
		 addObserver:self
		 forKeyPath:@"isPlaying"
		 options:0
		 context:nil];
		 
		[streamer start];
		
		bufferingSoundTimer = [NSTimer 
						scheduledTimerWithTimeInterval:0.7 
						target:self 
						selector:@selector(playBufferingSound) 
						userInfo:nil 
						repeats:YES
						];
		
		
		//[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		//[self spinButton];
	}
	else
	{
		//[button.layer removeAllAnimations];
		[streamer stop];
		[bufferStatusView setProgress:0];
	}
}

-(void)playBufferingSound{
	[bufferingSound play];
}
-(void) bufferStatus:(NSNumber *)buffersPercent {
	
	
	//NSLog(@"header Name: %@", data);
	
	[bufferStatusView setProgress:[buffersPercent floatValue]];
	
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			/*[self
			 performSelector:@selector(setButtonImage:)
			 onThread:[NSThread mainThread]
			 withObject:[UIImage imageNamed:@"stopbutton.png"]
			 waitUntilDone:NO];*/
			
			[bufferingSoundTimer invalidate];
		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			//[bufferingSound play];
			// play buffering sound here
			
			/*[self
			 performSelector:@selector(setButtonImage:)
			 onThread:[NSThread mainThread]
			 withObject:[UIImage imageNamed:@"playbutton.png"]
			 waitUntilDone:NO];*/
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}

- (IBAction) switchMode:(id) sender {
	[streamer stop];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];
	self.view.alpha = 0.0;
	[UIView commitAnimations];
	
}

-(void) finishedFading {
	
	[[self view] removeFromSuperview];
	
}


-(void) streamError {
	
	[failedSound play];
	
	NSLog(@"stream error!");
	
	
	
}




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[streamer stop];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}



@end
