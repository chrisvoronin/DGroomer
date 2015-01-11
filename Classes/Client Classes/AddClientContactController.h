//
//  AddClientContactController.h
//  myBusiness
//
//  Created by David J. Maier on 6/5/09.
//  Modified by David J. Maier on 10/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import <AddressBook/AddressBook.h> 
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>

@class Client;

@interface AddClientContactController : UIViewController <UITableViewDelegate, UITableViewDataSource, ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate> {
	IBOutlet UITableView *myTableView;
	// Our data structure
	ABRecordRef	group;
}

@property (nonatomic, retain) UITableView *myTableView;



@end
