//
//  SimpleInterfaceViewController.h
//  BluesCast
//
//  Created by Jeff H on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioStreamer.h"
#import "SoundEffect.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "AlertRun.h"


@interface SimpleInterfaceViewController : UIViewController {

	SoundEffect *clickSound;
	SoundEffect *bufferingSound;
	SoundEffect *failedSound;
	IBOutlet UIButton *nextButton; 
	IBOutlet UIButton *previousButton; 
	IBOutlet UIButton *switchModeButton; 
	NSMutableArray *data;
	int currentStationIndex;
	IBOutlet UIProgressView *bufferStatusView;
	NSTimer *bufferingSoundTimer;
	
}
@property (nonatomic, retain) IBOutlet UIProgressView *bufferStatusView;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *switchModeButton;
@property (nonatomic, retain)	AudioStreamer *streamer;

- (IBAction) nextStation:(id)sender;
- (IBAction) previousStation:(id)sender;
-(IBAction) switchMode:(id)sender;
@end
