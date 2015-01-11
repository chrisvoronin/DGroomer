//
//  PSAViewController.h
//  myBusiness
//
//  Created by David J. Maier on 6/8/09.
//  Modified by David J. Maier on 10/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
//#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

// This protocol is used to tell the root view to flip between views
@protocol FlipDelegate <NSObject>
@required
- (void) toggleView:(id)sender;
@end

@class PSAAboutViewController;

@interface PSAViewController : PSABaseViewController <FlipDelegate> {
	PSAAboutViewController	*aboutController;
	// Buttons
	IBOutlet UIButton *btnInfo;
	IBOutlet UIButton *btnProjects;
	IBOutlet UIButton *btnClients;
	IBOutlet UIButton *btnSchedule;
	IBOutlet UIButton *btnRegister;
	IBOutlet UIButton *btnServices;
	IBOutlet UIButton *btnProducts;
	IBOutlet UIButton *btnReports;
	IBOutlet UIButton *btnSettings;
}

@property (nonatomic, retain) UIButton *btnInfo;
@property (nonatomic, retain) UIButton *btnProjects;
@property (nonatomic, retain) UIButton *btnClients;
@property (nonatomic, retain) UIButton *btnSchedule;
@property (nonatomic, retain) UIButton *btnRegister;
@property (nonatomic, retain) UIButton *btnServices;
@property (nonatomic, retain) UIButton *btnProducts;
@property (nonatomic, retain) UIButton *btnReports;
@property (nonatomic, retain) UIButton *btnSettings;
@property (retain, nonatomic) IBOutlet UIButton *btnFreeCardReader;
@property (retain, nonatomic) IBOutlet UIButton *btnContact;

@property (retain, nonatomic) IBOutlet UIScrollView *containerView;

- (IBAction) scheduleB:(id)sender;
- (IBAction) clientsB:(id)sender;
- (IBAction) formulateB:(id)sender;
- (IBAction) registerB:(id)sender;
- (IBAction) reportsB:(id)sender;
- (IBAction) settingsB:(id)sender;
- (IBAction) productsB:(id)sender;
- (IBAction) servicesB:(id)sender;
- (IBAction) getInfo:(id)sender;

- (void) layoutButtonsWithoutProjects;

@end

