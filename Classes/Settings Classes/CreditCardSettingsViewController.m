    //
//  CreditCardSettingsViewController.m
//  PSA
//
//  Created by David J. Maier on 5/4/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "AuthorizeDotNetSignUpViewController.h"
#import "Company.h"
#import "CreditCardSettings.h"
#import "PSADataManager.h"
#import "CreditCardSettingsViewController.h"


@implementation CreditCardSettingsViewController

@synthesize segProcessingType, swEmail, txtAPILogin, txtTransactionKey, alertText;

- (void) viewDidLoad {
	self.title = @"GATEWAY SETTINGS";
	// Fetch settings from keychain/DB
	settings = [[PSADataManager sharedInstance] getCreditCardSettings];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Add Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
    
    [super viewDidLoad];
}
- (IBAction)btnEditGateway_clicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Please input password."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    
    
    //alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    //[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    //alert.tag = 100;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //[[alert textFieldAtIndex:0] setPlaceholder:@"Enter postal Code"];
    alertText = [alert textFieldAtIndex:0];
    alertText.keyboardType = UIKeyboardTypeNumberPad;
    //alertText.delegate=txtAPILogin.delegate;
    alert.tag=100;
    
    [alert show];
}

- (void) viewWillAppear:(BOOL)animated {
	// Set textField values, disable Charge button?
    isPasswordChecked = NO;
	if( settings ) {
		if( settings.apiLogin ) {
			txtAPILogin.text = settings.apiLogin;
		}
		if( settings.transactionKey ) {
			txtTransactionKey.text = settings.transactionKey;
		}
		segProcessingType.selectedSegmentIndex = settings.processingType;
		swEmail.on = settings.sendEmailFromGateway;
	}
    [self showControls];
    
}

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.segProcessingType = nil;
	self.swEmail = nil;
	self.txtAPILogin = nil;
	self.txtTransactionKey = nil;
    self.alertText = nil;
	[settings release];
    [lblAPILogin release];
    [lblTransactionKey release];
    [lblGateway release];
    [btnHelpAPILogin release];
    [btnHelpTransactionKey release];
    [lblMerchant release];
    [btnHelpMerchant release];
    [btnEditGateway release];
    [super dealloc];
}

- (void) showControls{
    lblAPILogin.hidden = YES;
    lblTransactionKey.hidden = YES;
    lblGateway.hidden = YES;
    btnHelpAPILogin.hidden = YES;
    btnHelpTransactionKey.hidden = YES;
    lblMerchant.hidden = YES;
    btnHelpMerchant.hidden = YES;
    segProcessingType.hidden = YES;
    swEmail.hidden = YES;
    txtAPILogin.hidden = YES;
    txtTransactionKey.hidden = YES;
    
    btnEditGateway.hidden = NO;
}

- (void) hideControls{
    lblAPILogin.hidden = NO;
    lblTransactionKey.hidden = NO;
    lblGateway.hidden = NO;
    btnHelpAPILogin.hidden = NO;
    btnHelpTransactionKey.hidden = NO;
    lblMerchant.hidden = NO;
    btnHelpMerchant.hidden = NO;
    segProcessingType.hidden = NO;
    swEmail.hidden = NO;
    txtAPILogin.hidden = NO;
    txtTransactionKey.hidden = NO;
    
    btnEditGateway.hidden = YES;
}
/*
 *	Get rid of the keyboard when the user touches outside the textField
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[txtAPILogin resignFirstResponder];
    [alertText resignFirstResponder];
	[txtTransactionKey resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}

/*
 *	Show an alert describing the API Login field.
 */
- (IBAction) helpAPILogin:(id)sender {
	UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"API Login" message:@"This is your Authorize.Net API Login. We use this when sending transactions so the gateway knows who is accessing it.\n\nThis is NOT your Merchant Interface Login or password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/*
 *	Show an alert describing the Merchant.
 */
- (IBAction) helpMerchantAccount:(id)sender {
	UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"Merchant Account" message:@"This is the type of merchant account you have, and determines how we communicate with Authorize.Net.\n\n\"Card Present\" is a retail account if you're doing business where the customer directly hands you their card. If you have a hardware card stripe reader, this may be your merchant type.\n\n\"Card Not Present\" is typically for \"MOTO\" or Internet transactions. If you also accept payment from a website, this may be your merchant type.\n\nYou will see error #85 or #87 when processing payments if your merchant type is incorrect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/*
 *	Show an alert describing the Transaction Key field.
 */
- (IBAction) helpTransactionKey:(id)sender {
	UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"Transaction Key" message:@"This is a key that Authorize.Net will give you that is sent along with the API Login when processing transactions." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/*
 *	Write to DB/Keychain, then dismiss the view
 */
- (void) save {
	settings.apiLogin = txtAPILogin.text;
	settings.processingType = segProcessingType.selectedSegmentIndex;
	settings.transactionKey = txtTransactionKey.text;
	settings.sendEmailFromGateway = swEmail.on;
	[settings save];
	[self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(isPasswordChecked)
        return YES;
    
    
    return NO;
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100){
        if(buttonIndex == 1){
            NSString * password = [[alertView textFieldAtIndex:0] text];
//            if([password isEqualToString:@"dg7937"]){
            if([password isEqualToString:@"3689"]){
                isPasswordChecked = YES;
                [self hideControls];
            }
        }
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"Range: %@", NSStringFromRange(range));
    return ( range.location < 4 );
    
}
/*
 *	Alert to possibilities
 */
- (IBAction) signUp:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"NetPay requires a signature to complete sign-up, and will not work on this device. Please call NetPay to assist you, or email the signup link to your flash enabled desktop computer." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call", @"Email Link", nil];
	[sheet showInView:self.view];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Clicked the Delete button
	switch( buttonIndex ) {
		case 0:
			if( [[[UIDevice currentDevice] model] hasPrefix:@"iPhone"] ) {
				NSString *urlString = [[NSString alloc] initWithString:@"tel://877-976-8218"];
				NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				[[UIApplication sharedApplication] openURL:url];
				[urlString release];
				[url release];
				break;
			} else {
				NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not able to make phone calls. NetPay can be reached at:\n\n1 877-976-8218", APPLICATION_NAME];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Call!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[msg release];
				[alert show];	
				[alert release];
			}
			break;
		case 1:
			if( [MFMailComposeViewController canSendMail] ) {
				MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
				//picker.navigationBar.tintColor = [UIColor blackColor];
				picker.mailComposeDelegate = self;
				// Company Info
				Company *company = [[PSADataManager sharedInstance] getCompany];
				NSArray *toRecipients = [NSArray arrayWithObjects:company.companyEmail, nil];
				[picker setToRecipients:toRecipients];
				// Subject
				[picker setSubject:@"Credit Card Processing Signup"];
				[picker setMessageBody:@"http://www.netpaybankcard.com/admin/onlineapplication.php?mid=58" isHTML:NO];
				[company release];
				// Present the mail composition interface. 
				[self presentViewController:picker animated:YES completion:nil]; 
				[picker release];
			} else {
				NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[msg release];
				[alert show];	
				[alert release];
			}
			break;
	}
}
- (IBAction)txtTransactionChanged:(id)sender {
    int nnn = txtTransactionKey.text.length;
    int vvv = 0;
    vvv = nnn;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error { 
    [self dismissViewControllerAnimated:YES completion:nil]; 
}


@end
