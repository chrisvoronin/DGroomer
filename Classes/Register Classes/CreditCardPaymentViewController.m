//
//  CreditCardInformationEntryViewController.m
//  PSA
//
//  Created by David J. Maier on 2/19/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import	"CreditCardPayment.h"
#import "CreditCardResponse.h"
#import "PSADataManager.h"
#import "Reachability.h"
#import "TransactionPayment.h"
#import "CreditCardPaymentViewController.h"
#import	<QuartzCore/QuartzCore.h>
#import "CardIO.h"
#import "CreditCardSettings.H"

@implementation CreditCardPaymentViewController

@synthesize owed, payment, delegate, autoRefunding, nonRefundable, notesView, scrollClient;
@synthesize btnCancelVoidRefund, btnCharge, btnContacts, ivTip, lbOwed, lbTotal, txtAmount, txtCardNumber, txtCVV, txtTip, txtExpDate;
@synthesize activityView, lbAmount, lbAmountTitle, lbDate, lbDateTitle, tvError, lbStatus, lbTransID, lbTransIDTitle;
@synthesize txtAddressStreet, txtAddressCity, txtAddressState, txtAddressZip, txtEmail, txtNameFirst, txtNameLast, txtPhone, tvNotes;

- (void) viewDidLoad {
	
    //self.title = @"Credit";
    self.title = @"PAYMENT";
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
	// Register for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	//
	tvError.font = [UIFont boldSystemFontOfSize:14];	
	// Resize the text fields
	
	
	//
	scrollClient.contentSize = CGSizeMake( 320, 410 );
	//
	UILabel *lbCurrency = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 40)];
	UILabel *lbCurrency2 = [[UILabel alloc] initWithFrame:CGRectMake( 0, 2, 20, 40)];
	lbCurrency.font = txtAmount.font;
	lbCurrency.text = @"$";
	lbCurrency2.font = txtAmount.font;
	lbCurrency2.text = @"$";
	txtAmount.leftView = lbCurrency;
	txtAmount.leftViewMode = UITextFieldViewModeAlways;
	txtTip.leftView = lbCurrency2;
	txtTip.leftViewMode = UITextFieldViewModeAlways;
	[lbCurrency release];
	[lbCurrency2 release];
	//
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
    [singleTap release];
    
    tvNotes.layer.cornerRadius = 5.0;
    tvNotes.clipsToBounds = YES;
    // you might have to play around a little with numbers in CGRectMake method
    // they work fine with my settings
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, tvNotes.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:@"Notes"];
    // placeholderLabel is instance variable retained by view controller
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    //[placeholderLabel setFont:[challengeDescription font]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    // textView is UITextView object you want add placeholder text to
    [tvNotes addSubview:placeholderLabel];
    tvNotes.delegate = self;
    
    strYear = @"";
    strMonth = @"";
    [self.mainContainer setContentSize:CGSizeMake(320, 680)];

}

- (void) viewWillAppear:(BOOL)animated {
    
    
	if( !payment.ccHydrated ) {
		[payment hydrateCreditCardPayment];
	}
	
	txtEmail.text = payment.creditCardPayment.clientEmail;
	txtNameFirst.text = payment.creditCardPayment.nameFirst;
	txtNameLast.text = payment.creditCardPayment.nameLast;
	txtPhone.text = payment.creditCardPayment.clientPhone;
	txtAddressStreet.text = payment.creditCardPayment.addressStreet;
	txtAddressCity.text = payment.creditCardPayment.addressCity;
	txtAddressState.text = payment.creditCardPayment.addressState;
	txtAddressZip.text = payment.creditCardPayment.addressZip;
	
	if( payment.transactionPaymentID > -1 || payment.creditCardPayment.response != nil ) {
		if( nonRefundable ) {
			btnCancelVoidRefund.hidden = YES;
		}
		// Populate the fields, 
		NSString *amt = [[NSString alloc] initWithFormat:@"%.2f", [payment.creditCardPayment.amount doubleValue]];
		txtAmount.text = amt;
		[amt release];
		NSString *tip = [[NSString alloc] initWithFormat:@"%.2f", [payment.creditCardPayment.tip doubleValue]];
		txtTip.text = tip;
		[tip release];
		txtCVV.text = @"***";
		strYear = @"**";
		strMonth = @"**";
		
		NSString *cc = [[NSString alloc] initWithFormat:@"Ending in %@", payment.creditCardPayment.ccNumber];
		txtCardNumber.text = cc;
		[cc release];
		[btnCancelVoidRefund setImage:[UIImage imageNamed:@"btnRefund.png"] forState:UIControlStateNormal];
		// Make them not editable
		btnCharge.enabled = NO;
		// Get rid of this until something actually changes
		self.navigationItem.rightBarButtonItem = nil;
		self.navigationItem.hidesBackButton = NO;
		//
		[self disableTextFields];
		[self processingDidChangeState];
	} else {
		if( autoRefunding ) {
			[self disableTextFields];
			[self processingDidChangeState];
		} else {
			// Show the keyboard if a new payment
			[txtAmount becomeFirstResponder];
		}
	}
	if( owed ) {
		double amt = [owed doubleValue];
		if( amt < 0.0 || amt == -0.0 ) {
			amt = 0.0;
		}
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		NSString *ow = [[NSString alloc] initWithFormat:@"Owed: %@", [formatter stringFromNumber:[NSNumber numberWithFloat:amt]]];
		lbOwed.text = ow;
		[ow release];
		[formatter release];
	}
	[self updateTotal];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	//if( !autoRefunding ) {
		// TODO: Always dehydrate? Never dehydrate?
		//[payment dehydrateCreditCardPayment];
	//}
	self.btnCancelVoidRefund = nil;
	self.btnCharge = nil;
	self.btnContacts = nil;
	self.ivTip = nil;
	self.lbOwed = nil;
	self.lbTotal = nil;
	self.txtAddressStreet = nil;
	self.txtAddressCity = nil;
	self.txtAddressState = nil;
	self.txtAddressZip = nil;
	self.txtAmount = nil;
	self.txtCardNumber = nil;
	self.txtCVV = nil;

	self.txtEmail = nil;
	self.txtNameFirst = nil;
	self.txtNameLast = nil;
	self.txtPhone = nil;
	self.txtTip = nil;
	self.lbAmount = nil;
	self.lbDate = nil;
	self.tvError = nil;
	self.lbStatus = nil;
	self.lbTransID = nil;
	self.lbAmountTitle = nil;
	self.lbDateTitle = nil;
	self.lbTransIDTitle = nil;
	self.activityView = nil;
	//
	self.notesView = nil;
	self.scrollClient = nil;
	//
	[owed release];
	[payment release];
    [_mainContainer release];
    [tvNotes release];
    [txtExpDate release];

    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -
/*
 *	Cancel, Void, or Refund the Transaction.
 */
- (IBAction) cancelVoidRefund:(id)sender {
	if( !payment.ccHydrated ) {
		[payment hydrateCreditCardPayment];
	}
	if( payment.creditCardPayment.status != CreditCardProcessingApproved ) {
		[payment.creditCardPayment cancel];
		if( autoRefunding ) {
			[self.delegate autoRefundedCreditPayment:payment];
		}
	} else {
		[activityView startAnimating];
		[payment.creditCardPayment refundWithDelegate:self];
	}
}

/*
 *
 */
- (IBAction) charge:(id)sender {
	
	if( [txtAmount.text doubleValue] <= 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Payment" message:@"Amount must be greater than $0.00!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if( [txtCardNumber.text isEqualToString:@""] ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Payment" message:@"You must enter the credit card number!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if( [txtCVV.text isEqualToString:@""] ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Payment" message:@"You must enter the credit card security code (CVV2/CVC2/CID)!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}    else if( txtExpDate.text.length <= 3 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Payment" message:@"You must enter an expiration month/year!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        
        if( txtExpDate.text.length > 4 ) {
            strMonth = [txtExpDate.text substringToIndex:2];
            strYear = [[NSString alloc] initWithFormat:@"20%@", [txtExpDate.text substringFromIndex:3]];
        }
        
		// Hide the keyboard (to show statuses)
		[txtAmount resignFirstResponder];
		[txtCardNumber resignFirstResponder];
		[txtCVV resignFirstResponder];
		[txtExpDate resignFirstResponder];
		[txtTip resignFirstResponder];
		// Make uneditable
		[self disableTextFields];
		// Put the values
		NSNumber *amt = [[NSNumber alloc] initWithDouble:[txtAmount.text doubleValue]];
		payment.creditCardPayment.amount = amt;
		[amt release];
		NSNumber *tip = [[NSNumber alloc] initWithDouble:[txtTip.text doubleValue]];
		payment.creditCardPayment.tip = tip;
		[tip release];
		payment.creditCardPayment.ccCVV = txtCVV.text;
		payment.creditCardPayment.ccExpirationMonth = strMonth;
		payment.creditCardPayment.ccExpirationYear = strMonth;
		payment.creditCardPayment.ccNumber = txtCardNumber.text;
		// Charge or Alert
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
				[activityView startAnimating];
				[payment.creditCardPayment chargeWithDelegate:self];
			}
		}
	}
	
}

/*
 *	Erase the text field values.
 */
- (void) clearFields {
	txtAmount.text = @"";
	txtCardNumber.text = @"";
	txtCVV.text = @"";
	txtExpDate.text = @"";
	txtTip.text = @"";
}

/*
 *	Dismiss this [modal] view
 */
- (void) close {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) closeNotes:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	// CC Number will get focus
	if( payment.creditCardPayment.milestoneStatus != CreditCardProcessingApproved && payment.creditCardPayment.milestoneStatus != CreditCardProcessingRefunded && 
	   payment.creditCardPayment.milestoneStatus != CreditCardProcessingVoided && payment.creditCardPayment.milestoneStatus != CreditCardProcessingError && 
	   payment.creditCardPayment.milestoneStatus != CreditCardProcessingDeclined ) 
	{
		[txtCardNumber becomeFirstResponder];
	}
	// Animate the hide
	CATransition *transition = [CATransition animation];
	transition.duration = 0.5;
	transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	notesView.hidden = YES;
}

/*
 *	Make the text fields not editable.
 */
- (void) disableTextFields {
	txtAddressCity.userInteractionEnabled = NO;
	txtAddressState.userInteractionEnabled = NO;
	txtAddressStreet.userInteractionEnabled = NO;
	txtAddressZip.userInteractionEnabled = NO;
	txtAmount.userInteractionEnabled = NO;
	txtCardNumber.userInteractionEnabled = NO;
	txtCVV.userInteractionEnabled = NO;
	txtExpDate.userInteractionEnabled = NO;
	txtEmail.userInteractionEnabled = NO;
	txtNameFirst.userInteractionEnabled = NO;
	txtNameLast.userInteractionEnabled = NO;
	txtPhone.userInteractionEnabled = NO;
	txtTip.userInteractionEnabled = NO;
}

- (void) dismissKeyboard {
	[txtAddressCity resignFirstResponder];
	[txtAddressState resignFirstResponder];
	[txtAddressStreet resignFirstResponder];
	[txtAddressZip resignFirstResponder];
	[txtAmount resignFirstResponder];
	[txtCardNumber resignFirstResponder];
	[txtCVV resignFirstResponder];
	[txtExpDate resignFirstResponder];
	[txtEmail resignFirstResponder];
	[txtNameFirst resignFirstResponder];
	[txtNameLast resignFirstResponder];
	[txtPhone resignFirstResponder];
	[txtTip resignFirstResponder];
    
    [self.mainContainer setContentOffset:CGPointMake(0, 0)];
}

/*
 *	Make the text fields not editable.
 */
- (void) enableTextFields {
	txtAddressCity.userInteractionEnabled = YES;
	txtAddressState.userInteractionEnabled = YES;
	txtAddressStreet.userInteractionEnabled = YES;
	txtAddressZip.userInteractionEnabled = YES;
	txtAmount.userInteractionEnabled = YES;
	txtCardNumber.userInteractionEnabled = YES;
	txtCVV.userInteractionEnabled = YES;
	txtExpDate.userInteractionEnabled = YES;
	txtTip.userInteractionEnabled = YES;
	txtEmail.userInteractionEnabled = YES;
	txtNameFirst.userInteractionEnabled = YES;
	txtNameLast.userInteractionEnabled = YES;
	txtPhone.userInteractionEnabled = YES;
}

/*
 *	If approved, save the payment and go back to the Transaction view.
 */
- (void) done {
	payment.creditCardPayment.ccNumber = [payment.creditCardPayment.ccNumber substringFromIndex:payment.creditCardPayment.ccNumber.length-4];
	[[PSADataManager sharedInstance] saveCreditCardPayment:payment.creditCardPayment];
	// Set the extraInfo to the creditCardPaymentID
	payment.extraInfo = [NSString stringWithFormat:@"%ld", (long)payment.creditCardPayment.ccPaymentID];
	NSNumber *total = [[NSNumber alloc] initWithDouble:[payment.creditCardPayment.amount doubleValue]+[payment.creditCardPayment.tip doubleValue]];
	payment.amount = total;
	[total release];
	//
	[self.delegate completedNewPayment:payment];
}

- (IBAction)onScanCard:(id)sender {
    
    /*[txtAmount resignFirstResponder];
    [txtCardNumber resignFirstResponder];
    [txtCVV resignFirstResponder];
    [txtDateMonth resignFirstResponder];
    [txtDateYear resignFirstResponder];
    [txtTip resignFirstResponder];*/
    [self.view endEditing:YES];
    
    //if([CardIOPaymentViewController canReadCardWithCamera])
    {
        CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self ];//  scanningEnabled:NO];
        scanViewController.useCardIOLogo=YES;
        scanViewController.modalPresentationStyle = UIModalPresentationCustom;//UIModalPresentationCustom;//UIModalPresentationFullScreen;//UIModalPresentationCurrentContext;//UIModalPresentationFormSheet;
        //CreditCardSettings * settings = [[PSADataManager sharedInstance] getCreditCardSettings];
    
        //scanViewController.appToken = @"630ada9f5f254f33b1511527b22cdabc"; // see Constants.h
        [self presentViewController:scanViewController animated:YES completion:nil];
    }
    /*CardIOView *cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0,40,320,480)];
    
    cardIOView.appToken = @"630ada9f5f254f33b1511527b22cdabc"; // get your app token from the card.io website
    //[cardIOView setDelegate:self.mainContainer delegate];
    //[cardIOView  setBackgroundColor:[UIColor redColor]];
    cardIOView.delegate = self;
    [self.mainContainer addSubview:cardIOView];*/
}


#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"Scan succeeded with info: %@", info);
    // Do whatever needs to be done to deliver the purchased items.
    [self dismissViewControllerAnimated:YES completion:nil];
    txtCardNumber.text=info.redactedCardNumber;
    
    strYear = [NSString stringWithFormat:@"%lu", (unsigned long)info.expiryYear];
    strMonth = [NSString stringWithFormat:@"%02lu", (unsigned long)info.expiryMonth];
    self.txtExpDate.text = [NSString stringWithFormat:@"%@/%@", strMonth, [strYear substringFromIndex:2]];
   
    txtCVV.text = info.cvv;
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction) editNotes:(id)sender {
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	// Animate the display
	CATransition *transition = [CATransition animation];
	transition.duration = 0.5;
	transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	notesView.hidden = NO;
	
}

- (void) updateTotal {
	NSString *tot = [[NSString alloc] initWithFormat:@"Total: $%.2f", [txtAmount.text doubleValue]+[txtTip.text doubleValue]];
	lbTotal.text = tot;
	[tot release];
}

#pragma mark -
#pragma mark Other Methods
#pragma mark -
/*
 *	Remove the "Clear All" button from the keyboard.
 */
- (void) keyboardWillHide:(NSNotification *)note {
    if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		
	} else {
		[doneButton removeFromSuperview];
		doneButton = nil;
	}
}

/*
 *	Put a "Clear All" button on the keyboard.
 *	Code borrowed from:
 *	http://www.neoos.ch/news/46-development/54-uikeyboardtypenumberpad-and-the-missing-return-key
 */
- (void) keyboardWillShow:(NSNotification *)note {
    if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// There is a new way to add custom keyboards in 3.2+
		// Handled in textFieldShouldBeingEditing
	} else {
		// Old way just puts a button over the window...
		doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		doneButton.frame = CGRectMake(0, 163, 105, 53);
		doneButton.adjustsImageWhenHighlighted = NO;
		[doneButton setImage:[UIImage imageNamed:@"btnClearUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"btnClearDown.png"] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(clearFields) forControlEvents:UIControlEventTouchUpInside];
		
		// locate keyboard view
		UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
		UIView* keyboard;
		for(int i=0; i<[tempWindow.subviews count]; i++) {
			keyboard = [tempWindow.subviews objectAtIndex:i];			
			// keyboard view found; add the custom button to it
			if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES) {
				[keyboard addSubview:doneButton];
			}
		}
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate and Supporting Methods
#pragma mark -
/*
 *	In iOS 3.2+ add the keyboardAccessory
 */
/*
 // TODO: If I REALLY want the Clear All button in OS 3.2+, this is where I'd load my custom keyboard!
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField.inputView == nil) {		
		if( !doneButton ) {
			doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
			doneButton.frame = CGRectMake(0, 163, 105, 53);
			doneButton.adjustsImageWhenHighlighted = NO;
			[doneButton setImage:[UIImage imageNamed:@"btnClearUp.png"] forState:UIControlStateNormal];
			[doneButton setImage:[UIImage imageNamed:@"btnClearDown.png"] forState:UIControlStateHighlighted];
			[doneButton addTarget:self action:@selector(clearFields) forControlEvents:UIControlEventTouchUpInside];
		}
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textField.inputView = doneButton;    
        doneButton = nil;
    }
	
    return YES;
}
*/

/*
 *	Update our labels with values, as well as figure out the decimal placement for amount and tip.
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( textField == txtAmount || textField == txtTip ) {
		NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
		// Strip Decimal
		new = [new stringByReplacingOccurrencesOfString:@"." withString:@""];
		NSString *new2 = [[NSString alloc] initWithFormat:@"%.2f", [new doubleValue]/100];
		textField.text = new2;
		[new2 release];
		[self updateTotal];
		return NO;
	} else if( textField == txtExpDate) {
		if( ![string isEqualToString:@""] ) {
            NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
			if( textField.text.length > 4 ) {
                strMonth = [textField.text substringToIndex:2];
                strYear = [[NSString alloc] initWithFormat:@"20%@", [textField.text substringFromIndex:3]];
				return NO;
			}
            if(new.length==5)
            {
                strMonth = [new substringToIndex:2];
                strYear = [[NSString alloc] initWithFormat:@"20%@", [new substringFromIndex:3]];
            }
            
            if (textField.text.length < 1 && [new integerValue] > 1) {
                NSString *new2 = [[NSString alloc] initWithFormat:@"%02ld/", (long)[new integerValue]];
                textField.text = new2;
                [new2 release];
                return NO;
            } else if(textField.text.length==1)
            {
                if ([new integerValue] > 12) {
                    return NO;
                }
                NSString *new2 = [[NSString alloc] initWithFormat:@"%02ld/", (long)[new integerValue]];
                textField.text = new2;
                [new2 release];
                return NO;
            }
		}

	}
	return YES;
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
			lbStatus.text = @"Not Processed";
			lbAmount.text = @"--";
			lbDate.text = @"";
			tvError.text = @"";
			lbTransID.text = @"";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = YES;
			lbDateTitle.hidden = YES;
			tvError.hidden = YES;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = YES;
			btnCancelVoidRefund.enabled = NO;
			break;
		case CreditCardProcessingCancelled:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[activityView stopAnimating];
			lbStatus.text = @"Cancelled";
			lbAmount.text = @"--";
			NSString *eDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = eDate;
			[eDate release];
			tvError.text = @"";
			lbTransID.text = @"";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = YES;
			btnCancelVoidRefund.enabled = NO;
			self.navigationItem.leftBarButtonItem.enabled = YES;
			//self.navigationItem.hidesBackButton = NO;
			break;
		case CreditCardProcessingConnecting:
			lbStatus.text = @"Connecting...";
			lbAmount.text = @"--";
			NSString *dDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = dDate;
			[dDate release];
			tvError.text = @"";
			lbTransID.text = @"";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = NO;
			[btnCancelVoidRefund setImage:[UIImage imageNamed:@"btnCancel.png"] forState:UIControlStateNormal];
			btnCancelVoidRefund.enabled = YES;
			self.navigationItem.leftBarButtonItem.enabled = NO;
			//self.navigationItem.hidesBackButton = YES;
			break;
		case CreditCardProcessingRequestSent:
			lbStatus.text = @"Request Sent...";
			lbAmount.text = @"--";
			NSString *cDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = cDate;
			[cDate release];
			tvError.text = @"";
			lbTransID.text = @"";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = NO;
			btnCancelVoidRefund.enabled = NO;
			self.navigationItem.leftBarButtonItem.enabled = NO;
			break;
		case CreditCardProcessingResponseReceived:
			lbStatus.text = @"Response Received...";
			lbAmount.text = @"--";
			NSString *bDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = bDate;
			[bDate release];
			tvError.text = @"";
			lbTransID.text = @"";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = NO;
			btnCancelVoidRefund.enabled = NO;
			self.navigationItem.leftBarButtonItem.enabled = NO;
			break;
		case CreditCardProcessingParsingResponse:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			lbStatus.text = @"Parsing...";
			lbAmount.text = @"--";
			NSString *aDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = aDate;
			[aDate release];
			tvError.text = @"";
			lbTransID.text = @"";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = NO;
			btnCancelVoidRefund.enabled = NO;
			self.navigationItem.leftBarButtonItem.enabled = NO;
			break;
		case CreditCardProcessingApproved:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			lbStatus.text = @"Approved!";
			NSString *amt = [[NSString alloc] initWithFormat:@"$ %.2f", ([payment.creditCardPayment.amount doubleValue]+[payment.creditCardPayment.tip doubleValue])];
			lbAmount.text = amt;
			[amt release];
			NSString *successDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = successDate;
			[successDate release];
			tvError.text = @"";
			lbTransID.text = payment.creditCardPayment.response.transID;
			// Hide or show
			lbAmount.hidden = NO;
			lbAmountTitle.hidden = NO;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = NO;
			lbTransIDTitle.hidden = NO;
			btnCharge.enabled = NO;
			[btnCancelVoidRefund setImage:[UIImage imageNamed:@"btnRefund.png"] forState:UIControlStateNormal];
			btnCancelVoidRefund.enabled = YES;
			[activityView stopAnimating];
			
			if( nonRefundable ) {
				self.navigationItem.leftBarButtonItem.enabled = YES;
			} else {
				if( payment.creditCardPayment.ccPaymentID == -1 ) {
					// Done Button
					UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
					self.navigationItem.rightBarButtonItem = btnDone;
					[btnDone release];
					// New payment, don't allow refund
					btnCancelVoidRefund.hidden = YES;
				}
				self.navigationItem.leftBarButtonItem.enabled = NO;
			}
			break;
		case CreditCardProcessingDeclined:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			lbStatus.text = @"Declined!";
			NSString *failDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = failDate;
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
			tvError.text = err;
			[err release];
			lbTransID.text = @"--";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = NO;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = YES;
			btnCancelVoidRefund.enabled = NO;
			[activityView stopAnimating];
			self.navigationItem.leftBarButtonItem.enabled = YES;
			[self enableTextFields];
			break;
		case CreditCardProcessingError:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			lbStatus.text = @"Error!";
			NSString *errorDate = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = errorDate;
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
			tvError.text = err2;
			[err2 release];
			lbTransID.text = @"--";
			lbAmount.hidden = YES;
			lbAmountTitle.hidden = YES;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = NO;
			lbTransID.hidden = YES;
			lbTransIDTitle.hidden = YES;
			btnCharge.enabled = YES;
			btnCancelVoidRefund.enabled = NO;
			[activityView stopAnimating];
			self.navigationItem.leftBarButtonItem.enabled = YES;
			//self.navigationItem.hidesBackButton = NO;
			[self enableTextFields];
			
			if( autoRefunding ) {
				[self.delegate autoRefundedCreditPayment:payment];
			}
			
			break;
		case CreditCardProcessingRefunded:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			lbStatus.text = @"Refunded!";
			NSString *amt2 = [[NSString alloc] initWithFormat:@"$ %.2f", ([payment.creditCardPayment.amount doubleValue]+[payment.creditCardPayment.tip doubleValue])];
			lbAmount.text = amt2;
			[amt2 release];
			NSString *successDate2 = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = successDate2;
			[successDate2 release];
			tvError.text = @"";
			lbTransID.text = payment.creditCardPayment.response.transID;
			// Hide or show
			lbAmount.hidden = NO;
			lbAmountTitle.hidden = NO;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = NO;
			lbTransIDTitle.hidden = NO;
			btnCharge.enabled = NO;
			btnCancelVoidRefund.enabled = NO;
			[activityView stopAnimating];			
			
			self.navigationItem.leftBarButtonItem.enabled = NO;
			self.navigationItem.hidesBackButton = YES;
			
			if( autoRefunding ) {
				[[PSADataManager sharedInstance] saveCreditCardPayment:payment.creditCardPayment];
				[self.delegate autoRefundedCreditPayment:payment];
			} else {
				if( nonRefundable ) {
					self.navigationItem.leftBarButtonItem.enabled = YES;
					self.navigationItem.hidesBackButton = NO;
				} else {
					// Done Button
					UIBarButtonItem *btnDone2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
					self.navigationItem.rightBarButtonItem = btnDone2;
					[btnDone2 release];
					[self.delegate refundedCreditPayment:payment];
				}
			}
			
			break;
		case CreditCardProcessingVoided:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			lbStatus.text = @"Voided!";
			NSString *amt3 = [[NSString alloc] initWithFormat:@"$ %.2f", ([payment.creditCardPayment.amount doubleValue]+[payment.creditCardPayment.tip doubleValue])];
			lbAmount.text = amt3;
			[amt3 release];
			NSString *successDate3 = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:payment.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:payment.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbDate.text = successDate3;
			[successDate3 release];
			tvError.text = @"";
			lbTransID.text = payment.creditCardPayment.response.transID;
			// Hide or show
			lbAmount.hidden = NO;
			lbAmountTitle.hidden = NO;
			lbDate.hidden = NO;
			lbDateTitle.hidden = NO;
			tvError.hidden = YES;
			lbTransID.hidden = NO;
			lbTransIDTitle.hidden = NO;
			btnCharge.enabled = NO;
			btnCancelVoidRefund.enabled = NO;
			[activityView stopAnimating];			
			
			self.navigationItem.leftBarButtonItem.enabled = NO;
			self.navigationItem.hidesBackButton = YES;
			
			if( autoRefunding ) {
				[[PSADataManager sharedInstance] saveCreditCardPayment:payment.creditCardPayment];
				[self.delegate autoRefundedCreditPayment:payment];
			} else {
				if( nonRefundable ) {
					self.navigationItem.leftBarButtonItem.enabled = YES;
					self.navigationItem.hidesBackButton = NO;
				} else {
					// Done Button
					UIBarButtonItem *btnDone3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
					self.navigationItem.rightBarButtonItem = btnDone3;
					[btnDone3 release];
					[self.delegate refundedCreditPayment:payment];
				}
			}
			
			break;
	}
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
    [self.mainContainer setContentOffset:CGPointMake(0, 0)];
    [self.view endEditing:YES];
}

- (void)viewDidUnload {
    [self setMainContainer:nil];
    [super viewDidUnload];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(![tvNotes hasText]) {
        [tvNotes addSubview:placeholderLabel];
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 1.0;
        }];
    } else if ([[tvNotes subviews] containsObject:placeholderLabel]) {
        
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [placeholderLabel removeFromSuperview];
        }];
    }
    //return YES;
}


- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![tvNotes hasText]) {
        [tvNotes addSubview:placeholderLabel];
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 1.0;
        }];
    }
}
@end
