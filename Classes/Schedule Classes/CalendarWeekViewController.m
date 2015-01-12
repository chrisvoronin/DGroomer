    //
//  CalendarWeekViewController.m
//  PSA
//
//  Created by David J. Maier on 7/1/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentViewController.h"
#import "CalendarWeekBackgroundView.h"
#import "ScheduleViewController.h"
#import "Settings.h"
#import "UIAppointmentButton.h"
#import "CalendarWeekViewController.h"

#define FULL_WIDTH_LANDSCAPE 461
#define FULL_WIDTH_PORTRAIT 301
#define MINIMUM_HEIGHT 30
#define OFFSET_X 19
#define OFFSET_Y 10
#define SCROLLVIEW_CONTENT_SIZE 1460
#define SCROLLVIEW_CONTENT_SIZE_15_MINUTES 2900

// Private methods
@interface CalendarWeekViewController (Private)
- (void)		scrollToFirstAppointment;
- (void)		scrollToNow;
@end

@implementation CalendarWeekViewController

@synthesize btnBackground, currentDate, lbHeader, parentsNavigationController, scheduleViewController, scrollView;
@synthesize lbSunday, lbMonday, lbTuesday, lbWednesday, lbThursday, lbFriday, lbSaturday;

- (void) viewDidLoad {
	firstLoad = YES;
	calendar = [[NSCalendar autoupdatingCurrentCalendar] retain];
	if( !currentDate ) {
		self.currentDate = [NSDate date];
		isThisWeek = YES;
	}
	// Fetch Settings
	settings = [[PSADataManager sharedInstance] getSettings];
	// Background positioning
	btnBackground.delegate = self;
	btnBackground.daysDisplayed = 7;
	btnBackground.offsetX = OFFSET_X;
	btnBackground.offsetY = OFFSET_Y;
	btnBackground.settings = settings;
	btnBackground.is15MinuteIntervals = settings.is15MinuteIntervals;
	// Adjustments needed?
	if( settings.is15MinuteIntervals ) {
		btnBackground.frame = CGRectMake( btnBackground.frame.origin.x, btnBackground.frame.origin.y, self.view.frame.size.width, SCROLLVIEW_CONTENT_SIZE_15_MINUTES );
		scrollView.contentSize = CGSizeMake( self.view.frame.size.width, SCROLLVIEW_CONTENT_SIZE_15_MINUTES );
	} else {
		btnBackground.frame = CGRectMake( btnBackground.frame.origin.x, btnBackground.frame.origin.y, self.view.frame.size.width, SCROLLVIEW_CONTENT_SIZE );
		scrollView.contentSize = CGSizeMake( self.view.frame.size.width, SCROLLVIEW_CONTENT_SIZE );
	}
	//
	pixelsPerHour = (btnBackground.frame.size.height-(OFFSET_Y*2))/24;
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	// Set header titles
	NSDate *today = [NSDate date];
	NSDate *weekBegin = nil;
	NSDate *weekEnd = nil;
	
	[calendar rangeOfUnit:NSWeekCalendarUnit startDate:&weekBegin interval:NULL forDate:currentDate];
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:6];
	weekEnd = [calendar dateByAddingComponents:comps toDate:weekBegin options:0];
	NSString *header = [[NSString alloc] initWithFormat:@"%@ - %@", [[PSADataManager sharedInstance] getStringForDate:weekBegin withFormat:NSDateFormatterShortStyle], [[PSADataManager sharedInstance] getStringForDate:weekEnd withFormat:NSDateFormatterShortStyle] ];
	lbHeader.text = header;
	[header release];
	[comps setDay:7];
	weekEnd = [calendar dateByAddingComponents:comps toDate:weekBegin options:0];
	[comps release];
	
	// Set the labels' colors
	if( [today earlierDate:weekEnd] == today && [today laterDate:weekBegin] == today ) {
		// Today gets a blue color
		lbHeader.textColor = [UIColor colorWithRed:0 green:.45 blue:.9 alpha:1];
		isThisWeek = YES;
		// Set the day label to blue for today
		NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:today];
		switch ( [comps weekday]-[calendar firstWeekday] ) {
			case -7:
			case 0:
				lbSunday.textColor = lbHeader.textColor;
				break;
			case -6:
			case 1:
				lbMonday.textColor = lbHeader.textColor;
				break;
			case -5:
			case 2:
				lbTuesday.textColor = lbHeader.textColor;
				break;
			case -4:
			case 3:
				lbWednesday.textColor = lbHeader.textColor;
				break;
			case -3:
			case 4:
				lbThursday.textColor = lbHeader.textColor;
				break;
			case -2:
			case 5:
				lbFriday.textColor = lbHeader.textColor;
				break;
			case -1:
			case 6:
				lbSaturday.textColor = lbHeader.textColor;
				break;
		}
	} else {
		// Otherwise a gray color
		lbHeader.textColor = [UIColor colorWithRed:.22 green:.27 blue:.33 alpha:1];
		lbSunday.textColor = lbHeader.textColor;
		lbMonday.textColor = lbHeader.textColor;
		lbTuesday.textColor = lbHeader.textColor;
		lbWednesday.textColor = lbHeader.textColor;
		lbThursday.textColor = lbHeader.textColor;
		lbFriday.textColor = lbHeader.textColor;
		lbSaturday.textColor = lbHeader.textColor;
		isThisWeek = NO;
	}
	
	// Fetch the appointments
	[[PSADataManager sharedInstance] getAppointmentsFromDate:weekBegin toDate:weekEnd];
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
 */
 
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[appointments release];
	self.btnBackground = nil;
	[calendar release];
	[currentDate release];
	self.lbHeader = nil;
	self.parentsNavigationController = nil;
	self.scheduleViewController = nil;
	self.scrollView = nil;
	[settings release];
	self.lbSunday = nil;
	self.lbMonday = nil;
	self.lbTuesday = nil;
	self.lbWednesday = nil;
	self.lbThursday = nil;
	self.lbFriday = nil;
	self.lbSaturday = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	if( appointments )	[appointments release];
	appointments = [theArray retain];
	
	[self redraw];
	
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[super.view setUserInteractionEnabled:YES];
}


- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
	// For some reason I need this to eliminate the unwanted options on subviews.
	return NO;
}

/*
 These methods are declared by the UIResponderStandardEditActions informal protocol.
 */
- (void)copy:(id)sender {
	if( [sender isKindOfClass:[UIAppointmentButton class]] ) {
		[scheduleViewController copyAppointment:((UIAppointmentButton*)sender).appointment];
	}
}

- (void)cut:(id)sender {
	if( [sender isKindOfClass:[UIAppointmentButton class]] ) {
		[scheduleViewController cutAppointment:((UIAppointmentButton*)sender).appointment];
	}
}

- (void)paste:(id)sender {
	if( sender == btnBackground ) {
		[scheduleViewController pasteAppointmentToDate:[self getDateForEvent:btnBackground.lastTouch]];
	}
}

- (void) addAppointment:(Appointment*)theAppt {
	[((NSMutableArray*)appointments) addObject:theAppt];
}

#pragma mark -
#pragma mark Drawing Methods
#pragma mark -

- (void) drawAppointments {
	
	// Remove any previously drawn UIAppointmentButtons
	for( UIView *sub in scrollView.subviews ) {
		if( [sub isKindOfClass:[UIAppointmentButton class]] ) {
			[sub removeFromSuperview];
		}
	}
	// Draw the UIAppointmentButtons
	for( Appointment *tmp in appointments ) {
		// Figure out the positioning based on time
		NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:tmp.dateTime];
		CGFloat width = (scrollView.contentSize.width-OFFSET_X)/btnBackground.daysDisplayed;
		//
		NSInteger weekdayIndex = [comps weekday]-[calendar firstWeekday];
		if( weekdayIndex < 0 ) {
			// Wrap it around by adding 7 (assumed number of days in a week)
			weekdayIndex = weekdayIndex + 7;
		}
		CGFloat xStart = OFFSET_X+(weekdayIndex*width);
		CGFloat yStart = OFFSET_Y+([comps hour]*pixelsPerHour)+(([comps minute]/60.0)*pixelsPerHour);
		CGFloat height = ((tmp.duration/60.0)/60.0)*pixelsPerHour;
		
		// Make the minimum height 30 to fit the text
		if( height < MINIMUM_HEIGHT )	height = MINIMUM_HEIGHT;
		
		CGRect frame = CGRectMake( xStart, yStart, width, height );
		UIAppointmentButton *btn = [[UIAppointmentButton alloc] initWithFrame:frame];
		btn.isWeekAppointment = YES;
		btn.pixelsPerMinute = pixelsPerHour/60;
		btn.appointment = tmp;
		
		frame = CGRectMake( xStart, yStart, width, btn.frame.size.height );
		btn.delegate = self;
		btn.frame = frame;
		btn.column = 0;
		[btn addTarget:self action:@selector(goToAppointment:forEvent:) forControlEvents:UIControlEventApplicationReserved];
		[self.scrollView addSubview:btn];
		[btn release];
	}
}

- (BOOL) hasAppointment:(Appointment*)theAppt {
	return [appointments containsObject:theAppt];
}

- (void) redraw {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSArray *weekdays = [formatter shortWeekdaySymbols];
	[formatter release];
	
	// Set the header weekday labels
	switch ( [calendar firstWeekday] ) {
		case 1:
			lbSunday.text = [weekdays objectAtIndex:0];
			lbMonday.text = [weekdays objectAtIndex:1];
			lbTuesday.text = [weekdays objectAtIndex:2];
			lbWednesday.text = [weekdays objectAtIndex:3];
			lbThursday.text = [weekdays objectAtIndex:4];
			lbFriday.text = [weekdays objectAtIndex:5];
			lbSaturday.text = [weekdays objectAtIndex:6];
			break;
		case 2:
			lbSunday.text = [weekdays objectAtIndex:1];
			lbMonday.text = [weekdays objectAtIndex:2];
			lbTuesday.text = [weekdays objectAtIndex:3];
			lbWednesday.text = [weekdays objectAtIndex:4];
			lbThursday.text = [weekdays objectAtIndex:5];
			lbFriday.text = [weekdays objectAtIndex:6];
			lbSaturday.text = [weekdays objectAtIndex:0];
			break;
		case 3:
			lbSunday.text = [weekdays objectAtIndex:2];
			lbMonday.text = [weekdays objectAtIndex:3];
			lbTuesday.text = [weekdays objectAtIndex:4];
			lbWednesday.text = [weekdays objectAtIndex:5];
			lbThursday.text = [weekdays objectAtIndex:6];
			lbFriday.text = [weekdays objectAtIndex:0];
			lbSaturday.text = [weekdays objectAtIndex:1];
			break;
		case 4:
			lbSunday.text = [weekdays objectAtIndex:3];
			lbMonday.text = [weekdays objectAtIndex:4];
			lbTuesday.text = [weekdays objectAtIndex:5];
			lbWednesday.text = [weekdays objectAtIndex:6];
			lbThursday.text = [weekdays objectAtIndex:0];
			lbFriday.text = [weekdays objectAtIndex:1];
			lbSaturday.text = [weekdays objectAtIndex:2];
			break;
		case 5:
			lbSunday.text = [weekdays objectAtIndex:4];
			lbMonday.text = [weekdays objectAtIndex:5];
			lbTuesday.text = [weekdays objectAtIndex:6];
			lbWednesday.text = [weekdays objectAtIndex:0];
			lbThursday.text = [weekdays objectAtIndex:1];
			lbFriday.text = [weekdays objectAtIndex:2];
			lbSaturday.text = [weekdays objectAtIndex:3];
			break;
		case 6:
			lbSunday.text = [weekdays objectAtIndex:5];
			lbMonday.text = [weekdays objectAtIndex:6];
			lbTuesday.text = [weekdays objectAtIndex:0];
			lbWednesday.text = [weekdays objectAtIndex:1];
			lbThursday.text = [weekdays objectAtIndex:2];
			lbFriday.text = [weekdays objectAtIndex:3];
			lbSaturday.text = [weekdays objectAtIndex:4];
			break;
		case 7:
			lbSunday.text = [weekdays objectAtIndex:6];
			lbMonday.text = [weekdays objectAtIndex:0];
			lbTuesday.text = [weekdays objectAtIndex:1];
			lbWednesday.text = [weekdays objectAtIndex:2];
			lbThursday.text = [weekdays objectAtIndex:3];
			lbFriday.text = [weekdays objectAtIndex:4];
			lbSaturday.text = [weekdays objectAtIndex:5];
			break;
	}
	
	[self drawAppointments];
	
	if( firstLoad ) {
		if( isThisWeek ) {
			[self scrollToNow];
		} else if( appointments.count > 0 ) {
			[self scrollToFirstAppointment];
		}
		firstLoad = NO;
	}
}

#pragma mark -
#pragma mark Custom Control Methods
#pragma mark -

- (NSDate*) getDateForEvent:(UIEvent*)theEvent {
	NSDate *theDate = nil;
	// Get the location of the touch and calculate the time of day
	CGFloat touchX = [((UITouch*)[[theEvent allTouches] anyObject]) locationInView:btnBackground].x - OFFSET_X;
	CGFloat touchY = [((UITouch*)[[theEvent allTouches] anyObject]) locationInView:btnBackground].y - OFFSET_Y;
	
	// I have no idea why, but the above doesn't work on 3.1.3
	if( [[UIDevice currentDevice].systemVersion doubleValue] < 3.2 ) {
		touchX = [btnBackground getLastTouchPoint].x - OFFSET_X;
		touchY = [btnBackground getLastTouchPoint].y - OFFSET_Y;
	}

	if( touchY > 0 && touchX > 0 ) {
		NSInteger weekDay = floor(touchX/((scrollView.contentSize.width-OFFSET_X)/btnBackground.daysDisplayed));
		NSInteger hours = floor(touchY/pixelsPerHour);
		NSInteger minutes = touchY-(hours*pixelsPerHour);
		if( minutes > 0 && minutes < 30 ) {
			minutes = 0;
		} else if( minutes > 30 ) { 
			minutes = 30;
		}
		// Set the date to our time
		NSDateComponents *comps = [calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:currentDate];
		[comps setHour:hours];
		[comps setMinute:minutes];
		
		NSInteger weekdayIndex = [comps weekday]-[calendar firstWeekday];
		if( weekdayIndex < 0 ) {
			// Wrap it around by adding 7 (assumed number of days in a week)
			weekdayIndex = weekdayIndex + 7;
		}
		NSInteger dayDiff = weekdayIndex-weekDay;
		[comps setDay:[comps day]-dayDiff];
		
		theDate = [calendar dateFromComponents:comps];
	}

	return theDate;
}

/*
 *	goToAppointment
 *	Pushes a view controller for the selected appointment onto the navigation stack that our parent VC sends us.
 *	If the sender is the background button, create a new appointment with the touch location as the date.
 */
- (void) goToAppointment:(id)sender forEvent:(UIEvent*)event {
	if( ![[UIMenuController sharedMenuController] isMenuVisible] ) {
		BOOL appointmentNeedsRelease = NO;
		BOOL createNewAppointment = NO;
		Appointment *appt = nil;
		
		if( [sender isKindOfClass:[UIAppointmentButton class]] ) {
			appt = ((UIAppointmentButton*)sender).appointment;
			// If in gap
			if( [((UIAppointmentButton*)sender) touchInGapWithEvent:event] ) {
				createNewAppointment = YES;
			}
		} else if( [sender isKindOfClass:[UIButton class]] ) {
			createNewAppointment = YES;
		}
		
		if( createNewAppointment ) {
			// Create the appointment
			appt = [[Appointment alloc] init];
			appointmentNeedsRelease = YES;
			appt.dateTime = [self getDateForEvent:event];
		}
		
		if( appt && parentsNavigationController ) {
			AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
			cont.appointment = appt;
			if( createNewAppointment ) {
				UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
				cont.isEditing = YES;
				cont.navigationItem.leftBarButtonItem = cancel;
				cont.navigationItem.hidesBackButton = YES;
				[cancel release];
				UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
				//nav.navigationBar.tintColor = [UIColor blackColor];
				[scheduleViewController presentViewController:nav animated:YES completion:nil];
				[nav release];
			} else {
				[parentsNavigationController pushViewController:cont animated:YES];
			}
			[cont release];
			if( appointmentNeedsRelease )	[appt release];
		}
	}
}

/*
 *	Subtract a week from the current date
 */
- (IBAction) goToLastWeek:(id)sender {
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
	[comps setDay:[comps day]-7];
	self.currentDate = [calendar dateFromComponents:comps];
	firstLoad = YES;
	[self viewWillAppear:YES];
}

/*
 *	Add a week to the current date
 */
- (IBAction) goToNextWeek:(id)sender {
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
	[comps setDay:[comps day]+7];
	self.currentDate = [calendar dateFromComponents:comps];
	firstLoad = YES;
	[self viewWillAppear:YES];
}

/*
 *	goToToday
 *	Sets the current date to today and displays
 */
- (void) goToToday {
	self.currentDate = [NSDate date];
	isThisWeek = YES;
	[self viewWillAppear:YES];
}

/*
 *	scrollToFirstAppointment
 *	Scrolls to the location of the first appointment of the day
 */
- (void) scrollToFirstAppointment {
	CGFloat firstLocation = SCROLLVIEW_CONTENT_SIZE;
	for( UIView *btn in scrollView.subviews ) {
		if( [btn isKindOfClass:[UIAppointmentButton class]] ) {
			if( btn.frame.origin.y < firstLocation ) {
				firstLocation = btn.frame.origin.y;
			}
		}
	}
	if( firstLocation == SCROLLVIEW_CONTENT_SIZE ) {
		firstLocation = 0;
	}
	CGRect visibleArea = CGRectMake( 0, firstLocation-7, scrollView.frame.size.width, scrollView.frame.size.height );
	[scrollView scrollRectToVisible:visibleArea animated:YES];
}

/*
 *	scrollToNow
 *	Scrolls to the current hour (of today)
 */
- (void) scrollToNow {
	NSDate *now = [NSDate date];
	NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:now];
	CGRect visibleArea = CGRectMake( 0, ([comps hour]*pixelsPerHour), scrollView.frame.size.width, scrollView.frame.size.height );
	[scrollView scrollRectToVisible:visibleArea animated:YES];
}

@end
