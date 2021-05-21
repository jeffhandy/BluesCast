//
//  InformationController.h
//  MonkeyIQ
//
//  Created by Jeff H on 5/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InformationController : UIViewController {
	IBOutlet UIButton* closeButton;

}
@property (nonatomic, retain) IBOutlet UIButton* closeButton;
-(IBAction) closeWindow;

@end
