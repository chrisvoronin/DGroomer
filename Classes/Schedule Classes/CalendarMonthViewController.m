//
//  MonthViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/5/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentViewController.h"
#import "Client.h"
#import "Project.h"
#import "Service.h"
#import "UICalendarMonthButton.h"
#import "CalendarMonthViewController.h"

@interface CalendarMonthViewController (Private)
- (NSInteger)	getNumberOfWeeksForCurrentMonth;
- (void)		releaseAndRepopulateAppointments;
- (void)		setCalendarRowsWithAnimation:(UITableViewRowAnimation)animation;
- (void)		setHeaderText;
@end

@implementation CalendarMonthViewController

@synthesize appointmentCell, calendarMonthCell, currentDate, currentMonth, lbHeader, parentsNavigationController, tblCalendar, tblList;
@synthesize lbSunday, lbMonday, lbTuesday, lbWednesday, lbThursday, lbFriday, lbSaturday;

#define HEIGHT_FOR_ROW 44
#define HEIGHT_FOR_HEADER 45

- (void) viewDidLoad {
	firstLoad = YES;
	calendar = [[NSCalendar autoupdatingCurrentCalendar] retain];
	if( !currentDate ) {
		self.currentDate = [NSDate date];
	}
	if( !currentMonth ) {
		NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentDate];
		[comps setDay:1];
		self.currentMonth = [calendar dateFromComponents:comps];
	}
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	// Fetch
	[self releaseAndRepopulateAppointments];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.lbHeader = nil;
	self.parentsNavigationController = nil;
	self.tblCalendar = nil;
	self.tblList = nil;
	[appointments release];
	[calendar release];
	self.currentDate = nil;
	self.currentMonth = nil;
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
#pragma mark Custom Methods
#pragma mark -
- (void) dataManagerReturnedArray:(NSArray*)theArray {
	if( appointments )	[appointments release];
	// Get dictionary from array...
	appointments = [[PSADataManager sharedInstance] getDictionaryOfAppointmentsForArray:theArray];
	// Draw
	[self setCalendarRowsWithAnimation:UITableViewRowAnimationTop];
	[tblList reloadData];
	[self setHeaderText];
	// Resume
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[parentsNavigationController.visibleViewController.view setUserInteractionEnabled:YES];
	firstLoad = NO;
}

- (void) releaseAndRepopulateAppointments {
	[parentsNavigationController.visibleViewController.view setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	[[PSADataManager sharedInstance] getDictionaryOfAppointmentsForMonth:self.currentMonth];
}

#pragma mark -
#pragma mark Date Methods
#pragma mark -

/*
 *	Updated for 3.2+, should work on 3.1+ equally
 */
- (NSInteger) getNumberOfWeeksForCurrentMonth {
	// Get the range of days in the month
	NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:currentMonth];
	// Get the first day of the first week of the month
	NSDate *firstDay = nil;
	[calendar rangeOfUnit:NSWeekCalendarUnit startDate:&firstDay interval:NULL forDate:currentMonth];
	// Get the last day of the month
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentMonth];
	[comps setDay:dayRange.length];
	NSDate *lastDay = [calendar dateFromComponents:comps];
	// Figure out the difference between first and last
	NSDateComponents *numWeekComps = [calendar components:NSWeekCalendarUnit fromDate:firstDay toDate:lastDay options:0];
	return [numWeekComps week]+1;
}

- (void) setHeaderText {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MMMM yyyy"];
	lbHeader.text = [formatter stringFromDate:self.currentMonth];
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
}

/*
 *
 *	Changed 2/2010: When calling this method the first time the view loaded, adding/deleting rows caused a crash.
 *					Added the firstLoad BOOL flag to handle the first load.
 */
- (void) setCalendarRowsWithAnimation:(UITableViewRowAnimation)animation {
	[UIView beginAnimations:@"aID" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:.3];
	
	NSInteger numWeeks = [self getNumberOfWeeksForCurrentMonth];
	
	if( !firstLoad ) {
		[tblCalendar beginUpdates];
		// Reload the month cells -- animate up
		NSMutableArray *paths = (NSMutableArray*)[tblCalendar indexPathsForVisibleRows];
		
		if( paths.count > numWeeks ) {
			NSInteger numToDelete = paths.count - numWeeks;
			NSMutableArray *pathArray = [[NSMutableArray alloc] init];
			for( int i=0; i < numToDelete; i++ ) {
				[pathArray addObject:[paths lastObject]];
				[paths removeLastObject];
			}
			[tblCalendar deleteRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationTop];
			[pathArray release];
		} else if( paths.count < numWeeks ) {
			NSInteger numToAdd = numWeeks - paths.count;
			NSMutableArray *pathArray = [[NSMutableArray alloc] init];
			for( int i=0; i < numToAdd; i++ ) {
				NSIndexPath *addPath = [NSIndexPath indexPathForRow:paths.count+i inSection:0];
				[pathArray addObject:addPath];
				//[paths addObject:addPath];
			}
			[tblCalendar insertRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationBottom];
			[pathArray release];
		}
		
		// Reload and set heights
		[tblCalendar reloadRowsAtIndexPaths:paths withRowAnimation:animation];
		[tblCalendar endUpdates];
	} else {
		[tblCalendar reloadData];
	}
	
	tblCalendar.frame = CGRectMake( tblCalendar.frame.origin.x, tblCalendar.frame.origin.y, tblCalendar.frame.size.width, numWeeks*HEIGHT_FOR_ROW);
	CGFloat y = tblCalendar.frame.origin.y + tblCalendar.frame.size.height;
	CGFloat height = self.view.frame.size.height - ( (numWeeks*HEIGHT_FOR_ROW)+HEIGHT_FOR_HEADER );
	tblList.frame = CGRectMake( tblList.frame.origin.x, y, tblList.frame.size.width, height );
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Control Methods
#pragma mark -
/*
 *	Turns interaction back on after the calendar draws.
 */
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// Taken out when threading was added
	//self.view.userInteractionEnabled = YES;
}

/*
 *	A calendar date was selected.
 */
- (IBAction) btnTouched:(id)sender {
	self.view.userInteractionEnabled = NO;
	// A calendar button was touched, highlight it and show the appointments
	if( [sender isKindOfClass:[UICalendarMonthButton class]] ) {
		if( currentSelection ) {
			currentSelection.selected = NO;
			[currentSelection setNeedsDisplay];
		}
		currentSelection = (UICalendarMonthButton*)sender;
		currentSelection.selected = YES;
		[currentSelection setNeedsDisplay];
		
		NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.currentMonth];
		[comps setDay:[currentSelection.dayNumber intValue]];
		self.currentDate = [calendar dateFromComponents:comps];
		
		// If a button is pressed that is for the next/previous month, switch to that month
		// Row # is based on indexPath.row which starts at 0
		// The first row should have day numbers 1-7 minimally
		// The last row should have day numbers 28/29/30/31 and below
		if( currentSelection.rowNumber == 0 && [currentSelection.dayNumber intValue] > 7 ) {
			// If it's the first row, and the day number is for 
			[self goToPreviousMonthWithDayNumber:[currentSelection.dayNumber intValue]];
		} else if( (currentSelection.rowNumber == 3 || currentSelection.rowNumber == 4 || currentSelection.rowNumber == 5) && [currentSelection.dayNumber intValue] < 7 ) {
			// If it's the last row, and the day number is for another month's beginning
			[self goToNextMonthWithDayNumber:[currentSelection.dayNumber intValue]];
		} else {
			// The other methods reload the data themselves
			[tblList reloadData];
			self.view.userInteractionEnabled = YES;
		}
	}
}

- (IBAction) goToNextMonthWithDayNumber:(NSInteger)num {
	//self.view.userInteractionEnabled = NO;
	// Deselect if selected
	if( currentSelection ) {
		currentSelection.selected = NO;
		[currentSelection setNeedsDisplay];
		currentSelection = nil;
	}
	// Figure out the next month
	NSDateComponents *todayComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.currentMonth];
	[comps setDay:1];
	if( [comps month] == 12 ) {
		[comps setMonth:1];
		[comps setYear:[comps year]+1];
	} else {
		[comps setMonth:[comps month]+1];
	}
	self.currentMonth = [calendar dateFromComponents:comps];
	
	if( num >= 1 && num <= 31 ) {
		[comps setDay:num];
		self.currentDate = [calendar dateFromComponents:comps];
	} else {
		if( [todayComps month] == [comps month] ) {
			self.currentDate = [calendar dateFromComponents:todayComps];
		} else {
			self.currentDate = [calendar dateFromComponents:comps];
		}
	}
	
	[self releaseAndRepopulateAppointments];
	//[self setCalendarRowsWithAnimation:UITableViewRowAnimationTop];
	//[tblList reloadData];
	//[self setHeaderText];
}

- (IBAction) goToPreviousMonthWithDayNumber:(NSInteger)num {
	//self.view.userInteractionEnabled = NO;
	// Deselect if selected
	if( currentSelection ) {
		currentSelection.selected = NO;
		[currentSelection setNeedsDisplay];
		currentSelection = nil;
	}
	// Figure out the last month
	NSDateComponents *todayComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.currentMonth];
	[comps setDay:1];
	if( [comps month] == 1 ) {
		[comps setMonth:12];
		[comps setYear:[comps year]-1];
	} else {
		[comps setMonth:[comps month]-1];
	}
	self.currentMonth = [calendar dateFromComponents:comps];
	if( num >= 1 && num <= 31 ) {
		[comps setDay:num];
		self.currentDate = [calendar dateFromComponents:comps];
	} else {
		if( [todayComps month] == [comps month] ) {
			self.currentDate = [calendar dateFromComponents:todayComps];
		} else {
			self.currentDate = [calendar dateFromComponents:comps];
		}
	}
	
	[self releaseAndRepopulateAppointments];
	//[self setCalendarRowsWithAnimation:UITableViewRowAnimationBottom];
	//[tblList reloadData];
	//[self setHeaderText];
}

- (void) goToToday {
	//self.view.userInteractionEnabled = NO;
	// Deselect if selected
	if( currentSelection ) {
		currentSelection.selected = NO;
		currentSelection = nil;
	}
	// Figure the dates
	self.currentDate = [NSDate date];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentDate];
	[comps setDay:1];
	self.currentMonth = [calendar dateFromComponents:comps];
	[self releaseAndRepopulateAppointments];
	//[tblList reloadData];
	//[self setHeaderText];
	//[tblCalendar reloadData];
	//self.view.userInteractionEnabled = YES;
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

/*
 *	1 section for both tables
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	return 1;
}

/*
 *	5 or 6 rows for calendar
 *	# of appointments for the appt list
 */
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( aTableView == tblCalendar ) {
		return [self getNumberOfWeeksForCurrentMonth];
	}
	NSArray *tmp = [appointments objectForKey:[[PSADataManager sharedInstance] getStringForAppointmentListHeader:self.currentDate]];
	return tmp.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier;
	if( aTableView == tblCalendar ) {
		identifier = @"CalendarMonthCell";
	} else {
		identifier = @"AppointmentCell";
	}
	UITableViewCell *cell = [tblList dequeueReusableCellWithIdentifier:identifier];
	
    if (cell == nil) {
		if( aTableView == tblCalendar ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = calendarMonthCell;
			self.calendarMonthCell = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		} else {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = appointmentCell;
			self.appointmentCell = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
    }
	
	// Set the data of our cells
	if( aTableView == tblList ) {
		NSArray *tmpArray = [appointments objectForKey:[[PSADataManager sharedInstance] getStringForAppointmentListHeader:self.currentDate]];
		Appointment *tmp = nil;
		if( tmpArray.count >= indexPath.row ) {
			tmp = [tmpArray objectAtIndex:indexPath.row];
		}
		if( tmp ) {
			// Date/Time
			NSString *time = [[PSADataManager sharedInstance] getStringForTime:tmp.dateTime withFormat:NSDateFormatterShortStyle];
			NSArray	*timeArray = [time componentsSeparatedByString:@" "];
			UILabel *label = (UILabel*)[cell viewWithTag:11];
			label.text = [timeArray objectAtIndex:0];
			
			UILabel *label2 = (UILabel*)[cell viewWithTag:12];
			if( timeArray.count > 1 ) {
				label2.text = [timeArray objectAtIndex:1];		
			} else {
				label2.text = nil;
			}
			
			// Name and Service Name
			if( tmp.type == iBizAppointmentTypeSingleService ) {
				[cell viewWithTag:10].backgroundColor = ((Service*)tmp.object).color;
				//
				label = (UILabel*)[cell viewWithTag:13];
				NSString *text = [[NSString alloc] initWithFormat:@"%@ - %@", ((Service*)tmp.object).serviceName, (tmp.client) ? [tmp.client getClientName] : @"No Client"];
				label.text = text;
				[text release];
			} else if( tmp.type == iBizAppointmentTypeProject ) {
				[cell viewWithTag:10].backgroundColor = [UIColor colorWithRed:.596 green:.678 blue:.843 alpha:.7];
				//
				label = (UILabel*)[cell viewWithTag:13];
				NSString *text = [[NSString alloc] initWithFormat:@"%@ - %@", ((Project*)tmp.object).name, (tmp.client) ? [tmp.client getClientName] : @"No Client"];
				label.text = text;
				[text release];
			} else if( tmp.type == iBizAppointmentTypeBlock ) {
				[cell viewWithTag:10].backgroundColor = [UIColor colorWithRed:.165 green:.733 blue:.945 alpha:.7];
				//
				label = (UILabel*)[cell viewWithTag:13];
				NSString *text = [[NSString alloc] initWithFormat:@"%@", (tmp.notes) ? tmp.notes : @"Block"];
				label.text = text;
				[text release];
			}
		}
		
	} else if( aTableView == tblCalendar ) {
		// The components for the selected date
		NSDateComponents *selectedComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
		// Components for calculating the next day
		NSDateComponents *addComps = [[NSDateComponents alloc] init];
		[addComps setDay:1];
		
		// Start with the first weekday of the week of the first day of the month
		NSDate *workingDate = nil;
		[calendar rangeOfUnit:NSWeekCalendarUnit startDate:&workingDate interval:NULL forDate:currentMonth];
		
		// Fixed the API changes (?) by just adding a week to the workingDate
		if( indexPath.row > 0 ) {
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setWeek:indexPath.row];
			workingDate = [calendar dateByAddingComponents:comps toDate:workingDate options:0];
			[comps release];
		}
		
		for( int i=10; i<17; i++ ) {
			NSDateComponents *thisDayComps = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:workingDate];
			UICalendarMonthButton *btn = (UICalendarMonthButton*)[cell viewWithTag:i];
			if( [thisDayComps month] != [selectedComps month] ) {
				btn.highlighted = YES;
			} else {
				btn.highlighted = NO;
				if( [thisDayComps day] == [selectedComps day] ) {
					currentSelection = btn;
					btn.selected = YES;
					[btn setNeedsDisplay];
				} 
			}
			
			NSArray *appts = [appointments objectForKey:[[PSADataManager sharedInstance] getStringForAppointmentListHeader:workingDate]];
			if( appts.count <= 0 ) {
				btn.appointmentsInMorning = NO;
				btn.appointmentsInAfternoon = NO;
			} else {
				// Loop and find if they are morning or evening appointments
				NSDateComponents *noonComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:workingDate];
				[noonComps setHour:12];
				NSDate *noonTime = [calendar dateFromComponents:noonComps];
				for( Appointment *appt in appts ) {
					// Compare it to noon of this day
					NSComparisonResult result = [appt.dateTime compare:noonTime];
					if( result == -1 ) {
						btn.appointmentsInMorning = YES;
					} else {
						btn.appointmentsInAfternoon = YES;
					} 
				}
			}
			// Set the day number and it's row position
			btn.dayNumber = [NSString stringWithFormat:@"%d", [thisDayComps day]];
			btn.rowNumber = indexPath.row;
			workingDate = [calendar dateByAddingComponents:addComps toDate:workingDate options:0];
		}
		
		[addComps release];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSArray *tmpArray = [appointments objectForKey:[[PSADataManager sharedInstance] getStringForAppointmentListHeader:self.currentDate]];
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
	if( tmpArray.count >= indexPath.row ) {
		cont.isEditing = NO;
		cont.appointment = [tmpArray objectAtIndex:indexPath.row];
	} else {
		cont.isEditing = YES;
	}
	[self.parentsNavigationController pushViewController:cont animated:YES];
	[cont release];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if( [cell.reuseIdentifier isEqualToString:@"AppointmentCell"] ) {
		UILabel *label2 = (UILabel*)[cell viewWithTag:12];
		UILabel *detail = (UILabel*)[cell viewWithTag:13];
		if( label2.text ) {
			detail.frame = CGRectMake( 103, 7, 190, 31 );
		} else {
			detail.frame = CGRectMake( 73, 7, 220, 31 );
		}
	}
}


@end