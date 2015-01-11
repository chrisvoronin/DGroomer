//
//  ProjectEditViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/18/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectDateEntryViewController.h"
#import "ProjectNameEntryViewController.h"
#import "ProjectNotesEntryViewController.h"
#import "ProjectViewController.h"
#import "PSADataManager.h"
#import "Transaction.h"
#import "TransactionPayment.h"
#import "ProjectEditViewController.h"


@implementation ProjectEditViewController

@synthesize project, tblProject;

- (void) viewDidLoad {
	if( project )	self.title = @"Edit Project";
	else			self.title = @"New Project";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblProject setBackgroundColor:bgColor];
	[bgColor release];
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	// Cancel Button
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
	self.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	// Temp Data
	if( project ) {
		projectClient = [project.client retain];
		projectDateDue = [project.dateDue retain];
		projectName = [project.name retain];
		projectNotes = [project.notes retain];
	}
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !project ) {
		project = [[Project alloc] init];
		project.isHydrated = YES;
	}
	[tblProject reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	// Temp
	[projectClient release];
	[projectDateDue release];
	[projectName release];
	[projectNotes release];
	//
	[project release];
	self.tblProject = nil;
    [super dealloc];
}

- (void) cancelEdit {
	project.client = projectClient;
	project.dateDue = projectDateDue;
	project.name = projectName;
	project.notes = projectNotes;
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) save {
	if( !project.name ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Project" message:@"Please enter a name for this project!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else if ( !project.client ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Project" message:@"Please select a Client!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		BOOL newProject = NO;
		if( project.projectID == -1 ) {
			newProject = YES;
		}
		[[PSADataManager sharedInstance] saveProject:project];
		[self dismissViewControllerAnimated:YES completion:nil];
		if( newProject ) {
			// Push a ProjectViewController onto the navigation stack...
			ProjectViewController *pvc = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
			pvc.project = project;
			if( [[self.parentViewController parentViewController] isKindOfClass:[UINavigationController class]] ) {
				[(UINavigationController*)[self.parentViewController parentViewController] pushViewController:pvc animated:YES];
			}
			[pvc release];
		}
	}
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == 0 ) {
		ClientTableViewController *cont = [[ClientTableViewController alloc] initWithNibName:@"ClientTableView" bundle:nil];
		cont.clientDelegate = self;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	}
}

/*
 *	Save the returned Client in our Project
 */
- (void) selectionMadeWithClient:(Client*)theClient {
	project.client = theClient;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"ProjectDefaultCell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UIColor *tmp = cell.textLabel.textColor;
		cell.textLabel.textColor = cell.detailTextLabel.textColor;
		cell.detailTextLabel.textColor = tmp;
		
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
		
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
	}
		
	//UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	
	switch (indexPath.section) {
		case 0:
			cell.textLabel.text = @"Name*";
			if( project.name ) {
				cell.detailTextLabel.text = project.name;
			} else {
				cell.detailTextLabel.text = @"Enter...";
			}
			break;
		case 1:
			cell.textLabel.text = @"Client*";
			if( project.client ) {
				cell.detailTextLabel.text = [project.client getClientName];
			} else {
				cell.detailTextLabel.text = @"Choose...";
			}
			break;
		case 2:
			cell.textLabel.text = @"Due Date";
			if( project.dateDue ) {
				cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:project.dateDue withFormat:NSDateFormatterLongStyle];
			} else {
				cell.detailTextLabel.text = @"None";
			}
			break;
		case 3:
			cell.textLabel.text = @"Notes";
			cell.detailTextLabel.text = project.notes;
			break;
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	switch (indexPath.section) {
		case 0: {
			// Name Entry
			ProjectNameEntryViewController *cont = [[ProjectNameEntryViewController alloc] initWithNibName:@"ProjectNameEntryView" bundle:nil];
			cont.project = project;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
		case 1: {
			// Clients Table
			BOOL hasCredit = NO;
			for( ProjectInvoice *tmpInv in [project.payments objectForKey:[project getKeyForInvoices]] ) {
				for( TransactionPayment *tmpPay in tmpInv.payments ) {
					if( tmpPay.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
						hasCredit = YES;
					}
				}
			}
			for( Transaction *tmpTran in [project.payments objectForKey:[project getKeyForTransactions]] ) {
				for( TransactionPayment *tmpPay in tmpTran.payments ) {
					if( tmpPay.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
						hasCredit = YES;
					}
				}
			}
			if( hasCredit ) {
				UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"This project has processed credit payments for the current client! The client's name on those payments will never change!\n\nEdit anyway?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit", nil];
				[action showInView:self.view];
				[action release];
			} else {
				ClientTableViewController *cont = [[ClientTableViewController alloc] initWithNibName:@"ClientTableView" bundle:nil];
				cont.clientDelegate = self;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			}
			break;
		}
		case 2: {
			// Due Date Entry
			ProjectDateEntryViewController *cont = [[ProjectDateEntryViewController alloc] initWithNibName:@"ProjectDateEntryView" bundle:nil];
			cont.project = project;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
		case 3: {
			// Notes
			ProjectNotesEntryViewController *cont = [[ProjectNotesEntryViewController alloc] initWithNibName:@"ProjectNotesEntryView" bundle:nil];
			cont.project = project;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
	}
}


@end
