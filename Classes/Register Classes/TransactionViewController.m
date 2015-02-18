//
//  TransactionViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/16/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Client.h"
#import "Company.h"
#import "CreditCardPayment.h"
#import "CreditCardPaymentViewController.h"
#import "CreditCardResponse.h"
#import "GiftCertificate.h"
#import "Product.h"
#import "ProductAdjustment.h"
#import "PSADataManager.h"
#import "Service.h"
#import "Transaction.h"
#import "TransactionAdjustmentViewController.h"
#import "TransactionItem.h"
#import "TransactionPayment.h"
#import "TransactionViewController.h"
#import "PSAAppDelegate.h"
#import "Reachability.h"
#import "ConfigurationUtility.h"
#import "PSAReminderViewController.h"

@implementation TransactionViewController

@synthesize isEditing, tblTransaction, transaction, voidCell, parent;
@synthesize cellItem, cellItemEdit, cellPayment, cellPaymentEdit;

- (void)viewDidLoad {
	self.title = @"TRANSACTIONS";
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblTransaction setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	if( isEditing || tblTransaction.editing || transaction == nil || transaction.transactionID < 0 ) {
		// Save Button
		/*UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		self.navigationItem.rightBarButtonItem = btnSave;
		[btnSave release];*/
		UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
		self.navigationItem.leftBarButtonItem = cancel;
		[cancel release];
	} else {
		if( transaction.dateClosed == nil ) {
			// Edit Button
			UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(save)];
			self.navigationItem.rightBarButtonItem = btnEdit;
			[btnEdit release];
		} else {
			// Email Receipt Button
			UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReceipt)];
			self.navigationItem.rightBarButtonItem = btnEmail;
			[btnEmail release];
		}
	}
	
	if( transaction && isEditing ) {
		transClient = [transaction.client retain];
		transCertificates = [[NSMutableArray alloc] initWithArray:transaction.giftCertificates];
		transPayments = [[NSMutableArray alloc] initWithArray:transaction.payments];
		transProducts = [[NSMutableArray alloc] initWithArray:transaction.products];
		transServices = [[NSMutableArray alloc] initWithArray:transaction.services];
	}
	//
	ccPaymentsToRemove = [[NSMutableArray alloc] init];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	isDismissing = NO;
	//
    self.isFirstTime = YES;
    
    isSelectedBoth = NO;
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !isDismissing ) {
		if( transaction == nil ) {
			transaction = [[Transaction alloc] init];
			transaction.isHydrated = YES;
			[tblTransaction setEditing:YES animated:NO];
		} else if( transaction.transactionID < 0 ) {
			[tblTransaction setEditing:YES animated:NO];
		} else {
			[transaction hydrate];
		}
		if( isEditing ) {
			[tblTransaction setEditing:YES animated:NO];
		}
		[tblTransaction reloadData];
	}
    
    if (self.isFirstTime == YES) {
        self.isFirstTime = NO;
        transaction.client = [[Client alloc] initWithID:0 personID:-1 isActive:YES];
    }
    
    isEmailSet = NO;
    self.activityView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tblTransaction = nil;
	//
	[transClient release];
	[transCertificates release];
	[transPayments release];
	[transProducts release];
	[transServices release];
	//
	[ccPaymentsToRemove release];
	//
	[formatter release];
	//
	[transaction release];
	//
    [chargeCell release];
    [_activityView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Control Methods
#pragma mark -
/*
 *
 */
- (IBAction) btnVoidPressed:(id)sender {
	
	if( [self checkForCreditPayments] ) {
		refundingMethodCall = 99;
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This transaction contains processed credit card payments! They must be refunded before the transaction can be voided!\n\nRefunding is not reversible!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Refund" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
	} else {
		// Void
		[[PSADataManager sharedInstance] voidTransaction:transaction];
		//
		/*
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
		 */
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
}

- (void) cancelEdit {
	

        //if(!transClient)
           // transClient = [[Client alloc] initWithID:0 personID:-1 isActive:YES];
        
        transaction.client = transClient;
		transaction.giftCertificates = transCertificates;
		transaction.payments = transPayments;
		transaction.products = transProducts;
		transaction.services = transServices;
		
		// The modal view is contained in a Nav Controller (self.parentViewController)
		// which was presented by the topViewController or selectedViewController (RegisterVC or TransactionVC) of the modal's parent (another Nav Controller or Tab Controller).
		// Drill down to this VC and dismiss the editing modal and any views on top of that.
		if( [self.parentViewController isKindOfClass:[UINavigationController class]] ) {
            if (self.parentViewController.parentViewController == nil) {
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                //[self.parent cancelEdit];
                return;
            }
             
			if( [self.parentViewController.parentViewController isKindOfClass:[UINavigationController class]] ) {
				[((UINavigationController*)((UINavigationController*)self.parentViewController).parentViewController).topViewController dismissViewControllerAnimated:YES completion:nil];
			} else if( [self.parentViewController.parentViewController isKindOfClass:[UITabBarController class]] ) {
				[((UITabBarController*)((UINavigationController*)self.parentViewController).parentViewController).selectedViewController dismissViewControllerAnimated:YES completion:nil];
			} else {
				// Do something here?
			}
		}
}

- (void) removeThisView {

	// If this TransVC is the only controller (it is probably modal)
	if( self.navigationController.viewControllers.count == 1 ) {

		UINavigationController *ourNav = self.navigationController;
		if( [ourNav.parentViewController isKindOfClass:[UINavigationController class]] ) {
			// If the topViewController of the NavigationController that contains our NavigationController as a modal...
			if( ((UINavigationController*)ourNav.parentViewController).topViewController.presentedViewController == ourNav ) {
				isDismissing = YES;
				UINavigationController *selectedNav = (UINavigationController*)ourNav.parentViewController;
				[selectedNav.topViewController dismissViewControllerAnimated:YES completion:nil];
				// Change edit button to email button
				if( [selectedNav.topViewController isKindOfClass:[TransactionViewController class]] ) {
					if( transaction.dateClosed ) {
						UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:selectedNav.topViewController action:@selector(emailReceipt)];
						selectedNav.topViewController.navigationItem.rightBarButtonItem = btnEmail;
						[btnEmail release];
					}
				}
			}
		} else if( [ourNav.parentViewController isKindOfClass:[UITabBarController class]] ) {
			// If the selectedViewController of the TabBarController that contains our NavigationController as a modal...
			if( ((UITabBarController*)ourNav.parentViewController).selectedViewController.presentedViewController == ourNav ) {
				isDismissing = YES;
				UINavigationController *selectedNav = (UINavigationController*)((UITabBarController*)ourNav.parentViewController).selectedViewController;
				[selectedNav dismissViewControllerAnimated:YES completion:nil];
				// Change edit button to email button
				if( [selectedNav.topViewController isKindOfClass:[TransactionViewController class]] ) {
					if( transaction.dateClosed ) {
						UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:selectedNav.topViewController action:@selector(emailReceipt)];
						selectedNav.topViewController.navigationItem.rightBarButtonItem = btnEmail;
						[btnEmail release];
					}
				}
			}
		} else {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self cancelEdit];
        }
		
	} else {
		[tblTransaction setEditing:NO animated:NO];
		[tblTransaction reloadData];
		if( transaction.dateClosed == nil ) {
			// Edit Button
			UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(save)];
			self.navigationItem.rightBarButtonItem = btnEdit;
			[btnEdit release];
		} else {
			// Email Receipt Button
			UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReceipt)];
			self.navigationItem.rightBarButtonItem = btnEmail;
			[btnEmail release];
		}
		[self dismissViewControllerAnimated:YES completion:nil];
	}
    
    //[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] swapClientTabWithNavigation];
}

/*
 *
 */
- (void) save {
	if( tblTransaction.editing ) {
		if( !transaction.client ) {
			// Alert
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Client" message:@"Must select a Client before saving this transaction!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];	
			[alert release];
		} else if( transaction.products.count == 0 && transaction.services.count == 0 && transaction.giftCertificates.count == 0 ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Item" message:@"Must add a Gift Certificate, Product, or Service before saving this transaction!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];	
			[alert release];
		} else {
			
			// Check for missing payments to remove.
			if( ![transaction.payments isEqualToArray:transPayments] ) {
				for( TransactionPayment *tmp in transPayments ) {
					if( ![transaction.payments containsObject:tmp] ) {
						if( tmp.transactionPaymentID > -1 ) {
							[[PSADataManager sharedInstance] removeTransactionPayment:tmp];
							if( tmp.paymentType == PSATransactionPaymentGiftCertificate && tmp.amountOriginal ) {
								if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] > 0.0 ) {
									NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amountOriginal doubleValue]-[tmp.amount doubleValue]];
									[[PSADataManager sharedInstance] refundAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
									[num release];
									tmp.amountOriginal = nil;
								}
							}
						}
					}
				}
			}
			// Check for missing products to remove.
			if( ![transaction.products isEqualToArray:transProducts] ) {
				for( TransactionItem *tmp in transProducts ) {
					if( ![transaction.products containsObject:tmp] ) {
						if( tmp.productAdjustment.productAdjustmentID > -1 ) {
							[[PSADataManager sharedInstance] removeProductAdjustmentWithID:tmp.productAdjustment.productAdjustmentID];
						}
						if( tmp.transactionItemID > -1 ) {
							[[PSADataManager sharedInstance] removeTransactionItem:tmp];
						}
					}
				}
			}
			// Check for missing services to remove.
			if( ![transaction.services isEqualToArray:transServices] ) {
				for( TransactionItem *tmp in transServices ) {
					if( ![transaction.services containsObject:tmp] ) {
						if( tmp.transactionItemID > -1 ) {
							[[PSADataManager sharedInstance] removeTransactionItem:tmp];
						}
					}
				}
			}
			// Check for missing certificates to remove.
			if( ![transaction.giftCertificates isEqualToArray:transCertificates] ) {
				for( TransactionItem *tmp in transCertificates ) {
					if( ![transaction.giftCertificates containsObject:tmp] ) {
						if( tmp.transactionItemID > -1 ) {
							[[PSADataManager sharedInstance]  removeTransactionItem:tmp];
							[[PSADataManager sharedInstance] removeGiftCertificate:(GiftCertificate*)tmp.item];
						}
					}
				}
			}

			BOOL isClosed = NO;
			[[PSADataManager sharedInstance] saveTransaction:transaction];
			if( transaction.dateClosed ) {
				isClosed = YES;
			}
			
			if( isClosed ) {
                /*UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Transaction successful! Do you want to send a receipt?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alertView.tag = 1011;
                [alertView show];
                [alertView release];*/
                //[self submitForm];
				// Action sheet
				UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Do you want to send a receipt?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Text", @"Both", nil];
                alert.tag = 100;
				[alert showInView:self.view];	
				[alert release];
                /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Please input email address."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Ok", nil];*/
                
                
                
                
                
                //alertText.delegate=txtAPILogin.delegate;
                //alert.tag=100;
                
                //[alert show];
			} else {
				[self removeThisView];
			}
			
		}
	} else {
		// Show Edit view
		TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
		cont.isEditing = YES;
		cont.transaction = transaction;
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
		//nav.navigationBar.tintColor = [UIColor blackColor];
		[cont release];
		[self presentViewController:nav animated:YES completion:nil];
		[nav release];
	}
}

- (void) progressTask
{
    [progress show:YES];
    //if(isEmail){
    Company *company = [[PSADataManager sharedInstance] getCompany];
    NSString *email = [transaction.client getEmailAddressHome];
    if( email == nil ) {
        email = [transaction.client getEmailAddressWork];
        if( email == nil ) {
            email = [transaction.client getEmailAddressAny];
        }
    }
    
    if (!email) {
        [self.progress hide:YES];
        return;
    }
    
    NSString *phone = [transaction.client getPhoneCell];
    if(phone.length<1)
    {
        phone = [transaction.client getPhoneHome];
        if(phone.length<1) {
            phone = [transaction.client getPhoneWork];
        }
    }
    NSString *tid = [NSString stringWithFormat:@"%ld", (long)transaction.transactionID];
    NSDictionary * dict = nil;
    dict = @{
             @"tid" : tid
             , @"em" : email
             , @"sms" : phone
             };
    self.dal = [[ServiceDAL alloc] initWiThPostData:dict urlString:URL_SEND_RECEIPT delegate:self];
    [self.dal startAsync];
    
}

- (void) handleServiceResponseErrorMessage:(NSString *)error
{
    [self.progress hide:YES];
    
    if (error != nil && ![error isEqualToString:@""])
    {
    }
}

- (void) handleServiceResponseWithDict:(NSDictionary *)dictionary
{
    [self.progress hide:YES];
    [self removeThisView];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100){
        if(buttonIndex == 1){
            strEmail = [[alertView textFieldAtIndex:0] text];
            if(strEmail.length>1)
            {
                isEmailSet = YES;
                [self autoEmailReceipt];
            }
        }
    }
    if(alertView.tag == 1011)
    {
        if(buttonIndex == 1){
            [self submitForm];
        }
        else{
            //isSelectedBoth = YES;
            [self removeThisView];
        }
    }
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (BOOL) checkForCreditPayments {
	for( TransactionPayment *tmp in transaction.payments ) {
		if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) checkForNewCreditPayments {
	for( TransactionPayment *tmp in transaction.payments ) {
		if( tmp.transactionPaymentID == -1 && tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			return YES;
		}
	}
	return NO;
}

/*
 *	MUST release this when done!
 */
- (TransactionItem*) createNewTransactionItemWithItem:(NSObject*)theItem {
	TransactionItem	*transactionItem = [[TransactionItem alloc] init];
	transactionItem.item = theItem;
	return transactionItem;
}

- (void) autoEmailReceipt:(int)nIndex {
    
    PSAReminderViewController *cont = [[PSAReminderViewController alloc] initWithNibName:@"PSAReminderViewController" bundle:nil];
        // Company Info
        Company *company = [[PSADataManager sharedInstance] getCompany];
        // Set up the recipients
        NSString *email = [transaction.client getEmailAddressHome];
        if( email == nil ) {
            email = [transaction.client getEmailAddressWork];
            if( email == nil ) {
                email = [transaction.client getEmailAddressAny];
            }
        }
        // Subject
        //[[PSADataManager sharedInstance] getBussinessItem];
        //NSString *strBusiness = [[PSADataManager sharedInstance] getBussinessItem].businessName;
        NSString *subject = [[NSString alloc] initWithFormat:@"Receipt %@ %@", (company.companyName) ? @"From" : @"", (company.companyName) ? company.companyName : @""];
        
        //NSString *subject = [[NSString alloc] initWithFormat:@"Receipt #%ld %@ %@", (long)transaction.transactionID, (company.companyName) ? @"From" : @"", (company.companyName) ? company.companyName : @""];
        // HTML message
        NSString *clientInfo = [transaction.client getMutlilineHTMLStringForReceipt];
        NSString *companyInfo = [company getMutlilineHTMLString];
        // Static Top
        NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@%@%@%ld%@%@%@%@%@",
                                    @"<html> <head> <style TYPE=\"text/css\"> BODY, TD { font-family: Helvetica, Verdana, Arial, Geneva; font-size: 12px; } .total { color: #333333; } </style> </head> <body> <table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\"><font size=\"5\"><b>",
                                    (company.companyName) ? company.companyName : @"",
                                    @"</b></font> <br/>",
                                    (companyInfo) ? companyInfo : @"",
                                    @"</td> <td align=\"right\" valign=\"top\"> <font size=\"5\" color=\"#6b6b6b\"><b>",
                                    @"Receipt</b></font> <br/> Transaction: ",
                                    (long)transaction.transactionID,
                                    @"<br/>",
                                    [[PSADataManager sharedInstance] getStringForAppointmentDate:transaction.dateClosed],
                                    @"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\" width=\"120\"> <font size=\"3\" color=\"#6b6b6b\"><b>Customer</b></font> </td> <td valign=\"top\">",
                                    (clientInfo) ? clientInfo : @"",
                                    @"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Purchases & Services</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"76\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Item No.</b> </td> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Price</b> </td> <td width=\"30\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Qty.</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"
                                    ];
        
        // Add row for each TransactionItem
        for( TransactionItem *item in transaction.services ) {
            NSString *itemID = nil;
            NSString *itemDescription = nil;
            NSInteger quantity = 1;
            
            Service *serv = (Service*)item.item;
            itemID = [[NSString alloc] initWithFormat:@"%ld", (long)serv.serviceID];
            itemDescription = [[NSString alloc] initWithString:serv.serviceName];
            
            [message appendFormat:@"%@%@%@%@%@%@%@%@%ld%@%@%@%@%@",
             @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             itemID,
             @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             itemDescription,
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             [formatter stringFromNumber:item.itemPrice],
             ([item.setupFee doubleValue] > 0.0) ? [NSString stringWithFormat:@"<br/>Setup: %@", [formatter stringFromNumber:item.setupFee]] : @"",
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             (long)quantity,
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             [formatter stringFromNumber:[item getDiscountAmount]],
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
             [formatter stringFromNumber:[item getSubTotal]],
             @"</td></tr>"
             ];
            
            [itemID release];
            [itemDescription release];
        }
        
        for( TransactionItem *item in transaction.products ) {
            NSString *itemDescription = nil;
            NSInteger quantity = 1;
            
            Product *prod = (Product*)item.item;
            itemDescription = [[NSString alloc] initWithString:prod.productName];
            if( item.productAdjustment ) {
                quantity = ((ProductAdjustment*)item.productAdjustment).quantity;
            }
            [message appendFormat:@"%@%@%@%@%@%@%@%ld%@%@%@%@%@",
             @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             prod.productNumber,
             @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             itemDescription,
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             [formatter stringFromNumber:item.itemPrice],
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             (long)quantity,
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             [formatter stringFromNumber:[item getDiscountAmount]],
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
             [formatter stringFromNumber:[item getSubTotal]],
             @"</td></tr>"
             ];
            
            [itemDescription release];
        }
        
        for( TransactionItem *item in transaction.giftCertificates ) {
            NSString *itemID = nil;
            NSString *itemDescription = nil;
            NSInteger quantity = 1;
            
            GiftCertificate *cert = (GiftCertificate*)item.item;
            itemID = [[NSString alloc] initWithFormat:@"%ld", (long)cert.certificateID];
            if( cert.recipientLast && cert.recipientFirst ) {
                itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@ %@", cert.recipientFirst, cert.recipientLast];
            } else if( cert.recipientLast ) {
                itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@", cert.recipientLast];
            } else if( cert.recipientFirst ) {
                itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@", cert.recipientFirst];
            } else {
                itemDescription = [[NSString alloc] initWithString:@"Gift Certificate"];
            }
            
            [message appendFormat:@"%@%@%@%@%@%@%@%ld%@%@%@%@%@",
             @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             itemID,
             @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             itemDescription,
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             [formatter stringFromNumber:item.itemPrice],
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             (long)quantity,
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
             [formatter stringFromNumber:[item getDiscountAmount]],
             @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
             [formatter stringFromNumber:[item getSubTotal]],
             @"</td></tr>"
             ];
            
            [itemID release];
            [itemDescription release];
        }
        
        // Static middle
        [message appendFormat:@"%@%@ %@%@ %@%@ %@%@ %@%@ %@",
         @"<tr align=\"right\" class=\"total\"> <td colspan=\"4\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Discount Total</b></font> </td> <td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\"> <b>",
         [formatter stringFromNumber:[transaction getDiscounts]], // Discount Total
         @"</b> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> &nbsp; </td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Tip</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\">",
         [formatter stringFromNumber:[transaction tip]], // Tip
         @"</td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sub-Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
         [formatter stringFromNumber:[transaction getSubTotal]], // Sub-Total
         @"</b> </td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
         [formatter stringFromNumber:[transaction getTax]], // Tax
         @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Total Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
         [formatter stringFromNumber:[transaction getTotal]], // Total Balance
         @"</b> </td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr><tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Payments</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td style=\"border-bottom:solid 1px #cccccc;\"> <b>Payment Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Amount</b> </td> </tr>"];
        
        // Add row for each TransactionPayment
        for( TransactionPayment *payment in transaction.payments ) {
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
                    paymentDescription = [[NSString alloc] initWithFormat:@"Gift Certificate %ld", (long)cert.certificateID];
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
        
        // Semi-Static bottom
        [message appendFormat:@"%@%@%@%@%@",
         @"<tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Payment Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
         [formatter stringFromNumber:[transaction getAmountPaid]], // Total Payments
         @"</b> </td> </tr> <tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Change</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
         [formatter stringFromNumber:[transaction getChangeDue]], // Change
         @"</b> </td> </tr> </table> </td> </tr></table> </body> </html>"];
    
    NSString *strPhone = [transaction.client getPhoneCell];
    if(strPhone.length<1)
    {
        strPhone = [transaction.client getPhoneHome];
        if(strPhone.length<1) {
            strPhone = [transaction.client getPhoneWork];
        }
    }
    
    cont.strEmailTo = email;
    cont.strEmailContent = message;
    cont.strEmailSubject = subject;
    cont.strTextTo = strPhone;
    cont.isEmail = nIndex;
    [self.navigationController pushViewController:cont animated:YES];
    [cont release];

        [message release];
        [clientInfo release];
        [company release];
        // Present the mail composition interface. 

}

- (void) emailReceipt {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Set up the recipients
		NSString *email = [transaction.client getEmailAddressHome];
		if( email == nil ) {
			email = [transaction.client getEmailAddressWork];
			if( email == nil ) {
				email = [transaction.client getEmailAddressAny];
			}
		}
        
        if(isEmailSet == YES)
        {
            email = strEmail;
            isEmailSet = NO;
        }
        
		NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
		//[email release];
		[picker setToRecipients:toRecipients];
		// BCC to self
		if( company.companyEmail ) {
			NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setBccRecipients:bccRecipients];
		}
		// Subject
        //[[PSADataManager sharedInstance] getBussinessItem];
        //NSString *strBusiness = [[PSADataManager sharedInstance] getBussinessItem].businessName;
		NSString *subject = [[NSString alloc] initWithFormat:@"Receipt %@ %@", (company.companyName) ? @"From" : @"", (company.companyName) ? company.companyName : @""];
        
        //NSString *subject = [[NSString alloc] initWithFormat:@"Receipt #%ld %@ %@", (long)transaction.transactionID, (company.companyName) ? @"From" : @"", (company.companyName) ? company.companyName : @""];
		[picker setSubject:subject];
		[subject release];
		// HTML message
		NSString *clientInfo = [transaction.client getMutlilineHTMLStringForReceipt];
		NSString *companyInfo = [company getMutlilineHTMLString];
		// Static Top
		NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@%@%@%ld%@%@%@%@%@", 
									@"<html> <head> <style TYPE=\"text/css\"> BODY, TD { font-family: Helvetica, Verdana, Arial, Geneva; font-size: 12px; } .total { color: #333333; } </style> </head> <body> <table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\"><font size=\"5\"><b>",
									(company.companyName) ? company.companyName : @"",
									@"</b></font> <br/>", 
									(companyInfo) ? companyInfo : @"", 
									@"</td> <td align=\"right\" valign=\"top\"> <font size=\"5\" color=\"#6b6b6b\"><b>",
									@"Receipt</b></font> <br/> Transaction: ",
									(long)transaction.transactionID, 
									@"<br/>", 
									[[PSADataManager sharedInstance] getStringForAppointmentDate:transaction.dateClosed], 
									@"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\" width=\"120\"> <font size=\"3\" color=\"#6b6b6b\"><b>Customer</b></font> </td> <td valign=\"top\">", 
									(clientInfo) ? clientInfo : @"",
									@"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Purchases & Services</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"76\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Item No.</b> </td> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Price</b> </td> <td width=\"30\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Qty.</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"
									];
		
		// Add row for each TransactionItem
		for( TransactionItem *item in transaction.services ) {
			NSString *itemID = nil;
			NSString *itemDescription = nil;
			NSInteger quantity = 1;
			
			Service *serv = (Service*)item.item;
			itemID = [[NSString alloc] initWithFormat:@"%ld", (long)serv.serviceID];
			itemDescription = [[NSString alloc] initWithString:serv.serviceName];
			
			[message appendFormat:@"%@%@%@%@%@%@%@%@%ld%@%@%@%@%@",
			 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 itemID,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 itemDescription,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:item.itemPrice],
			 ([item.setupFee doubleValue] > 0.0) ? [NSString stringWithFormat:@"<br/>Setup: %@", [formatter stringFromNumber:item.setupFee]] : @"",
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 (long)quantity,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:[item getDiscountAmount]],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
			 [formatter stringFromNumber:[item getSubTotal]],
			 @"</td></tr>"
			 ];
			
			[itemID release];
			[itemDescription release];
		}
		
		for( TransactionItem *item in transaction.products ) {
			NSString *itemDescription = nil;
			NSInteger quantity = 1;
			
			Product *prod = (Product*)item.item;
			itemDescription = [[NSString alloc] initWithString:prod.productName];
			if( item.productAdjustment ) {
				quantity = ((ProductAdjustment*)item.productAdjustment).quantity;
			}
			[message appendFormat:@"%@%@%@%@%@%@%@%ld%@%@%@%@%@",
			 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 prod.productNumber,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 itemDescription,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:item.itemPrice],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 (long)quantity,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:[item getDiscountAmount]],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
			 [formatter stringFromNumber:[item getSubTotal]],
			 @"</td></tr>"
			 ];
			
			[itemDescription release];
		}
		
		for( TransactionItem *item in transaction.giftCertificates ) {
			NSString *itemID = nil;
			NSString *itemDescription = nil;
			NSInteger quantity = 1;
			
			GiftCertificate *cert = (GiftCertificate*)item.item;
			itemID = [[NSString alloc] initWithFormat:@"%ld", (long)cert.certificateID];
			if( cert.recipientLast && cert.recipientFirst ) {
				itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@ %@", cert.recipientFirst, cert.recipientLast];
			} else if( cert.recipientLast ) {
				itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@", cert.recipientLast];
			} else if( cert.recipientFirst ) {
				itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@", cert.recipientFirst];
			} else {
				itemDescription = [[NSString alloc] initWithString:@"Gift Certificate"];
			}
			
			[message appendFormat:@"%@%@%@%@%@%@%@%ld%@%@%@%@%@",
			 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 itemID,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 itemDescription,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:item.itemPrice],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 (long)quantity,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:[item getDiscountAmount]],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
			 [formatter stringFromNumber:[item getSubTotal]],
			 @"</td></tr>"
			 ];
			
			[itemID release];
			[itemDescription release];
		}
		
		// Static middle
		[message appendFormat:@"%@%@ %@%@ %@%@ %@%@ %@%@ %@", 
		 @"<tr align=\"right\" class=\"total\"> <td colspan=\"4\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Discount Total</b></font> </td> <td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\"> <b>",
		 [formatter stringFromNumber:[transaction getDiscounts]], // Discount Total
		 @"</b> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> &nbsp; </td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Tip</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[transaction tip]], // Tip
		 @"</td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sub-Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
		 [formatter stringFromNumber:[transaction getSubTotal]], // Sub-Total
		 @"</b> </td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
		 [formatter stringFromNumber:[transaction getTax]], // Tax
		 @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Total Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
		 [formatter stringFromNumber:[transaction getTotal]], // Total Balance
		 @"</b> </td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr><tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Payments</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td style=\"border-bottom:solid 1px #cccccc;\"> <b>Payment Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Amount</b> </td> </tr>"];
		
		// Add row for each TransactionPayment
		for( TransactionPayment *payment in transaction.payments ) {
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
					paymentDescription = [[NSString alloc] initWithFormat:@"Gift Certificate %ld", (long)cert.certificateID];
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
		
		// Semi-Static bottom
		[message appendFormat:@"%@%@%@%@%@",
		 @"<tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Payment Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
		 [formatter stringFromNumber:[transaction getAmountPaid]], // Total Payments
		 @"</b> </td> </tr> <tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Change</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
		 [formatter stringFromNumber:[transaction getChangeDue]], // Change
		 @"</b> </td> </tr> </table> </td> </tr></table> </body> </html>"];
		
		[picker setMessageBody:message isHTML:YES];
		[message release];
		[clientInfo release];
		[company release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil];
		//[picker release];
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Receipt!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}

- (void) smsReceipt {
    // Open sms
    
    
    if( [MFMessageComposeViewController canSendText] ) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.body = @"sms body";
        
        picker.messageComposeDelegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

- (void) refundAllCreditPayments {
	for( TransactionPayment *tmp in transaction.payments ) {
		if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			[ccPaymentsToRemove addObject:tmp];
		}
	}
	[self refundCreditPayment];
}

- (void) refundAllNewCreditPayments {
	for( TransactionPayment *tmp in transaction.payments ) {
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
		[cont.view setBackgroundColor:tblTransaction.backgroundColor];
		cont.title = @"Refunding Credit";
		[cont cancelVoidRefund:self];
		[cont release];
		
	} else {
		
		// If last method was void or cancel... do that
		if( refundingMethodCall == 99 ) {
			[self btnVoidPressed:nil];
		} else if( refundingMethodCall == 98 ) {
			[self cancelEdit];
		} else if( refundingMethodCall == 97 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
	
}

#pragma mark -
#pragma mark Custom Delegate Methods
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
		}
		
		// Subtract payment's tip from transaction's tip
		NSNumber *newTip = [[NSNumber alloc] initWithDouble:[transaction.tip doubleValue]-[thePayment.creditCardPayment.tip doubleValue]];
		transaction.tip = newTip;
		[newTip release];
		// Save only the tip to the DB...
		[[PSADataManager sharedInstance] saveTransactionTip:transaction];
		
		// Remove from the editing array, and the transaction itself so it is never put back...
		[transaction.payments removeObject:thePayment];
		[transPayments removeObject:thePayment];
		//
		[thePayment dehydrateCreditCardPayment];
		// Continue if there are more...
		[self refundCreditPayment];
	}
}

/*
 *
 */
- (void) completedMoneyEntry:(NSString*)value title:(NSString*)title {
	NSNumberFormatter *formatter2 = [[NSNumberFormatter alloc] init];
	NSNumber *num = nil;
	if( [value hasPrefix:@" "] ) {
		num = [formatter2 numberFromString:[value substringFromIndex:1]];
	} else {
		num = [formatter2 numberFromString:value];
	}
	transaction.tip = num;
	[formatter2 release];
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 *
 */
- (void) completedNewGiftCertificate:(GiftCertificate*)theCert {
	TransactionItem *tmp = [self createNewTransactionItemWithItem:theCert];
	tmp.itemType = PSATransactionItemGiftCertificate;
	tmp.itemPrice = theCert.amountPurchased;
	[transaction.giftCertificates addObject:tmp];
	[tmp release];
	[self dismissViewControllerAnimated:YES completion:nil];
}

/*
 *
 */
- (void) completedNewPayment:(TransactionPayment*)thePayment {
	// Payments are modal when new
	if( self.presentedViewController != nil ) {
		if( thePayment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			NSNumber *tipT = [[NSNumber alloc] initWithDouble:[thePayment.creditCardPayment.tip doubleValue]+[transaction.tip doubleValue]];
			transaction.tip = tipT;
			[tipT release];
		}
		// New payments get added to the transaction
		[transaction.payments addObject:thePayment];
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		// Existing payments are not modal, as such should already exist in the payments array
		[self.navigationController popViewControllerAnimated:YES];
	}

	[self.navigationController.parentViewController viewWillAppear:YES];
}

/*
 *
 */
- (void) delegateShouldPop {
	if( self.navigationController.viewControllers.count == 2 ) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		// This is kind of hacky, but I want to go back 2 view controllers
		[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3] animated:YES];
	}
}

/*
 *	Remove the payment from the transaction!
 */
- (void) refundedCreditPayment:(TransactionPayment*)thePayment {
	
	if( thePayment.transactionPaymentID > -1 ) {
		// Remove transactionPayment from database...
		[[PSADataManager sharedInstance] removeTransactionPayment:thePayment];
	}
	
	// Subtract payment's tip from transaction's tip
	NSNumber *newTip = [[NSNumber alloc] initWithDouble:[transaction.tip doubleValue]-[thePayment.creditCardPayment.tip doubleValue]];
	transaction.tip = newTip;
	[newTip release];
	// Save only the tip to the DB...
	[[PSADataManager sharedInstance] saveTransactionTip:transaction];
	
	// Remove from the editing array, and the transaction itself so it is never put back...
	[transaction.payments removeObject:thePayment];
	[transPayments removeObject:thePayment];
}

/*
 *	Save the returned Client in our Transaction
 */
- (void) selectionMadeWithClient:(Client*)theClient {
	transaction.client = theClient;
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 *	Save the returned Product in our Transaction
 */
- (void) selectionMadeWithProduct:(Product*)theProduct {
	// Look for a duplicate
	BOOL exists = NO;
	for( TransactionItem *tmp in transaction.products ) {
		if( ((Product*)tmp.item).productID == theProduct.productID ) {
			exists = YES;
		}
	}
	// Alert that no duplicate products should be added, or add it
	if( exists ) {
		// Alert
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Product" message:@"This product already exists in your transaction!\n\nPlease alter the quantity by tapping on the product on the Transaction view, instead of adding it multiple times." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		// Add
		TransactionItem *tmp = [self createNewTransactionItemWithItem:theProduct];
		tmp.itemType = PSATransactionItemProduct;
		tmp.itemPrice = theProduct.productPrice;
		tmp.taxed = theProduct.productTaxable;
		tmp.cost = theProduct.productCost;

		// Show the detail view... curl animation
		[self.presentedViewController.view setUserInteractionEnabled:NO];
		// Adjustment View
		TransactionAdjustmentViewController *cont = [[TransactionAdjustmentViewController alloc] initWithNibName:@"TransactionAdjustmentQuantityView" bundle:nil];
		cont.transactionItem = tmp;
		cont.transaction = transaction;
		[tmp release];
		// Animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.75];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.presentedViewController.view cache:YES];
		NSArray *controllers = [NSArray arrayWithObject:cont];
		if( [self.presentedViewController isKindOfClass:[UINavigationController class]] ) {
			[(UINavigationController*)self.presentedViewController setViewControllers:controllers animated:NO];
		}
		[UIView commitAnimations];
		// Cancel
		UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
		cont.navigationItem.leftBarButtonItem = cancel;
		[cancel release];
		// Resume
		[self.presentedViewController.view setUserInteractionEnabled:YES];
		[cont release];
	}
	// TODO: NEED THIS?!?
	//[self.navigationController popViewControllerAnimated:YES];
}

/*
 *	Save the returned Service in our Transaction
 */
- (void) selectionMadeWithService:(Service*)theService {
	TransactionItem *tmp = [self createNewTransactionItemWithItem:theService];
	tmp.itemType = PSATransactionItemService;
	tmp.itemPrice = theService.servicePrice;
	tmp.taxed = theService.taxable;
	tmp.cost = theService.serviceCost;
	tmp.setupFee = theService.serviceSetupFee;
    if(!theService.serviceIsFlatRate)
    {
        NSInteger tmpPrice = [theService.servicePrice integerValue] * theService.duration / 3600;
        tmp.itemPrice = [NSNumber numberWithInteger:tmpPrice];
    }
	
	// Show the detail view... curl animation
	[self.presentedViewController.view setUserInteractionEnabled:NO];
	// Adjustment View
	TransactionAdjustmentViewController *cont = [[TransactionAdjustmentViewController alloc] initWithNibName:@"TransactionAdjustmentView" bundle:nil];
	cont.transactionItem = tmp;
	cont.transaction = transaction;
	[tmp release];
	// Animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.presentedViewController.view cache:YES];
	NSArray *controllers = [NSArray arrayWithObject:cont];
	if( [self.presentedViewController isKindOfClass:[UINavigationController class]] ) {
		[(UINavigationController*)self.presentedViewController setViewControllers:controllers animated:NO];
	}
	[UIView commitAnimations];
	// Cancel
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	// Resume
	[self.presentedViewController.view setUserInteractionEnabled:YES];
	[cont release];
}

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	//
    [self removeThisView];
    
    if(isSelectedBoth)
    {
        [self smsReceipt];
        isSelectedBoth = NO;
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self removeThisView];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -
/*
 *	Receives notification of which button was pressed on the alert view.
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( [actionSheet.title hasPrefix:@"This transaction contains processed"] ) {
		if( buttonIndex == 0 ) {
			[self refundAllCreditPayments];
		}
	} else if( [actionSheet.title hasPrefix:@"This transaction contains new credit"] ) {
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
	} else {
		if( buttonIndex == 3 ) {
            [self removeThisView];
            return;
        }
        else {
            [self autoEmailReceipt:buttonIndex];
            
		}
	}
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 9;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( tblTransaction.editing ) {
		if( section == 0 ) {
			if( transaction.projectID > -1 )	return 0;
			else								return 1;
		}
		else if( section == 1 )	return transaction.services.count+1;
		else if( section == 2 )	return 1;
		else if( section == 3 )	return transaction.products.count+1;
		else if( section == 4 )	return transaction.giftCertificates.count+1;
		else if( section == 5 )	return 3;
		else if( section == 6 )	return transaction.payments.count+1;
		else if( section == 7 )	return 2;
		else if( section == 8 )	return 1;
	} else {
		if( section == 0 ) {
			if( transaction.projectID > -1 )	return 2;
			else								return 1;
		}
		else if( section == 1 )	return (transaction.services.count == 0) ? 1 : transaction.services.count;
		else if( section == 2 )	return 1;
		else if( section == 3 )	return (transaction.products.count == 0) ? 1 : transaction.products.count;
		else if( section == 4 )	return (transaction.giftCertificates.count == 0) ? 1 : transaction.giftCertificates.count;
		else if( section == 5 )	return 3;
		else if( section == 6 )	return (transaction.payments.count == 0) ? 1 : transaction.payments.count;
		else if( section == 7 )	return 2;
        //else if( section == 8 ) return 1;
        else if( section == 8 )	return (transaction.dateVoided) ? 0 : 1;
	}
	return 1;
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

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
	if( indexPath.section == 8 ) {
        if(!tblTransaction.editing)
            identifier = @"TransactionVoidCell";
        else
            identifier = @"TransactionChargeCell";
	} else if( indexPath.section == 1 || indexPath.section == 3 ) {
		if( tblTransaction.editing ) {
			identifier = @"TransactionItemEditCell";
		} else {
			identifier = @"TransactionItemCell";
		}
	} else if( indexPath.section == 4 || indexPath.section == 6 ) {
		if( tblTransaction.editing ) {
			identifier = @"TransactionPaymentEditCell";
		} else {
			identifier = @"TransactionPaymentCell";
		}
	} else {
		identifier = @"TransactionCell";
	}
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if( cell == nil ) {
		if( indexPath.section == 8 ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
            if(tblTransaction.editing)
            {
                cell = chargeCell;
                chargeCell = nil;
            }
            else {
                cell = voidCell;
                self.voidCell = nil;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.editingAccessoryType = UITableViewCellAccessoryNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            //cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
            
		} else if( indexPath.section == 1 || indexPath.section == 3 ) {
			if( tblTransaction.editing ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = cellItemEdit;
				self.cellItemEdit = nil;
			} else {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = cellItem;
				self.cellItem = nil;
			}
		} else if( indexPath.section == 4 || indexPath.section == 6 ) {
			if( tblTransaction.editing ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = cellPaymentEdit;
				self.cellPaymentEdit = nil;
			} else {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = cellPayment;
				self.cellPayment = nil;
			}
		} else {
            if(indexPath.section==8)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
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
    }
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch ( indexPath.section ) {
        case 8:
        {
           cell.editingAccessoryType = UITableViewCellAccessoryNone;
        }
            break;
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Client";
				if( transaction.client ) {
					cell.detailTextLabel.text = [transaction.client getClientName];
				} else {
                    transaction.client = [[Client alloc] initWithID:0 personID:-1 isActive:YES];
					cell.detailTextLabel.text = [transaction.client getClientName];
				}
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Project";
				if( transaction.projectName ) {
					cell.detailTextLabel.text = transaction.projectName;
				} else {
					cell.detailTextLabel.text = @"Deleted Project";
				}
			}
			break;
		case 1: {
			UILabel *lbName = (UILabel*)[cell viewWithTag:99];
			UILabel	*lbQty = (UILabel*)[cell viewWithTag:98];
			UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
			UILabel	*lbTitleQty = (UILabel*)[cell viewWithTag:96];
			if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 && tblTransaction.editing ) {
				lbName.text = @"Add Service";
				lbQty.hidden = YES;
				lbTotal.hidden = YES;
				lbTitleQty.hidden = YES;
				cell.editingAccessoryType = UITableViewCellAccessoryNone;
			} else {
				if( transaction.services.count == 0 ) {
					lbName.text = @"No Services";
					lbQty.hidden = YES;
					lbTotal.hidden = YES;
					lbTitleQty.hidden = YES;
				} else {
					TransactionItem *tmpService = [transaction.services objectAtIndex:indexPath.row];
					lbName.text = ((Service*)tmpService.item).serviceName;
					lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithFloat:[[tmpService getSubTotal] doubleValue]-[[tmpService getDiscountAmount] doubleValue]]];
					lbQty.hidden = YES;
					lbTotal.hidden = NO;
					lbTitleQty.hidden = YES;
				}
			}
			break;
		}
		case 2:  {
			cell.textLabel.text = @"Tip";
			if( transaction.tip ) {
				cell.detailTextLabel.text = [formatter stringFromNumber:transaction.tip];
			} else {
				cell.detailTextLabel.text = [formatter stringFromNumber:[NSNumber numberWithInt:0]];
			}
			break;
		}
		case 3: {
			UILabel *lbName = (UILabel*)[cell viewWithTag:99];
			UILabel	*lbQty = (UILabel*)[cell viewWithTag:98];
			UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
			UILabel	*lbTitleQty = (UILabel*)[cell viewWithTag:96];
			if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 && tblTransaction.editing ) {
				lbName.text = @"Add Product";
				lbQty.hidden = YES;
				lbTotal.hidden = YES;
				lbTitleQty.hidden = YES;
				cell.editingAccessoryType = UITableViewCellAccessoryNone;
			} else {
				if( transaction.products.count == 0 ) {
					lbName.text = @"No Products";
					lbQty.hidden = YES;
					lbTotal.hidden = YES;
					lbTitleQty.hidden = YES;
				} else {
					TransactionItem *tmpProduct = [transaction.products objectAtIndex:indexPath.row];
					lbName.text = ((Product*)tmpProduct.item).productName;
					NSString *qty = [[NSString alloc] initWithFormat:@"%ld", (long)tmpProduct.productAdjustment.quantity];
					lbQty.text = qty;
					[qty release];
					lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithFloat:[[tmpProduct getSubTotal] doubleValue]-[[tmpProduct getDiscountAmount] doubleValue]]];
					lbQty.hidden = NO;
					lbTotal.hidden = NO;
					lbTitleQty.hidden = NO;
				}
			}
			break;
		}
		case 4: {
			UILabel *lbName = (UILabel*)[cell viewWithTag:99];
			UILabel	*lbTotal = (UILabel*)[cell viewWithTag:98];
			if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 && tblTransaction.editing ) {
				lbName.text = @"Add Gift Certificate";
				lbTotal.hidden = YES;
				cell.editingAccessoryType = UITableViewCellAccessoryNone;
			} else {
				if( transaction.giftCertificates.count == 0 ) {
					lbName.text = @"No Certificates";
					lbTotal.hidden = YES;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
					TransactionItem *tmpCert = [transaction.giftCertificates objectAtIndex:indexPath.row];
					
					GiftCertificate *certificate = (GiftCertificate*)tmpCert.item;
					if( certificate ) {
						NSString *str = nil;
						if( certificate.recipientFirst && certificate.recipientLast ) {
							str = [[NSString alloc] initWithFormat:@"%@, %@", certificate.recipientLast, certificate.recipientFirst];
						} else if( certificate.recipientFirst ) {
							str = [[NSString alloc] initWithFormat:@"%@", certificate.recipientFirst];
						} else if( certificate.recipientLast ) {
							str = [[NSString alloc] initWithFormat:@"%@", certificate.recipientLast];
						} else {
							str = [[NSString alloc] initWithString:@"No Name"];
						}
						
						NSString *desc = [[NSString alloc] initWithFormat:@"Certificate for %@", str];
						lbName.text = desc;
						[desc release];
						[str release];
						
						lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithFloat:[[tmpCert getSubTotal] doubleValue]-[[tmpCert getDiscountAmount] doubleValue]]];
						lbTotal.hidden = NO;
					} else {
						lbName.text = @"Voided Certificate";
						lbTotal.text = @"";
						cell.accessoryType = UITableViewCellAccessoryNone;
						cell.editingAccessoryType = UITableViewCellAccessoryNone;
					}
				}
			}
			break;
		}
		case 5:
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Sub-Total";
				cell.detailTextLabel.text = [formatter stringFromNumber:[transaction getSubTotal]];
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Sales Tax";
				NSString *tmp = [[NSString alloc] initWithFormat:@"+ %@", [formatter stringFromNumber:[transaction getTax]]];
				cell.detailTextLabel.text = tmp;
				[tmp release];
			}  else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Bal. Due";
				cell.detailTextLabel.text = [formatter stringFromNumber:[transaction getTotal]];
			} 
			break;
		case 6: {
			UILabel *lbName = (UILabel*)[cell viewWithTag:99];
			UILabel	*lbTotal = (UILabel*)[cell viewWithTag:98];
			if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 && tblTransaction.editing ) {
				lbName.text = @"Add Payment";
				lbTotal.text = @"";
				cell.editingAccessoryType = UITableViewCellAccessoryNone;
			} else {
				if( transaction.payments.count == 0 ) {
					lbName.text = @"No Payments";
					lbTotal.text = @"";
				} else {
					TransactionPayment *tmpPay = [transaction.payments objectAtIndex:indexPath.row];
					lbName.text = [tmpPay stringForType:tmpPay.paymentType];
					lbTotal.text = [formatter stringFromNumber:tmpPay.amount];
				}
			}
			break;
		}
		case 7:
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Paid";
				cell.detailTextLabel.text = [formatter stringFromNumber:[transaction getAmountPaid]];
			} else if( indexPath.row == 1 ) {
				NSNumber *change = [transaction getChangeDue];
				if( [change doubleValue] < 0 ) {
					cell.textLabel.text = @"Owed";
					cell.detailTextLabel.text = [formatter stringFromNumber:[NSNumber numberWithFloat:-1*[change doubleValue]]];
				} else {
					cell.textLabel.text = @"Change";
					cell.detailTextLabel.text = [formatter stringFromNumber:change];
				}
			}
	}
	
	return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 5 || indexPath.section == 7  || indexPath.section == 8 )	return UITableViewCellEditingStyleNone;
	if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 )	return UITableViewCellEditingStyleInsert;
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 6 ) {
		if( tblTransaction.editing ) {
			return YES;
		} else {
			return NO;
		}
	}	
	return NO;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove something from the Transaction object

	switch ( indexPath.section ) {
		case 1:
			// Services
			if( editingStyle == UITableViewCellEditingStyleInsert ) {
				// Add Service
				[self tableView:tblTransaction didSelectRowAtIndexPath:indexPath];
			} else {
				TransactionItem *item = [transaction.services objectAtIndex:indexPath.row];
				if( item ) {
					[transaction.services removeObjectAtIndex:indexPath.row];
					[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
					NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] initWithIndex:5];
					[sections addIndex:7];
					[tv reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
					[sections release];
				}
			}
			break;
		case 3:
			// Products
			if( editingStyle == UITableViewCellEditingStyleInsert ) {
				// Add Product
				[self tableView:tblTransaction didSelectRowAtIndexPath:indexPath];
			} else {
				TransactionItem *item = [transaction.products objectAtIndex:indexPath.row];
				if( item ) {
					[transaction.products removeObjectAtIndex:indexPath.row];
					[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
					NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] initWithIndex:5];
					[sections addIndex:7];
					[tv reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
					[sections release];
				}
			}
			break;
		case 4:
			// Gift Certificates
			if( editingStyle == UITableViewCellEditingStyleInsert ) {
				// Add Certificate
				[self tableView:tblTransaction didSelectRowAtIndexPath:indexPath];
			} else {
				TransactionItem *item = [transaction.giftCertificates objectAtIndex:indexPath.row];
				if( item ) {
					[transaction.giftCertificates removeObjectAtIndex:indexPath.row];
					[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
					NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] initWithIndex:5];
					[sections addIndex:7];
					[tv reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
					[sections release];
				}
			}
			break;
		case 6:
			// Payment
			if( editingStyle == UITableViewCellEditingStyleInsert ) {
				// Add Payment
				[self tableView:tblTransaction didSelectRowAtIndexPath:indexPath];
			} else {
				TransactionPayment *payment = [transaction.payments objectAtIndex:indexPath.row];
				if( payment ) {
					if( payment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
						[ccPaymentsToRemove addObject:payment];
						UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This payment is from a credit card! It must be refunded before it can be removed!\n\nRefunding is not reversible!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Refund" otherButtonTitles:nil];
						[alert showInView:self.view];	
						[alert release];
					} else {
						[transaction.payments removeObjectAtIndex:indexPath.row];
						[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
						NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] initWithIndex:7];
						[tv reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
						[sections release];
					}
				}
			}
			break;
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
	if( tblTransaction.editing ) {
		switch ( indexPath.section ) {
			case 0: {
				// Changed in version 2.0... don't let the Client be editable if CC Payment.
				BOOL ccPayments = NO;
				for( TransactionPayment *tmp in transaction.payments ) {
					if( tmp.creditCardPayment ) {
						ccPayments = YES;
					}
				}
				if( ccPayments ) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Edit Client!" message:@"There are credit card payments that have been processed under this client's name. You must void or cancel the transaction if the client is incorrect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
					[alert release];
				} else {
					// Clients Table
					ClientTableViewController *cont = [[ClientTableViewController alloc] initWithNibName:@"ClientTableView" bundle:nil];
					cont.clientDelegate = self;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
				break;
			}
			case 1:
				if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 ) {
					// Services Table
					ServicesTableViewController *cont = [[ServicesTableViewController alloc] initWithNibName:@"ServicesTableView" bundle:nil];
					cont.serviceDelegate = self;
					UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelService)];
					cont.navigationItem.leftBarButtonItem = cancel;
					[cancel release];
					UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
					//nav.navigationBar.tintColor = [UIColor blackColor];
					[self presentViewController:nav animated:YES completion:nil];
					[cont release];
					[nav release];
				} else {
					// Adjustment View
					TransactionAdjustmentViewController *cont = [[TransactionAdjustmentViewController alloc] initWithNibName:@"TransactionAdjustmentView" bundle:nil];
					cont.transactionItem = [transaction.services objectAtIndex:indexPath.row];
					cont.transaction = transaction;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
				break;
			case 2: {
				TransactionMoneyEntryViewController *cont = [[TransactionMoneyEntryViewController alloc] initWithNibName:@"TransactionMoneyEntryView" bundle:nil];
				cont.delegate = self;
				cont.title = @"ADD TIP";
				NSNumberFormatter *formatter2 = [[NSNumberFormatter alloc] init];
				[formatter2 setNumberStyle:NSNumberFormatterCurrencyStyle];
				[formatter2 setCurrencySymbol:@""];
				cont.value = [formatter2 stringFromNumber:transaction.tip];
				[formatter2 release];
				[self.navigationController pushViewController:cont animated:YES];
				cont.lbBalance.hidden = NO;
                NSNumber *owed = [[NSNumber alloc] initWithDouble:([[transaction getTotal] doubleValue])];
                NSString *bal = nil;
                if( owed ) {
                    double amt = [owed doubleValue];
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
                cont.owedValue = [[NSString alloc] initWithFormat:@"%@", bal];
                
				[cont release];
				break;
			}
			case 3:
				if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 ) {
					// Products Table
					ProductsTableViewController *cont = [[ProductsTableViewController alloc] initWithNibName:@"ProductsTableView" bundle:nil];
					cont.productDelegate = self;
					UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
					cont.navigationItem.leftBarButtonItem = cancel;
					[cancel release];
					UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
					//nav.navigationBar.tintColor = [UIColor blackColor];
					[self presentViewController:nav animated:YES completion:nil];
					[cont release];
					[nav release];
				} else {
					// Adjustment View
					TransactionAdjustmentViewController *cont = [[TransactionAdjustmentViewController alloc] initWithNibName:@"TransactionAdjustmentQuantityView" bundle:nil];
					cont.transactionItem = [transaction.products objectAtIndex:indexPath.row];
					cont.transaction = transaction;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
				break;
			case 4:
				if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 ) {
					// New Gift Certificate
					GiftCertificateViewController *cont = [[GiftCertificateViewController alloc] initWithNibName:@"GiftCertificateView" bundle:nil];
					cont.delegate = self;
					cont.transaction = transaction;
					UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
					cont.navigationItem.leftBarButtonItem = cancel;
					[cancel release];
					UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
					//nav.navigationBar.tintColor = [UIColor blackColor];
					[cont.tblCertificate setEditing:YES animated:NO];
					[self presentViewController:nav animated:YES completion:nil];
					[cont release];
					[nav release];
				} else {
					// Adjustment View
					TransactionAdjustmentViewController *cont = [[TransactionAdjustmentViewController alloc] initWithNibName:@"TransactionAdjustmentView" bundle:nil];
					cont.transactionItem = [transaction.giftCertificates objectAtIndex:indexPath.row];
					cont.transaction = transaction;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
				break;
			case 6:
				if( indexPath.row == [tblTransaction numberOfRowsInSection:indexPath.section]-1 ) {
					if( transaction.client ) {
						// Add Payment
						TransactionPaymentViewController *cont = [[TransactionPaymentViewController alloc] initWithNibName:@"TransactionPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[transaction getTotal] doubleValue])];
						cont.amountOwed = owed;
						[owed release];
						cont.delegate = self;
						cont.editing = YES;
						UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
						cont.navigationItem.leftBarButtonItem = cancel;
						[cancel release];
						UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
						//nav.navigationBar.tintColor = [UIColor blackColor];
						[self presentViewController:nav animated:YES completion:nil];
						[cont release];
						[nav release];
					} else {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose Client!" message:@"Please choose a client before adding a payment!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
						[alert show];	
						[alert release];
					}
				} else {
					// Edit Payment
					TransactionPayment *tmp = [transaction.payments objectAtIndex:indexPath.row];
					if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
						CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[transaction getChangeDue] doubleValue]*-1)];
						cont.owed = owed;
                        cont.editing = YES;
						[owed release];
						cont.delegate = self;
						cont.payment = tmp;
						[self.navigationController pushViewController:cont animated:YES];
						[cont.view setBackgroundColor:tblTransaction.backgroundColor];
						[cont release];
					} else {
						TransactionPaymentViewController *cont = [[TransactionPaymentViewController alloc] initWithNibName:@"TransactionPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[transaction getChangeDue] doubleValue]*-1)];
						cont.amountOwed = owed;
						[owed release];
						cont.delegate = self;
						cont.editing = YES;
						cont.payment = tmp;
						[self.navigationController pushViewController:cont animated:YES];
						[cont release];
					}
				}
				break;
		}
	} else {
		switch ( indexPath.section ) {
			case 4: {
				if( transaction.giftCertificates.count > 0 ) {
					GiftCertificateViewController *cont = [[GiftCertificateViewController alloc] initWithNibName:@"GiftCertificateView" bundle:nil];
					GiftCertificate *cert = (GiftCertificate*)((TransactionItem*)[transaction.giftCertificates objectAtIndex:indexPath.row]).item;
					if( cert ) {
						cont.certificate = cert;
						[self.navigationController pushViewController:cont animated:YES];
					}
					[cont release];
				}
				break;
			}
			case 6: {
				if( transaction.payments.count > 0 ) {
					TransactionPayment *tmp = [transaction.payments objectAtIndex:indexPath.row];
					if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
						CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[transaction getChangeDue] doubleValue]*-1)];
						cont.owed = owed;
						[owed release];
						cont.delegate = self;
						cont.payment = tmp;
						[self.navigationController pushViewController:cont animated:YES];
						[cont.view setBackgroundColor:tblTransaction.backgroundColor];
						[cont release];
					} else {
						TransactionPaymentViewController *cont = [[TransactionPaymentViewController alloc] initWithNibName:@"TransactionPaymentView" bundle:nil];
						NSNumber *owed = [[NSNumber alloc] initWithDouble:([[transaction getChangeDue] doubleValue]*-1)];
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
	
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 8 ) {
		// Get rid of background and border
		//[cell setBackgroundView:nil];
        [cell setBackgroundColor:tblTransaction.backgroundColor];
        [cell.contentView setBackgroundColor:tblTransaction.backgroundColor];
	}
}

#pragma mark -
#pragma mark Credit Card Processing
#pragma mark -
- (IBAction)clicked_chargeBtn:(id)sender {
    
    
    // Charge or Alert
    
    for( TransactionPayment *tmp in transaction.payments ) {
        if( tmp.transactionPaymentID == -1 && tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
            payment = tmp;
            if( payment.creditCardPayment ) {
                Reachability *curReach = [Reachability reachabilityForInternetConnection];
                // Check network reachability
                NetworkStatus netStatus = [curReach currentReachabilityStatus];
                if( netStatus == NotReachable ) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required" message:@"Credit card processing requires a Wifi or 3G connection in order to function. " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                } else {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    self.activityView.hidden = NO;
                    [self.activityView startAnimating];
                    [payment.creditCardPayment chargeWithDelegate:self];
                }
            }
        }
    }
    
    [self save];
}

#pragma mark -
#pragma mark Credit Card Processing Delegate Methods
#pragma mark -
/*
 *	Update the labels for the current transaction status.
 */
- (void) processingDidChangeState {
    switch ( payment.creditCardPayment.status ) {
        case CreditCardProcessingNotProcessed:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [activityView stopAnimating];
            
            //btnCharge.enabled = YES;
            break;
        case CreditCardProcessingCancelled:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [activityView stopAnimating];
            
            //NSString *eDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            break;
        case CreditCardProcessingConnecting:
            //NSString *dDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];

            break;
        case CreditCardProcessingRequestSent:
            
            //NSString *cDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            break;
        case CreditCardProcessingResponseReceived:
            //NSString *bDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            break;
        case CreditCardProcessingParsingResponse:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            NSString *aDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            break;
        case CreditCardProcessingApproved:{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSString *amt = [[NSString alloc] initWithFormat:@"$ %.2f", ([payment.creditCardPayment.amount doubleValue]+[payment.creditCardPayment.tip doubleValue])];
            //lbAmount.text = amt;
            [amt release];
            NSString *successDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            [activityView stopAnimating];
            
            
        }
            break;
        case CreditCardProcessingDeclined:{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSString *failDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            [failDate release];
            NSMutableString *err = nil;
            for( NSString *key in [payment.creditCardPayment.response.errors allKeys] ) {
                NSString *desc = [payment.creditCardPayment.response.errors objectForKey:key];
                if( !err ) {
                    err = [[NSMutableString alloc] initWithFormat:@"%@ [Error %@]", desc, key];
                } else {
                    [err appendFormat:@"\n%@ [Error %@]", desc, key];
                }
            }
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Payment Decline." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            [activityView stopAnimating];
        }
            break;
        case CreditCardProcessingError:{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSString *errorDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
            [errorDate release];
            NSMutableString *err2 = nil;
            for( NSString *key in [payment.creditCardPayment.response.errors allKeys] ) {
                NSString *desc = [payment.creditCardPayment.response.errors objectForKey:key];
                if( !err2 ) {
                    err2 = [[NSMutableString alloc] initWithFormat:@"%@ [Error %@]", desc, key];
                } else {
                    [err2 appendFormat:@"\n%@ [Error %@]", desc, key];
                }
            }
            
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Credit Card processing Error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
            break;
        case CreditCardProcessingRefunded:
            
            [activityView stopAnimating];
            
            
            break;
        case CreditCardProcessingVoided:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            NSString *amt3 = [[NSString alloc] initWithFormat:@"$ %.2f", ([payment.creditCardPayment.amount doubleValue]+[payment.creditCardPayment.tip doubleValue])];
 
            [amt3 release];
            NSString *successDate3 = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];

            [successDate3 release];
            
            [activityView stopAnimating];			
            
            
            break;
    }
}

@end
