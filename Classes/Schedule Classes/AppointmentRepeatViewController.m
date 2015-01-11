//
//  AppointmentRepeatViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/19/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentRepeatViewController.h"


@implementation AppointmentRepeatViewController

@synthesize appointment, tblRepeat;


- (void) viewDidLoad {
	self.title = @"Standing Appt.";
	//
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGray.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblRepeat setBackgroundColor:bgColor];
	[bgColor release];
	//
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tblRepeat = nil;
	[appointment release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 8;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"NotesID";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	if( indexPath.row == appointment.standingRepeat ) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	switch ( indexPath.row ) {
		case 0:
			cell.textLabel.text = @"Never";
			break;
		case 1:
			cell.textLabel.text = @"Daily";
			break;
		case 2:
			cell.textLabel.text = @"Weekly";
			break;
		case 3:
			cell.textLabel.text = @"Monthly";
			break;
		case 4:
			cell.textLabel.text = @"Yearly";
			break;
		case 5:
			cell.textLabel.text = @"Every 2 Weeks";
			break;
		case 6:
			cell.textLabel.text = @"Every 3 Weeks";
			break;
		case 7:
			cell.textLabel.text = @"Every 4 Weeks";
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Deselect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Save and pop
	if( appointment ) {
		appointment.standingRepeat = indexPath.row;
	}
	[self.navigationController popViewControllerAnimated:YES];
}


@end
