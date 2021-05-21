//
//  StreamEditorViewController.h
//  BluesCast
//
//  Created by Jeff H on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpeakHereAppDelegate.h"

#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "AlertRun.h"



@interface StreamEditorViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate>  {

	IBOutlet UITextField *stationURLField;
	IBOutlet UITextField *stationTitleField;
	IBOutlet UIButton *finishedButton;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIButton *button; //test link button
	IBOutlet UISegmentedControl *streamTypeSegmentedControl;
	IBOutlet UISegmentedControl *streamRateSegmentedControl;
	NSInteger CurrentLevel;
	IBOutlet UIProgressView *bufferStatusView;
	AudioStreamer *streamer;
}

/*@property (nonatomic, retain) IBOutlet UITextField stationURLField;
@property (nonatomic, retain) IBOutlet UITextField stationTitleField;
@property (nonatomic, retain) IBOutlet UISegmentedControl streamTypeSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl streamRateSegmentedControl;*/

@property (nonatomic, retain) IBOutlet UIProgressView *bufferStatusView;
@property (nonatomic, readwrite) NSInteger CurrentLevel;
@property (nonatomic, retain)	AudioStreamer *streamer;

- (IBAction)submitChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;
- (IBAction)testLink:(id)sender;

- (IBAction)buttonPressed:(id)sender;
- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;

@end
