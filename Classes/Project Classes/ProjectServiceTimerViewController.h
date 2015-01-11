//
//  ProjectServiceTimerViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/27/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, ProjectService;

@interface ProjectServiceTimerViewController : UIViewController {
	Project				*project;
	ProjectService		*projectService;
	// Interface
	UIButton			*btnReset;
	UIButton			*btnStartStop;
	UILabel				*lbActual;
	UILabel				*lbColonLeft;
	UILabel				*lbColonRight;
	UILabel				*lbSaveInfo;
	UILabel				*lbTime;	// Replace with UITextField for manual entry?
	UISegmentedControl	*segManual;
	UITextField			*txtActualHours;
	UITextField			*txtActualMinutes;
	UITextField			*txtActualSeconds;
	UITextField			*txtEstimated;
	UIView				*viewTimer;
	
	NSTimer				*timer;
}

@property (nonatomic, retain) Project			*project;
@property (nonatomic, retain) ProjectService	*projectService;
// Interface
@property (nonatomic, retain) IBOutlet UIButton				*btnReset;
@property (nonatomic, retain) IBOutlet UIButton				*btnStartStop;
@property (nonatomic, retain) IBOutlet UILabel				*lbActual;
@property (nonatomic, retain) IBOutlet UILabel				*lbColonLeft;
@property (nonatomic, retain) IBOutlet UILabel				*lbColonRight;
@property (nonatomic, retain) IBOutlet UILabel				*lbSaveInfo;
@property (nonatomic, retain) IBOutlet UILabel				*lbTime;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segManual;
@property (nonatomic, retain) IBOutlet UITextField			*txtActualHours;
@property (nonatomic, retain) IBOutlet UITextField			*txtActualMinutes;
@property (nonatomic, retain) IBOutlet UITextField			*txtActualSeconds;
@property (nonatomic, retain) IBOutlet UITextField			*txtEstimated;
@property (nonatomic, retain) IBOutlet UIView				*viewTimer;

- (IBAction)	btnResetTouchUp:(id)sender;
- (IBAction)	btnStartStopTouchUp:(id)sender;
- (void)		createAndStartTimer;
- (void)		resignResponders;
- (void)		save;
- (IBAction)	segManualChanged:(id)sender;
- (void)		setActualTextFields;
- (void)		timerFireMethod:(NSTimer*)theTimer;
- (void)		updateLabels;

@end
