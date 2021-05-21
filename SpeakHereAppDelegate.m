/*

    File: SpeakHereAppDelegate.m
Abstract: Application delegate for SpeakHere
 Version: 2.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.


*/

#import "SpeakHereAppDelegate.h"
//#import "SpeakHereViewController.h"
#import "iPhoneStreamingPlayerViewController.h"
#import "TopicsViewController.h"

@implementation SpeakHereAppDelegate

@synthesize window;
@synthesize controller;
@synthesize topicsController;
@synthesize data;
@synthesize streamer;
@synthesize currentURLPlaying;
@synthesize carMode, shuffleMode;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
    //[[NSUserDefaults standardUserDefaults] objectforKey:@"shuffleMode"];
	
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *dataPath = [path stringByAppendingPathComponent:@"Data.plist"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [[NSString alloc] initWithString: @"datacopy.plist"];
	NSString* copyPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	// randomize the array
	
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:copyPath];
	
	NSMutableArray *tempArray = NULL;
	if(exists) {
	    //NSMutableDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	    tempArray = [[NSMutableArray alloc] initWithContentsOfFile:copyPath];
	} else {
		tempArray = [[NSMutableArray alloc] initWithContentsOfFile:dataPath];
		
	}
	
	NSMutableArray *randomizedArray = [[NSMutableArray alloc] init];
	
	int size = [tempArray count];
	int randArr[size];
	[self chooseNonDuplicatingSequence:size max:size array:randArr];
	
	for(int i=0; i< size; i++) {
		int r = randArr[i];
		id obj = [tempArray objectAtIndex:r];
		[randomizedArray insertObject:obj atIndex:i];
	}
	
	//BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:copyPath];
	if(!exists) {

	    BOOL success = [tempArray writeToFile:copyPath atomically:YES];
	    if (success == NO)
	    {
		    NSLog(@"failed copying XML plist file");
		
	    } else {
		    NSLog(@"success copying XML plist file");
	    }
	}
	
	
	self.data = randomizedArray;
	[tempArray release];
	[randomizedArray release];
	
	
	// old method before randomizing
	/*NSMutableArray *tempArray;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:copyPath];
	if(!exists) {
		
	    tempArray = [[NSMutableArray alloc] initWithContentsOfFile:dataPath];
		BOOL success = [tempArray writeToFile:copyPath atomically:NO];
		if (success == NO)
		{
			NSLog(@"failed copying XML plist file");
			
		} else {
			NSLog(@"success copying XML plist file");
		}
		
	} else {
		
	    tempArray = [[NSMutableArray alloc] initWithContentsOfFile:copyPath];
	}
		
	self.data = tempArray;
	[tempArray release];*/
	
	
	
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
	
	
	//topicsController = [[TopicsViewController alloc] initWithNibName:@"TopicsViewController" bundle:[NSBundle mainBundle]];
	//viewController = [[SpeakHereViewController alloc] initWithNibName:@"SpeakHereViewController" bundle:[NSBundle mainBundle]];
	
	//NSLog(@"init player!!!---");
	//player = [[Player alloc] init];
	
	topicsController = [[TopicsViewController alloc] init];
	//[window addSubview:topicsController.view];
    [window setRootViewController: topicsController];

    [window makeKeyAndVisible];
	
	[self setupSounds];
}



-(void) chooseNonDuplicatingSequence:(int)size max:(int)max array:(int*)seq {
	
		
	for(int i=0; i< size; i++) {
	    int pos = (int)(0 + (arc4random() % max));
		bool found = 0;
		for(int a=0; a< i; a++) {
			int c =seq[a];
			if(pos == c) {
				//NSLog(@"found dup: %d at count: %d", c, i);
				found = 1;
				i--;
				break;
			}
		}
		if(!found) {
			seq[i] = pos;
		}
	}
	
	//NSLog(@"chosen positions:");
	
	for(int b=0; b < size; b++) {
		int c = seq[b];
	    //NSLog(@"position is %d",c);
	}
	
	
}

-(void) setupSounds {
	//clickSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"]];
    bluesSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blues" ofType:@"caf"]];
	
	[bluesSound play];
		
}


- (void)dealloc {
	[data release];
    //[viewController release];
    [window release];
    [super dealloc];
}


@end
