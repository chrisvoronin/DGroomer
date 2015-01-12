//
//  ScheduleViewController.m
//  myBusiness
//
//  Created by David J. Maier on 6/26/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
//#import "AppointmentViewController.h"
#import "CalendarDayViewController.h"
#import "CalendarListViewController.h"
#import "CalendarMonthViewController.h"
#import "CalendarWeekViewController.h"
#import "ScheduleViewController.h"
//#import <QuartzCore/QuartzCore.h>
#import "Project.h"
#import "Client.h"
#import "Company.h"
#import "Service.h"

@implementation ScheduleViewController

@synthesize activeAppointment, calendarView, currentDate, segCalendarType, toolbar;


- (void) viewDidLoad {
	self.title = @"Appointments";
	// Default to today!
	if( !currentDate ) {
		self.currentDate = [NSDate date];
	}
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAppointment)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	firstTime = YES;
	// Orientation Notifications
	//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	//
    firstTime = YES;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;

	// The first time this VC loads it calls viewWillAppear too many times on the calendarView subview
	if( !firstTime ) {
		// Pass on the message
		if( calendarView.subviews.count > 0 ) {
			if( dayController ) {
				[dayController viewWillAppear:YES];
			} else if( listController ) {
				[listController viewWillAppear:YES];
			} else if( monthController ) {
				[monthController viewWillAppear:YES];
			} else if( weekController ) {
				[weekController viewWillAppear:YES];
			}
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (firstTime == YES) {
        segCalendarType.selectedSegmentIndex = 1;
        [self getCalendarEvent:segCalendarType];
        firstTime = NO;
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	//
	[activeAppointment release];
	[dayController release];
	[monthController release];
	[listController release];
	[weekController release];
	self.calendarView = nil;
	self.segCalendarType = nil;
	self.toolbar = nil;
	self.currentDate = nil;
    [super dealloc];
}


- (void) addAppointment {
	// Set the current selected date
	if( dayController )	 {
		self.currentDate = dayController.currentDate;
	}
	if( monthController ) {
		self.currentDate = monthController.currentDate;
	}
	if( weekController ) {
		self.currentDate = weekController.currentDate;
	}
	NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:self.currentDate];
	[comps setSecond:0];
	if( [comps minute] > 0 && [comps minute] < 15 ) {
		[comps setMinute:15];
	} else if( [comps minute] > 15 && [comps minute] < 30 ) {
		[comps setMinute:30];
	} else if( [comps minute] > 30 && [comps minute] < 45 ) { 
		[comps setMinute:45];
	} else if( [comps minute] > 45 ) {
		[comps setHour:[comps hour]+1];
		[comps setMinute:0];
	}
	// Appointment
	Appointment *appt = [[Appointment alloc] init];
	appt.dateTime = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
	// View Controller
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
    
    cont.delegate = self;
    
	cont.isEditing = YES;
	cont.appointment = appt;
	[appt release];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

-(void)appointmentCreated:(id)sender {
    Appointment *appointment = sender;
    
    if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		Email *email = [[PSADataManager sharedInstance] getAppointmentReminderEmail];
		
		// If there's no client, and this is a project, temporarily set the appointment client to the project's client.
		if( !appointment.client && appointment.type == iBizAppointmentTypeProject ) {
			appointment.client = ((Project*)appointment.object).client;
		}
		
		NSString *clientEmail = [appointment.client getEmailAddressHome];
		if( clientEmail == nil ) {
			clientEmail = [appointment.client getEmailAddressWork];
			if( clientEmail == nil ) {
				clientEmail = [appointment.client getEmailAddressAny];
			}
		}
		NSArray *to = [NSArray arrayWithObjects:clientEmail, nil];
		[picker setToRecipients:to];
		[clientEmail release];
		
		if( email.bccCompany ) {
			// Company Info
			Company *company = [[PSADataManager sharedInstance] getCompany];
			// Set up the recipients
			if( company.companyEmail ) {
				NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil];
				[picker setBccRecipients:bccRecipients];
			}
			[company release];
		}
		
		NSString *message = email.message;
		message = [message stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:[appointment.client getClientNameFirstThenLast]];
		if( appointment.type == iBizAppointmentTypeSingleService ) {
			message = [message stringByReplacingOccurrencesOfString:@"<<SERVICE>>" withString:((Service*)appointment.object).serviceName];
		} else if( appointment.type == iBizAppointmentTypeProject ) {
			message = [message stringByReplacingOccurrencesOfString:@"<<SERVICE>>" withString:((Project*)appointment.object).name];
		} else {
			message = [message stringByReplacingOccurrencesOfString:@"<<SERVICE>>" withString:@"Block"];
		}
		message = [message stringByReplacingOccurrencesOfString:@"<<APPT_DATE>>" withString:[[PSADataManager sharedInstance] getStringForDate:appointment.dateTime withFormat:NSDateFormatterLongStyle]];
		message = [message stringByReplacingOccurrencesOfString:@"<<APPT_TIME>>" withString:[[PSADataManager sharedInstance] getStringForTime:appointment.dateTime withFormat:NSDateFormatterShortStyle]];
		
		[picker setSubject:email.subject];
		[picker setMessageBody:message isHTML:NO];
		
		[email release];
		// Present the mail composition interface.
		[self presentViewController:picker animated:YES completion:nil];
		[picker release];
		
		// Get rid of the appointment project client reference
		if( appointment.type == iBizAppointmentTypeProject ) {
			appointment.client = nil;
		}
		
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];
		[alert release];
	}

}

- (IBAction) getCalendarEvent:(id)sender {

	for( UIView *tmp in self.calendarView.subviews ) {
		[tmp removeFromSuperview];
	}
	
	if( sender == segCalendarType ) {
		switch ( ((UISegmentedControl*)sender).selectedSegmentIndex ) {
			case 0: {
				if( dayController )	 {
					self.currentDate = dayController.currentDate;
					[dayController release];
					dayController = nil;
				}
				if( monthController ) {
					self.currentDate = monthController.currentDate;
					[monthController release];
					monthController = nil;
				}
				if( weekController ) {
					self.currentDate = weekController.currentDate;
					[weekController release];
					weekController = nil;
				}
				listController = [[CalendarListViewController alloc] initWithNibName:@"CalendarListView" bundle:nil];
				listController.parentsNavigationController = self.navigationController;
				[self.calendarView addSubview:listController.view];
				[listController viewWillAppear:YES];
				break;
			}
			case 1: {
				if( listController ) {
					[listController release];
					listController = nil;
				}
				if( monthController ) {
					self.currentDate = monthController.currentDate;
					[monthController release];
					monthController = nil;
				}
				if( weekController ) {
					self.currentDate = weekController.currentDate;
					[weekController release];
					weekController = nil;
				}
				dayController = [[CalendarDayViewController alloc] initWithNibName:@"CalendarDayView" bundle:nil];
				dayController.scheduleViewController = self;
				dayController.parentsNavigationController = self.navigationController;
				dayController.currentDate = self.currentDate;
				[self.calendarView addSubview:dayController.view];
				[dayController viewWillAppear:YES];
				break;
			}
			case 2: {
				if( dayController )	 {
					self.currentDate = dayController.currentDate;
					[dayController release];
					dayController = nil;
				}
				if( listController ) {
					[listController release];
					listController = nil;
				}
				if( monthController ) {
					self.currentDate = monthController.currentDate;
					[monthController release];
					monthController = nil;
				}
				weekController = [[CalendarWeekViewController alloc] initWithNibName:@"CalendarWeekView" bundle:nil];
				weekController.parentsNavigationController = self.navigationController;
				weekController.scheduleViewController = self;
				weekController.currentDate = self.currentDate;
				[self.calendarView addSubview:weekController.view];
				[weekController viewWillAppear:YES];
				break;
			}
			case 3: {
				if( listController ) {
					[listController release];
					listController = nil;
				}
				if( dayController ) {
					self.currentDate = dayController.currentDate;
					[dayController release];
					dayController = nil;
				}
				if( weekController ) {
					self.currentDate = weekController.currentDate;
					[weekController release];
					weekController = nil;
				}
				monthController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthView" bundle:nil];
				monthController.parentsNavigationController = self.navigationController;
				monthController.currentDate = self.currentDate;
				[self.calendarView addSubview:monthController.view];
				[monthController viewWillAppear:YES];
				break;
			}
		}
	}
}

- (IBAction) goToToday:(id)sender {
	if( self.calendarView.subviews.count > 0 ) {
		if( [self.calendarView.subviews objectAtIndex:0] == dayController.view ) {
			[dayController goToToday];
		} else if( [self.calendarView.subviews objectAtIndex:0] == listController.view ) {
			[listController goToToday];
		} else if( [self.calendarView.subviews objectAtIndex:0] == monthController.view ) {
			[monthController goToToday];
		} else if( [self.calendarView.subviews objectAtIndex:0] == weekController.view ) {
			[weekController goToToday];
		}
	}	
}

#pragma mark -
#pragma mark Custom Pasteboard Methods
#pragma mark -

- (void) copyAppointment:(Appointment*)appt {
	if( activeAppointment )	[activeAppointment release];
	activeAppointment = [[Appointment alloc] initWithAppointment:appt];
	activeAppointment.standingRepeat = iBizAppointmentRepeatNever;
	activeAppointment.standingRepeatCustom = nil;
	activeAppointment.standingRepeatUntilDate = nil;
	activeAppointment.appointmentID = -1;
}

- (void) cutAppointment:(Appointment*)appt {
	if( activeAppointment )	[activeAppointment release];
	activeAppointment = [appt retain];
	activeAppointment.standingRepeat = iBizAppointmentRepeatNever;
	activeAppointment.standingRepeatCustom = nil;
	activeAppointment.standingRepeatUntilDate = nil;
}

- (void) pasteAppointmentToDate:(NSDate*)date {

	if( activeAppointment ) {

		if( activeAppointment.appointmentID == -1 ) {
			// Copy
			if( calendarView.subviews.count > 0 ) {
				if( dayController ) {
					[dayController addAppointment:activeAppointment];
				} else if( weekController ) {
					[weekController addAppointment:activeAppointment];
				}
			}
			activeAppointment.dateTime = date;
			[[PSADataManager sharedInstance] saveAppointment:activeAppointment updateStanding:NO ignoreConflicts:YES];
			
			if( calendarView.subviews.count > 0 ) {
				if( dayController ) {
					[dayController drawAppointments];
				} else if( weekController ) {
					[weekController drawAppointments];
				}
			}
			// So we can copy again without moving the one just created
			[self copyAppointment:activeAppointment];

		} else {
			// Cut
			
			if( calendarView.subviews.count > 0 ) {
				if( dayController && ![dayController hasAppointment:activeAppointment] ) {
					[dayController addAppointment:activeAppointment];
				} else if( weekController && ![weekController hasAppointment:activeAppointment] ) {
					[weekController addAppointment:activeAppointment];
				}
			}
			
			activeAppointment.dateTime = date;
			[[PSADataManager sharedInstance] saveAppointment:activeAppointment updateStanding:NO ignoreConflicts:YES];
			[activeAppointment release];
			activeAppointment = nil;
			
			if( calendarView.subviews.count > 0 ) {
				if( dayController ) {
					[dayController drawAppointments];
				} else if( weekController ) {
					[weekController drawAppointments];
				}
			}
		}
	}
}


/*
#pragma mark -
#pragma mark Orientation Methods
#pragma mark -

- (void)orientationChanged:(NSNotification *)notification
{
    // We must add a delay here, otherwise we'll swap in the new view
	// too quickly and we'll get an animation glitch
    [self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
}

- (void)updateLandscapeView
{
	if( weekController ) {
		
		UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
		
		if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
		{
			
			DebugLog( @"Landscape!" );

			self.navigationController.navigationBarHidden = YES;
			self.toolbar.hidden = YES;
			weekController.view.frame = CGRectMake( 0, 0, 480, 340 );

			isShowingLandscapeView = YES;
		}
		else if (deviceOrientation == UIDeviceOrientationPortrait && isShowingLandscapeView)
		{
			DebugLog( @"Portrait!" );

			self.navigationController.navigationBarHidden = NO;
			self.toolbar.hidden = NO;
			weekController.view.frame = CGRectMake( 0, 0, 320, 416 );

			isShowingLandscapeView = NO;
		}
		
		[weekController redraw];
		
		DebugLog( @"frame: %f %f %f %f", weekController.view.frame.origin.x, weekController.view.frame.origin.y, weekController.view.frame.size.width, weekController.view.frame.size.height );
		DebugLog( @"bounds: %f %f %f %f", weekController.view.bounds.origin.x, weekController.view.bounds.origin.y, weekController.view.bounds.size.width, weekController.view.bounds.size.height );
		DebugLog( @"center: %f %f", weekController.view.center.x, weekController.view.center.y );
		
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if( weekController ) {
		if( interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
			return NO;
		}
		return YES;
	}
	return NO;
}
 */

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
