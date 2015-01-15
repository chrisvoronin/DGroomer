//
//  ScheduleViewController.h
//  myBusiness
//
//  Created by David J. Maier on 6/26/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "PSADataManager.h"
#import "Service.h"
#import "AppointmentDatePickerViewController.h"


@implementation AppointmentDatePickerViewController

@synthesize appointment, datePicker, lbDate, segPicker;


- (void)viewDidLoad {
	self.title = @"APPT. DATE";
    // Set the view background to match the grouped tables in the other views.
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
	
	if( appointment.dateTime ) {
		[datePicker setDate:appointment.dateTime animated:NO];
	} else {
		// Set minimum date to the current time rounded to the nearest 15 minutes
		//NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		NSDate *theDate = [NSDate date];
		NSDateComponents *comps = [gregorian components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:theDate];
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
		[datePicker setDate:[gregorian dateFromComponents:comps] animated:NO];
		//[gregorian release];
	}
	[self updateLabel];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.datePicker = nil;
	self.lbDate = nil;
	self.segPicker = nil;
	[appointment release];
    [super dealloc];
}


- (void) done {
	appointment.dateTime = datePicker.date;
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) datePickerChanged:(id)sender {
	[self updateLabel];
}

- (IBAction) segPickerChanged:(id)sender {
	if( segPicker.selectedSegmentIndex == 0 ) {
		datePicker.datePickerMode = UIDatePickerModeDateAndTime;
	} else {
		// Updated 7/2010, time was changing incorrectly
		NSDate *tmp = [datePicker.date retain];
		datePicker.datePickerMode = UIDatePickerModeDate;
		datePicker.date = tmp;
		[tmp release];
	}
}

- (void) updateLabel {
	NSString *dateTime = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:datePicker.date withFormat:NSDateFormatterFullStyle], [[PSADataManager sharedInstance] getStringForTime:datePicker.date withFormat:NSDateFormatterShortStyle]];
	lbDate.text = dateTime;
	[dateTime release];
}

@end

