//
//  ProjectServiceTimerViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/27/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectService.h"
#import "PSADataManager.h"
#import "ProjectServiceTimerViewController.h"


@implementation ProjectServiceTimerViewController

@synthesize project, projectService;
@synthesize btnReset, btnStartStop, lbActual, lbColonLeft, lbColonRight, lbSaveInfo, lbTime, segManual;
@synthesize txtActualHours, txtActualMinutes, txtActualSeconds, txtEstimated, viewTimer;

- (void) viewDidLoad {
	if( projectService ) {
		self.title = projectService.serviceName;
	} else {
		self.title = @"Service Details";
	}
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	//
	if( project.dateCompleted ) {
		lbSaveInfo.hidden = YES;
		[self.view setUserInteractionEnabled:NO];
	}
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[self setActualTextFields];
	// Set values and whatnot
	if( projectService.isTimed ) {
		[segManual setSelectedSegmentIndex:1];
		if( projectService.isTiming ) {
			// Start the timer if needed
			btnReset.enabled = NO;
			[btnStartStop setImage:[UIImage imageNamed:@"btnServiceTimerStop.png"] forState:UIControlStateNormal];
			[self createAndStartTimer];
		}
	} else {
		[segManual setSelectedSegmentIndex:0];
	}
	NSString *est = [[NSString alloc] initWithFormat:@"%d", (projectService.secondsEstimated/3600)];
	txtEstimated.text = est;
	[est release];
}

- (void) viewWillDisappear:(BOOL)animated {
	if( !project.dateCompleted ) {
		[self save];
	}
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	if( [timer isValid] ) {
		[timer invalidate];
		timer = nil;
	}
	self.btnReset = nil;
	self.btnStartStop = nil;
	self.lbActual = nil;
	self.lbColonLeft = nil;
	self.lbColonRight = nil;
	self.lbSaveInfo = nil;
	self.lbTime = nil;
	self.segManual = nil;
	self.txtActualHours = nil;
	self.txtActualMinutes = nil;
	self.txtActualSeconds = nil;
	self.txtEstimated = nil;
	self.viewTimer = nil;
	[project release];
	[projectService release];
    [super dealloc];
}

- (void) createAndStartTimer {
	if( [timer isValid] ) {
		[timer invalidate];
		timer = nil;
	}
	timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	[timer release];
}

- (void) save {
	BOOL allOK = YES;
	if( [txtEstimated.text integerValue] >= 0  ) {
		projectService.secondsEstimated = [txtEstimated.text integerValue]*3600;
		
		if( !projectService.isTimed ) {
			NSInteger hours = [txtActualHours.text integerValue];
			NSInteger minutes = [txtActualMinutes.text integerValue];
			NSInteger seconds = [txtActualSeconds.text integerValue];
			projectService.secondsWorked = (hours*3600)+(minutes*60)+seconds;
		}
		
	} else {
		allOK = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Estimate" message:@"Estimated hours must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
	
	if( allOK ) {
		// Save to DB
		[[PSADataManager sharedInstance] saveProjectService:projectService];
		// Update Invoice & Project totals
		[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
		//
		// Not needed when saving in viewWillDisappear:
		//[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark Control Methods
#pragma mark -
/*
 *
 */
- (IBAction) btnResetTouchUp:(id)sender {
	segManual.enabled = NO;
	btnReset.enabled = NO;
	btnStartStop.enabled = NO;
	[projectService resetTimer];
	[self updateLabels];
	segManual.enabled = YES;
	btnReset.enabled = YES;
	btnStartStop.enabled = YES;
	// (This is done in viewWillDisappear) -- Update Invoice & Project totals
	//[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
}

/*
 *
 */
- (IBAction) btnStartStopTouchUp:(id)sender {
	segManual.enabled = NO;
	btnReset.enabled = NO;
	btnStartStop.enabled = NO;
	if( projectService.isTiming ) {
		[projectService stopTiming];
		if( [timer isValid] ) {
			[timer invalidate];
			timer = nil;
		}
		btnReset.enabled = YES;
		[btnStartStop setImage:[UIImage imageNamed:@"btnServiceTimerStart.png"] forState:UIControlStateNormal];
		[self updateLabels];
	} else {
		btnReset.enabled = NO;
		[btnStartStop setImage:[UIImage imageNamed:@"btnServiceTimerStop.png"] forState:UIControlStateNormal];
		[projectService startTiming];
		[self createAndStartTimer];
	}
	btnStartStop.enabled = YES;
	segManual.enabled = YES;
	// (This is done in viewWillDisappear) -- Update Invoice & Project totals
	//[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
}

/*
 *
 */
- (IBAction) segManualChanged:(id)sender {

	if( segManual.selectedSegmentIndex == 0 ) {
		if( projectService.isTiming ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Timer Running" message:@"Please stop the timer before switching back to manual entry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			segManual.selectedSegmentIndex = 1;
		} else {
			[self setActualTextFields];
			
			projectService.isTimed = NO;
			lbTime.hidden = YES;
			btnReset.hidden = YES;
			btnStartStop.hidden = YES;
			lbActual.hidden = NO;
			lbColonLeft.hidden = NO;
			lbColonRight.hidden = NO;
			txtActualHours.hidden = NO;
			txtActualMinutes.hidden = NO;
			txtActualSeconds.hidden = NO;
		}
	} else {
		
		NSInteger hours = [txtActualHours.text integerValue];
		NSInteger minutes = [txtActualMinutes.text integerValue];
		NSInteger seconds = [txtActualSeconds.text integerValue];
		projectService.secondsWorked = (hours*3600)+(minutes*60)+seconds;
		
		projectService.isTimed = YES;
		lbActual.hidden = YES;
		lbColonLeft.hidden = YES;
		lbColonRight.hidden = YES;
		txtActualHours.hidden = YES;
		txtActualMinutes.hidden = YES;
		txtActualSeconds.hidden = YES;
		lbTime.hidden = NO;
		btnReset.hidden = NO;
		btnStartStop.hidden = NO;
	}
	[self updateLabels];
}

- (void) setActualTextFields {
	NSInteger seconds = projectService.secondsWorked;
	NSInteger hours = seconds / 3600;
	NSInteger minutes = (seconds % 3600) / 60;
	seconds = seconds-(hours*3600)-(minutes*60);
	NSString *hrs = [[NSString alloc] initWithFormat:@"%02d", hours];
	txtActualHours.text = hrs;
	[hrs release];
	NSString *mins = [[NSString alloc] initWithFormat:@"%02d", minutes];
	txtActualMinutes.text = mins;
	[mins release];
	NSString *secs = [[NSString alloc] initWithFormat:@"%02d", seconds];
	txtActualSeconds.text = secs;
	[secs release];
}

/*
 *
 */
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( [string isEqualToString:@""] ) {
		return YES;
	} else if( textField == txtActualHours ) {
		if( txtActualHours.text.length >= 3 ) {
			return NO;
		}
	} else if( textField == txtActualMinutes ) {
		if( txtActualMinutes.text.length >= 2 ) {
			return NO;
		}
	} else if( textField == txtActualSeconds ) {
		if( txtActualSeconds.text.length >= 2 ) {
			return NO;
		}
	}
	return YES;
}

/*
 *	Update the timer label
 */
- (void) timerFireMethod:(NSTimer*)theTimer {
	[self updateLabels];
}

/*
 *	Resign all responders (dismiss keyboard)
 */
- (void) resignResponders {
	[txtActualHours resignFirstResponder];
	[txtActualMinutes resignFirstResponder];
	[txtActualSeconds resignFirstResponder];
	[txtEstimated resignFirstResponder];
}
/*
 *	Resign all responders (dismiss keyboard)
 */
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self resignResponders];
}

/*
 *	Update the timer (and other?) labels
 */
- (void) updateLabels {
	NSInteger seconds = [projectService getSecondsWorkedForTimer];
	NSInteger hours = seconds / 3600;
	NSInteger minutes = (seconds % 3600) / 60;
	seconds = seconds-(hours*3600)-(minutes*60);
	NSString *time = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
	lbTime.text = time;
	[time release];
	[lbTime setNeedsDisplay];
}

@end
