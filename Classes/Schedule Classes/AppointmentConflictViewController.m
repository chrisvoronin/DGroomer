//
//  AppointmentConflictViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "ProjectAppointmentsViewController.h"
#import "PSADataManager.h"
#import "AppointmentConflictViewController.h"


@implementation AppointmentConflictViewController

@synthesize conflicts, delegate, tblConflicts;

- (void) viewDidLoad {
	self.title = @"Conflicts";
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGray.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblConflicts setBackgroundColor:bgColor];
	[bgColor release];*/
	// Book Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Book" style:UIBarButtonItemStyleBordered target:self action:@selector(book)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	self.navigationItem.hidesBackButton = YES;
	//
	conflictSelections = [[NSMutableArray alloc] init];
	for( int i=0; i < conflicts.count; i++ ) {
		[conflictSelections addObject:[NSNumber numberWithInt:0]];
	}
	//
	headerView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 75)];
	headerView.backgroundColor = tblConflicts.backgroundColor;
	headerView.opaque = YES;
	UILabel *headerViewLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 0, 280, 75 )];
	headerViewLabel.backgroundColor = [UIColor clearColor];
	headerViewLabel.font = [UIFont boldSystemFontOfSize:14];
	headerViewLabel.numberOfLines = 0;
	headerViewLabel.shadowColor = [UIColor grayColor];
	headerViewLabel.shadowOffset = CGSizeMake( 0, 1 );
	headerViewLabel.textAlignment = UITextAlignmentCenter;
	headerViewLabel.textColor = [UIColor whiteColor];
	headerViewLabel.text = @"Appointments without conflict have been booked! Choose the conflicting dates you wish to book as well...";
	[headerView addSubview:headerViewLabel];
	[headerViewLabel release];
	//
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.conflicts = nil;
	[conflictSelections release];
	[headerView release];
	self.tblConflicts = nil;
    [super dealloc];
}

- (void) book {
	for( int i=0; i < conflictSelections.count; i++ ) {
		NSNumber *selection = [conflictSelections objectAtIndex:i];
		if( [selection boolValue] == YES ) {
			Appointment *tmp = [conflicts objectAtIndex:i];
			if( tmp.appointmentID > -1 ) {
				[[PSADataManager sharedInstance] updateAppointment:tmp];
			} else {
				[[PSADataManager sharedInstance] insertAppointment:tmp];
			}
		}
	}
	// If no appointments were inserted, this should get rid of the standing appointment
	[[PSADataManager sharedInstance] deleteOrphanedStandingAppointments];
	//
	[self.delegate delegateShouldPop];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )	return 2;
	return conflicts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if( section == 0 ) {
		return 75;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if( section == 0 ) {
		return headerView;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"ConflictCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	if( indexPath.section == 0 ) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		if( indexPath.row == 0 ) {
			cell.textLabel.text = @"Select All";
		} else if( indexPath.row == 1 ) {
			cell.textLabel.text = @"Select None";
		}
	} else if( indexPath.section == 1 ) {
		NSNumber *selected = [conflictSelections objectAtIndex:indexPath.row];
		Appointment *tmp = [conflicts objectAtIndex:indexPath.row];
		if( [selected boolValue] ) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		cell.textLabel.text = [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.dateTime];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Deselect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if( indexPath.section == 0 ) {
		for( int i=0; i < conflictSelections.count; i++ ) {
			if( indexPath.row == 0 ) {
				[conflictSelections replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES] ];
			} else {
				[conflictSelections replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO] ];
			}
		}
		[tblConflicts reloadData];
	} else if( indexPath.section == 1 ) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];	
		if( cell.accessoryType == UITableViewCellAccessoryCheckmark ) {
			cell.accessoryType = UITableViewCellAccessoryNone;
			[conflictSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO] ];
		} else {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[conflictSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
		}
	}
	
}

@end
