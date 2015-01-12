//
//  ViewOptionsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/7/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "Settings.h"
#import "ViewOptionsViewController.h"


@implementation ViewOptionsViewController

@synthesize tblOptions;

- (void)viewDidLoad {
	// Nav Bar Title
	self.title = @"View Options";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblOptions setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( settings )	[settings release];
	settings = [[PSADataManager sharedInstance] getSettings];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tblOptions = nil;
	[settings release];
    [super dealloc];
}


/*
 *	save
 *	Updates the color line in the DB. Called when a UISwitch fires UIControlEventValueChanged
 */
- (void) save:(id)sender {
	// tag stores the MasterColorLine index
	if( [sender isKindOfClass:[UISwitch class]] ) {
		settings.is15MinuteIntervals = ((UISwitch*)sender).on;
	} else if( [sender isKindOfClass:[UISegmentedControl class]] ) {
		UISegmentedControl *seg = (UISegmentedControl*)sender;
		if( seg.tag == 99 ) {
			[[PSADataManager sharedInstance] setClientNameSortSetting:seg.selectedSegmentIndex];
		} else {
			[[PSADataManager sharedInstance] setClientNameViewSetting:seg.selectedSegmentIndex];
		}
	}
	[[PSADataManager sharedInstance] updateSettings:settings];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 ) {
		return 1;
	} else {
		return 2;
	}
	return 0;
}

/*
 *
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( section == 0 ){
		return @"Calendar Views";
	} else {
		return @"Client Sort and View";
	}
	return nil;
}

/*
 *
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if( section == 0 ) {
		return @"\nThis will make the \"Day\" calendar view enlarge to better show shorter appointments";
	}
	return nil;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
	if( indexPath.section == 0 ) {
		cell = [aTableView dequeueReusableCellWithIdentifier:@"LineCell"];
	} else {
		cell = [aTableView dequeueReusableCellWithIdentifier:@"ClientSortCell"];
	}
    //
    if( cell == nil ) {
		if( indexPath.section == 0 ) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LineCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UISwitch *swActive = [[UISwitch alloc] init];
			[swActive addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = swActive;
			[swActive release];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClientSortCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UISegmentedControl *segSort = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Last, First", @"First Last", nil]];
			segSort.segmentedControlStyle = UISegmentedControlStyleBar;
			[segSort addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = segSort;
			[segSort release];
		}
        
    }
	
	if( indexPath.section == 0 ) {
		cell.textLabel.text = @"15 Min. Intervals";
		((UISwitch*)cell.accessoryView).on = settings.is15MinuteIntervals;
	} else {
		if( indexPath.row == 0 ) {
			cell.textLabel.text = @"Client Sort";
			UISegmentedControl *seg = (UISegmentedControl*)cell.accessoryView;
			seg.tag = 99;
			seg.selectedSegmentIndex = [PSADataManager sharedInstance].clientNameSortOption;
		} else {
			cell.textLabel.text = @"Client View";
			UISegmentedControl *seg = (UISegmentedControl*)cell.accessoryView;
			seg.tag = 98;
			seg.selectedSegmentIndex = [PSADataManager sharedInstance].clientNameViewOption;
		}
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
}

@end
