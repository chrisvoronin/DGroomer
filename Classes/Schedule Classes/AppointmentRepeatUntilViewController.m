//
//  AppointmentRepeatUntilViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/4/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentRepeatUntilViewController.h"


@implementation AppointmentRepeatUntilViewController

@synthesize appointment, datePicker;


- (void) viewDidLoad {
	//
	self.title = @"REPEAT UNTIL";
	//
    /*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGray.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	// Fixes the time zone issues in 4.0
	datePicker.calendar = [NSCalendar autoupdatingCurrentCalendar];
	//
	if( appointment.dateTime ) {
		datePicker.minimumDate = appointment.dateTime;
	}
	if( appointment.standingRepeatUntilDate ) {
		datePicker.date = appointment.standingRepeatUntilDate;
	} else if( appointment.dateTime ) {
		datePicker.date = appointment.dateTime;
	}
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.appointment = nil;
	self.datePicker = nil;
    [super dealloc];
}

- (void) done {
	// Include the day selected, so set the time to 11:59:00 PM
	NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:datePicker.date];
	[comps setHour:23];
	[comps setMinute:59];
	appointment.standingRepeatUntilDate = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
