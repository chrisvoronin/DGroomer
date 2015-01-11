//
//  ServiceTimeController.m
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "PSADataManager.h"
#import "Service.h"
#import "DurationViewController.h"


@implementation DurationViewController

@synthesize appointment, picker, tblTimes, service, lbHours, lbMinutes, tableIndexEditing;

- (void) viewDidLoad {
	self.title = @"Durations";
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	tblTimes.backgroundColor = [UIColor clearColor];
	//
	minuteArray = [[NSArray alloc] initWithObjects: @"00", @"15", @"30", @"45", nil];
	hourArray = [[NSArray alloc] initWithObjects: @" 0", @" 1", @" 2", @" 3", @" 4", @" 5", @" 6", @" 7", @" 8", @" 9", @"10", @"11", nil];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( service ) {
		startInSeconds = service.duration;
	} else if( appointment ) {
		startInSeconds = appointment.duration;
	}
	[self selectRowsInPicker];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        lbHours.frame = CGRectMake(CGRectGetMinX(lbHours.frame) - 45.f,
                                   CGRectGetMinY(lbHours.frame),
                                   CGRectGetWidth(lbHours.frame),
                                   CGRectGetHeight(lbHours.frame));
        
        lbMinutes.frame = CGRectMake(CGRectGetMinX(lbMinutes.frame) - 40.f,
                                     CGRectGetMinY(lbMinutes.frame),
                                     CGRectGetWidth(lbMinutes.frame),
                                     CGRectGetHeight(lbMinutes.frame));
    }
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.lbMinutes = nil;
	self.lbHours = nil;
	self.tblTimes = nil;
	self.picker = nil;
	[appointment release];
	[service release];
	[minuteArray release];
	[hourArray release];
	//
    [super dealloc];
}


- (void) done {
	// Save to Service and go away
	if( service ) {
		service.duration = startInSeconds;
	} else if( appointment ) {
		appointment.duration = startInSeconds;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) selectRowsInPicker {
	NSInteger hourValue;
	switch ( tableIndexEditing ) {
		case 0:
			hourValue = startInSeconds/3600;
			[picker selectRow:(startInSeconds/3600) inComponent:0 animated:YES];
			[picker selectRow:(((startInSeconds % 3600) / 60)/15) inComponent:1 animated:YES];
			break;
	}
	if( hourValue == 1 ) {
		lbHours.text = @"hour";
	} else {
		lbHours.text = @"hours";
	}
}

#pragma mark -
#pragma mark UIPickerView DataSource and Delegate
#pragma mark -
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {	
	switch (component) {
		case 0:		return hourArray.count;
		case 1:		return minuteArray.count;
	}
	return 0;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	switch (component) {
		case 0:		return [hourArray objectAtIndex:row];
		case 1:		return [minuteArray objectAtIndex:row];
	}
	return @"";
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSInteger hourValue = 0;
	NSInteger minuteValue = 0;
	switch (component) {
		case 0: {
			// Hours
			NSString *hVal = [hourArray objectAtIndex:row];
			hourValue = [hVal intValue];
			NSString *mVal = [minuteArray objectAtIndex:[pickerView selectedRowInComponent:1]];
			minuteValue = [mVal intValue];
			break;
		}
		case 1: {
			// Minutes
			NSString *mVal = [minuteArray objectAtIndex:row];
			minuteValue = [mVal intValue];
			NSString *hVal = [hourArray objectAtIndex:[pickerView selectedRowInComponent:0]];
			hourValue = [hVal intValue];
			break;
		}
	}
	
	NSInteger totalSeconds = ( (hourValue*60) + minuteValue ) * 60;
	
	switch ( tableIndexEditing ) {
		case 0:
			startInSeconds = totalSeconds;
			break;
	}
	
	if( hourValue == 1 ) {
		lbHours.text = @"hour";
	} else {
		lbHours.text = @"hours";
	}
	
	[tblTimes reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblTimes dequeueReusableCellWithIdentifier:@"TimeCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TimeCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
    }

	switch ( indexPath.row ) {
		case 0: {
			cell.textLabel.text = @"Duration";
			cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringOfHoursAndMinutesForSeconds:startInSeconds];
			break;
		}
	}
	
	return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	tableIndexEditing = indexPath.row;
	// Set Picker Values
	[self selectRowsInPicker];
	// Reload to get proper background view for the cells
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
