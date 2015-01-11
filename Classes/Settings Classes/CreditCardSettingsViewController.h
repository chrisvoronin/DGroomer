//
//  CreditCardSettingsViewController.h
//  PSA
//
//  Created by David J. Maier on 5/4/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class CreditCardSettings;

@interface CreditCardSettingsViewController : PSABaseViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate> {
	CreditCardSettings	*settings;
	// Interface
	UISegmentedControl	*segProcessingType;
	UISwitch			*swEmail;
	UITextField			*txtAPILogin;
	UITextField			*txtTransactionKey;
    UITextField         *alertText;
    BOOL isPasswordChecked;
    IBOutlet UILabel *lblAPILogin;
    IBOutlet UILabel *lblTransactionKey;
    
    IBOutlet UIButton *btnHelpAPILogin;
    IBOutlet UILabel *lblGateway;
    IBOutlet UIButton *btnHelpTransactionKey;
    IBOutlet UILabel *lblMerchant;
    IBOutlet UIButton *btnHelpMerchant;
    IBOutlet UIButton *btnEditGateway;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl	*segProcessingType;
@property (nonatomic, retain) IBOutlet UISwitch				*swEmail;
@property (nonatomic, retain) IBOutlet UITextField			*txtAPILogin;
@property (nonatomic, retain) IBOutlet UITextField			*txtTransactionKey;
@property (nonatomic, retain)  IBOutlet UITextField          *alertText;


- (IBAction)	helpAPILogin:(id)sender;
- (IBAction)	helpMerchantAccount:(id)sender;
- (IBAction)	helpTransactionKey:(id)sender;
- (void)		save;
- (IBAction)	signUp:(id)sender;
- (void)        showControls;
- (void)        hideControls;
@end
