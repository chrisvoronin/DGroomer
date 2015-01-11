//
//  FirstViewController.m
//  PSA
//
//  Created by Michael Simone on 3/5/09.
//  Copyright Dropped Pin 2009. All rights reserved.
//

#import "FirstViewController.h"


@implementation FirstViewController

@synthesize dayController;
@synthesize weekController;
@synthesize monthController;
@synthesize apptController;
@synthesize addApptController;

static FirstViewController *_sharedFirstViewController = nil;

+ (FirstViewController *) FirstViewSharedController
{
    if (!_sharedFirstViewController)
        _sharedFirstViewController = [[[self class] alloc] init];
    return _sharedFirstViewController;
}

- (IBAction)cancel:(id)sender {
	[self.view removeFromSuperview];
}

- (NSString*)getCalendarDay {
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSDate *date =[NSDate date];
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	
	return formattedDateString;
}

// Get the correct nib loaded depending on which action the user wants to take
- (IBAction)getCalendarEvent:(id)sender {
    	
	switch ([sender selectedSegmentIndex])
	{
		case 0:	// Day
		{
			// Load the calendar day nib file
			[self.view addSubview:dayController.view];
			break;
		}
		case 1: // Week
		{	
			// Load the calendar week nib file
			[self.view addSubview:weekController.view];
			break;
		}
		case 2:	// Month
		{
			// Load the calendar month nib file
			[self.view addSubview:monthController.view];
			break;
		}
	}
}

- (IBAction)getCurrentDay:(id)sender {
	
    NSLog(@"Get current day please");
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
 */

- (void)loadControllers {
	// Load the controllers for later
	dayController = [[DayViewController alloc] initWithNibName:@"CalendarDayView" bundle:[NSBundle mainBundle]];
	weekController = [[WeekViewController alloc] initWithNibName:@"CalendarWeekView" bundle:[NSBundle mainBundle]];
	monthController = [[MonthViewController alloc] initWithNibName:@"CalendarMonthView" bundle:[NSBundle mainBundle]];
	apptController = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:[NSBundle mainBundle]];
	addApptController = [[AddApptController alloc] initWithNibName:@"AddAppointView" bundle:[NSBundle mainBundle]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// Load the controllers
	[self loadControllers];
	
	//Since we are starting with the day selected, show that nib
	[self.view addSubview:dayController.view];

}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[dayController release];
	[weekController release];
	[monthController release];
	[apptController release];
	[addApptController release];

    [super dealloc];
}

@end
