//
//  ClientSwapViewController.h
//  PSA
//
//  Created by David J. Maier on 2/10/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "GenericClientDetailViewController.h"
#import <AddressBook/AddressBook.h> 
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>

@class Client;

@interface ClientSwapViewController : GenericClientDetailViewController <ABPeoplePickerNavigationControllerDelegate> {
	UIButton	*btnManual;
	UILabel		*lbName;
	UILabel		*lbNameContact;
}

@property (nonatomic, retain) IBOutlet UIButton	*btnManual;
@property (nonatomic, retain) IBOutlet UILabel	*lbName;
@property (nonatomic, retain) IBOutlet UILabel	*lbNameContact;

- (IBAction) btnManualPressed:(id)sender;

@end