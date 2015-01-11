//
//  ClientRecoveryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 2/10/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "GenericClientDetailViewController.h"
#import <AddressBook/AddressBook.h> 
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>

@class Client;

@interface ClientRecoveryViewController : GenericClientDetailViewController <ABPeoplePickerNavigationControllerDelegate> {
	UIButton	*btnAutomatic;
	UIButton	*btnManual;
	UILabel		*lbName;
}

@property (nonatomic, retain) IBOutlet UIButton	*btnAutomatic;
@property (nonatomic, retain) IBOutlet UIButton	*btnManual;
@property (nonatomic, retain) IBOutlet UILabel	*lbName;

- (IBAction) btnAutomaticPressed:(id)sender;
- (IBAction) btnManualPressed:(id)sender;

@end
