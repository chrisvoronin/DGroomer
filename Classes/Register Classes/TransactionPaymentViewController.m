//
//  TransactionPaymentViewController.m
//  myBusiness
//
//  Created by David J. Maier on 1/5/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "CreditCardPayment.h"
#import "CreditCardPaymentViewController.h"
#import "GiftCertificate.h"
#import "GiftCertificateViewController.h"
#import "PSADataManager.h"
#import "Reachability.h"
#import "Transaction.h"
#import "TransactionPayment.h"
#import "TransactionPaymentInfoViewController.h"
#import "TransactionPaymentViewController.h"
#import "TransactionViewController.h"
#import "CreditCardSettings.H"

@implementation TransactionPaymentViewController

@synthesize amountOwed, delegate, editing, isInvoicePayment, payment, tblPayment;

- (void) viewDidLoad {
	//
	self.title = @"PAYMENT";
	//
	/*if( isInvoicePayment ) {
		UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
		UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
		[tblPayment setBackgroundColor:bgColor];
		[bgColor release];
	} else {
		UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
		UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
		[tblPayment setBackgroundColor:bgColor];
		[bgColor release];
	}*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	//
	if( editing ) {
		// Save Button
		UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		self.navigationItem.rightBarButtonItem = btnSave;
		[btnSave release];
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !payment ) {
		payment = [[TransactionPayment alloc] init];
	}
	[tblPayment reloadData];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[amountOwed release];
	[formatter release];
	[payment release];
	self.tblPayment = nil;
    [super dealloc];
}

- (void) done {
	if( [payment.amount doubleValue] > 0.0 ) {
		if( payment.paymentType == PSATransactionPaymentGiftCertificate ) {
			GiftCertificate *cert = [[PSADataManager sharedInstance] getGiftCertificateWithID:[payment.extraInfo integerValue]];
			double amountLeft = [cert.amountPurchased doubleValue]-[cert.amountUsed doubleValue];
			double amount = [payment.amount doubleValue];
			// Check for valid GiftCertificate amount
			if( payment.transactionPaymentID > -1 ) {
				// This already has a deduction. Add that to the amountLeft to get the real value left on the certificate
				if( payment.amountOriginal ) {
					amountLeft = amountLeft + [payment.amountOriginal doubleValue];
				} else {
					amountLeft = amountLeft + [payment.amount doubleValue];
				}
			}
			// If our amount can safely be deducted...
			if( amount <= amountLeft ) {
				payment.datePaid = [NSDate date];
				[self.delegate completedNewPayment:payment];
			} else {
				// Alert
				NSString *msg = [[NSString alloc] initWithFormat:@"The chosen Gift Certificate only has %@ left!\n\nPlease choose an amount equal or less than that value.", [formatter stringFromNumber:[NSNumber numberWithDouble:amountLeft]]];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];	
				[alert release];
				[msg release];
			}
		} else if(payment.paymentType == PSATransactionPaymentCheck || payment
                  .paymentType == PSATransactionPaymentCoupon)
        {
            double extras = [payment.extraInfo doubleValue];
            if(payment.extraInfo.length < 1 || extras == 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please fill out the check number!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            else {
                payment.datePaid = [NSDate date];
                [self.delegate completedNewPayment:payment];
            }
        } else {
			payment.datePaid = [NSDate date];
			[self.delegate completedNewPayment:payment];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Amount" message:@"Payment amount must be greater than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void) completedMoneyEntry:(NSString*)value title:(NSString*)title {
	
	NSNumberFormatter *formatter2 = [[NSNumberFormatter alloc] init];
	
	NSNumber *num = nil;
	if( [value hasPrefix:@" "] ) {
		num = [formatter2 numberFromString:[value substringFromIndex:1]];
	} else {
		num = [formatter2 numberFromString:value];
	}

	if( [title isEqualToString:@"AMOUNT"] ) {
		if( payment.transactionPaymentID > -1 && payment.paymentType == PSATransactionPaymentGiftCertificate ) {
			// Keep track of the old value by storing the new one
			if( !payment.amountOriginal ) {
				payment.amountOriginal = payment.amount;
			}
			payment.amount = num;
		} else {
			payment.amount = num;
		}
	}
	[formatter2 release];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) selectionMadeWithCertificate:(GiftCertificate*)theCertificate {
	NSString *str = [[NSString alloc] initWithFormat:@"%ld", (long)theCertificate.certificateID];
	payment.extraInfo = str;
	[str release];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) selectionMadeWithString:(NSString*)theValue {
    
    PSATransactionPaymentType payOldType = payment.paymentType;
	payment.paymentType = [payment typeForString:theValue];
	
	if( payment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
		// Don't even go there if there is no connection
		Reachability *curReach = [Reachability reachabilityForInternetConnection];
		// Check network reachability
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if( netStatus == NotReachable ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required" message:@"Credit card processing requires a Wi-Fi or 3G connection in order to function. " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
            payment.paymentType = payOldType;
		} else {
            
            CreditCardSettings	*settings = [[PSADataManager sharedInstance] getCreditCardSettings];
            NSString *x_login = settings.apiLogin;
            NSString *x_tran_key = settings.transactionKey;
            
            if(x_login.length < 1 || x_tran_key.length < 1)
            {
                NSString *message = [[NSString alloc] initWithString:@"To process a credit card, please fill out the Credit Card Settings in the Settings option from the main screen."];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alert.tag = 2;
                [alert show];
                [alert release];
                [message release];
                payment.paymentType = payOldType;
                return;
            }
            
			// Create a payment object if needed
			if( !payment.creditCardPayment ) {
				CreditCardPayment *credit = [[CreditCardPayment alloc] init];
				if( [self.delegate isKindOfClass:[TransactionViewController class]] ) {
					credit.client = ((TransactionViewController*)self.delegate).transaction.client;
					[credit extractDataFromClientContact];
				}
				payment.creditCardPayment = credit;
				[credit release];
				payment.ccHydrated = YES;
			}
			//
			CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
			cont.delegate = self.delegate;
			cont.owed = amountOwed;
			cont.payment = payment;
			UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(close)];
			cont.navigationItem.leftBarButtonItem = cancel;
			[cancel release];
			// Replace the TransactionPaymentViewController (root) with the CCPaymentVC
			NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
			[vcs replaceObjectAtIndex:vcs.count-2 withObject:cont];
			[vcs removeLastObject];
			[self.navigationController setViewControllers:vcs animated:NO];
			[vcs release];
			//[self.navigationController pushViewController:cont animated:YES];
			[cont.view setBackgroundColor:tblPayment.backgroundColor];
			// Hide the tip if invoice
			if( isInvoicePayment ) {
				cont.ivTip.hidden = YES;
				cont.lbTotal.hidden = YES;
				cont.txtTip.hidden = YES;
			}
			[cont release];
		}
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        if(alertView.tag == 2){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 && payment.paymentType != PSATransactionPaymentCash && payment.paymentType != PSATransactionPaymentCreditCardForProcessing ) {
		return 2;
	}
	if( section == 1 )	return 1;
	return 1;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"RegisterCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RegisterCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		UIColor *tmp = cell.textLabel.textColor;
		cell.textLabel.textColor = cell.detailTextLabel.textColor;
		cell.detailTextLabel.textColor = tmp;
		
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
		
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }
	
	if( editing || (payment.paymentType == PSATransactionPaymentGiftCertificate && indexPath.section == 0 && indexPath.row == 1) ) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Type";
				cell.detailTextLabel.text = [payment stringForType:payment.paymentType];
			} else {
				switch (payment.paymentType) {
					case PSATransactionPaymentCheck:
						cell.textLabel.text = @"Check No.";
						break;
					case PSATransactionPaymentCoupon:
						cell.textLabel.text = @"Coupon No.";
						break;
					case PSATransactionPaymentGiftCertificate:
						cell.textLabel.text = @"Certificate";
						break;
					case PSATransactionPaymentCredit:
						cell.textLabel.text = @"Last 4 No.";
						break;
				}
				if( payment.paymentType == PSATransactionPaymentGiftCertificate && [payment.extraInfo isEqualToString:@"-2"] ) {
					cell.detailTextLabel.text = @"Voided Certificate";
				} else {
					cell.detailTextLabel.text = payment.extraInfo;
				}
			}
			break;
		case 1:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Amount";
				cell.detailTextLabel.text = [formatter stringFromNumber:payment.amount];
			}
			break;
	}
	
	return cell;
}

/*
 *	
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// GoTo
	if( editing ) {
		switch ( indexPath.section ) {
			case 0: {
				if( indexPath.row == 0 ) {
					TablePickerViewController *picker = [[TablePickerViewController alloc] initWithNibName:@"TablePickerView" bundle:nil];
					picker.title = @"PAYMENT TYPE";
					picker.pickerDelegate = self;
					picker.selectedValue = [payment stringForType:payment.paymentType];
					picker.pickerValues = [payment getPaymentTypes];
					[self.navigationController pushViewController:picker animated:YES];
					// Set the background same as this
					[picker.tblItems setBackgroundColor:tblPayment.backgroundColor];
					[picker release];
				} else {
					if( payment.paymentType == PSATransactionPaymentGiftCertificate ) {
						// Certificate Picker
						GiftCertificateTableViewController *cont = [[GiftCertificateTableViewController alloc] initWithNibName:@"GiftCertificateTableView" bundle:nil];
						cont.delegate = self;
						[self.navigationController pushViewController:cont animated:YES];
						[cont release];
					} else {
						TransactionPaymentInfoViewController *cont = [[TransactionPaymentInfoViewController alloc] initWithNibName:@"TransactionPaymentInfoView" bundle:nil];
						cont.payment = payment;
						[self.navigationController pushViewController:cont animated:YES];
						[cont.view setBackgroundColor:tblPayment.backgroundColor];
						[cont release];
					}
				}
				break;
			}
			case 1: {
				if( payment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
					// Nothing, this view should transition after picking
				} else {
					TransactionMoneyEntryViewController *cont = [[TransactionMoneyEntryViewController alloc] initWithNibName:@"TransactionMoneyEntryView" bundle:nil];
					cont.delegate = self;
					if( indexPath.row == 0 ) {
						cont.title = @"AMOUNT";
						NSNumberFormatter *formatter2 = [[NSNumberFormatter alloc] init];
						[formatter2 setNumberStyle:NSNumberFormatterCurrencyStyle];
						[formatter2 setCurrencySymbol:@""];
						cont.value = [formatter2 stringFromNumber:payment.amount];
						[formatter2 release];
					}
					[self.navigationController pushViewController:cont animated:YES];
					//[cont.view setBackgroundColor:tblPayment.backgroundColor];
                    NSString *bal = nil;
					if( amountOwed ) {
						double amt = [amountOwed doubleValue];
						if( amt < 0.0 || amt == -0.0 ) {
							amt = 0.0;
						}
						bal = [[NSString alloc] initWithFormat:@"Owed: %@", [formatter stringFromNumber:[NSNumber numberWithFloat:amt]]];
						cont.lbBalance.text = bal;
						//[bal release];
					} else {
						cont.lbBalance.text = @"Owed: Unknown";
                        bal = @"Owed: Unknown";
					}
                    cont.owedValue = bal;
					[cont release];
				}
				break;
			}
		}
	} else {
		if( indexPath.section == 0 && indexPath.row == 1 ) {
			// Show GiftCertificate
			GiftCertificateViewController *cont = [[GiftCertificateViewController alloc] initWithNibName:@"GiftCertificateView" bundle:nil];
			GiftCertificate *cert = [[PSADataManager sharedInstance] getGiftCertificateWithID:[payment.extraInfo intValue]];
			if( cert ) {
				cont.certificate = cert;
				[self.navigationController pushViewController:cont animated:YES];
			} else {
				// Alert
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Void Certificate" message:@"This Gift Certificate was part of a transaction that has been voided. No details for this certificate are available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];	
				[alert release];
			}
			[cert release];
			[cont release];
		}
	}
	
}

@end
