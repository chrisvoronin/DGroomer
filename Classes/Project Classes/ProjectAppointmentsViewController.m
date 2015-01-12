//
//  ProjectAppointmentsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/24/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentViewController.h"
#import "Project.h"
#import "ProjectAppointmentsViewController.h"

@implementation ProjectAppointmentsViewController

@synthesize project, tblAppointments;

- (void) viewDidLoad {
	//
	self.title = @"Appointments";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblAppointments setBackgroundColor:bgColor];
	[bgColor release];
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[tblAppointments reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.tblAppointments = nil;
	[project release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (void) add {
	// Show the product table in modal
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
	cont.isEditing = YES;
	Appointment *appt = [[Appointment alloc] init];
	appt.type = iBizAppointmentTypeProject;
	appt.object = project;
	cont.appointment = appt;
	[appt release];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	project.appointments = (NSMutableArray*)theArray;
	[tblAppointments reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[super.view setUserInteractionEnabled:YES];
}

- (void) reload {
	[super.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	// Implement DataManager delegate when it returns the array
	[[PSADataManager sharedInstance] getAppointmentsForProject:project];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( project.appointments.count == 0 ) {
		return 1;
	}
	return project.appointments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *identifier = @"ProjectAppointmentCell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		// Default cell type
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProjectAppointmentCell"] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	}
	
	if( project.appointments.count == 0 ) {
		cell.textLabel.text = @"No Appointments";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		Appointment *tmp = [project.appointments objectAtIndex:indexPath.row];
		if( tmp ) {
			NSString *start = [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.dateTime];
			NSDate *endDate = [[NSDate alloc] initWithTimeInterval:tmp.duration sinceDate:tmp.dateTime];
			NSString *end = [[PSADataManager sharedInstance] getStringForTime:endDate withFormat:NSDateFormatterShortStyle];
			NSString *text = [[NSString alloc] initWithFormat:@"%@ - %@", start, end];
			cell.textLabel.text = text;
			[endDate release];
			[text release];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	Appointment *appt = [project.appointments objectAtIndex:indexPath.row]; 
	if( appt ) {
		AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
		cont.appointment = appt;
		appt.object = project;
		cont.isEditing = NO;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	}
}


@end
