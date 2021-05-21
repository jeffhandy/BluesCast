//
//  PreferencesViewController.h
//  BluesCast
//
//  Created by Jeff H on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreferencesViewController : UIViewController {
	
	IBOutlet UISwitch *shuffleStationsSwitch;
	IBOutlet UISwitch *carModeSwitch;
	IBOutlet UIButton *doneButton; 
	
}

- (IBAction)submitChanges:(id)sender;

@end
