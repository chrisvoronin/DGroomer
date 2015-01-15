//
//  GiftCertificateViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "GiftCertificate.h"
#import "GiftCertificateAmountViewController.h"
#import "GiftCertificateExpirationViewController.h"
#import "GiftCertificateRecipientViewController.h"
#import "GiftCertificateTextViewController.h"
#import "PSADataManager.h"
#import "Transaction.h"
#import "GiftCertificateViewController.h"

@implementation GiftCertificateViewController

@synthesize certificate, delegate, newID, tblCertificate, transaction;

- (void) viewDidLoad {
	// Background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblCertificate setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
	//
	if( !certificate ) {
		// Make a blank (new) certificate
		certificate = [[GiftCertificate alloc] init];
		certificate.certificateID = newID;
		self.title = @"NEW CERTIFICATES";
		tblCertificate.allowsSelectionDuringEditing = YES;
		isEditing = YES;
	} else {
		self.title = @"GIFT CERTIFICATES";
		self.navigationItem.rightBarButtonItem = nil;
		isEditing = NO;
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[tblCertificate reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[certificate release];
	[formatter release];
	self.tblCertificate = nil;
	[transaction release];
    [super dealloc];
}

#pragma mark -
#pragma mark Control Methods
#pragma mark -

- (void) save {
	if( !certificate.recipientLast && !certificate.recipientFirst ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Recipient!" message:@"Must specify a name for the recipient!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else if( [certificate.amountPurchased doubleValue] <= 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Amount!" message:@"Must specify an amount greater than 0 for this gift certificate!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else if( !certificate.expiration ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Expiration Date!" message:@"Must select an expiration date for this gift certificate!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		[self.delegate completedNewGiftCertificate:certificate];
	}
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

/*
 *	Save the returned Client in our Transaction
 */
- (void) selectionMadeWithClient:(Client*)theClient {
	certificate.purchaser = theClient;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

/*
 *	
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 && isEditing )		return 1;
	if( section == 0 && !isEditing )	return 3;
	if( section == 1 && !isEditing )	return 3;
	return 1;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CertificateCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CertificateCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UIColor *tmp = cell.textLabel.textColor;
		cell.textLabel.textColor = cell.detailTextLabel.textColor;
		cell.detailTextLabel.textColor = tmp;
		
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
		
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }
	
	if( !isEditing ) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	switch ( indexPath.section ) {
		case 0:
			if( (indexPath.row == 0 && !isEditing) ) {
				cell.textLabel.text = @"Cert. ID";
				if( certificate.certificateID > -1 ) {
					NSString *str = [[NSString alloc] initWithFormat:@"%ld", (long)certificate.certificateID];
					cell.detailTextLabel.text = str;
					[str release];
				}
			} else if( (indexPath.row == 1 && !isEditing) ) {
				cell.textLabel.text = @"Purchaser";
				if( certificate.purchaser ) {
					cell.detailTextLabel.text = [certificate.purchaser getClientName];
				} else {
					cell.detailTextLabel.text = @"None";
				}
			} else if( (indexPath.row == 0 && isEditing) || (indexPath.row == 2 && !isEditing) ) {
				cell.textLabel.text = @"Recipient";
				if( certificate.recipientFirst && certificate.recipientLast ) {
					NSString *str = [[NSString alloc] initWithFormat:@"%@, %@", certificate.recipientLast, certificate.recipientFirst];
					cell.detailTextLabel.text = str;
					[str release];
				} else if( certificate.recipientFirst ) {
					cell.detailTextLabel.text = certificate.recipientFirst;
				} else if( certificate.recipientLast ) {
					cell.detailTextLabel.text = certificate.recipientLast;
				} else {
					cell.detailTextLabel.text = @"None";
				}
			}
			break;
		case 1:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Amount";
				if( certificate.amountPurchased ) {
					cell.detailTextLabel.text = [formatter stringFromNumber:certificate.amountPurchased];
				} else {
					cell.detailTextLabel.text = @"Choose";
				}
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Used";
				if( certificate.amountUsed ) {
					cell.detailTextLabel.text = [formatter stringFromNumber:certificate.amountUsed];
				}
			} else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Remaining";
				if( certificate.amountUsed && certificate.amountPurchased ) {
					cell.detailTextLabel.text = [formatter stringFromNumber:[NSNumber numberWithFloat:[certificate.amountPurchased doubleValue]-[certificate.amountUsed doubleValue]]];
				}
			}
			break;
		case 2:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Message";
			if( certificate.message ) {
				cell.detailTextLabel.text = certificate.message;
			} else {
				cell.detailTextLabel.text = @"None";
			}
			break;
		case 3:
			cell.textLabel.text = @"Expiration";
			if( certificate.expiration ) {
				cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:certificate.expiration withFormat:NSDateFormatterMediumStyle];
			} else {
				cell.detailTextLabel.text = @"Choose";
			}
			break;
		case 4:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Notes";
			if( certificate.notes ) {
				cell.detailTextLabel.text = certificate.notes;
			} else {
				cell.detailTextLabel.text = @"None";
			}
			break;
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
	if( isEditing || indexPath.section == 4 || indexPath.section == 2 ) {
		// GoTo
		switch ( indexPath.section ) {
			case 0: {
				// Go to the name input
				GiftCertificateRecipientViewController *cont = [[GiftCertificateRecipientViewController alloc] initWithNibName:@"GiftCertificateRecipientView" bundle:nil];
				cont.certificate = certificate;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
			case 1: {
				// Go to amount input
				GiftCertificateAmountViewController *cont = [[GiftCertificateAmountViewController alloc] initWithNibName:@"GiftCertificateAmountView" bundle:nil];
				cont.certificate = certificate;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
			case 2: {
				// Go to message input
				GiftCertificateTextViewController *cont = [[GiftCertificateTextViewController alloc] initWithNibName:@"GiftCertificateTextView" bundle:nil];
				cont.certificate = certificate;
				cont.editing = isEditing;
				cont.title = @"Message";
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
			case 3: {
				// Go to expiration date picker
				GiftCertificateExpirationViewController *cont = [[GiftCertificateExpirationViewController alloc] initWithNibName:@"GiftCertificateExpirationView" bundle:nil];
				cont.certificate = certificate;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
			case 4: {
				// Go to notes input
				GiftCertificateTextViewController *cont = [[GiftCertificateTextViewController alloc] initWithNibName:@"GiftCertificateTextView" bundle:nil];
				cont.certificate = certificate;
				cont.editing = isEditing;
				cont.title = @"Notes";
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			}
		}
	}
}


@end
