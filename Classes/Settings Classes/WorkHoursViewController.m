//
//  WorkHoursViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "SetDailyHoursViewController.h"
#import "Settings.h"
#import "WorkHoursViewController.h"


@implementation WorkHoursViewController

@synthesize hoursTable;


- (void) viewDidLoad {
	// Nav Bar Title
	self.title = @"WORKING HOURS";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[hoursTable setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
	settings = [[PSADataManager sharedInstance] getSettings];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[hoursTable reloadData];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[settings release];
	[hoursTable release];
    [super dealloc];
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
 *	Row for each day
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 7;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"WorkHoursCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"WorkHoursCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
    }
	
	NSString *start = nil;
	NSString *end = nil;
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Sunday";
			if( !settings.isSundayOff ) {
				start = settings.sundayStart;
				end = settings.sundayFinish;
			}
			break;
		case 1:
			cell.textLabel.text = @"Monday";
			if( !settings.isMondayOff ) {
				start = settings.mondayStart;
				end = settings.mondayFinish;
			}
			break;
		case 2:
			cell.textLabel.text = @"Tuesday";
			if( !settings.isTuesdayOff ) {
				start = settings.tuesdayStart;
				end = settings.tuesdayFinish;
			}
			break;
		case 3:
			cell.textLabel.text = @"Wednesday";
			if( !settings.isWednesdayOff ) {
				start = settings.wednesdayStart;
				end = settings.wednesdayFinish;
			}
			break;
		case 4:
			cell.textLabel.text = @"Thursday";
			if( !settings.isThursdayOff ) {
				start = settings.thursdayStart;
				end = settings.thursdayFinish;
			}
			break;
		case 5:
			cell.textLabel.text = @"Friday";
			if( !settings.isFridayOff ) {
				start = settings.fridayStart;
				end = settings.fridayFinish;
			}
			break;
		case 6:
			cell.textLabel.text = @"Saturday";
			if( !settings.isSaturdayOff ) {
				start = settings.saturdayStart;
				end = settings.saturdayFinish;
			}
			break;
	}
	
	if( start && end ) {
		NSString *detail = [[NSString alloc] initWithFormat:@"%@ - %@", start, end];
		cell.detailTextLabel.text = detail;
		[detail release];
	} else {
		cell.detailTextLabel.text = @"Off";
	}

	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	SetDailyHoursViewController *setHours = [[SetDailyHoursViewController alloc] initWithNibName:@"SetDailyHoursView" bundle:nil];
	setHours.settings = settings;
	switch (indexPath.row) {
		case 0:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekSunday;
			setHours.dayIsOff = settings.isSundayOff;
			break;
		case 1:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekMonday;
			setHours.dayIsOff = settings.isMondayOff;
			break;
		case 2:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekTuesday;
			setHours.dayIsOff = settings.isTuesdayOff;
			break;
		case 3:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekWednesday;
			setHours.dayIsOff = settings.isWednesdayOff;
			break;
		case 4:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekThursday;
			setHours.dayIsOff = settings.isThursdayOff;
			break;
		case 5:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekFriday;
			setHours.dayIsOff = settings.isFridayOff;
			break;
		case 6:
			setHours.dayOfTheWeek = DailyHoursDayOfTheWeekSaturday;
			setHours.dayIsOff = settings.isSaturdayOff;
			break;
	}
	[self.navigationController pushViewController:setHours animated:YES];
	[setHours release];
}


@end
