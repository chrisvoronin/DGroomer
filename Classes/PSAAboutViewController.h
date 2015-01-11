//
//  PSAAboutViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/4/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSAViewController.h"
#import <UIKit/UIKit.h>


@interface PSAAboutViewController : UIViewController<UIAlertViewDelegate> {
	id	flipDelegate;
	IBOutlet UILabel	*lbVersion;
}

@property (nonatomic, retain) UILabel				*lbVersion;
@property (nonatomic, assign) id <FlipDelegate>		flipDelegate;


- (IBAction) contactSupport:(id)sender;
- (IBAction) done:(id)sender;
- (IBAction) goToWebsite:(id)sender;


@end
