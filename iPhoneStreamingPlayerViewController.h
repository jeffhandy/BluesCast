//
//  iPhoneStreamingPlayerViewController.h
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

#import <UIKit/UIKit.h>


@class AudioStreamer;
@class MPVolumeView;
@class AQLevelMeter;
@class WebViewController;

@interface iPhoneStreamingPlayerViewController : UIViewController <UIAlertViewDelegate>
{
	IBOutlet UITextField *downloadSourceField;
	IBOutlet UILabel *currentArtist;
	IBOutlet UITextView *currentStation;
	IBOutlet UILabel *currentBitRate;
	IBOutlet UILabel *currentGenre;
	IBOutlet UILabel *currentURL;
	IBOutlet UIButton *button;
	IBOutlet MPVolumeView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet AQLevelMeter*		lvlMeter_in;
	IBOutlet UIProgressView *bufferStatusView;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSString *shoutCastURL;
	UISlider *volumeViewSlider;
	NSInteger CurrentLevel;
	int selectedTableRow;
}

- (IBAction)buttonPressed:(id)sender;
- (IBAction)showWebPage:(id)sender;
- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;

@property (nonatomic, retain) NSString *shoutCastURL;
@property (nonatomic, retain) IBOutlet UILabel *currentArtist;
@property (nonatomic, retain) IBOutlet UITextView *currentStation;
@property (nonatomic, retain) IBOutlet UILabel *currentBitRate;
@property (nonatomic, retain) IBOutlet UILabel *currentGenre;
@property (nonatomic, retain) IBOutlet UILabel *currentURL;
@property (nonatomic, retain) IBOutlet MPVolumeView *volumeSlider;
@property (nonatomic, retain) IBOutlet UIProgressView *bufferStatusView;
@property (nonatomic, retain)	AQLevelMeter		*lvlMeter_in;
@property (nonatomic, retain)	AudioStreamer *streamer;
@property (nonatomic, readwrite) NSInteger CurrentLevel;
@property (readwrite) int selectedTableRow;

@end

