//
//  ClientServicesViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentViewController.h"
#import "PSADataManager.h"
#import "Project.h"
#import "Service.h"
#import "ClientServicesViewController.h"


@implementation ClientServicesViewController

@synthesize tblServices;

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle { 
    self = [super initWithNibName:nibName bundle:nibBundle]; 
    if (self) { 
        self.title = @"Schedule";
		self.tabBarItem.image = [UIImage imageNamed:@"iconServices.png"];
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"Back";
        self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
        [barButton release];
    } 
    return self; 
} 

- (void) viewDidLoad {
	// + Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAppointmentButtonTouchUp)];
	self.navigationItem.rightBarButtonItem = btnAdd;
    [btnAdd release];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    [barButton release];
	//
	//[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	//
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	[[PSADataManager sharedInstance] getAppointmentsForClient:client];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBackToClients)];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.leftBarButtonItem = barButton;
    [barButton release];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	self.tblServices = nil;
	[appointments release];
	//
	[super viewDidUnload];
}


- (void) dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (IBAction) addAppointmentButtonTouchUp {
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil client:client];
	cont.isEditing = YES;
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
	if( appointments )	[appointments release];
	appointments = [theArray retain];
	[tblServices reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
}

- (IBAction) goBackToClients {
	[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] swapClientTabWithNavigation];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [appointments count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ServiceApptCell"];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ServiceApptCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		// Set up a view to show the Service's color on the edge of the cell
		UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 44)];
		colorView.opaque = YES;
		colorView.tag = 88;
		[cell.contentView addSubview:colorView];
		[colorView release];
    }
	
	Appointment *tmp = [appointments objectAtIndex:indexPath.row];
	if( tmp ) {
		// Colorize
		if( tmp.type == iBizAppointmentTypeSingleService ) {
			[cell.contentView viewWithTag:88].backgroundColor = ((Service*)tmp.object).color;
			cell.textLabel.text = ((Service*)tmp.object).serviceName;
		} else if( tmp.type == iBizAppointmentTypeProject ) {
			[cell.contentView viewWithTag:88].backgroundColor = [UIColor colorWithRed:.596 green:.678 blue:.843 alpha:.7];
			//
			cell.textLabel.text = ((Project*)tmp.object).name;
		} else {
			[cell.contentView viewWithTag:88].backgroundColor = [UIColor colorWithRed:.165 green:.733 blue:.945 alpha:.7];
			//
			NSString *text = [[NSString alloc] initWithFormat:@"%@", (tmp.notes) ? tmp.notes : @"Block"];
			cell.textLabel.text = text;
			[text release];
		}
		
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		if( [[formatter dateFormat] hasSuffix:@"a"] ) {
			// Shows AM/PM (localized)
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			[formatter setDateFormat:@"EEE MMMM d, yyyy h:mm a"];
		} else {
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			[formatter setDateFormat:@"EEE MMMM d, yyyy H:mm"];
		}
		cell.detailTextLabel.text = [formatter stringFromDate:tmp.dateTime];
		[formatter release];
	}
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
	cont.isEditing = NO;
	cont.appointment = [appointments objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:cont animated:YES];
	[cont release];
}

@end
