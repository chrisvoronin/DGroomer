//
//  ScheduleViewController.h
//  myBusiness
//
//  Created by David J. Maier on 6/26/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Appointment.h"
#import "AppointmentDatePickerViewController.h"
#import "AppointmentNotesViewController.h"
#import "AppointmentRepeatViewController.h"
#import "AppointmentRepeatUntilViewController.h"
#import "Client.h"
#import "Company.h"
#import "DurationViewController.h"
#import "Email.h"
#import "Project.h"
#import "ProjectAppointmentsViewController.h"
#import "ProjectViewController.h"
#import "PSAAppDelegate.h"
#import "Service.h"
#import "ServiceInformationController.h"
#import "Transaction.h"
#import	"TransactionItem.h"
#import "TransactionViewController.h"
#import "AppointmentViewController.h"

@interface AppointmentViewController (Private)
- (void) bookAppointment;
- (void) handleConflicts:(NSArray*)collisions;
- (void) save;
@end

@implementation AppointmentViewController

@synthesize appointment, buttonsCell, isEditing, tblAppointment, delegate;

- (id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)nibBundle client:(Client*)theClient {
	self = [super initWithNibName:nibName bundle:nibBundle]; 
    if (self) { 
		appointment = [[Appointment alloc] init];
        appointment.client = theClient;
    } 
    return self; 
}

- (void) viewDidLoad {
	self.title = @"APPOINTMENT";
	//
#ifdef PROJECT_NOT_INCLUDED
	types = [[NSArray alloc] initWithObjects:@"Block", @"Single Service", nil];
#else
	types = [[NSArray alloc] initWithObjects:@"Block", @"Project", @"Single Service", nil];
#endif
	// Clear the table background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGray.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblAppointment setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:12/255.0 green:138/255.0 blue:235/255.0 alpha:1.0]};
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
    //self.navigationController.view.tintColor = [UIColor blueColor];
    /*if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor blueColor];
        //self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.tintColor = [UIColor blueColor];
        self.navigationController.view.tintColor = [UIColor blueColor];
        //self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = NO;
    }*/
    
	if( isEditing ) {
		// Save Button
		UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		self.navigationItem.rightBarButtonItem = btnSave;
		[btnSave release];
	} else {
		// Edit Button
		UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
		self.navigationItem.rightBarButtonItem = btnEdit;
		[btnEdit release];
	}
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	// If there is not one set, create a new Appointment
	if( !appointment ) {
		appointment = [[Appointment alloc] init];
		appointment.type = iBizAppointmentTypeSingleService;
	}
	[tblAppointment reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) dealloc {
	self.tblAppointment = nil;
	[appointment release];
	[oldAppointment release];
	[types release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -
/*
 *
 *
 */
- (void) bookAppointment {
	// Check some values then warn and save, or just save
	if( appointment.standingAppointmentID > -1 && appointment.standingRepeat != iBizAppointmentRepeatNever && appointment.standingRepeatUntilDate != nil ) {
		// If it's already standing, and the repeat value has not been changed to never
		UIActionSheet *query = [[UIActionSheet alloc] initWithTitle:@"This is a standing appointment." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save for this appt. only", @"Save for future appts.", nil];
		[query showInView:self.view];
		[query release];
	} else {
		if( appointment.standingRepeat != iBizAppointmentRepeatNever && appointment.standingRepeatUntilDate != nil ) {
			[self.view setUserInteractionEnabled:NO];
			[[PSADataManager sharedInstance] showActivityIndicator];
			[[PSADataManager sharedInstance] setDelegate:self];
			ignoreConflicts = NO;
			[[PSADataManager sharedInstance] saveAppointmentThreaded:appointment updateStanding:YES ignoreConflicts:NO];
			//NSArray *conflicts = [[PSADataManager sharedInstance] saveAppointment:appointment updateStanding:YES ignoreConflicts:NO];
			//[self handleConflicts:conflicts];
		} else {
			[self.view setUserInteractionEnabled:NO];
			[[PSADataManager sharedInstance] showActivityIndicator];
			[[PSADataManager sharedInstance] setDelegate:self];
			ignoreConflicts = NO;
			[[PSADataManager sharedInstance] saveAppointmentThreaded:appointment updateStanding:NO ignoreConflicts:NO];
			//NSArray *conflicts = [[PSADataManager sharedInstance] saveAppointment:appointment updateStanding:NO ignoreConflicts:NO];
			//[self handleConflicts:conflicts];
		}
	}
}

- (IBAction) btnCheckoutPressed {
	Transaction *trans = [[PSADataManager sharedInstance] getTransactionForAppointment:appointment];
	if( !trans ) {
		trans = [[Transaction alloc] init];
		trans.appointmentID = appointment.appointmentID;
		trans.client = appointment.client;
		TransactionItem *item = [[TransactionItem alloc] init];
		item.item = appointment.object;
		item.itemType = PSATransactionItemService;
		item.itemPrice = ((Service*)appointment.object).servicePrice;
		item.taxed = ((Service*)appointment.object).taxable;
		[trans.services addObject:item];
		[item release];
	}
	// Show
	TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
	//
	cont.transaction = trans;
	[trans release];
	// Edit if not closed
	if( !trans.dateClosed ) {
		UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
		cont.navigationItem.leftBarButtonItem = cancel;
		[cancel release];
		cont.isEditing = YES;
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
		//nav.navigationBar.tintColor = [UIColor blackColor];
		[self presentViewController:nav animated:YES completion:nil];
		[nav release];
	} else {
		[self.navigationController pushViewController:cont animated:YES];
	}
	[cont release];
}

/*
 *
 */
- (IBAction) btnDeletePressed {
	if( appointment.standingAppointmentID > -1 ) {
		UIActionSheet *query = [[UIActionSheet alloc] initWithTitle:@"This is a standing appointment." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete This Appt.", @"Delete All Future Appts.", nil];
		[query showInView:self.view];
		[query release];
	} else {
		// Single Appointment Delete
		UIActionSheet *query = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Appointment" otherButtonTitles:nil];
		[query showInView:self.view];
		[query release];
	}
	
}

- (IBAction) btnEmailPressed {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
        //
        [[picker navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:self.navigationController.view.tintColor forKey:NSForegroundColorAttributeName]];
		picker.mailComposeDelegate = self;
		
		Email *email = [[PSADataManager sharedInstance] getAppointmentReminderEmail];
		
		// If there's no client, and this is a project, temporarily set the appointment client to the project's client.
		if( !appointment.client && appointment.type == iBizAppointmentTypeProject ) {
			appointment.client = ((Project*)appointment.object).client;
		}
		
		NSString *clientEmail = [appointment.client getEmailAddressHome];
		if( clientEmail == nil ) {
			clientEmail = [appointment.client getEmailAddressWork];
			if( clientEmail == nil ) {
				clientEmail = [appointment.client getEmailAddressAny];
			}
		}
        
        if(clientEmail == nil)
        {
            NSString *message = [[NSString alloc] initWithString:@"This contact does not have an email."];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
            [message release];
            return;
        }
        
		NSArray *to = [NSArray arrayWithObjects:clientEmail, nil]; 
		[picker setToRecipients:to];
		[clientEmail release];
		
		if( email.bccCompany ) {
			// Company Info
			Company *company = [[PSADataManager sharedInstance] getCompany];
			// Set up the recipients
			if( company.companyEmail ) {
				NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
				[picker setBccRecipients:bccRecipients];
			}
			[company release];
		}
		
		NSString *message = email.message;
		message = [message stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:[appointment.client getClientNameFirstThenLast]];
		if( appointment.type == iBizAppointmentTypeSingleService ) {
			message = [message stringByReplacingOccurrencesOfString:@"<<SERVICE>>" withString:((Service*)appointment.object).serviceName];
		} else if( appointment.type == iBizAppointmentTypeProject ) {
			message = [message stringByReplacingOccurrencesOfString:@"<<SERVICE>>" withString:((Project*)appointment.object).name];
		} else {
			message = [message stringByReplacingOccurrencesOfString:@"<<SERVICE>>" withString:@"Block"];
		}
		message = [message stringByReplacingOccurrencesOfString:@"<<APPT_DATE>>" withString:[[PSADataManager sharedInstance] getStringForDate:appointment.dateTime withFormat:NSDateFormatterLongStyle]];
		message = [message stringByReplacingOccurrencesOfString:@"<<APPT_TIME>>" withString:[[PSADataManager sharedInstance] getStringForTime:appointment.dateTime withFormat:NSDateFormatterShortStyle]];
		
		[picker setSubject:email.subject];
		[picker setMessageBody:message isHTML:NO];
		
		[email release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil];
		[picker release];
		
		// Get rid of the appointment project client reference
		if( appointment.type == iBizAppointmentTypeProject ) {
			appointment.client = nil;
		}
		
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}

- (void) handleConflicts:(NSArray*)collisions {
	if( collisions.count == 1 ) {
		self.appointment = [collisions objectAtIndex:0];
		NSString *title = [[NSString alloc] initWithFormat:@"There is a conflict with a currently scheduled appointment.\n\nSchedule anyway for %@?", [[PSADataManager sharedInstance] getStringForAppointmentDate:appointment.dateTime]];
		UIActionSheet *query = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Schedule Conflict", nil];
		[query showInView:self.view];
		[query release];
		[title release];
	} else if( collisions.count > 1 ) {
		// Show a table that allows selection
		AppointmentConflictViewController *cont = [[AppointmentConflictViewController alloc] initWithNibName:@"AppointmentConflictView" bundle:nil];
		cont.delegate = self;
		cont.conflicts = collisions;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else {
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
			[self appointmentsChanged];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
		//[self.navigationController.parentViewController viewWillAppear:YES];
	}
}

/*
 *	Restores old appt. info from DB
 */
- (void) cancelEdit {
	[appointment release];
	appointment = [[Appointment alloc] initWithAppointment:oldAppointment];
	[oldAppointment release];
	oldAppointment = nil;
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self appointmentsChanged];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }}

/*
 *
 */
- (void) edit {
	// Copy this view into a navigationController, in edit mode, as a modalViewController
	// View Controller
	oldAppointment = [[Appointment alloc] initWithAppointment:appointment];
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
	cont.isEditing = YES;
	cont.appointment = appointment;
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

/*
 *	Checks and warns on incomplete or conflicting appointments.
 */
- (void) save {
	
	// Check for proper values
	if( appointment.duration <= 0 ) {
		NSString *message = [[NSString alloc] initWithString:@"Duration should be a value greater than zero!"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Appointment" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[message release];
	}
	else if( appointment.type == iBizAppointmentTypeSingleService && (!appointment.client || !appointment.object || !appointment.dateTime) ) {
		NSString *message = [[NSString alloc] initWithString:@"Client, Service, and Date need to be selected before saving!"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Appointment" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[message release];
	} 
	else if( appointment.type == iBizAppointmentTypeProject && (!appointment.object || !appointment.dateTime) ) {
		NSString *message = [[NSString alloc] initWithString:@"Project and Date need to be selected before saving!"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Appointment" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[message release];
	}
	else if( appointment.type == iBizAppointmentTypeBlock && !appointment.dateTime ) {
		NSString *message = [[NSString alloc] initWithString:@"Date needs to be selected before saving!"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Appointment" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[message release];
	}
	else {
		// Check standing values
		if( appointment.standingRepeat != iBizAppointmentRepeatNever && appointment.standingRepeatUntilDate == nil ) {
			// Incomplete... alert
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Standing Appointment" message:@"If you specify a standing interval for this appointment, you must also select a date to repeat until!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		} else {
            
            NSString *clientEmail = [appointment.client getEmailAddressHome];
            if( clientEmail == nil ) {
                clientEmail = [appointment.client getEmailAddressWork];
                if( clientEmail == nil ) {
                    clientEmail = [appointment.client getEmailAddressAny];
                }
            }
            NSString *clientname = [appointment.client getClientName];
            if(clientEmail == nil && ![clientname isEqualToString:@"Guest"])
            {
                NSString *message = [[NSString alloc] initWithString:@"This contact does not have an email."];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
                [message release];
            }
			// Erase the client from these types
			if( appointment.type == iBizAppointmentTypeProject || appointment.type == iBizAppointmentTypeBlock ) {
				appointment.client = nil;
			}
			[self bookAppointment];
		}
	}
	
}

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -
/*
 *
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Conflicting Appt. warning
	if( [actionSheet.title hasPrefix:@"There is a conflict"] ) {
		if( buttonIndex == 0 ) {
			[self.view setUserInteractionEnabled:NO];
			[[PSADataManager sharedInstance] showActivityIndicator];
			[[PSADataManager sharedInstance] setDelegate:self];
			ignoreConflicts = YES;
			[[PSADataManager sharedInstance] saveAppointmentThreaded:appointment updateStanding:NO ignoreConflicts:YES];
			/*
			//[[PSADataManager sharedInstance] saveAppointment:appointment updateStanding:NO ignoreConflicts:YES];
			if( self.navigationController.viewControllers.count == 1 ) {
				[self dismissViewControllerAnimated:YES completion:nil];
			} else {
				[self.navigationController popViewControllerAnimated:YES];
			}
			[self.navigationController.parentViewController viewWillAppear:YES];
			 */
		}
	}
	// Standing Appt. alert
	else if( [actionSheet.title hasPrefix:@"This is a standing"] ) {
		if( buttonIndex == 0 ) {
			// This one only
			if( [[actionSheet buttonTitleAtIndex:0] hasPrefix:@"Delete"] ) {
				[[PSADataManager sharedInstance] deleteAppointment:appointment deleteStanding:NO];
				[self appointmentsChanged];
				[self.navigationController popViewControllerAnimated:YES];
				[self.navigationController.parentViewController viewWillAppear:YES];
			} else {
				[self.view setUserInteractionEnabled:NO];
				[[PSADataManager sharedInstance] showActivityIndicator];
				[[PSADataManager sharedInstance] setDelegate:self];
				ignoreConflicts = NO;
				[[PSADataManager sharedInstance] saveAppointmentThreaded:appointment updateStanding:NO ignoreConflicts:NO];
				//NSArray *conflicts = [[PSADataManager sharedInstance] saveAppointment:appointment updateStanding:NO ignoreConflicts:NO];
				//[self handleConflicts:conflicts];
			}
		} else if( buttonIndex == 1 ) {
			// All appts.
			if( [[actionSheet buttonTitleAtIndex:0] hasPrefix:@"Delete"] ) {
				[[PSADataManager sharedInstance] deleteAppointment:appointment deleteStanding:YES];
				[self appointmentsChanged];
				[self.navigationController popViewControllerAnimated:YES];
				[self.navigationController.parentViewController viewWillAppear:YES];
			} else {
				[self.view setUserInteractionEnabled:NO];
				[[PSADataManager sharedInstance] showActivityIndicator];
				[[PSADataManager sharedInstance] setDelegate:self];
				ignoreConflicts = NO;
				[[PSADataManager sharedInstance] saveAppointmentThreaded:appointment updateStanding:YES ignoreConflicts:NO];
				//NSArray *conflicts = [[PSADataManager sharedInstance] saveAppointment:appointment updateStanding:YES ignoreConflicts:NO];
				//[self handleConflicts:conflicts];
			}
		}
	}
	// Delete Appointment message
	else {
		if ( buttonIndex == 0 ) {
			// Delete Appointment
			[[PSADataManager sharedInstance] deleteAppointment:appointment deleteStanding:NO];
			[self appointmentsChanged];
			[self.navigationController popViewControllerAnimated:YES];
			[self.navigationController.parentViewController viewWillAppear:YES];
		}
	}
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -
/*
 *
 */
- (void) delegateShouldPop {
	if( self.navigationController.viewControllers.count == 2 ) {
		[self dismissViewControllerAnimated:YES completion:nil];
		[self appointmentsChanged];
	} else {
		// This is kind of hacky, but I want to go back 2 view controllers
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3] animated:YES];
	}
}

- (void) appointmentsChanged {
	// Tell ProjectAppointmentsViewController (if exists) to reload it's appointments
	if( [[self.parentViewController parentViewController] isKindOfClass:[UINavigationController class]] ) {
		if( [[(UINavigationController*)[self.parentViewController parentViewController] topViewController] isKindOfClass:[ProjectAppointmentsViewController class]] ) {
			// ProjectAppointmentsVC is on top
			[(ProjectAppointmentsViewController*)[(UINavigationController*)[self.parentViewController parentViewController] topViewController] reload];
		} else if( [[(UINavigationController*)[self.parentViewController parentViewController] topViewController] isKindOfClass:[self class]] ) {
			// If editing, we'll have this vc on top
			if( [[[(UINavigationController*)[self.parentViewController parentViewController] viewControllers] objectAtIndex:[[(UINavigationController*)[self.parentViewController parentViewController] viewControllers] count]-2] isKindOfClass:[ProjectAppointmentsViewController class]] ) {
				[(ProjectAppointmentsViewController*)[[(UINavigationController*)[self.parentViewController parentViewController] viewControllers] objectAtIndex:[[(UINavigationController*)[self.parentViewController parentViewController] viewControllers] count]-2] reload];
			}
		}
	} else {
		for( UIViewController *tmp in self.navigationController.viewControllers ) {
			if( [tmp isKindOfClass:[ProjectAppointmentsViewController class]] ) {
				[(ProjectAppointmentsViewController*)tmp reload];
			}
		}
	}
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	[[PSADataManager sharedInstance] setDelegate:nil];
	
	if( !ignoreConflicts ) {
		[self handleConflicts:theArray];
	} else {
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
			[self appointmentsChanged];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
		//[self.navigationController.parentViewController viewWillAppear:YES];
        [self.delegate appointmentCreated:appointment];
	}
	
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
    
}

/*
 *	Save the returned Client in our Appointment
 */
- (void) selectionMadeWithClient:(Client*)theClient {
	appointment.client = theClient;
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 *	Save the returned Project in our Appointment
 */
- (void) selectionMadeWithProject:(Project*)theProject {
	appointment.object = theProject;
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 *	Save the returned Service in our Appointment
 */
- (void) selectionMadeWithService:(Service*)theService {
	appointment.object = theService;
	appointment.duration = theService.duration;
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 *	Sent back by TablePicker with the type name
 */
- (void) selectionMadeWithString:(NSString*)theValue {
	for( NSInteger i=0; i<types.count; i++ ) {
		if( [(NSString*)[types objectAtIndex:i] isEqualToString:theValue] ) {
#ifdef PROJECT_NOT_INCLUDED
			// For apps without projects, single service is in index 1 of the picker table
			if( i == 0 ) {
				appointment.type = iBizAppointmentTypeBlock;
			} else if ( i == 1 ) {
				appointment.type = iBizAppointmentTypeSingleService;
			}
#else
			appointment.type = i;
#endif
		}
	}
	appointment.object = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 2 ) {
		if( appointment.type == iBizAppointmentTypeSingleService ) {
            if (!isEditing) {
                return 92;
            }
            else{
                return 44;
            }
		} else if( appointment.type == iBizAppointmentTypeProject ) {
			return 92;
		} else {
			return 44;
		}
	}	
	return 44;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return 10.0;
    }
    
    return 30.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:	{
			if( appointment.type == iBizAppointmentTypeBlock )		return 1;
			if( appointment.type == iBizAppointmentTypeProject )	return 2;
			return 3;
		}
		case 1:		if( appointment.standingRepeat == iBizAppointmentRepeatNever )	return 4;
            return 5;
		case 2:	{
			// Hide the buttons if this appointment is new or in editing
            //return 1;
			if(appointment.appointmentID > -1 )	return 1;
			else								return 0;
		}
	}
	return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
	if( indexPath.section == 2 ) {
		if( appointment.type == iBizAppointmentTypeSingleService ) {
            if(!isEditing)
                identifier = @"AppointmentServiceButtonsCell";
            else
                identifier = @"AppointmentDeleteButtonCell";
		} else if( appointment.type == iBizAppointmentTypeProject ) {
			identifier = @"AppointmentProjectButtonsCell";
		} else {
			identifier = @"AppointmentDeleteButtonCell";
		}
	} else {
		identifier = @"AppointmentGenericCell";
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		if( indexPath.section == 2 ) {
			if( appointment.type == iBizAppointmentTypeSingleService ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = buttonsCell;
				self.buttonsCell = nil;
			} else if( appointment.type == iBizAppointmentTypeProject ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = buttonsCell;
				self.buttonsCell = nil;
			} else {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = buttonsCell;
				self.buttonsCell = nil;
			}
             //cell.backgroundColor = cell.contentView.backgroundColor;
             //cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0);
            //cell.bounds.size = CGSizeMake(0,0);
            //cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
		}
    }
	
	if( isEditing && indexPath.section != 2) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
	}
	
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Type";
				if( appointment.type == iBizAppointmentTypeSingleService ) {
					cell.detailTextLabel.text = @"Single Service";
				} else if( appointment.type == iBizAppointmentTypeProject ) {
					cell.detailTextLabel.text = @"Project";
				} else if( appointment.type == iBizAppointmentTypeBlock ) {
					cell.detailTextLabel.text = @"Block";
				} else {
					cell.detailTextLabel.text = @"Choose...";
				}
			} else if( indexPath.row == 1 ) {
				// Should only show for Projects and Services
				if( appointment.type == iBizAppointmentTypeSingleService ) {
					cell.textLabel.text = @"Service";
					if( appointment.object ) {
						cell.detailTextLabel.text = ((Service*)appointment.object).serviceName;
					} else {
						cell.detailTextLabel.text = @"None";
					}
                    if( isEditing ) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
				} else if( appointment.type == iBizAppointmentTypeProject ) {
					cell.textLabel.text = @"Project";
					if( appointment.object ) {
						cell.detailTextLabel.text = ((Project*)appointment.object).name;
					} else {
						cell.detailTextLabel.text = @"None";
					}
                    if( isEditing ) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
				} else if( appointment.type == iBizAppointmentTypeBlock ) {
					cell.textLabel.text = @"";
					if( appointment.object ) {
						cell.detailTextLabel.text = @"Block";
					} else {
						cell.detailTextLabel.text = @"None";
					}
				}
			} else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Client";
				if( appointment.client ) {
					cell.detailTextLabel.text = [appointment.client getClientName];
				} else {
					cell.detailTextLabel.text = @"None";
				}
                if( isEditing ) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
			}
			break;
		case 1:
            if( appointment.standingRepeat == iBizAppointmentRepeatNever ){
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Date";
				if( appointment.dateTime ) {
					cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForAppointmentDate:appointment.dateTime];
				} else {
					cell.detailTextLabel.text = @"None";
				}
			}
            else if(indexPath.row == 1){
                cell.textLabel.text = @"Duration";
                cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringOfHoursAndMinutesForSeconds:appointment.duration];
            }
            else if( indexPath.row == 2 ) {
                cell.textLabel.text = @"Standing Appt.";
                switch ( appointment.standingRepeat ) {
                    case 0:
                        cell.detailTextLabel.text = @"Never";
                        break;
                    case 1:
                        cell.detailTextLabel.text = @"Daily";
                        break;
                    case 2:
                        cell.detailTextLabel.text = @"Weekly";
                        break;
                    case 3:
                        cell.detailTextLabel.text = @"Monthly";
                        break;
                    case 4:
                        cell.detailTextLabel.text = @"Yearly";
                        break;
                    case 5:
                        cell.detailTextLabel.text = @"Every 2 Weeks";
                        break;
                    case 6:
                        cell.detailTextLabel.text = @"Every 3 Weeks";
                        break;
                    case 7:
                        cell.detailTextLabel.text = @"Every 4 Weeks";
                        break;
                }
            }
            else if(indexPath.row == 3){
                cell.textLabel.text = @"Notes";
                if( appointment.notes != nil ) {
                    cell.detailTextLabel.text = @"...";
                } else {
                    cell.detailTextLabel.text = @"None";
                }
                if( isEditing ) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }} else{
                if( indexPath.row == 0 ) {
                    cell.textLabel.text = @"Date";
                    if( appointment.dateTime ) {
                        cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForAppointmentDate:appointment.dateTime];
                    } else {
                        cell.detailTextLabel.text = @"None";
                    }
                }
                else if(indexPath.row == 1){
                    cell.textLabel.text = @"Duration";
                    cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringOfHoursAndMinutesForSeconds:appointment.duration];
                }
                else if( indexPath.row == 2 ) {
                    cell.textLabel.text = @"Standing Appt.";
                    switch ( appointment.standingRepeat ) {
                        case 0:
                            cell.detailTextLabel.text = @"Never";
                            break;
                        case 1:
                            cell.detailTextLabel.text = @"Daily";
                            break;
                        case 2:
                            cell.detailTextLabel.text = @"Weekly";
                            break;
                        case 3:
                            cell.detailTextLabel.text = @"Monthly";
                            break;
                        case 4:
                            cell.detailTextLabel.text = @"Yearly";
                            break;
                        case 5:
                            cell.detailTextLabel.text = @"Every 2 Weeks";
                            break;
                        case 6:
                            cell.detailTextLabel.text = @"Every 3 Weeks";
                            break;
                        case 7:
                            cell.detailTextLabel.text = @"Every 4 Weeks";
                            break;
                    }
                } else if( indexPath.row == 3 ) {
                    cell.textLabel.text = @"Repeat Until";
                    if( appointment.standingRepeatUntilDate ) {
                        cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:appointment.standingRepeatUntilDate withFormat:NSDateFormatterMediumStyle];
                    } else {
                        cell.detailTextLabel.text = @"Never";
                    }
                }
                else if(indexPath.row == 4){
                    cell.textLabel.text = @"Notes";
                    if( appointment.notes != nil ) {
                        cell.detailTextLabel.text = @"...";
                    } else {
                        cell.detailTextLabel.text = @"None";
                    }
                    if( isEditing ) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
            }
			break;
	}
	
	return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 2 ) {
		// Get rid of background and border
		[cell setBackgroundView:nil];
	}
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Deselect as per Apple guidelines
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Where to go
	if( isEditing ) {
		switch ( indexPath.section ) {
			case 0:
				if( indexPath.row == 0 ) {
					// Pick the type
					TablePickerViewController *picker = [[TablePickerViewController alloc] initWithNibName:@"TablePickerView" bundle:nil];
					picker.title = @"APPOINTMENT TYPE";
					picker.pickerDelegate = self;
#ifdef PROJECT_NOT_INCLUDED
					if( appointment.type == iBizAppointmentTypeSingleService ) {
						picker.selectedValue = [types objectAtIndex:1];
					} else {
						picker.selectedValue = [types objectAtIndex:0];
					}
#else
					picker.selectedValue = [types objectAtIndex:appointment.type];
#endif
					picker.pickerValues = types;
					[self.navigationController pushViewController:picker animated:YES];
					// Set the background
					UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGray.png"];
					UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
					[picker.tblItems setBackgroundColor:bgColor];
					[bgColor release];
					//
					[picker release];
					break;
				} else if( indexPath.row == 1 ) {
					if( appointment.type == iBizAppointmentTypeSingleService ) {
						// Service Table
						ServicesTableViewController *cont = [[ServicesTableViewController alloc] initWithNibName:@"ServicesTableView" bundle:nil];
						cont.serviceDelegate = self;
						[self.navigationController pushViewController:cont animated:YES];
						[cont release];
					} else if( appointment.type == iBizAppointmentTypeProject ) {
						// Project Table
						ProjectsTableViewController *cont = [[ProjectsTableViewController alloc] initWithNibName:@"ProjectsTableView" bundle:nil];
						cont.dontAllowNewProject = YES;
						cont.projectsDelegate = self;
						[self.navigationController pushViewController:cont animated:YES];
						[cont release];
					}				
				} else if( indexPath.row == 2 ) {
					// Client Table
					ClientTableViewController *cont = [[ClientTableViewController alloc] initWithNibName:@"ClientTableView" bundle:nil];
					cont.clientDelegate = self;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
				break;
			case 1: {
                if( appointment.standingRepeat == iBizAppointmentRepeatNever ){
				if( indexPath.row == 0 ) {
					// Date/Time picker
					AppointmentDatePickerViewController *cont = [[AppointmentDatePickerViewController alloc] initWithNibName:@"AppointmentDatePickerView" bundle:nil];
					cont.appointment = appointment;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
                } else if( indexPath.row == 1 ) {
                    // Duration picker
                    DurationViewController *cont = [[DurationViewController alloc] initWithNibName:@"DurationView" bundle:nil];
                    cont.view.backgroundColor = self.tblAppointment.backgroundColor;
                    cont.appointment = appointment;
                    if( indexPath.row == 1 ) {
                        cont.tableIndexEditing = 1;
                    } else if( indexPath.row == 2 ) {
                        cont.tableIndexEditing = 2;
                    }
                    [self.navigationController pushViewController:cont animated:YES];
                    [cont release];
                } else if( indexPath.row == 2 ) {
                    // Standing Appointment Table of Repeats
                    AppointmentRepeatViewController *cont = [[AppointmentRepeatViewController alloc] initWithNibName:@"AppointmentRepeatView" bundle:nil];
                    cont.appointment = appointment;
                    [self.navigationController pushViewController:cont animated:YES];
                    [cont release];
                } else if( indexPath.row == 3) {
                    // Note filler-outer
                    AppointmentNotesViewController *cont = [[AppointmentNotesViewController alloc] initWithNibName:@"AppointmentNotesView" bundle:nil];
                    cont.isEditable = YES;
                    cont.appointment = appointment;
                    [self.navigationController pushViewController:cont animated:YES];
                    [cont release];
                }
                }
                else{
                    if( indexPath.row == 0 ) {
                        // Date/Time picker
                        AppointmentDatePickerViewController *cont = [[AppointmentDatePickerViewController alloc] initWithNibName:@"AppointmentDatePickerView" bundle:nil];
                        cont.appointment = appointment;
                        [self.navigationController pushViewController:cont animated:YES];
                        [cont release];
                    } else if( indexPath.row == 1 ) {
                        // Duration picker
                        DurationViewController *cont = [[DurationViewController alloc] initWithNibName:@"DurationView" bundle:nil];
                        cont.view.backgroundColor = self.tblAppointment.backgroundColor;
                        cont.appointment = appointment;
                        if( indexPath.row == 1 ) {
                            cont.tableIndexEditing = 1;
                        } else if( indexPath.row == 2 ) {
                            cont.tableIndexEditing = 2;
                        }
                        [self.navigationController pushViewController:cont animated:YES];
                        [cont release];
                    } else if( indexPath.row == 2 ) {
                        // Standing Appointment Table of Repeats
                        AppointmentRepeatViewController *cont = [[AppointmentRepeatViewController alloc] initWithNibName:@"AppointmentRepeatView" bundle:nil];
                        cont.appointment = appointment;
                        [self.navigationController pushViewController:cont animated:YES];
                        [cont release];
                    } else if( indexPath.row == 3 ) {
                        AppointmentRepeatUntilViewController *cont = [[AppointmentRepeatUntilViewController alloc] initWithNibName:@"AppointmentRepeatUntilView" bundle:nil];
                        cont.appointment = appointment;
                        [self.navigationController pushViewController:cont animated:YES];
                        [cont release];
                    } else if( indexPath.row == 4) {
                        // Note filler-outer
                        AppointmentNotesViewController *cont = [[AppointmentNotesViewController alloc] initWithNibName:@"AppointmentNotesView" bundle:nil];
                        cont.isEditable = YES;
                        cont.appointment = appointment;
                        [self.navigationController pushViewController:cont animated:YES];
                        [cont release];
                    }
                }
				break;
			}
		}
    }
    /*else {
		
		switch ( indexPath.section ) {
			case 0:
				if( indexPath.row == 1 ) {
					if( appointment.type == iBizAppointmentTypeSingleService ) {
						// Service View
						ServiceInformationController *tmp = [[ServiceInformationController alloc] initWithNibName:@"ServiceInformation" bundle:nil];
						tmp.service = (Service*)appointment.object;
						[self.navigationController pushViewController:tmp animated:YES];
						[tmp release];
					} else if( appointment.type == iBizAppointmentTypeProject ) {
						BOOL inMemory = NO;
						for( UIViewController *tmp in self.navigationController.viewControllers ) {
							if( [tmp isKindOfClass:[ProjectViewController class]] ) {
								inMemory = YES;
							}
						}
						if( !inMemory ) {
							// Project View
							ProjectViewController *pvc = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
							pvc.project = (Project*)appointment.object;
							[self.navigationController pushViewController:pvc animated:YES];
							[pvc release];
						} else {
							UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Project Already Loaded" message:@"The Project you are trying to access is already displayed on one of your previous views. Use the back button (top left corner) to navigate to it." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
							[alert show];	
							[alert release];
						}
					}				
				} else if( indexPath.row == 2 ) {
					// Client View
					[(PSAAppDelegate *)[[UIApplication sharedApplication] delegate] swapNavigationForClientTabWithClient:appointment.client];
				}
				break;
			case 4: {
				// Note filler-outer
				AppointmentNotesViewController *cont = [[AppointmentNotesViewController alloc] initWithNibName:@"AppointmentNotesView" bundle:nil];
				cont.appointment = appointment;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
		}

	}*/
	
}


@end
