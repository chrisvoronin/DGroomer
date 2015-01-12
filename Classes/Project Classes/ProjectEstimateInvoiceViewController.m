//
//  ProjectEstimateInvoiceViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Company.h"
#import	"CreditCardPayment.h"
#import "CreditCardPaymentViewController.h"
#import "CreditCardResponse.h"
#import "GiftCertificate.h"
#import "ProductAdjustment.h"
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectInvoiceItem.h"
#import "ProjectDateEntryViewController.h"
#import "ProjectNameEntryViewController.h"
#import "ProjectNotesEntryViewController.h"
#import "ProjectProduct.h"
#import	"ProjectService.h"
#import "PSADataManager.h"
#import "TransactionPayment.h"
#import "ProjectEstimateInvoiceViewController.h"


@implementation ProjectEstimateInvoiceViewController

@synthesize cellEditButtons, cellEstimateButtons, cellInvoiceButtons, cellInvoiceNotes, cellItem, cellItemEdit, cellPayment, cellPaymentEdit;
@synthesize invoice, isModal, project, tblInvoice;

- (void) viewDidLoad {
	//
	if( invoice.type == iBizProjectEstimate ) {
		self.title = @"Estimate";
	} else if( invoice.type == iBizProjectInvoice ) {
		self.title = @"Invoice";
	}
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblInvoice	setBackgroundColor:bgColor];
	[bgColor release];
	//
	if( isModal ) {
		tblInvoice.editing = YES;
		// Save Button
		UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		self.navigationItem.rightBarButtonItem = btnSave;
		[btnSave release];
		// Cancel Button
		UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
		self.navigationItem.leftBarButtonItem = cancel;
		[cancel release];
	} else {
		if( invoice.datePaid == nil ) {
			// Edit Button
			UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
			self.navigationItem.rightBarButtonItem = btnEdit;
			[btnEdit release];
		}
	}
	
	// Temporary Data (should not be saved to invoice on "Cancel")
	invoiceDateDue	= [invoice.dateDue retain];
	invoiceName		= [invoice.name retain];
	invoiceNotes	= [invoice.notes retain];
	invoicePayments = [[NSMutableArray alloc] initWithArray:invoice.payments];
	invoiceProducts = [[NSMutableArray alloc] initWithArray:invoice.products];
	invoiceServices = [[NSMutableArray alloc] initWithArray:invoice.services];
	//
	ccPaymentsToRemove = [[NSMutableArray alloc] init];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( invoice.datePaid ) {
		self.navigationItem.rightBarButtonItem = nil;
	}
	[tblInvoice reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	// Temp
	[invoiceDateDue release];
	[invoiceName release];
	[invoiceNotes release];
	[invoicePayments release];
	[invoiceProducts release];
	[invoiceServices release];
	//
	[ccPaymentsToRemove release];
	[formatter release];
	// Other
	[invoice release];
	[project release];
	self.tblInvoice = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Action Methods
#pragma mark -
- (IBAction) acceptEstimate {
	invoice.datePaid = [NSDate date];
	[[PSADataManager sharedInstance] saveInvoice:invoice];
	[tblInvoice reloadData];
}

- (void) addInvoicePayment {
	TransactionPaymentViewController *cont = [[TransactionPaymentViewController alloc] initWithNibName:@"TransactionPaymentView" bundle:nil];
	NSNumber *owed = [[NSNumber alloc] initWithDouble:([[invoice getChangeDue] doubleValue]*-1)];
	cont.amountOwed = owed;
	[owed release];
	cont.delegate = self;
	cont.editing = YES;
	cont.isInvoicePayment = YES;	
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

- (void) cancelEdit {
	if( [self checkForNewCreditPayments] ) {
		refundingMethodCall = 98;
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This invoice contains new credit card payments! They must be refunded before the invoice editing can be cancelled!\n\nRefunding is not reversible!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Refund" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
	} else {
		invoice.dateDue = invoiceDateDue;
		invoice.name = invoiceName;
		invoice.notes = invoiceNotes;
		invoice.payments = invoicePayments;
		invoice.products = invoiceProducts;
		invoice.services = invoiceServices;
		
		// The modal view is contained in a Nav Controller (self.parentViewController)
		// which was presented by the topViewController or selectedViewController (RegisterVC or TransactionVC) of the modal's parent (another Nav Controller or Tab Controller).
		// Drill down to this VC and dismiss the editing modal and any views on top of that.
		if( [self.parentViewController isKindOfClass:[UINavigationController class]] ) {
			if( [self.parentViewController.parentViewController isKindOfClass:[UINavigationController class]] ) {
				[((UINavigationController*)((UINavigationController*)self.parentViewController).parentViewController).topViewController dismissViewControllerAnimated:YES completion:nil];
			} else if( [self.parentViewController.parentViewController isKindOfClass:[UITabBarController class]] ) {
				[((UITabBarController*)((UINavigationController*)self.parentViewController).parentViewController).selectedViewController dismissViewControllerAnimated:YES completion:nil];
			} else {
				// Do something here?
			}
		}
	}
	
}

- (IBAction) copyToInvoice:(id)sender {
	// Copy
	ProjectInvoice *newInvoice = [[ProjectInvoice alloc] init];
	newInvoice.projectID = project.projectID;
	newInvoice.type = iBizProjectInvoice;
	NSString *name = [[NSString alloc] initWithFormat:@"Invoice of %@", invoice.name];
	newInvoice.name = name;
	[name release];
	newInvoice.notes = invoice.notes;
	newInvoice.commissionAmount = invoice.commissionAmount;
	newInvoice.taxPercent = invoice.taxPercent;
	newInvoice.totalForTable = invoice.totalForTable;
	newInvoice.products = [NSMutableArray arrayWithArray:invoice.products];
	newInvoice.services = [NSMutableArray arrayWithArray:invoice.services];
	// Erase any IDs on ProjectInvoiceItems so they will insert
	for( ProjectInvoiceItem *tmp in newInvoice.products ) {
		tmp.invoiceItemID = -1;
	}
	for( ProjectInvoiceItem *tmp in newInvoice.services ) {
		tmp.invoiceItemID = -1;
	}
	// Just make a copy, changing the type?
	ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
	cont.invoice = newInvoice;
	cont.project = project;
	cont.isModal = YES;
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
	[newInvoice release];
}

/*
 *	Removes the invoice...
 */
- (void) deleteCurrentInvoice {
	[[PSADataManager sharedInstance] removeInvoice:invoice];
	
	// Remove From Array
	NSMutableArray *array = nil;
	if( invoice.type == iBizProjectEstimate ) {
		array = [project.payments objectForKey:[project getKeyForEstimates]];
	} else if( invoice.type == iBizProjectInvoice ) {
		array = [project.payments objectForKey:[project getKeyForInvoices]];
	}
	if( array ) {
		[array removeObject:invoice];
	}
	
	// Update Project Total
	[[PSADataManager sharedInstance] updateProjectTotal:project];
	
	//
	if( self.navigationController.viewControllers.count == 1 ) {
		// Dismiss the modal (CreditCardPaymentVC?)
		[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
	} else {
		if( self.presentedViewController ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		// Remove the top navigation view
		[self.navigationController popViewControllerAnimated:YES];
	}
}

/*
 *	Only shows action sheets
 */
- (IBAction) deleteInvoice:(id)sender {
	// Warn
	if( [self checkForCreditPayments] ) {
		refundingMethodCall = 99;
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This invoice contains processed credit card payments! They must be refunded before the invoice can be deleted!\n\nRefunding is not reversible!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Refund" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
	} else {
		NSString *aTitle = nil;
		if( invoice.type == iBizProjectInvoice ) {
			aTitle = @"This will refund and remove any payments and invoice data.\n\nDelete Invoice?";
		} else {
			aTitle = @"This will remove all estimate data.\n\nDelete Estimate?";
		}
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:aTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
	}
}

- (void) edit {
	ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
	cont.invoice = invoice;
	cont.project = project;
	cont.isModal = YES;
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

- (IBAction) importProjectItems:(id)sender {
	// Warn
	NSString *aTitle = nil;
	if( invoice.type == iBizProjectInvoice ) {
		aTitle = @"This will replace products and services in this Invoice, with all that are in the Project...";
	} else {
		aTitle = @"This will replace products and services in this Estimate, with all that are in the Project...";
	}
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:aTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Import", nil];
	[sheet showInView:self.view];
	[sheet release];
}

- (void) save {
	if( !invoice.name ) {
		NSString *aTitle = [[NSString alloc] initWithFormat:@"Incomplete %@", (invoice.type == iBizProjectInvoice) ? @"Invoice" : @"Estimate"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:@"Please enter a name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
		[aTitle release];
	} else if( invoice.type == iBizProjectInvoice && !invoice.dateDue ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Invoice" message:@"Please enter a due date!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		// Check for missing payments to remove.
		if( ![invoice.payments isEqualToArray:invoicePayments] ) {
			for( TransactionPayment *tmp in invoicePayments ) {
				if( ![invoice.payments containsObject:tmp] ) {
					if( tmp.transactionPaymentID > -1 ) {
						if( tmp.paymentType == PSATransactionPaymentGiftCertificate && tmp.amountOriginal ) {
							if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] > 0.0 ) {
								NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amountOriginal doubleValue]-[tmp.amount doubleValue]];
								[[PSADataManager sharedInstance] refundAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
								[num release];
								tmp.amountOriginal = nil;
							}
						}
						[[PSADataManager sharedInstance] removeTransactionPayment:tmp];
						[[PSADataManager sharedInstance] removeInvoicePaymentFromCloseouts:tmp];
					}
				}
			}
		}
		// Check for missing products to remove.
		if( ![invoice.products isEqualToArray:invoiceProducts] ) {
			for( ProjectInvoiceItem *tmp in invoiceProducts ) {
				if( ![invoice.products containsObject:tmp] ) {
					if( tmp.invoiceItemID > -1 ) {
						[[PSADataManager sharedInstance] removeInvoiceProduct:tmp];
					}
				}
			}
		}
		// Check for missing services to remove.
		if( ![invoice.services isEqualToArray:invoiceServices] ) {
			for( ProjectInvoiceItem *tmp in invoiceServices ) {
				if( ![invoice.services containsObject:tmp] ) {
					if( tmp.invoiceItemID > -1 ) {
						[[PSADataManager sharedInstance] removeInvoiceService:tmp];
					}
				}
			}
		}
		
		NSInteger preSaveID = invoice.invoiceID;
		
		// Save, inserting or updating the rest of the payments, products, and services.
		[[PSADataManager sharedInstance] saveInvoice:invoice];		
		
		// Add to Project payments
		NSMutableArray *array = nil;
		if( invoice.type == iBizProjectEstimate ) {
			array = [project.payments objectForKey:[project getKeyForEstimates]];
		} else if( invoice.type == iBizProjectInvoice ) {
			array = [project.payments objectForKey:[project getKeyForInvoices]];
		}
		if( array && ![array containsObject:invoice] ) {
			[array addObject:invoice];
		}
		// Update Project Total
		[[PSADataManager sharedInstance] updateProjectTotal:project];
		
		// Put the EstimateInvoiceView behind the current modal view
		if( preSaveID == -1 ) {
			if( [self.navigationController.parentViewController isKindOfClass:[UINavigationController class]] ) {
				ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
				cont.invoice = invoice;
				cont.project = project;
				cont.isModal = NO;
				[(UINavigationController*)self.navigationController.parentViewController pushViewController:cont animated:NO];
				[cont release];
			}
		}
		
		// Always modal when editing...
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark -
#pragma mark UI Delegate Methods
#pragma mark -
/*
 *	Responds to the Import button ActionSheet...
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( [actionSheet.title hasPrefix:@"This invoice contains processed"] ) {
		if( buttonIndex == 0 ) {
			[self refundAllCreditPayments];
		}
	} else if( [actionSheet.title hasPrefix:@"This invoice contains new credit"] ) {
		if( buttonIndex == 0 ) {
			[self refundAllNewCreditPayments];
		}
	} else if( [actionSheet.title hasPrefix:@"This payment is from a credit card"] ) {
		if( buttonIndex == 0 ) {
			refundingMethodCall = 97;
			[self refundCreditPayment];
		} else {
			// Remove the object(s) since it was cancelled.
			[ccPaymentsToRemove removeAllObjects];
		}
	} else if( [actionSheet.title hasPrefix:@"This will replace products"] ) {
		if( buttonIndex == 0 ) {
			[invoice importProducts:project.products];
			[invoice importServices:project.services];
			[tblInvoice reloadData];
		}
	} else {
		if( buttonIndex == 0 ) {
			[self deleteCurrentInvoice];
		}
	}
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

/*
 *
 */
- (void) completedNewPayment:(TransactionPayment*)thePayment {
	// Payments are modal when new
	if( self.presentedViewController != nil ) {
		// New payments get added to the transaction
		thePayment.invoiceID = invoice.invoiceID;
		if( thePayment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			thePayment.creditCardPayment.client = project.client;
		}
		[invoice.payments addObject:thePayment];
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		// Existing payments are not modal, as such should already exist in the payments array
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	if( invoice.type == iBizProjectInvoice ) {
		if( tblInvoice.editing )	return 6;
		else						return 8;
	} else if( invoice.type == iBizProjectEstimate ) {
		if( tblInvoice.editing )	return 5;
		else						return 6;
	}
	return 1;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( invoice.type == iBizProjectInvoice ) {
		if( tblInvoice.editing ) {
			// Editing Invoice
			switch (section) {
				case 0:
					// Name, Date Due
					return 2;
				case 1:
					// Rows for Services, else 1 ("No Services")
					if( invoice.services.count > 0 )	return invoice.services.count;
					else								return 1;
				case 2:
					// Rows for Products, else 1 ("No Products")
					if( invoice.products.count > 0 )	return invoice.products.count;
					else								return 1;
				case 3:
					// Rows for Payments + 1 (Add Payment)
					return invoice.payments.count+1;
				case 4:
					// Notes
					return 1;
				case 5:
					// Edit Buttons
					return 1;
			}
		} else {
			// Not Editing Invoice
			switch (section) {
				case 0:
					// Name, Estimate ID, Date Due or Date Paid
					return 3;
				case 1:
					// Rows for Services, else 1 ("No Services")
					if( invoice.services.count > 0 )	return invoice.services.count;
					else								return 1;
				case 2:
					// Rows for Products, else 1 ("No Products")
					if( invoice.products.count > 0 )	return invoice.products.count;
					else								return 1;
				case 3:
					// Sub-Total, Sales Tax, Est. Total
					return 3;
				case 4:
					// Number of Payments
					if( invoice.payments.count > 0 )	return invoice.payments.count;
					else								return 1;
				case 5:
					// Paid, Change/Owed
					return 2;
				case 6:
					// Notes
					return 1;
				case 7:
					// Invoice Buttons
					return 1;
			}
		}
	} else if( invoice.type == iBizProjectEstimate ) {
		if( tblInvoice.editing ) {
			// Editing Estimate
			switch (section) {
				case 0:
					// Name, Accept Date
					return 2;
				case 1:
					// Rows for Services, else 1 ("No Services")
					if( invoice.services.count > 0 )	return invoice.services.count;
					else								return 1;
				case 2:
					// Rows for Products, else 1 ("No Products")
					if( invoice.products.count > 0 )	return invoice.products.count;
					else								return 1;
				case 3:
					// Notes
					return 1;
				case 4:
					// Edit Buttons
					return 1;
			}
		} else {
			// Not Editing Estimate
			switch (section) {
				case 0:
					// Name, Estimate ID, Date Due
					return 3;
				case 1:
					// Rows for Services, else 1 ("No Services")
					if( invoice.services.count > 0 )	return invoice.services.count;
					else								return 1;
				case 2:
					// Rows for Products, else 1 ("No Products")
					if( invoice.products.count > 0 )	return invoice.products.count;
					else								return 1;
				case 3:
					// Sub-Total, Sales Tax, Est. Total
					return 3;
				case 4:
					// Notes
					return 1;
				case 5:
					// Estimate Buttons
					return 1;
			}
		}
	}
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ( indexPath.section ) {
		case 4:
			if( invoice.type == iBizProjectEstimate && !tblInvoice.editing ) {
				return 92;
			}
			break;
		case 5: {
			if( invoice.type == iBizProjectEstimate ) {
				return 188;
			} else {
				return 44;
			}
			break;
		}
		case 6:
			return 92;
		case 7: {
			return 92;
		}
	}
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ( section ) {
		case 1:		return @"Services";
		case 2:		return @"Products";
		case 3:
			if( section == 3 && tblInvoice.editing && invoice.type == iBizProjectInvoice )	return @"Payments";
			break;
		case 4:
			if( invoice.type == iBizProjectInvoice && !tblInvoice.editing )	return @"Payments";
			break;
	}
	return @"";
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
	if( indexPath.section == 1 || indexPath.section == 2 ) {
		if( tblInvoice.editing ) {
			 identifier = @"ProjectInvoiceItemEditCell";
		} else {
			identifier = @"ProjectInvoiceItemCell";
		}
	} else if( indexPath.section == 5 && invoice.type == iBizProjectEstimate ) {
		identifier = @"ProjectEstimateButtonsCell";
	} else if( indexPath.section == 3 && tblInvoice.editing && invoice.type == iBizProjectInvoice ) {
		identifier = @"ProjectInvoicePaymentEditCell";
	} else if( (indexPath.section == 4 && !tblInvoice.editing && invoice.type == iBizProjectEstimate) || 
			   (indexPath.section == 6 && !tblInvoice.editing && invoice.type == iBizProjectInvoice) ) {
		identifier = @"ProjectInvoiceNotesCell";
	} else if( (indexPath.section == 4 && tblInvoice.editing && invoice.type == iBizProjectEstimate) ||
			   (indexPath.section == 5 && tblInvoice.editing && invoice.type == iBizProjectInvoice) ) {
		identifier = @"ProjectInvoiceEditButtonsCell";
	} else if( indexPath.section == 4 && !tblInvoice.editing && invoice.type == iBizProjectInvoice ) {
		identifier = @"ProjectInvoicePaymentCell";
	} else if( indexPath.section == 7 ) {
		identifier = @"ProjectInvoiceButtonsCell";
	} else {
		identifier = @"InvoiceValue2Cell";
	}
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if( cell == nil ) {
		if( indexPath.section == 1 || indexPath.section == 2 ) {
			if( tblInvoice.editing ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = cellItemEdit;
				self.cellItemEdit = nil;
			} else {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = cellItem;
				self.cellItem = nil;
			}			
		} else if( indexPath.section == 3 && tblInvoice.editing && invoice.type == iBizProjectInvoice ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellPaymentEdit;
			self.cellPaymentEdit = nil;
		} else if( indexPath.section == 4 && !tblInvoice.editing && invoice.type == iBizProjectInvoice ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellPayment;
			self.cellPayment = nil;
		} else if( indexPath.section == 4 && !tblInvoice.editing && invoice.type == iBizProjectEstimate ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellInvoiceNotes;
			self.cellInvoiceNotes = nil;
		} else if( (indexPath.section == 4 && tblInvoice.editing && invoice.type == iBizProjectEstimate) ||
				   (indexPath.section == 5 && tblInvoice.editing && invoice.type == iBizProjectInvoice) ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellEditButtons;
			self.cellEditButtons = nil;
		} else if( indexPath.section == 5 && invoice.type == iBizProjectEstimate ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellEstimateButtons;
			self.cellEstimateButtons = nil;
		} else if( indexPath.section == 6 && !tblInvoice.editing && invoice.type == iBizProjectInvoice ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellInvoiceNotes;
			self.cellInvoiceNotes = nil;
		} else if( indexPath.section == 7 ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = cellInvoiceButtons;
			self.cellInvoiceButtons = nil;
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
			
			UIColor *tmp = cell.textLabel.textColor;
			cell.textLabel.textColor = cell.detailTextLabel.textColor;
			cell.detailTextLabel.textColor = tmp;
			
			cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
			cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
			
			cell.textLabel.textAlignment = NSTextAlignmentLeft;
			cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
		}
    }
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

	switch ( indexPath.section ) {
		case 0: {
			switch ( indexPath.row ) {
				case 0:
					cell.textLabel.text = @"Name";
					cell.detailTextLabel.text = ( invoice.name ) ? invoice.name : @"Enter...";
					break;
				case 1:
					if( tblInvoice.editing ) {
						if( invoice.type == iBizProjectEstimate ) {
							cell.textLabel.text = @"Accept By";
						} else {
							cell.textLabel.text = @"Pay Due";
						}
						if( invoice.dateDue ) {
							cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:invoice.dateDue withFormat:NSDateFormatterLongStyle];
						} else {
							cell.detailTextLabel.text = @"Not Specified";
						}
					} else {
						if( invoice.type == iBizProjectEstimate ) {
							cell.textLabel.text = @"Est. ID";
						} else {
							cell.textLabel.text = @"Invoice ID";
						}
						NSString *strID = [[NSString alloc] initWithFormat:@"%d", invoice.invoiceID];
						cell.detailTextLabel.text = strID;
						[strID release];
					}
					break;
				case 2:
					if( invoice.type == iBizProjectEstimate ) {
						if( invoice.datePaid ) {
							cell.textLabel.text = @"Accepted";
						} else {
							cell.textLabel.text = @"Accept By";
						}
					} else {
						if( invoice.datePaid ) {
							cell.textLabel.text = @"Paid";
						} else {
							cell.textLabel.text = @"Pay Due";
						}
					}
					if( invoice.datePaid ) {
						cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:invoice.datePaid withFormat:NSDateFormatterLongStyle];
					} else if( invoice.dateDue ) {
						NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
						[comps setHour:0];
						[comps setMinute:0];
						[comps setSecond:0];
						NSDate *todayNoTime = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];				
						comps = nil;
						comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSDayCalendarUnit fromDate:todayNoTime toDate:invoice.dateDue options:0];
						if( [comps day] > 0 ) {
							NSString *due = [[NSString alloc] initWithFormat:@"%@ (%d day%@)", [[PSADataManager sharedInstance] getStringForDate:invoice.dateDue withFormat:NSDateFormatterLongStyle], [comps day], ([comps day] == 1) ? @"" : @"s"];
							cell.detailTextLabel.text = due;
							[due release];
						} else if( [comps day] == 0 ) {
							NSString *due = [[NSString alloc] initWithFormat:@"%@ (Today!)", [[PSADataManager sharedInstance] getStringForDate:invoice.dateDue withFormat:NSDateFormatterLongStyle], [comps day], ([comps day] == 1) ? @"" : @"s"];
							cell.detailTextLabel.textColor = [UIColor blueColor];
							cell.detailTextLabel.text = due;
							[due release];
						} else {
							NSString *due = [[NSString alloc] initWithFormat:@"%@ (overdue)", [[PSADataManager sharedInstance] getStringForDate:invoice.dateDue withFormat:NSDateFormatterLongStyle]];
							cell.detailTextLabel.textColor = [UIColor redColor];
							cell.detailTextLabel.text = due;
							[due release];
						}
					} else {
						cell.detailTextLabel.text = @"Not Specified";
					}
					break;
			}
			break;
		}
		case 1: {
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			UILabel *lbName = (UILabel*)[cell viewWithTag:99];
			UILabel	*lbQty = (UILabel*)[cell viewWithTag:98];
			UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
			UILabel	*lbTitleQty = (UILabel*)[cell viewWithTag:96];
			if( invoice.services.count > 0 ) {
				ProjectService *tmp = (ProjectService*)[(ProjectInvoiceItem*)[invoice.services objectAtIndex:indexPath.row] item];
				lbName.text = (tmp.serviceName) ? tmp.serviceName : @"Removed From Project";
				if( tmp.isFlatRate ) {
					lbQty.text = @"Flat";
				} else {
					if( invoice.type == iBizProjectInvoice ) {
						lbQty.text = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:tmp.secondsWorked];
					} else if( invoice.type == iBizProjectEstimate ) {
						lbQty.text = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:tmp.secondsEstimated];
					}
				}
				if( invoice.type == iBizProjectInvoice ) {
					lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]]];
				} else if( invoice.type == iBizProjectEstimate ) {
					lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[[tmp getEstimateSubTotal] doubleValue]-[[tmp getEstimateDiscountAmount] doubleValue]]];
				}
				lbTitleQty.text = @"Hrs.";
				lbQty.hidden = NO;
				lbTotal.hidden = NO;
				lbTitleQty.hidden = NO;
			} else {
				lbName.text = @"No Services";
				lbQty.hidden = YES;
				lbTotal.hidden = YES;
				lbTitleQty.hidden = YES;
			}
			break;
		}
		case 2: {
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			UILabel *lbName = (UILabel*)[cell viewWithTag:99];
			UILabel	*lbQty = (UILabel*)[cell viewWithTag:98];
			UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
			UILabel	*lbTitleQty = (UILabel*)[cell viewWithTag:96];
			if( invoice.products.count > 0 ) {
				ProjectProduct *tmp = (ProjectProduct*)[(ProjectInvoiceItem*)[invoice.products objectAtIndex:indexPath.row] item];
				lbName.text = (tmp.productName) ? tmp.productName : @"Removed From Project";;
				NSString *qty = [[NSString alloc] initWithFormat:@"%d", tmp.productAdjustment.quantity];
				lbQty.text = qty;
				[qty release];
				lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]]];
				lbQty.hidden = NO;
				lbTotal.hidden = NO;
				lbTitleQty.hidden = NO;
			} else {
				lbName.text = @"No Products";
				lbQty.hidden = YES;
				lbTotal.hidden = YES;
				lbTitleQty.hidden = YES;
			}
			break;
		}
		case 3: {
			if( invoice.type == iBizProjectInvoice && tblInvoice.editing ) {
				UILabel *lbName = (UILabel*)[cell viewWithTag:99];
				UILabel	*lbTotal = (UILabel*)[cell viewWithTag:98];
				if( invoice.payments.count == 0 || indexPath.row == invoice.payments.count ) {
					lbName.text = @"Add Payment";
					lbTotal.text = @"";

				} else {
					// Payment Cells
					TransactionPayment *tmpPay = [invoice.payments objectAtIndex:indexPath.row];
					lbName.text = [tmpPay stringForType:tmpPay.paymentType];
					lbTotal.text = [formatter stringFromNumber:tmpPay.amount];
				}
			} else if( invoice.type == iBizProjectEstimate && tblInvoice.editing ) {
				// Estimate Notes
				cell.textLabel.text = @"Notes";
				cell.detailTextLabel.text = invoice.notes;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			} else {
				switch ( indexPath.row ) {
					case 0:
						cell.textLabel.text = @"Sub-Total";
						cell.detailTextLabel.text = [formatter stringFromNumber:[invoice getSubTotal]];
						break;
					case 1:
						cell.textLabel.text = @"Sales Tax";
						NSString *tmpStr2 = [[NSString alloc] initWithFormat:@"+ %@", [formatter stringFromNumber:[invoice getTax]]];
						cell.detailTextLabel.text = tmpStr2;
						[tmpStr2 release];
						break;
					case 2:
						cell.textLabel.text = @"Total";
						cell.detailTextLabel.text = [formatter stringFromNumber:[invoice getTotal]];
						break;
				}
			}
			break;
		}
		case 4: {
			if( invoice.type == iBizProjectInvoice ) {
				if( !tblInvoice.editing ) {
					UILabel *lbName = (UILabel*)[cell viewWithTag:99];
					UILabel	*lbTotal = (UILabel*)[cell viewWithTag:98];
					if( invoice.payments.count == 0 ) {
						lbName.text = @"No Payments";
						lbTotal.text = @"";
					} else {
						// Payment Cells
						TransactionPayment *tmpPay = [invoice.payments objectAtIndex:indexPath.row];
						lbName.text = [tmpPay stringForType:tmpPay.paymentType];
						lbTotal.text = [formatter stringFromNumber:tmpPay.amount];
					}
				} else {
					// Invoice Edit Notes
					cell.textLabel.text = @"Notes";
					cell.detailTextLabel.text = invoice.notes;
					cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			} else {
				if( tblInvoice.editing ) {
					// Estimate Buttons
					cell.editingAccessoryType = UITableViewCellAccessoryNone;
				} else {
					// Notes Cell
					UITextView *tvNotes = (UITextView*)[cell viewWithTag:99];
					tvNotes.text = invoice.notes;
					break;
				}				
			}
			break;
		}
		case 5: {
			if( invoice.type == iBizProjectInvoice ) {
				if( tblInvoice.editing ) {
					// Invoice Edit Buttons
					cell.editingAccessoryType = UITableViewCellAccessoryNone;
				} else {
					cell.editingAccessoryType = UITableViewCellAccessoryNone;
					if( indexPath.row == 0 ) {
						// Paid
						cell.textLabel.text = @"Paid";
						cell.detailTextLabel.text = [formatter stringFromNumber:[invoice getAmountPaid]];
					} else if( indexPath.row == 1 ) {
						// Change/Owed
						NSNumber *change = [invoice getChangeDue];
						NSString *tmp = nil;
						if( [change doubleValue] < 0 ) {
							cell.textLabel.text = @"Owed";
							tmp = [formatter stringFromNumber:[NSNumber numberWithDouble:-1*[change doubleValue]]];
						} else {
							cell.textLabel.text = @"Change";
							tmp = [formatter stringFromNumber:change];
						}
						cell.detailTextLabel.text = tmp;
					}
				}
			} else {
				UIButton *btnAccept = (UIButton*)[cell viewWithTag:55];
				if( invoice.datePaid ) {
					btnAccept.enabled = NO;
				}
			}
			break;
		}
		case 6: {
			UITextView *tvNotes = (UITextView*)[cell viewWithTag:99];
			tvNotes.text = invoice.notes;
			break;
		}
	}
	
	return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( tblInvoice.editing ) {
		if( indexPath.section == 1 ) {
			if( invoice.services.count > 0 )	return UITableViewCellEditingStyleDelete;
		} else if( indexPath.section == 2 ) {
			if( invoice.products.count > 0 )	return UITableViewCellEditingStyleDelete;
		} else if( indexPath.section == 3 && indexPath.row != invoice.payments.count ) {
			return UITableViewCellEditingStyleDelete;
		} else if( indexPath.section == 4  && invoice.type == iBizProjectInvoice ) {
			return UITableViewCellEditingStyleNone;
		}
	}
	if( (indexPath.section == 3 || indexPath.section == 4) && invoice.type == iBizProjectInvoice && indexPath.row == invoice.payments.count ) {
		return UITableViewCellEditingStyleInsert;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.section == 1 ) {
		if( invoice.services.count > 0 ) {
			// Remove Object
			[invoice.services removeObjectAtIndex:indexPath.row];
			// Reload or remove cell
			if( invoice.services.count == 0 ) {
				[tblInvoice reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			} else {
				[tblInvoice deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			}
		}
	} else if( indexPath.section == 2 ) {
		if( invoice.products.count > 0 ) {
			// Remove Object
			[invoice.products removeObjectAtIndex:indexPath.row];
			// Reload or remove cell
			if( invoice.products.count == 0 ) {
				[tblInvoice reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			} else {
				[tblInvoice deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			}
		}
	} else if( indexPath.section == 3 ) {
		if( editingStyle == UITableViewCellEditingStyleInsert ) {
			[self addInvoicePayment];
		} else {
			TransactionPayment *payment = [invoice.payments objectAtIndex:indexPath.row];
			if( payment ) {
				if( payment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
					[ccPaymentsToRemove addObject:payment];
					UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This payment is from a credit card! It must be refunded before it can be removed!\n\nRefunding is not reversible!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Refund" otherButtonTitles:nil];
					[alert showInView:self.view];	
					[alert release];
				} else {
					[invoice.payments removeObjectAtIndex:indexPath.row];
					[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
				}
			}
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// If is a product/service cell... return YES
	if( indexPath.section == 1 || indexPath.section == 2 )		return YES;
	else if( indexPath.section == 3 && tblInvoice.editing && invoice.type == iBizProjectInvoice )		return YES;
	else if( indexPath.section == 3 && tblInvoice.editing && invoice.type == iBizProjectEstimate )		return NO;
	else if( indexPath.section == 4 && tblInvoice.editing && invoice.type == iBizProjectInvoice )		return NO;
	else if( (indexPath.section == 3 || indexPath.section == 4) && invoice.type == iBizProjectInvoice && indexPath.row == invoice.payments.count ) {
		return YES;
	}
	return NO;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if( (indexPath.section == 7 || indexPath.section == 6) || ((indexPath.section == 5 || indexPath.section == 4) && invoice.type == iBizProjectEstimate) ) {
		// Get rid of background and border
		[cell setBackgroundView:nil];
	}
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// GoTo
	if( tblInvoice.editing ) {
		switch (indexPath.section) {
			case 0: {
				if( indexPath.row == 0 ) {
					// Name Entry
					ProjectNameEntryViewController *cont = [[ProjectNameEntryViewController alloc] initWithNibName:@"ProjectNameEntryView" bundle:nil];
					cont.invoice = invoice;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				} else if( indexPath.row == 1 ) {
					// Date Picker
					ProjectDateEntryViewController *cont = [[ProjectDateEntryViewController alloc] initWithNibName:@"ProjectDateEntryView" bundle:nil];
					cont.invoice = invoice;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
				break;
			}
			case 3: {
				if( invoice.type == iBizProjectEstimate ) {
					// Notes
					ProjectNotesEntryViewController *cont = [[ProjectNotesEntryViewController alloc] initWithNibName:@"ProjectNotesEntryView" bundle:nil];
					cont.invoice = invoice;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				} else {
					if( indexPath.row == invoice.payments.count ) {
						[self addInvoicePayment];
					} else {
						// GoTo Payment Non-Modal, Editable
						TransactionPayment *tranny = [invoice.payments objectAtIndex:indexPath.row];
						if( tranny.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
							CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
							NSNumber *owed = [[NSNumber alloc] initWithDouble:([[invoice getChangeDue] doubleValue]*-1)];
							cont.owed = owed;
							[owed release];
							cont.delegate = self;
							cont.payment = tranny;
							[self.navigationController pushViewController:cont animated:YES];
							[cont.view setBackgroundColor:tblInvoice.backgroundColor];
							// Hide tip
							cont.ivTip.hidden = YES;
							cont.lbTotal.hidden = YES;
							cont.txtTip.hidden = YES;
							[cont release];
						} else {
							TransactionPaymentViewController *cont = [[TransactionPaymentViewController alloc] initWithNibName:@"TransactionPaymentView" bundle:nil];
							NSNumber *owed = [[NSNumber alloc] initWithDouble:([[invoice getChangeDue] doubleValue]*-1)];
							cont.amountOwed = owed;
							[owed release];
							cont.delegate = self;
							cont.editing = YES;
							cont.isInvoicePayment = YES;
							cont.payment = tranny;
							[self.navigationController pushViewController:cont animated:YES];
							[cont release];
						}
					}
				}
				break;
			}
			case 4: {
				// Notes
				ProjectNotesEntryViewController *cont = [[ProjectNotesEntryViewController alloc] initWithNibName:@"ProjectNotesEntryView" bundle:nil];
				cont.invoice = invoice;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
		}
	} else {
		switch (indexPath.section) {
			case 4:
				if( invoice.payments.count > 0 ) {
					TransactionPayment *tmp = [invoice.payments objectAtIndex:indexPath.row];
					if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
						CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[invoice getChangeDue] doubleValue]*-1)];
						cont.owed = owed;
						[owed release];
						cont.delegate = self;
						cont.payment = tmp;
						[self.navigationController pushViewController:cont animated:YES];
						[cont.view setBackgroundColor:tblInvoice.backgroundColor];
						// Hide tip
						cont.ivTip.hidden = YES;
						cont.lbTotal.hidden = YES;
						cont.txtTip.hidden = YES;
						[cont release];
					} else {
						TransactionPaymentViewController *cont = [[TransactionPaymentViewController alloc] initWithNibName:@"TransactionPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[invoice getChangeDue] doubleValue]*-1)];
						cont.amountOwed = owed;
						[owed release];
						cont.delegate = self;
						cont.editing = NO;
						cont.payment = tmp;
						[self.navigationController pushViewController:cont animated:YES];
						[cont release];
					}
				}
				break;
		}
	}
}




#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Email Report
#pragma mark -
/*
 *
 */
- (IBAction) email:(id)sender {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Set up the recipients
		NSString *email = [project.client getEmailAddressHome];
		if( email == nil ) {
			email = [project.client getEmailAddressWork];
			if( email == nil ) {
				email = [project.client getEmailAddressAny];
			}
		}
		NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
		[email release];
		[picker setToRecipients:toRecipients];
		// BCC to self
		if( company.companyEmail ) {
			NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setBccRecipients:bccRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ %@", (company.companyName) ? company.companyName : @"", (invoice.type == iBizProjectInvoice) ? @"Invoice" : @"Work Estimate"];
		[picker setSubject:subject];
		[subject release];
		// HTML message
		NSString *clientInfo = [project.client getMutlilineHTMLStringForReceipt];
		NSString *companyInfo = [company getMutlilineHTMLString];
		// Static Top
		NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %d %@ %@ %@ %@ %@ %@ %@", 
									@"<html> <head> <style TYPE=\"text/css\"> BODY, TD { font-family: Helvetica, Verdana, Arial, Geneva; font-size:   12px; }.total { color: #333333; } </style> </head> <body> <table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td> <font size=\"5\"><b>",
									(company.companyName) ? company.companyName : @"",
									@"</b></font> <br/> ",
									(companyInfo) ? companyInfo : @"",
									@"</td> <td align=\"right\" valign=\"top\"> <font size=\"5\" color=\"#6b6b6b\"><b>",
									(invoice.type == iBizProjectInvoice) ? @"INVOICE" : @"ESTIMATE",
									@"</b></font> <br/> ",
									(invoice.type == iBizProjectInvoice) ? @"Invoice" : @"Estimate",
									@"ID: ", 
									invoice.invoiceID,
									@"<br/>",
									(invoice.type == iBizProjectInvoice) ? @"Due" : @"Approve",
									@" By: ",
									(invoice.dateDue) ? [[PSADataManager sharedInstance] getStringForDate:invoice.dateDue withFormat:NSDateFormatterLongStyle] : @"Not Specified",
									@"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\" width=\"120\"> <font size=\"3\" color=\"#6b6b6b\"><b>Customer</b></font> </td> <td valign=\"top\"> ",
									(clientInfo) ? clientInfo : @"",
									@"</td> </tr> </table> </td> </tr>"
									];
		
		if( invoice.products.count > 0 ) {
			[message appendString:@"<tr><td>&nbsp;</td></tr> <tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Products</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"76\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Item No.</b> </td> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Price</b> </td> <td width=\"30\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Qty.</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"];
			double productTax = 0.0;
			// Add row for each Product
			for( ProjectInvoiceItem *tmp in invoice.products ) {
				ProjectProduct *product = (ProjectProduct*)tmp.item;
				NSString *itemDescription = product.productName;
				// Total up the tax... maybe TODO make this a method of ProjectInvoice?
				productTax += [[product getTaxableAmount] doubleValue]*([company.salesTax doubleValue]/100);
				
				[message appendFormat:@"%@%@ %@%@ %@%@ %@%d %@%@ %@%@ %@",
				 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 (product.productNumber) ? product.productNumber : @"-",
				 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 itemDescription,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:product.price],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 product.productAdjustment.quantity,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:[product getDiscountAmount]],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 [formatter stringFromNumber:[NSNumber numberWithDouble:[[product getSubTotal] doubleValue]-[[product getDiscountAmount] doubleValue]]],
				 @"</td></tr>"
				 ];
			}
			
			[message appendFormat:@"%@ %@ %@ %@ %@",
			 @"<tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[NSNumber numberWithDouble:productTax]],
			 @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Product Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[NSNumber numberWithDouble:[[invoice getProductSubTotal] doubleValue]+productTax]],
			 @"</b> </td> </tr> </table> </td> </tr>"
			 ];
		}
		
		if( invoice.services.count > 0 ) {
			[message appendString:@"<tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Services</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"30\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Hours</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Rate</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Setup Fee</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"];
			double serviceTax = 0.0;
			// Add row for each Product
			for( ProjectInvoiceItem *tmp in invoice.services ) {
				ProjectService *service = (ProjectService*)tmp.item;
				// Total up the tax... maybe TODO make this a method of ProjectInvoice?
				if( invoice.type == iBizProjectEstimate ) {
					serviceTax += [[service getTaxableEstimateAmount] doubleValue]*([company.salesTax doubleValue]/100);
				} else {
					serviceTax += [[service getTaxableAmount] doubleValue]*([company.salesTax doubleValue]/100);
				}
				
				NSString *hours = @"";
				if( service.isFlatRate ) {
					hours = @"Flat";
				} else {
					if( invoice.type == iBizProjectInvoice ) {
						hours = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:service.secondsWorked];
					} else {
						hours = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:service.secondsEstimated];
					}
				}
				
				[message appendFormat:@"%@%@ %@%@ %@%@ %@%@ %@%@ %@%@ %@",
				 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 service.serviceName,
				 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 hours,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:service.price],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:service.setupFee],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 (invoice.type == iBizProjectEstimate) ? [formatter stringFromNumber:[service getEstimateDiscountAmount]] : [formatter stringFromNumber:[service getDiscountAmount]],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 (invoice.type == iBizProjectEstimate) ? [formatter stringFromNumber:[NSNumber numberWithDouble:[[service getEstimateSubTotal] doubleValue]-[[service getEstimateDiscountAmount] doubleValue]]] : [formatter stringFromNumber:[NSNumber numberWithDouble:[[service getSubTotal] doubleValue]-[[service getDiscountAmount] doubleValue]]],
				 @"</td></tr>"
				 ];
			}
			
			[message appendFormat:@"%@%@ %@%@ %@",
			 @"<tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[NSNumber numberWithDouble:serviceTax]],
			 @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Service Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[NSNumber numberWithDouble:[[invoice getServiceSubTotal] doubleValue]+serviceTax]],
			 @"</b> </td> </tr> </table> </td> </tr> "
			 ];
		}
		
		
		double paid = [[invoice getAmountPaid] doubleValue];
		double total = [[invoice getTotal] doubleValue];
		
		if( invoice.type == iBizProjectInvoice && invoice.payments.count > 0 ) {
			[message appendString:@"<tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Payments</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td style=\"border-bottom:solid 1px #cccccc;\"> <b>Payment Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Amount</b> </td> </tr>"];
			// Add row for each TransactionPayment
			for( TransactionPayment *payment in invoice.payments ) {
				NSString *paymentDescription = nil;
				if( payment.paymentType == PSATransactionPaymentCash ) {
					paymentDescription = [[NSString alloc] initWithString:@"Cash"];
				} else if( payment.paymentType == PSATransactionPaymentCheck ) {
					paymentDescription = [[NSString alloc] initWithFormat:@"Check No. %@", payment.extraInfo];
				} else if( payment.paymentType == PSATransactionPaymentCoupon ) {
					paymentDescription = [[NSString alloc] initWithFormat:@"Coupon: %@", payment.extraInfo];
				} else if( payment.paymentType == PSATransactionPaymentCredit ) {
					paymentDescription = [[NSString alloc] initWithFormat:@"Credit Card ending in %@", payment.extraInfo];
				} else if( payment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
					[payment hydrateCreditCardPayment];
					paymentDescription = [[NSString alloc] initWithFormat:@"Credit Card ending in %@", payment.creditCardPayment.ccNumber];
					[payment dehydrateCreditCardPayment];
				} else if( payment.paymentType == PSATransactionPaymentGiftCertificate ) {
					GiftCertificate *cert = [[PSADataManager sharedInstance] getGiftCertificateWithID:[payment.extraInfo integerValue]];
					if( cert ) {
						paymentDescription = [[NSString alloc] initWithFormat:@"Gift Certificate %d", cert.certificateID];
					} else {
						paymentDescription = [[NSString alloc] initWithString:@"Unknown Gift Certificate"];
					}
					[cert release];
				}
				
				[message appendFormat:@"%@%@%@%@%@",
				 @"<tr align=\"right\"><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">",
				 paymentDescription,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 [formatter stringFromNumber:payment.amount],
				 @"</td></tr>"
				 ];
				[paymentDescription release];
			}
			[message appendFormat:@"%@%@%@",
				@"<tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Payment Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
				[formatter stringFromNumber:[NSNumber numberWithDouble:paid]],
				@"</b> </td> </tr> </table> </td> </tr>"
			 ];
		}
		
		
		[message appendFormat:@"%@%@ %@%@ %@%@",
			@"</table> <br/><br/><table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr align=\"right\"> <td> <b><font size=\"5\">",
			(invoice.type == iBizProjectInvoice) ? @"Invoice" : @"Estimate",
			(paid > 0) ? @" Unpaid" : @"",
			@" Total:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
			(paid > total) ? [formatter stringFromNumber:[NSNumber numberWithInt:0]] : [formatter stringFromNumber:[NSNumber numberWithDouble:total-paid]],
			@"</font></b> </td> </tr> </table> <br/><br/><br/>"
		 ];
		
		if( invoice.notes ) {
			[message appendFormat:@"%@%@%@",
				@"<table width=\"95%\" height=\"50\" border=\"0\" cellpadding=\"4\" cellspacing=\"0\" align=\"center\"> <tr align=\"left\" valign=\"top\"> <td width=\"50\" style=\"border-top:solid 1px #cccccc;border-bottom:solid 1px #cccccc;border-left:solid 1px #cccccc;\"> Notes: </td> <td style=\"border-top:solid 1px #cccccc;border-bottom:solid 1px #cccccc;border-right:solid 1px #cccccc;\">",
				invoice.notes,
				@"</td> </tr> </table>"
			 ];
		}
		
		[message appendString:@"</body> </html>"];
		
		[picker setMessageBody:message isHTML:YES];
		[message release];
		[company release];
		[clientInfo release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil];
		[picker release];
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Report!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}

#pragma mark -
#pragma mark Credit Card Processing Methods
#pragma mark -
- (void) autoRefundedCreditPayment:(TransactionPayment*)thePayment {
	
	// Wait for it to return... check it for errors
	if( thePayment.creditCardPayment.response.responseCode != 1 || thePayment.creditCardPayment.status == CreditCardProcessingCancelled ) {
		[thePayment dehydrateCreditCardPayment];
		[ccPaymentsToRemove removeAllObjects];
		[self dismissViewControllerAnimated:YES completion:nil];
		// Display Alert
		NSString *message = nil;
		if( refundingMethodCall == 99 ) {
			message = @"There was a problem refunding a credit card payment!\n\nAny payments already refunded have been removed. The transaction will not be voided.";
		} else if( refundingMethodCall == 98 ) {
			message = @"There was a problem refunding a credit card payment!\n\nAny payments already refunded have been removed. The transaction will not be cancelled.";
		} else {
			message = @"There was a problem refunding a credit card payment! It will not be removed from the transaction.";
		}
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Refund Error!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		
		[ccPaymentsToRemove removeObject:thePayment];
		
		if( thePayment.transactionPaymentID > -1 ) {
			// Remove transactionPayment from database...
			[[PSADataManager sharedInstance] removeTransactionPayment:thePayment];
			[[PSADataManager sharedInstance] removeInvoicePaymentFromCloseouts:thePayment];
		}
		
		// Remove from the editing array, and the transaction itself so it is never put back...
		[invoice.payments removeObject:thePayment];
		[invoicePayments removeObject:thePayment];
		//
		[thePayment dehydrateCreditCardPayment];
		// Continue if there are more...
		[self refundCreditPayment];
	}
}

- (BOOL) checkForCreditPayments {
	for( TransactionPayment *tmp in invoice.payments ) {
		if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) checkForNewCreditPayments {
	for( TransactionPayment *tmp in invoice.payments ) {
		if( tmp.transactionPaymentID == -1 && tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			return YES;
		}
	}
	return NO;
}

- (void) refundAllCreditPayments {
	for( TransactionPayment *tmp in invoice.payments ) {
		if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			[ccPaymentsToRemove addObject:tmp];
		}
	}
	[self refundCreditPayment];
}

- (void) refundAllNewCreditPayments {
	for( TransactionPayment *tmp in invoice.payments ) {
		if( tmp.transactionPaymentID == -1 && tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			[ccPaymentsToRemove addObject:tmp];
		}
	}
	[self refundCreditPayment];
}

- (void) refundCreditPayment {
	
	if( ccPaymentsToRemove.count > 0 ) {
		
		// Pop up modal view... hiding the credit input portion (making it transparent!?)
		CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
		cont.autoRefunding = YES;
		cont.delegate = self;
		cont.payment = [ccPaymentsToRemove objectAtIndex:0];
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
		//nav.navigationBar.tintColor = [UIColor blackColor];
		[self presentViewController:nav animated:YES completion:nil];
		[cont.view setBackgroundColor:tblInvoice.backgroundColor];
		// Hide tip
		cont.ivTip.hidden = YES;
		cont.lbTotal.hidden = YES;
		cont.txtTip.hidden = YES;
		cont.title = @"Refunding Credit";
		[cont cancelVoidRefund:self];
		[cont release];
		
	} else {
		
		// If last method was void or cancel... do that
		if( refundingMethodCall == 99 ) {
			[self deleteCurrentInvoice];
		} else if( refundingMethodCall == 98 ) {
			[self cancelEdit];
		} else if( refundingMethodCall == 97 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
	
}

/*
 *	Remove the payment from the invoice!
 */
- (void) refundedCreditPayment:(TransactionPayment*)thePayment {
	
	if( thePayment.transactionPaymentID > -1 ) {
		// Remove transactionPayment from database...
		[[PSADataManager sharedInstance] removeTransactionPayment:thePayment];
		[[PSADataManager sharedInstance] removeInvoicePaymentFromCloseouts:thePayment];
	}
	
	// Remove from the editing array, and the transaction itself so it is never put back...
	[invoice.payments removeObject:thePayment];
	[invoicePayments removeObject:thePayment];
}

@end
