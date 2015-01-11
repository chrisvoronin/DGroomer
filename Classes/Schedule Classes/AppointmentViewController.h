//
//  ScheduleViewController.h
//  myBusiness
//
//  Created by David J. Maier on 6/26/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "AppointmentConflictViewController.h"
#import "ClientTableViewController.h"
#import "ProjectsTableViewController.h"
#import "PSADataManager.h"
#import "ServicesTableViewController.h"
#import "TablePickerViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Appointment;

@protocol AppointmentViewDelegate
- (void)appointmentCreated:(id)sender;
@end

@interface AppointmentViewController : UIViewController 
<iBizProjectTableDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, 
UITableViewDataSource, PSAAppointmentConflictDelegate, PSAClientTableDelegate, PSADataManagerDelegate, PSAServiceTableDelegate,
PSATablePickerDelegate>
{
	IBOutlet UITableViewCell	*buttonsCell;
	IBOutlet UITableView		*tblAppointment;	
	Appointment					*appointment;
	Appointment					*oldAppointment;
	BOOL						ignoreConflicts;
	//
	BOOL						isEditing;
	NSArray						*types;
}

@property (nonatomic, retain) Appointment		*appointment;
@property (nonatomic, assign) UITableViewCell	*buttonsCell;
@property (nonatomic, assign) BOOL				isEditing;
@property (nonatomic, retain) UITableView		*tblAppointment;

@property (nonatomic, assign) id<AppointmentViewDelegate> delegate;

- (IBAction)	btnCheckoutPressed;
- (IBAction)	btnDeletePressed;
- (IBAction)	btnEmailPressed;
- (id)			initWithNibName:(NSString*)nibName bundle:(NSBundle*)nibBundle client:(Client*)theClient;

- (void) appointmentsChanged;
- (void) cancelEdit;
- (void) edit;
- (void) save;

@end