//
//  iPhoneStreamingPlayerViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "iPhoneStreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "AlertRun.h"


@class SpeakHereAppDelegate;


@implementation iPhoneStreamingPlayerViewController
@synthesize shoutCastURL;
@synthesize currentArtist, currentStation, currentBitRate, currentGenre, currentURL;
@synthesize volumeSlider;
@synthesize CurrentLevel;
@synthesize streamer;
@synthesize bufferStatusView;
@synthesize selectedTableRow;

//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
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
		
		/*[[NSNotificationCenter defaultCenter]
			removeObserver:self
			name:ASStatusChangedNotification
			object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;*/
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
/*- (void)createStreamer:(NSString *)shoutCastURL
{
	if (streamer)
	{
		return;
	}

	[self destroyStreamer];
	
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
	
	progressUpdateTimer =
		[NSTimer
			scheduledTimerWithTimeInterval:0.1
			target:self
			selector:@selector(updateProgress:)
			userInfo:nil
			repeats:YES];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(playbackStateChanged:)
		name:ASStatusChangedNotification
		object:streamer];
}*/

//
// viewDidLoad
//
// Creates the volume slider, sets the default path for the local file and
// creates the streamer immediately if we already have a file at the local
// location.
//
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	
		
	CurrentLevel = 1; // used to identify this view in navcontroller
	
	/*MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
	
	
	// Find the volume view slider - we'll need to reference it in volumeChanged:
	for (UIView *view in [volumeSlider subviews]){
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
			volumeViewSlider = view;
		}
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(volumeChanged:) 
												 name:@"AVSystemController_SystemVolumeDidChangeNotification" 
											   object:nil];*/
	
	
	
	[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	
	//if(!streamer.isPlaying) 
	
//	NSString *lastURL = [[[UIApplication sharedApplication] delegate] currentURLPlaying];
	
//	if(![lastURL isEqualToString: shoutCastURL]) {
		
	    [self buttonPressed:nil];
}

- (void) volumeChanged:(NSNotification *)notify
{
	NSLog(@"volume changed");
	//[volumeViewSlider _updateVolumeFromAVSystemController];
	[volumeViewSlider setValue:[[[notify userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue]];
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
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

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
/*- (IBAction)buttonPressed:(id)sender
{
	if ([button.currentImage isEqual:[UIImage imageNamed:@"playbutton.png"]])
	{
		[downloadSourceField resignFirstResponder];
		
		[self createStreamer: shoutCastURL];
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		[streamer start];
	}
	else
	{
		[streamer stop];
	}
}*/



//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
/*- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
	}
	else if ([streamer isPlaying])
	{
		[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	}
}*/

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
/*- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		positionLabel.text =
			[NSString stringWithFormat:@"Time Played: %.1f seconds",
				progress];
	}
	else
	{
		positionLabel.text = @"Time Played:";
	}
}*/

//
// textFieldShouldReturn:
//
// Dismiss the text field when done is pressed
//
// Parameters:
//    sender - the text field
//
// returns YES
//
/*- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer];
	return YES;
}*/



/****************************************************************************/

- (IBAction)buttonPressed:(id)sender
{
	if (!streamer)
	{
		/////[textField resignFirstResponder];
		
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)shoutCastURL,
															 NULL,
															 NULL,
															 kCFStringEncodingUTF8)
		 autorelease];
		
		
		//NSString *lastURL = [[[UIApplication sharedApplication] delegate] currentURLPlaying];
		
		//if(![lastURL isEqualToString: shoutCastURL]) {
			
			NSURL *url = [NSURL URLWithString:escapedValue];
			
			streamer = [[AudioStreamer alloc] initWithURL:url];
		
		    //copy reference to appDelegate so we can control this stream from anywhere in app
		    [[[UIApplication sharedApplication] delegate] setStreamer: streamer];

			
			// store reference in sharedApp so we get stop at will from
			// anywhere in app
			// test first to see if this stream is playing
		
			
			//[[[UIApplication sharedApplication] delegate] setStreamer: streamer];
			//[[[UIApplication sharedApplication] delegate] setCurrentURLPlaying: shoutCastURL];
			
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
		/*} else {
			NSLog(@"======== same station is playing again! ===========");
			streamer = [[[UIApplication sharedApplication] delegate] streamer];
			[streamer setDelegate:self];
			
			[streamer
			 addObserver:self
			 forKeyPath:@"isPlaying"
			 options:0
			 context:nil];
			//[streamer start];
			
		}*/
		
		
	}
	else
	{
		[button.layer removeAllAnimations];
		[streamer stop];
		[bufferStatusView setProgress:0];
	}
}

- (IBAction)showWebPage:(id)sender {
	
	
	NSString *currentURLString = [currentURL text];
	
	//[navigationController.view addSubview:tableController.view];
	//[navigationController pushViewController:webViewController animated:YES];
	SpeakHereAppDelegate *appDelegate = (SpeakHereAppDelegate*)[[UIApplication sharedApplication] delegate];
	 
	//WebViewController *webViewController = [[WebViewController alloc] init];
	WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle] urlString: currentURLString ];
	[[[appDelegate topicsController] navigationController] pushViewController:webViewController animated:YES];
	
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

-(void) metaDataUpdated:(NSString *)metaData {
	
	NSArray *parts = [metaData componentsSeparatedByString:@";"];
	NSString *streamTitle = [parts objectAtIndex:0];
	NSArray *parts2 = [streamTitle componentsSeparatedByString:@"="];
    NSString *title = [parts2 objectAtIndex:1];
	int start = 1;
	int stop = [title length] -2;
	NSString *trimTitle = [title substringWithRange: NSMakeRange(start,stop)];
	NSLog(@"Meta data updated: %@", trimTitle);
	
	[currentArtist setText:trimTitle];
	[currentArtist setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
	
}

-(void) headerNameUpdated:(NSString *)data {
	

	NSLog(@"header Name: %@", data);
	
	[currentStation setText:data];
	[currentStation setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
	
}

-(void) headerGenreUpdated:(NSString *)data {
	
	
	NSLog(@"header Name: %@", data);
	
	[currentGenre setText:data];
	[currentGenre setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
	
}

-(void) headerURLUpdated:(NSString *)data {
	
	
	NSLog(@"header Name: %@", data);
	
	[currentURL setText:data];
	[currentURL setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
	
}

-(void) headerBitRateUpdated:(NSString *)data {
	
	
	NSLog(@"header Name: %@", data);
	
	[currentBitRate setText:data];
	[currentBitRate setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
	
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
					@"You may want to try a lower bandwidth station if connection keeps dropping."
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



//- (BOOL)textFieldShouldReturn:(UITextField *)sender
//{
//	[self buttonPressed:sender];
///	return NO;
//}
/****************************************************************************/

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[self stopAll];
	//NSLog(@"--------dealloc called!!!!!");
	[self destroyStreamer];
	
	//[streamer stop];
	//[streamer release];
	//streamer = nil;
	
	
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
	[super dealloc];
}

@end
