//
//  SetDailyHoursViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "Settings.h"
#import "SetDailyHoursViewController.h"

// Private methods
@interface SetDailyHoursViewController (Private)
- (void) finishLessThanStartError;
@end

@implementation SetDailyHoursViewController

@synthesize dayIsOff, dayOfTheWeek, hoursTable, settings, timePicker;

- (void)viewDidLoad {
	// Set the background
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[hoursTable setBackgroundColor:bgColor];
	[bgColor release];
	// Cancel Button
	UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = btnCancel;
	[btnCancel release];
	// Save Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	start = nil;
	finish = nil;
	tableIndexEditing = 0;
	// Fixes the time zone issues in 4.0
	timePicker.calendar = [NSCalendar autoupdatingCurrentCalendar];
	//
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	PSADataManager *manager = [PSADataManager sharedInstance];
	NSDateFormatterStyle format = [manager getWorkHoursDateFormat];
	switch (dayOfTheWeek) {
		case DailyHoursDayOfTheWeekSunday:
			self.title = @"Sunday";
			if( settings.sundayStart )	start = [[manager getTimeForString:settings.sundayStart withFormat:format] retain];
			if( settings.sundayFinish )	finish = [[manager getTimeForString:settings.sundayFinish withFormat:format] retain];
			break;
		case DailyHoursDayOfTheWeekMonday:
			self.title = @"Monday";
			if( settings.mondayStart )	start = [[manager getTimeForString:settings.mondayStart withFormat:format] retain];
			if( settings.mondayFinish )	finish = [[manager getTimeForString:settings.mondayFinish withFormat:format] retain];
			break;
		case DailyHoursDayOfTheWeekTuesday:
			self.title = @"Tuesday";
			if( settings.tuesdayStart )		start = [[manager getTimeForString:settings.tuesdayStart withFormat:format] retain];
			if( settings.tuesdayFinish )	finish = [[manager getTimeForString:settings.tuesdayFinish withFormat:format] retain];
			break;
		case DailyHoursDayOfTheWeekWednesday:
			self.title = @"Wednesday";
			if( settings.wednesdayStart )	start = [[manager getTimeForString:settings.wednesdayStart withFormat:format] retain];
			if( settings.wednesdayFinish )	finish = [[manager getTimeForString:settings.wednesdayFinish withFormat:format] retain];
			break;
		case DailyHoursDayOfTheWeekThursday:
			self.title = @"Thursday";
			if( settings.thursdayStart )	start = [[manager getTimeForString:settings.thursdayStart withFormat:format] retain];
			if( settings.thursdayFinish )	finish = [[manager getTimeForString:settings.thursdayFinish withFormat:format] retain];
			break;
		case DailyHoursDayOfTheWeekFriday:
			self.title = @"Friday";
			if( settings.fridayStart )	start = [[manager getTimeForString:settings.fridayStart withFormat:format] retain];
			if( settings.fridayFinish )	finish = [[manager getTimeForString:settings.fridayFinish withFormat:format] retain];
			break;
		case DailyHoursDayOfTheWeekSaturday:
			self.title = @"Saturday";
			if( settings.saturdayStart )	start = [[manager getTimeForString:settings.saturdayStart withFormat:format] retain];
			if( settings.saturdayFinish )	finish = [[manager getTimeForString:settings.saturdayFinish withFormat:format] retain];
			break;
	}
	// Refresh the table
	[hoursTable reloadData];
	// Set the time to the start time
	[timePicker setDate:start animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.timePicker = nil;
	[start release];
	[finish release];
	[hoursTable release];
	[settings release];
    [super dealloc];
}

- (void) cancel {
	// Just go back
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) save {
	if( [start compare:finish] != NSOrderedAscending ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Finishing time cannot be before the starting time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		PSADataManager *manager = [PSADataManager sharedInstance];
		NSDateFormatterStyle format = [manager getWorkHoursDateFormat];
		// Set the values
		switch (dayOfTheWeek) {
			case DailyHoursDayOfTheWeekSunday:
				settings.sundayStart = [manager getStringForTime:start withFormat:format];
				settings.sundayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isSundayOff = dayIsOff;
				break;
			case DailyHoursDayOfTheWeekMonday:
				settings.mondayStart = [manager getStringForTime:start withFormat:format];
				settings.mondayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isMondayOff = dayIsOff;
				break;
			case DailyHoursDayOfTheWeekTuesday:
				settings.tuesdayStart = [manager getStringForTime:start withFormat:format];
				settings.tuesdayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isTuesdayOff = dayIsOff;
				break;
			case DailyHoursDayOfTheWeekWednesday:
				settings.wednesdayStart = [manager getStringForTime:start withFormat:format];
				settings.wednesdayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isWednesdayOff = dayIsOff;
				break;
			case DailyHoursDayOfTheWeekThursday:
				settings.thursdayStart = [manager getStringForTime:start withFormat:format];
				settings.thursdayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isThursdayOff = dayIsOff;
				break;
			case DailyHoursDayOfTheWeekFriday:
				settings.fridayStart = [manager getStringForTime:start withFormat:format];
				settings.fridayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isFridayOff = dayIsOff;
				break;
			case DailyHoursDayOfTheWeekSaturday:
				settings.saturdayStart = [manager getStringForTime:start withFormat:format];
				settings.saturdayFinish = [manager getStringForTime:finish withFormat:format];
				settings.isSaturdayOff = dayIsOff;
				break;
			default:
				break;
		}
		// Save and pop
		[manager updateSettings:settings];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction) timeChanged:(id)sender {
	if( tableIndexEditing == 0 ) {
		if( start )		[start release];
		start = [timePicker.date retain];
	} else if( tableIndexEditing == 1 ) {
		if( finish )	[finish release];
		finish = [timePicker.date retain];
	}
	[hoursTable reloadData];
}

- (void) toggleOffDay {
	dayIsOff = !dayIsOff;
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	Start, Finish, Off Day switch
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = nil;
	if( indexPath.row == 2 ) {
		identifier = @"DayOffCell";
	} else {
		identifier = @"WorkHoursCell";
	}
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if( cell == nil ) {
		if( indexPath.row == 2 ) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
			// Make the switch
			UISwitch *swActive = [[UISwitch alloc] init];
			[swActive addTarget:self action:@selector(toggleOffDay) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = swActive;
			[swActive release];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
			cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
		}
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

	PSADataManager *manager = [PSADataManager sharedInstance];
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Start";
			cell.detailTextLabel.text = [manager getStringForTime:start withFormat:[manager getWorkHoursDateFormat]];
			break;
		case 1:
			cell.textLabel.text = @"Finish";
			cell.detailTextLabel.text = [manager getStringForTime:finish withFormat:[manager getWorkHoursDateFormat]];
			break;
		case 2:
			cell.textLabel.text = @"Day Off";
			((UISwitch*)cell.accessoryView).on = dayIsOff;
			break;
	}

	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
	// Set the time of the picker to the selected row's time
	if( indexPath.row == 0 ) {
		tableIndexEditing = 0;
		if( start )		[timePicker setDate:start animated:YES];
	} else if( indexPath.row == 1 ) {
		tableIndexEditing = 1;
		if( finish )	[timePicker setDate:finish animated:YES];
	}
	[tableView reloadData];
}

/*
 *	Maintain a background color on the row that is being "edited".
 *	This is the way Apple shows selection in the Calendar app, so it should be OK.
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {	
	// Change the background of the "editing" cell, or revert to the "unediting" cell style
	if( tableIndexEditing == indexPath.row ) {
		UIImage *bg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"selectedCellBackground" ofType:@"png"]];
		UIColor *color = [[UIColor alloc] initWithPatternImage:bg];
		cell.backgroundColor = color;
		[color release];
		[bg release];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	} else {
		cell.backgroundColor = [UIColor whiteColor];
		cell.detailTextLabel.textColor = [UIColor colorWithRed:.22 green:.33 blue:.53 alpha:1];
		cell.textLabel.textColor = [UIColor blackColor];
	}
}


@end
