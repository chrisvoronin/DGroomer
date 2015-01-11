//
//  Client.m
//  myBusiness
//
//  Created by David J. Maier on 6/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "Client.h"

@implementation Client

@synthesize clientID, firstName, isActive, lastName, notes, personID;

- (id) initWithID:(NSInteger)cID personID:(NSInteger)ABPersonRefID isActive:(BOOL)active {
	self.clientID = cID;
	self.personID = ABPersonRefID;
	self.isActive = active;
	self.firstName = nil;
	self.lastName = nil;
	return self;
}

- (void) dealloc {
	[notes release];
	[firstName release];
	[lastName release];
	[super dealloc];
}

/*
 *	clear
 *	Resets all values.
 */
- (void) clear {
	clientID = -1;
	personID = -1;
	self.firstName = nil;
	self.lastName = nil;
	if( person ) CFRelease(person);
}

/*
 *	deleteClient
 *	Deletes the address book contact for this Client
 */
- (void) deleteClient {
	// Don't do this for now
	/*
	if( addressBook && person ) {
		ABAddressBookRemoveRecord( addressBook, person, nil );
		ABAddressBookSave( addressBook, nil );
	}*/
}

- (ABRecordRef) getPerson {
	if( !person ) {
		person = ABAddressBookGetPersonWithRecordID( [PSADataManager sharedInstance].addressBook, self.personID );
	}
	return person;
}

- (void) updatePerson {
	person = ABAddressBookGetPersonWithRecordID( [PSADataManager sharedInstance].addressBook, self.personID );
}

#pragma mark -
#pragma mark Getter Methods
#pragma mark -
/*
 *
 *	Must release this when finished!
 */
- (NSDictionary*) getAddressAny {
	return [self getAnyAddressValue];
}

/*
 *
 *	Must release this when finished!
 */
- (NSDictionary*) getAddressHome {
	return [self getAddressWithLabel:kABHomeLabel];
}

/*
 *
 *	Must release this when finished!
 */
- (NSDictionary*) getAddressWork {
	return [self getAddressWithLabel:kABWorkLabel];
}

/*
 *	MUST release this when finished!
 */
- (NSDate*) getAnniversaryDate {
	NSDate *returnValue = nil;
	if( [self getPerson] ) {
		CFStringRef label;
		ABMultiValueRef multiValue = ABRecordCopyValue( [self getPerson], kABPersonDateProperty );
		for ( CFIndex i = 0; i < ABMultiValueGetCount( multiValue ); i++ ) {
			label = ABMultiValueCopyLabelAtIndex( multiValue, i );
			if ( CFStringCompare( label, kABPersonAnniversaryLabel, 0) == 0 ) {
				CFDateRef date = ABMultiValueCopyValueAtIndex(multiValue, i); 
				returnValue = [(NSDate*)date retain]; 
				CFRelease(date);
			}
			// Cleanup
			CFRelease(label);
		}
		if( multiValue )	CFRelease(multiValue);
	}
	return returnValue;
}

/*
 *
 */
- (NSDate*) getBirthdate {
	NSDate *returnValue = nil;
	if( [self getPerson] ) {
		CFDateRef birth = ABRecordCopyValue( [self getPerson], kABPersonBirthdayProperty );
		if( birth != nil ){
			returnValue = [(NSDate*)birth retain];
			CFRelease(birth);
		}
	}
	return returnValue;
}

/*
 *
 *	Do NOT need to release when finished!
 */
- (NSString*) getClientName {
	NSString *text = nil;
	if( [PSADataManager sharedInstance].clientNameViewOption == 0 ) {
		NSString *last = [self getLastName];
		NSString *first = [self getFirstName];
		if( last && first ) {
			text = [NSString stringWithFormat:@"%@, %@", last, first];
		} else if( first ) {
			text = [NSString stringWithFormat:@"%@", first];
		} else if( last ) {
			text = [NSString stringWithFormat:@"%@", last];
		} else {
			text = @"No Name";
		}
	} else {
		text = [self getClientNameFirstThenLast];
	}
	return text;
}

/*
 *
 *	Do NOT need to release when finished!
 */
- (NSString*) getClientNameFirstThenLast {
	NSString *last = [self getLastName];
	NSString *first = [self getFirstName];
	NSString *text = nil;
	if( last && first ) {
		text = [NSString stringWithFormat:@"%@ %@", first, last];
	} else if( first ) {
		text = [NSString stringWithFormat:@"%@", first];
	} else if( last ) {
		text = [NSString stringWithFormat:@"%@", last];
	} else {
		text = @"No Name";
	}
	return text;
}

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getEmailAddressAny {
	return [self getAnyValueInProperty:kABPersonEmailProperty];
}

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getEmailAddressHome {
	return [self getProperty:kABPersonEmailProperty withLabel:kABHomeLabel];
}

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getEmailAddressWork {
	return [self getProperty:kABPersonEmailProperty withLabel:kABWorkLabel];
}

/*
 *
 *	Changed 2/2010: No need to release;
 */
- (NSString*) getFirstName {
	NSString *returnValue = nil;
	if( clientID == 0 ) {
		returnValue = @"Guest";
	} else if( [self getPerson] ) {
		CFStringRef first = ABRecordCopyValue( [self getPerson], kABPersonFirstNameProperty );
		if( first != nil ){
			returnValue = [NSString stringWithString:(NSString*)first];
			CFRelease(first);
		}
	} else {
		if( firstName ) {
			returnValue = firstName;
		}
	}
	return returnValue;
}

/*
 *
 *	Changed 2/2010: No need to release;
 */
- (NSString*) getLastName {
	NSString *returnValue = nil;
	if( [self getPerson] ) {
		CFStringRef last = ABRecordCopyValue( [self getPerson], kABPersonLastNameProperty );
		if( last != nil ){
			returnValue = [NSString stringWithString:(NSString*)last];
			CFRelease(last);
		}
	} else {
		if( lastName ) {
			returnValue = lastName;
		}
	}
	return returnValue;
}

/*
 *	Must release this string when finished!
 */
- (NSString*) getPhoneAny {
	return [self getAnyValueInProperty:kABPersonPhoneProperty];
}

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getPhoneCell {
	return [self getProperty:kABPersonPhoneProperty withLabel:kABPersonPhoneMobileLabel];
}

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getPhoneHome {
	return [self getProperty:kABPersonPhoneProperty withLabel:kABHomeLabel];
}

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getPhoneWork {
	return [self getProperty:kABPersonPhoneProperty withLabel:kABWorkLabel];
}

#pragma mark -
#pragma mark Generic Getters
#pragma mark -
/*
 *	This is for Address properties...
 *	Must release when done!
 */
- (NSDictionary*) getAnyAddressValue {
	NSDictionary *returnValue = nil;
	if( [self getPerson] ) {
		ABMultiValueRef multiValue = ABRecordCopyValue( [self getPerson], kABPersonAddressProperty );
		for ( CFIndex i = 0; i < ABMultiValueGetCount( multiValue ); i++ ) {
			CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, i);
			returnValue = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)dict];
			CFRelease(dict);
			break;
		}
		if( multiValue )	CFRelease(multiValue);
	}
	return returnValue;
}

/*
 *	This is for Address properties...
 *	Must release when done!
 */
- (NSDictionary*) getAddressWithLabel:(CFStringRef)theLabel {
	NSDictionary *returnValue = nil;
	if( [self getPerson] ) {
		CFStringRef label;
		ABMultiValueRef multiValue = ABRecordCopyValue( [self getPerson], kABPersonAddressProperty );
		for ( CFIndex i = 0; i < ABMultiValueGetCount( multiValue ); i++ ) {
			label = ABMultiValueCopyLabelAtIndex( multiValue, i );
			if ( CFStringCompare( label, theLabel, 0) == 0 ) {
				CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, i);
				returnValue = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)dict];
				CFRelease(dict);
			}
			// Cleanup
			CFRelease(label);
		}
		if( multiValue )	CFRelease(multiValue);
	}
	return returnValue;
}

/*
 *	This is for MULTIVALUE properties...
 *	Must release string when done!
 */
- (NSString*) getAnyValueInProperty:(ABPropertyID)theProperty {
	NSString *returnValue = nil;
	if( [self getPerson] ) {
		ABMultiValueRef multiValue = ABRecordCopyValue( [self getPerson], theProperty );
		for ( CFIndex i = 0; i < ABMultiValueGetCount( multiValue ); i++ ) {
			CFStringRef number = ABMultiValueCopyValueAtIndex(multiValue, i); 
			returnValue = [[NSString alloc] initWithString:(NSString*)number]; 
			CFRelease(number);
			break;
		}
		if( multiValue )	CFRelease(multiValue);
	}
	return returnValue;
}

/*
 *	This is for MULTIVALUE properties...
 *	Must release string when done!
 */
- (NSString*) getProperty:(ABPropertyID)theProperty withLabel:(CFStringRef)theLabel {
	NSString *returnValue = nil;
	if( [self getPerson] ) {
		CFStringRef label;
		ABMultiValueRef multiValue = ABRecordCopyValue( [self getPerson], theProperty );
		for ( CFIndex i = 0; i < ABMultiValueGetCount( multiValue ); i++ ) {
			label = ABMultiValueCopyLabelAtIndex( multiValue, i );
			if ( CFStringCompare( label, theLabel, 0) == 0 ) {
				CFStringRef number = ABMultiValueCopyValueAtIndex(multiValue, i); 
				returnValue = [[NSString alloc] initWithString:(NSString*)number]; 
				CFRelease(number);
			}
			// Cleanup
			CFRelease(label);
		}
		if( multiValue )	CFRelease(multiValue);
	}
	return returnValue;
}

#pragma mark -
#pragma mark Formatted Strings
#pragma mark -

/*
 *
 *	Must release this string when finished!
 */
- (NSString*) getMutlilineHTMLStringForReceipt {
	// Don't release name
	NSString *name = [self getClientName];
	// Use cell, home, work, or any phone # found... in that order
	NSString *phone = [self getPhoneCell];
	if( phone == nil ) {
		phone = [self getPhoneHome];		
		if( phone == nil ) {
			phone = [self getPhoneWork];
			if( phone == nil ) {
				phone = [self getPhoneAny];
			}
		}
	}
	// Address... home, work, any
	NSDictionary *address = [self getAddressHome];
	if( address == nil ) {
		address = [self getAddressWork];
		if( address == nil ) {
			address = [self getAddressAny];
		}
	}
	// Email... home, work, any
	NSString *email = [self getEmailAddressHome];
	if( email == nil ) {
		email = [self getEmailAddressWork];
		if( email == nil ) {
			email = [self getEmailAddressAny];
		}
	}
	// Generate the full string
	NSMutableString *returnValue = [[NSMutableString alloc] initWithFormat:@"%@", name];
	if( address ) {
		NSString *street = (NSString*)CFDictionaryGetValue((CFDictionaryRef)address, kABPersonAddressStreetKey);
		NSString *city = (NSString*)CFDictionaryGetValue((CFDictionaryRef)address, kABPersonAddressCityKey);
		NSString *state = (NSString*)CFDictionaryGetValue((CFDictionaryRef)address, kABPersonAddressStateKey);
		NSString *zip = (NSString*)CFDictionaryGetValue((CFDictionaryRef)address, kABPersonAddressZIPKey);
		
		if( street ) {
			[returnValue appendFormat:@"<br/>%@", CFDictionaryGetValue((CFDictionaryRef)address, kABPersonAddressStreetKey)];
		}
		
		if( city && state && zip ) {
			[returnValue appendFormat:@"<br/>%@, %@ %@", city, state, zip];
		} else if( city && state ) {
			[returnValue appendFormat:@"<br/>%@, %@", city, state];
		} else if( city && !state && zip ) {
			[returnValue appendFormat:@"<br/>%@, %@", city, zip];
		} else if( !city && state && zip ) {
			[returnValue appendFormat:@"<br/>%@, %@", state, zip];
		} else if( city ) {
			[returnValue appendFormat:@"<br/>%@", city];
		} else if( state ) {
			[returnValue appendFormat:@"<br/>%@", state];
		} else if( zip ) {
			[returnValue appendFormat:@"<br/>%@", zip];
		}
	}
	
	if( phone ) {
		[returnValue appendFormat:@"<br/>%@", phone];
	}
	if( email ) {
		[returnValue appendFormat:@"<br/>%@", email];
	}
	
	[address release];
	[email release];
	[phone release];
	return returnValue;
}

- (void) updateClientNameFromContact {
	if( [self getPerson] ) {
		CFStringRef first = ABRecordCopyValue( [self getPerson], kABPersonFirstNameProperty );
		if( first != nil ) {
			self.firstName = [NSString stringWithString:(NSString*)first];
			CFRelease(first);
		} else {
			self.firstName = nil;
		}
		
		CFStringRef last = ABRecordCopyValue( [self getPerson], kABPersonLastNameProperty );
		if( last != nil ) {
			self.lastName = [NSString stringWithString:(NSString*)last];
			CFRelease(last);
		} else {
			self.lastName = nil;
		}
	}
}

@end