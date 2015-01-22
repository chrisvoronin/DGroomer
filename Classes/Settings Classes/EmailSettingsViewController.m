//
//  EmailSettingsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 2/25/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "EmailMessageViewController.h"
#import "PSADataManager.h"
#import "EmailSettingsViewController.h"


@implementation EmailSettingsViewController

@synthesize tblEmail;

- (void)viewDidLoad {
	self.title = @"ALERTS";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblEmail setBackgroundColor:bgColor];
	[bgColor release];*/
	//
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	self.tblEmail = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	1 Section for Settings, 1 for other editable datas
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	We have 6 rows (4 active... no emails yet)
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Anniversaries";
			break;
		case 1:
			cell.textLabel.text = @"Appointment Reminders";
			break;
		case 2:
			cell.textLabel.text = @"Birthdays";
			break;
	}
	
	return cell;
}

/*
 *	Loads and pushes the editing views onto the navigation stack
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Go
	switch (indexPath.row) {
		case 0: {
			EmailMessageViewController *vc = [[EmailMessageViewController alloc] initWithNibName:@"EmailMessageView" bundle:nil];
			vc.title = @"ANNIVERSARY";
			Email *mail = [[PSADataManager sharedInstance] getAnniversaryEmail];
			vc.email = mail;
			[mail release];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
		}
		case 1: {
			EmailMessageViewController *vc = [[EmailMessageViewController alloc] initWithNibName:@"EmailMessageView" bundle:nil];
			vc.title = @"APPT.REMINDER";
			Email *mail = [[PSADataManager sharedInstance] getAppointmentReminderEmail];
			vc.email = mail;
			[mail release];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
		}
		case 2: {
			EmailMessageViewController *vc = [[EmailMessageViewController alloc] initWithNibName:@"EmailMessageView" bundle:nil];
			vc.title = @"BIRTHDAY";
			Email *mail = [[PSADataManager sharedInstance] getBirthdayEmail];
			vc.email = mail;
			[mail release];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
		}
	}
}



@end
