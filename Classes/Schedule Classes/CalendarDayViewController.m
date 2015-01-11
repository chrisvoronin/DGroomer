//
//  DayViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/18/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentViewController.h"
#import "CalendarDayBackgroundView.h"
#import "Client.h"
#import "ScheduleViewController.h"
#import "Service.h"
#import "Settings.h"
#import "UIAppointmentButton.h"
#import "CalendarDayViewController.h"

// Private methods
@interface CalendarDayViewController (Private)
- (NSInteger)	getAvailableColumnForButtons:(NSArray*)buttons;
- (NSArray*)	getOverlappingViewsWithFrame:(CGRect)traversingFrame;
- (NSInteger)	getTotalNumberOfColumnsForButtons:(NSArray*)buttons;
- (CGFloat)		getWidthForNumberOfColumns:(NSInteger)cols;
- (void)		resizeButtons;
- (void)		scrollToFirstAppointment;
- (void)		scrollToNow;
@end

#define FULL_WIDTH 260
#define MINIMUM_HEIGHT 30
#define OFFSET_X 53
#define OFFSET_Y 10
#define SCROLLVIEW_CONTENT_SIZE 1460
#define SCROLLVIEW_CONTENT_SIZE_15_MINUTES 2900

@implementation CalendarDayViewController

@synthesize btnBackground, currentDate, lbDayHeader, lbMonthHeader, parentsNavigationController, scheduleViewController, scrollView;

- (void) viewDidLoad {
	firstLoad = YES;
	calendar = [[NSCalendar autoupdatingCurrentCalendar] retain];
	if( !currentDate ) {
		self.currentDate = [NSDate date];
		isToday = YES;
	}
	// Fetch Settings
	settings = [[PSADataManager sharedInstance] getSettings];
	// Background positioning
	btnBackground.delegate = self;
	btnBackground.offsetX = OFFSET_X;
	btnBackground.offsetY = OFFSET_Y;
	btnBackground.is15MinuteIntervals = settings.is15MinuteIntervals;
	// Adjustments needed?
	if( settings.is15MinuteIntervals ) {
		btnBackground.frame = CGRectMake( btnBackground.frame.origin.x, btnBackground.frame.origin.y, btnBackground.frame.size.width, SCROLLVIEW_CONTENT_SIZE_15_MINUTES );
		scrollView.contentSize = CGSizeMake( 320, SCROLLVIEW_CONTENT_SIZE_15_MINUTES );
	} else {
		scrollView.contentSize = CGSizeMake( 320, SCROLLVIEW_CONTENT_SIZE );
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
	NSString *todayString = [[PSADataManager sharedInstance] getStringForAppointmentListHeader:[NSDate date]];
	NSString *realString = [[PSADataManager sharedInstance] getStringForAppointmentListHeader:currentDate];
	// Set the labels' colors
	if( [todayString isEqualToString:realString] ) {
		// Today gets a blue color
		lbDayHeader.textColor = [UIColor colorWithRed:0 green:.45 blue:.9 alpha:1];
		lbMonthHeader.textColor = lbDayHeader.textColor;
		isToday = YES;
	} else {
		// Otherwise a gray color
		lbDayHeader.textColor = [UIColor colorWithRed:.22 green:.27 blue:.33 alpha:1];
		lbMonthHeader.textColor = lbDayHeader.textColor;
	}
	// Set the labels' text
	NSArray *substrings = [realString componentsSeparatedByString:@"_"];
	if( substrings.count > 2 ) {
		lbDayHeader.text = [substrings objectAtIndex:2];
		lbMonthHeader.text = [substrings objectAtIndex:1];
	}

	// Remove any previously drawn UIAppointmentButtons
	for( UIView *sub in scrollView.subviews ) {
		if( [sub isKindOfClass:[UIAppointmentButton class]] ) {
			[sub removeFromSuperview];
		}
	}
	
	// Set some more background properties
	NSDateComponents *hourComponents = [calendar components:NSWeekdayCalendarUnit fromDate:currentDate];
	btnBackground.isDayOff = NO;
	btnBackground.workHoursBegin = nil;
	btnBackground.workHoursEnd = nil;
	
	switch( [hourComponents weekday] ) {
		case 1:
			if( settings.isSundayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.sundayStart;
				btnBackground.workHoursEnd = settings.sundayFinish;
			}
			break;
		case 2:
			if( settings.isMondayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.mondayStart;
				btnBackground.workHoursEnd = settings.mondayFinish;
			}
			break;
		case 3:
			if( settings.isTuesdayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.tuesdayStart;
				btnBackground.workHoursEnd = settings.tuesdayFinish;
			}
			break;
		case 4:
			if( settings.isWednesdayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.wednesdayStart;
				btnBackground.workHoursEnd = settings.wednesdayFinish;
			}
			break;
		case 5:
			if( settings.isThursdayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.thursdayStart;
				btnBackground.workHoursEnd = settings.thursdayFinish;
			}
			break;
		case 6:
			if( settings.isFridayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.fridayStart;
				btnBackground.workHoursEnd = settings.fridayFinish;
			}
			break;
		case 7:
			if( settings.isSaturdayOff )	btnBackground.isDayOff = YES;
			else {
				btnBackground.workHoursBegin = settings.saturdayStart;
				btnBackground.workHoursEnd = settings.saturdayFinish;
			}
			break;
	}
	[btnBackground setNeedsDisplay];
	
	// Fetch the appointments
	[[PSADataManager sharedInstance] getAppointmentsForDay:currentDate];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[settings release];
	[appointments release];
	[calendar release];
	self.currentDate = nil;
	self.parentsNavigationController = nil;
	self.scrollView = nil;
	self.btnBackground = nil;
	self.lbDayHeader = nil;
	self.lbMonthHeader = nil;
	self.scheduleViewController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	if( appointments )	[appointments release];
	appointments = [theArray retain];
	// Draw the UIAppointmentButtons
	[self drawAppointments];
	
	if( firstLoad ) {
		if( isToday ) {
			[self scrollToNow];
		} else if( appointments.count > 0 ) {
			[self scrollToFirstAppointment];
		}
		firstLoad = NO;
	}
	
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
- (void) copy:(id)sender {
	if( [sender isKindOfClass:[UIAppointmentButton class]] ) {
		[scheduleViewController copyAppointment:((UIAppointmentButton*)sender).appointment];
	}
}

- (void) cut:(id)sender {
	if( [sender isKindOfClass:[UIAppointmentButton class]] ) {
		[scheduleViewController cutAppointment:((UIAppointmentButton*)sender).appointment];
	}
}

- (void) paste:(id)sender {
	if( sender == btnBackground ) {
		[scheduleViewController pasteAppointmentToDate:[self getDateForEvent:btnBackground.lastTouch]];
	}
}

#pragma mark -
#pragma mark Appointment Methods
#pragma mark -

- (void) addAppointment:(Appointment*)theAppt {
	[((NSMutableArray*)appointments) addObject:theAppt];
}

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
		NSDateComponents *comps = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:tmp.dateTime];
		CGFloat xStart = OFFSET_X;
		CGFloat yStart = OFFSET_Y+([comps hour]*pixelsPerHour)+(([comps minute]/60.0)*pixelsPerHour);
		CGFloat width = 260;
		CGFloat height = ((tmp.duration/60.0)/60.0)*pixelsPerHour;
		
		// Make the minimum height 30 to fit the text
		if( height < MINIMUM_HEIGHT )	height = MINIMUM_HEIGHT;
		
		CGRect frame = CGRectMake( xStart, yStart, width, height );
		UIAppointmentButton *btn = [[UIAppointmentButton alloc] initWithFrame:frame];
		btn.pixelsPerMinute = pixelsPerHour/60;
		btn.appointment = tmp;
		
		frame = CGRectMake( xStart, yStart, width, btn.frame.size.height );
		btn.frame = frame;
		btn.column = 0;
		btn.delegate = self;
		[btn addTarget:self action:@selector(goToAppointment:forEvent:) forControlEvents:UIControlEventApplicationReserved];
		[self.scrollView addSubview:btn];
		[btn release];
	}
	[self resizeButtons];
}

- (BOOL) hasAppointment:(Appointment*)theAppt {
	return [appointments containsObject:theAppt];
}

#pragma mark -
#pragma mark Custom Control Methods
#pragma mark -

- (NSDate*) getDateForEvent:(UIEvent*)theEvent {
	NSDate *theDate = nil;
	// Get the location of the touch and calculate the time of day
	CGFloat touchY = [((UITouch*)[[theEvent allTouches] anyObject]) locationInView:btnBackground].y - OFFSET_Y;
	
	// I have no idea why, but the above doesn't work on 3.1.3
	if( [[UIDevice currentDevice].systemVersion doubleValue] < 3.2 ) {
		touchY = [btnBackground getLastTouchPoint].y - OFFSET_Y;
	}

	if( touchY > 0 ) {
		NSInteger hours = floor(touchY/pixelsPerHour);
		NSInteger minutes = touchY-(hours*pixelsPerHour);
		if( minutes > 0 && minutes < 30 ) {
			minutes = 0;
		} else if( minutes > 30 ) { 
			minutes = 30;
		}
		// Set the date to our time
		NSDateComponents *comps = [calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:currentDate];
		[comps setHour:hours];
		[comps setMinute:minutes];
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
				nav.navigationBar.tintColor = [UIColor blackColor];
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
 *	goToToday
 *	Sets the current date to today and displays
 */
- (void) goToToday {
	self.currentDate = [NSDate date];
	isToday = YES;
	firstLoad = YES;
	[self viewWillAppear:YES];
}

/*
 *	goToTomorrow
 *	Sets the current date to tomorrow and displays
 */
- (IBAction) goToTomorrow:(id)sender {
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
	[comps setDay:[comps day]+1];
	self.currentDate = [calendar dateFromComponents:comps];
	isToday = NO;
	firstLoad = YES;
	[self viewWillAppear:YES];
}

/*
 *	goToYesterday
 *	Sets the current date to yesterday and displays
 */
- (IBAction) goToYesterday:(id)sender {
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
	[comps setDay:[comps day]-1];
	self.currentDate = [calendar dateFromComponents:comps];
	isToday = NO;
	firstLoad = YES;
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

#pragma mark -
#pragma mark Custom Methods
#pragma mark -
/*
 *	getOverlappingViewsWithFrame
 *	Returns an array of buttons that overlap with the traversingFrame (15 min. block)
 *	Must release when done!
 */
- (NSArray*) getOverlappingViewsWithFrame:(CGRect)traversingFrame {
	NSMutableArray * returnArray = [[NSMutableArray alloc] init];
	// For each appointment button
	for( UIView *sub in scrollView.subviews ) {
		if( [sub isKindOfClass:[UIAppointmentButton class]] ) {
			// If it intersects add it for return
			if( [(UIAppointmentButton*)sub overlapsWithFrame:traversingFrame] ) {
				[returnArray addObject:sub];
			}
		}
	}
	return returnArray;
}

/*
 *	getWidthForNumberOfColumns
 *	Returns the width of each appointment based on the number of columns
 */
- (CGFloat) getWidthForNumberOfColumns:(NSInteger)cols {
	switch ( cols ) {
		case 1:
			return FULL_WIDTH;
		case 2:
			return FULL_WIDTH/2;
		case 3:
			return FULL_WIDTH/3;
		case 4:
			return FULL_WIDTH/4;
		case 5:
			return FULL_WIDTH/5;
		case 6:
			return FULL_WIDTH/6;
		default:
			return FULL_WIDTH/4;
	}
}

/*
 *	getAvailableColumnForButtons
 *	Returns the column index of the first available column based on the buttons passed
 */
- (NSInteger) getAvailableColumnForButtons:(NSArray*)buttons {
	// TODO: Handle a double booking gap?
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for( int i=0; i<buttons.count; i++ ) {
		[array addObject:[NSNumber numberWithInt:i]];
	}
	
	for( UIAppointmentButton *btn in buttons ) {
		if( btn.positionFixed ) {
			[array removeObject:[NSNumber numberWithInt:btn.column]];
		}
	}
	
	//DebugLog( @"Total: %d   Avail Columns: %d", buttons.count, array.count );
	
	if( array.count > 0 ) {
		int returnVal = [[array objectAtIndex:0] intValue];
		[array release];
		return returnVal;
	}
	return -1;
}

/*
 *	getTotalNumberOfColumnsForButtons
 *	Returns the total number of columns known by each button, or the number of buttons
 */
- (NSInteger) getTotalNumberOfColumnsForButtons:(NSArray*)buttons {
	// TODO: Handle a double booking gap?
	NSInteger returnVal = buttons.count;
	for( UIAppointmentButton *tmp in buttons ) {
		if( tmp.totalColumns > returnVal ) {
			returnVal = tmp.totalColumns;
		}
	}
	return returnVal;
}

/*
 *	resizeButtons
 *	Traverses down the scroll view, measuring overlapping buttons in 15 minute increments
 *	then adjusting their width according to the number of buttons (columns) that overlap.
 *	Button positions are marked fixed and their column is recorded after being set.
 *
 *	NOTE: Some overlap may occur in situations where there are 4+ columns, but it should not be detrimental 
 *	except for very small appointment durations. This may need to be fixed later.
 */
- (void) resizeButtons {
	// Calculation variables
	NSInteger currentYPosition, numCols, width;
	// For each 15 minute interval from 12:00 AM on...
	for( currentYPosition = OFFSET_Y; currentYPosition < pixelsPerHour*24+OFFSET_Y; currentYPosition=currentYPosition+(pixelsPerHour/4) ) {
		// Get the colliding views
		NSArray *collisions = [self getOverlappingViewsWithFrame:CGRectMake( OFFSET_X, currentYPosition, FULL_WIDTH, (pixelsPerHour/4)-1 )];
		// Get the variable data
		numCols = [self getTotalNumberOfColumnsForButtons:collisions];
		width = [self getWidthForNumberOfColumns:numCols];
		CGRect frame;
		//DebugLog( @"Position: %d  Collisions: %d", currentYPosition, numCols );
		// For each button that overlaps
		for( NSInteger i=0; i < collisions.count; i++ ) {
			// Fetch the object
			UIAppointmentButton *btn = (UIAppointmentButton*)[collisions objectAtIndex:i];
			frame = btn.frame;
			// If this position was set to fixed after the first pass
			if( btn.positionFixed ) {
				// If the fixed position width is greater than the width our columns need
				if( btn.frame.size.width > width ) {
					frame = CGRectMake( OFFSET_X+(width*i), btn.frame.origin.y, width, btn.frame.size.height );
					btn.column = i;
				}
			} else {
				// Get the column to put our button in
				NSInteger col = [self getAvailableColumnForButtons:collisions];
				// Otherwise default to i (iterative)
				if( col == -1 )	col = i;
				// Set the frame and column position
				frame = CGRectMake( OFFSET_X+(width*col), currentYPosition, width, btn.frame.size.height );
				btn.column = col;
				btn.totalColumns = numCols;
			}
			btn.frame = frame;
			btn.positionFixed = YES;
		}
		[collisions release];
	}
}

@end
