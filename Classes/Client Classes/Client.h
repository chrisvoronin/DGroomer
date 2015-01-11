//
//  Client.h
//  myBusiness
//
//  Created by David J. Maier on 6/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <AddressBook/AddressBook.h> 
#import <AddressBookUI/AddressBookUI.h>
#import <Foundation/Foundation.h>

@interface Client : NSObject {
	// Information needed for the client database
	NSInteger		clientID;
	NSInteger		personID;
	ABRecordRef		person;
	NSString		*notes;
	BOOL			isActive;
	// Alternate Datas
	NSString		*firstName;
	NSString		*lastName;
}

@property (nonatomic, assign) BOOL		isActive;
@property (nonatomic, assign) NSInteger clientID;
@property (nonatomic, assign) NSInteger	personID;
@property (nonatomic, retain) NSString	*notes;
@property (nonatomic, retain) NSString	*firstName;
@property (nonatomic, retain) NSString	*lastName;

- (id) initWithID:(NSInteger)cID personID:(NSInteger)ABPersonRefID isActive:(BOOL)active;

- (void) clear;

- (void) deleteClient;

// Get Values
- (NSDictionary*)	getAddressAny;
- (NSDictionary*)	getAddressHome;
- (NSDictionary*)	getAddressWork;
- (NSDate*)			getAnniversaryDate;
- (NSDate*)			getBirthdate;
- (NSString*)		getClientName;
- (NSString*)		getClientNameFirstThenLast;
- (NSString*)		getEmailAddressAny;
- (NSString*)		getEmailAddressHome;
- (NSString*)		getEmailAddressWork;
- (NSString*)		getFirstName;
- (NSString*)		getLastName;
- (NSString*)		getPhoneAny;
- (NSString*)		getPhoneCell;
- (NSString*)		getPhoneHome;
- (NSString*)		getPhoneWork;
// Generic Getter
- (NSDictionary*)	getAnyAddressValue;
- (NSDictionary*)	getAddressWithLabel:(CFStringRef)theLabel;
- (NSString*)		getAnyValueInProperty:(ABPropertyID)theProperty;
- (NSString*)		getProperty:(ABPropertyID)theProperty withLabel:(CFStringRef)theLabel;


- (NSString*)		getMutlilineHTMLStringForReceipt;
- (ABRecordRef)		getPerson;

- (void)			updateClientNameFromContact;
- (void)			updatePerson;

@end
