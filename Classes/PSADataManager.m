//
//  PSADataManager.m
//  myBusiness
//
//  Created by David J. Maier on 10/14/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "Client.h"
#import "CloseOut.h"
#import "Company.h"
#import "CreditCardPayment.h"
#import "CreditCardResponse.h"
#import "CreditCardSettings.h"
#import "Email.h"
#import "GiftCertificate.h"
#import "Product.h"
#import "ProductAdjustment.h"
#import "ProductType.h"
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectInvoiceItem.h"
#import "ProjectProduct.h"
#import "ProjectService.h"
#import "PSAAppDelegate.h"
#import "Report.h"
#import "Service.h"
#import "ServiceGroup.h"
#import "Settings.h"
#import "Transaction.h"
#import "TransactionItem.h"
#import "TransactionPayment.h"
#import "Vendor.h"
#import "PSADataManager.h"

// Singleton Object
static PSADataManager *mySharedDelegate = nil;

@implementation PSADataManager

@synthesize addressBook, addressBookGroup, askAboutRecoveringClients, clientNameSortOption, clientNameViewOption, delegate;

- (void) dealloc {
	if( addressBook )		CFRelease(addressBook);
	if( addressBookGroup )	CFRelease(addressBookGroup);
	// TODO: Need this cancel?
	[operationQueue cancelAllOperations];
	[operationQueue release];
	[dbManager release];
	[super dealloc];
}

#pragma mark -
#pragma mark Threading and DBManager Delegate Methods
#pragma mark -
/*
 *
 */
- (NSOperationQueue *) operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

/*
 *	NO NEED TO RELEASE ARRAY!
 *	Retain if needed.
 */
- (void) dbReturnedArray:(NSArray*)theArray {
	[self.delegate dataManagerReturnedArray:theArray];
}

/*
 *	NO NEED TO RELEASE DICTIONARY!
 *	Retain if needed.
 */
- (void) dbReturnedDictionary:(NSDictionary*)theDictionary {
	[self.delegate dataManagerReturnedDictionary:theDictionary];
}

- (void) dbReturnedNothing {
	[self.delegate dataManagerReturnedNothing];
}

- (void) dbReturnedError:(NSString*)theMessage {
	[self showError:theMessage];
}

#pragma mark -
#pragma mark Database Methods
#pragma mark -
/*
 *
 *
 */
- (void) loadDatabase {
	askAboutRecoveringClients = YES;
	// Initialize the database manager
	dbManager = [[PSADatabaseManager alloc] init];
	[dbManager setDelegate:self];
	// Initialize database connection
    [dbManager initializeDatabase];
	// Get the client name view option
	clientNameSortOption = [dbManager getClientNameSortSetting];
	clientNameViewOption = [dbManager getClientNameViewSetting];
}

/*
 *
 *
 */
- (void) prepareForExit {
	[dbManager closeDatabase];
}

#pragma mark -
#pragma mark Client Methods
#pragma mark -

/*
 *
 */
- (void) attemptRecoveryForAllClients:(NSDictionary*)theClients {
	BOOL thereWasAFailure = NO;
	for( NSArray *tmp in [theClients allValues] ) {
		if( (NSNull*)tmp != [NSNull null] ) {
			for( Client *tmpClient in tmp ) {
				if( tmpClient.clientID > 0 && ![tmpClient getPerson] ) {
					if( ![self attemptRecoveryForClient:tmpClient] ) {
						thereWasAFailure = YES;
					}
				}
			}
		}
	}
	
	if( thereWasAFailure ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Recovery" message:@"One or more of your clients could not be recovered. They are shown with a red background.\n\nYou will have to select these Contacts manually." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
}

/*
 *
 */
- (BOOL) attemptRecoveryForClient:(Client*)theClient {
	BOOL returnValue = NO;
	NSArray *matches = (NSArray*)ABAddressBookCopyPeopleWithName( self.addressBook, (CFStringRef)[theClient getClientName] );
	if( matches.count == 1 ) {
		ABRecordRef person = [matches objectAtIndex:0];
		theClient.personID = ABRecordGetRecordID(person);
		[theClient updateClientNameFromContact];
		[self updateClient:theClient];
		returnValue = YES;
	} else {
		if( matches.count > 1 ) {
			//DebugLog( @"Too many matches for %@", [theClient getClientName] );
			/*
			// Check the first and last names explicitly for each match...
			// But what if there are 2 Contacts with the same name???
			// I think it would be best to let the user handle that, since there is no way to replace a contact for a client... yet
			for( NSInteger i=0; i < matches.count; i++ ) {
				ABRecordRef foundPerson = [matches objectAtIndex:i];
				BOOL firstMatches = NO;
				BOOL lastMatches = NO;
				CFStringRef first = ABRecordCopyValue( foundPerson, kABPersonFirstNameProperty );
				CFStringRef last = ABRecordCopyValue( foundPerson, kABPersonLastNameProperty );
				NSString *ourFirst = [theClient getFirstName];
				NSString *ourLast = [theClient getLastName];
				
				if( first != nil ) {
					if( [ourFirst isEqualToString:(NSString*)first] ) {
						firstMatches = YES;
						DebugLog( @"Match for First %@ %@ %@ %@", ourFirst, ourLast, first, last );
					}
					CFRelease(first);
				} else if( ourFirst == nil ) {
					// They are both nil
					DebugLog( @"Match for nil firsts" );
					firstMatches = YES;
				}
				
				if( last != nil ){
					if( [ourLast isEqualToString:(NSString*)last] ) {
						lastMatches = YES;
						DebugLog( @"Match for Last %@ %@ %@ %@", ourFirst, ourLast, first, last );
					}
					CFRelease(last);
				} else if( ourLast == nil ) {
					// They are both nil
					DebugLog( @"Match for nil lasts" );
					lastMatches = YES;
				}
				
				if( firstMatches && lastMatches ) {
					// If first and last both matched...
					theClient.personID = ABRecordGetRecordID( foundPerson );
					[theClient updateClientNameFromContact];
					[self updateClient:theClient];
					return YES;
				}
			}
			 */
			
		}
	}
	[matches release];
	return returnValue;
}

/*
 *	Looks for any indication of an existing AddressBook Group named "APPLICATION_NAME Clients"
 *	Makes reference to it if exists, creates the group and saves it if it doesn't exist.
 *	Checks a written PList file for the groupID, or all of the existing groups' titles in the AB.
 */
- (void) createAddressBookGroupIfNecessary {
	NSString *groupName = [[NSString alloc] initWithFormat:@"%@ Clients", APPLICATION_NAME];
	// File Path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
	// Address Book
	addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	// Fetch existing group ID
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:writableDBPath];
	if( dict ) {
		NSNumber *groupID = [dict objectForKey:@"AddressBookGroupID"];
		addressBookGroup = ABAddressBookGetGroupWithRecordID( addressBook, [groupID intValue] );
		
		// TODO: If the address book group's ID changes, does that make the object nil and cause an EXC_BAD_ACCESS below?
		
		// Check the name of the group (we renamed to APPLICATION_NAME from iBiz)
		NSString *name = (NSString*)ABRecordCopyValue( addressBookGroup, kABGroupNameProperty );
		if( [name isEqualToString:@"iBiz Clients"] ) {
			// Rename the group
			ABRecordSetValue(addressBookGroup, kABGroupNameProperty, groupName, nil);
			BOOL abSaveSuccess = ABAddressBookSave( addressBook, nil );
			if( !abSaveSuccess ) {
				DebugLog( @"There was an issue renaming the %@ AddressBook Group", APPLICATION_NAME );
			}
		}
		[name release];
	}
	[dict release];
	
	// Nothing found
	if( !addressBookGroup ) {
		// Look through existing groups
		NSArray *groups = (NSArray*)ABAddressBookCopyArrayOfAllGroups( addressBook );
		for( int i = 0; i < groups.count; i++ ) {
			NSString *name = (NSString*)ABRecordCopyValue( [groups objectAtIndex:i], kABGroupNameProperty );
			if( [name isEqualToString:groupName] ) {
				addressBookGroup = [groups objectAtIndex:i];
				break;
			} else if( [name isEqualToString:@"iBiz Clients"] ) {
				addressBookGroup = [groups objectAtIndex:i];
				// Rename the group
				ABRecordSetValue(addressBookGroup, kABGroupNameProperty, groupName, nil);
				BOOL abSaveSuccess = ABAddressBookSave( addressBook, nil );
				if( !abSaveSuccess ) {
					DebugLog( @"There was an issue renaming the %@ AddressBook Group", APPLICATION_NAME );
				}
				break;
			}
			[name release];
		}
		[groups release];
		
		// Still nothing found
		if( !addressBookGroup ) {
			// Otherwise add a new one
			addressBookGroup = ABGroupCreate();
			ABRecordSetValue( addressBookGroup, kABGroupNameProperty, groupName, nil );
			BOOL abAddGroupSuccess = ABAddressBookAddRecord( addressBook, addressBookGroup, nil);
			BOOL abSaveSuccess = ABAddressBookSave( addressBook, nil );
			if( abAddGroupSuccess && abSaveSuccess ) {
				NSNumber *num = [[NSNumber alloc] initWithInt:ABRecordGetRecordID(addressBookGroup)];
				NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
				[newDict setObject:num forKey:@"AddressBookGroupID"];
				[num release];
				[newDict writeToFile:writableDBPath atomically:YES];
				[newDict release];
			}
		}
	}
	[groupName release];
}

/*
 *	getClientDateFormat
 *	Returns the format of date that is stored as a string in our DB
 */
- (NSDateFormatterStyle) getClientDateFormat {
	return NSDateFormatterShortStyle;
}

/*
 *	getClients
 *	Returns the clients, or loads them if necessary
 *	THREADED!
 */
- (void) getClientsWithActiveFlag:(BOOL)active {
	NSNumber *activeFlag = [[NSNumber alloc] initWithBool:active];
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getClientsWithActiveFlag:) object:activeFlag];
	[self.operationQueue addOperation:op];
	[op release];
	[activeFlag release];
}

/*
 *	getClientsDictionaryWithLastNameKeys
 *	Returns a dictionary of client arrays for today, tomorrow, and the next 7 days.
 *	Need to release NSDictionary when finished!
 */
- (NSDictionary*) getClientsDictionaryWithArray:(NSArray*)theArray isBirthday:(BOOL)isBirthday {	
	// Start with a dictionary of keys and NSNull objects
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"Today", [NSNull null], @"Tomorrow", [NSNull null], @"Next 7 Days", nil];
	// Some variables
	NSString *firstName;
	NSString *lastName;
	NSString *key;
	// Reusable calendar
	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
	// Components to add to dates
	NSDateComponents *addComps = [[NSDateComponents alloc] init];
	[addComps setDay:1];
	// Get today's date without time
	NSDateComponents *todayComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	NSDate *today = [calendar dateFromComponents:todayComps];
	// Rest of the dates
	NSDate *tomorrow = [calendar dateByAddingComponents:addComps toDate:today options:0];
	NSDate *dayAfterTomorrow = [calendar dateByAddingComponents:addComps toDate:tomorrow options:0];
	[addComps setDay:8];
	NSDate *dayEightFromToday = [calendar dateByAddingComponents:addComps toDate:today options:0];
	[addComps release];
	
	NSDate *clientDate = nil;
	
	for( Client* client in theArray ) {
		firstName = [client getFirstName];
		lastName = [client getLastName];
		
		if( isBirthday ) {
			clientDate = [client getBirthdate];
		} else {
			clientDate = [client getAnniversaryDate];
		}
		
		if( clientDate ) {
			NSDateComponents *birthComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:clientDate];
			[birthComps setYear:[todayComps year]];
			[clientDate release];
			clientDate = [calendar dateFromComponents:birthComps];
			
			if( [clientDate compare:today] != NSOrderedAscending && [clientDate compare:tomorrow] == NSOrderedAscending ) {
				key = @"Today";
			} else if( [clientDate compare:tomorrow] != NSOrderedAscending && [clientDate compare:dayAfterTomorrow] == NSOrderedAscending ) {
				key = @"Tomorrow";
			} else if( [clientDate compare:dayAfterTomorrow] != NSOrderedAscending && [clientDate compare:dayEightFromToday] == NSOrderedAscending ) {
				key = @"Next 7 Days";
			} else {
				key = nil;
			}
			
			if( key ) {
				NSMutableArray *array = [dict objectForKey:key];
				if( (NSNull *)array == [NSNull null] ){
					array = [[NSMutableArray alloc] init];
					[dict setObject:array forKey:key];
					[array release];
				}
				
				// Insert sorted by last name
				BOOL inserted = NO;
				for( NSInteger i=0; i < array.count; i++ ) {
					Client *existing = [array objectAtIndex:i];
					if( clientNameSortOption == 0 ) {
						NSString *existingLast = [existing getLastName];
						NSComparisonResult result = [lastName compare:existingLast];
						if( result == NSOrderedAscending ) {
							inserted = YES;
							[array insertObject:client atIndex:i];
							break;
						}
					} else {
						NSString *existingFirst = [existing getFirstName];
						NSComparisonResult result = [firstName compare:existingFirst];
						if( result == NSOrderedAscending ) {
							inserted = YES;
							[array insertObject:client atIndex:i];
							break;
						}
					}
				}
				if( !inserted ) {
					[array addObject:client];
				}
			}
		}
		
		key = nil;
		firstName = nil;
		lastName = nil;
		clientDate = nil;
	}
	
	return dict;
}

/*
 *	getClientsDictionaryWithArray
 *	Returns a dictionary of client arrays for each letter index (0-25) of the alphabet.
 *	Used for indexing on the table view.
 *	Need to release NSDictionary when finished!
 */
- (NSDictionary*) getClientsDictionaryWithArray:(NSArray*)theArray {	
	// Start with a dictionary of alphabet keys and NSNull objects
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"", [NSNull null], @"A", [NSNull null], @"B", [NSNull null], @"C", [NSNull null], @"D", [NSNull null], @"E", [NSNull null], @"F", [NSNull null], @"G", [NSNull null], @"H", [NSNull null], @"I", [NSNull null], @"J", [NSNull null], @"K", [NSNull null], @"L", [NSNull null], @"M", [NSNull null], @"N", [NSNull null], @"O", [NSNull null], @"P", [NSNull null], @"Q", [NSNull null], @"R", [NSNull null], @"S", [NSNull null], @"T", [NSNull null], @"U", [NSNull null], @"V", [NSNull null], @"W", [NSNull null], @"X", [NSNull null], @"Y", [NSNull null], @"Z", nil];
	// Make an array and populate with the clients
	NSString *firstName;
	NSString *lastName;
	NSString *key;
	for( Client* client in theArray ) {
		firstName = [client getFirstName];
		lastName = [client getLastName];
		
		if( clientNameSortOption == 0 ) {
			if( lastName == nil || [lastName length] == 0 ) {
				key = [[NSString alloc] initWithString:@""];
			} else {
				key = [[NSString alloc] initWithString:[[lastName substringToIndex:1] uppercaseString]];
			}
		} else {
			if( firstName == nil || [firstName length] == 0 ) {
				key = [[NSString alloc] initWithString:@""];
			} else {
				key = [[NSString alloc] initWithString:[[firstName substringToIndex:1] uppercaseString]];
			}
		}
		
		NSMutableArray *array = [dict objectForKey:key];
		if( (NSNull *)array == [NSNull null] ){
			array = [[NSMutableArray alloc] init];
			[dict setObject:array forKey:key];
			[array release];
		}

		// Insert sorted by last name
		BOOL inserted = NO;
		for( NSInteger i=0; i < array.count; i++ ) {
			Client *existing = [array objectAtIndex:i];
			if( clientNameSortOption == 0 ) {
				NSString *existingLast = [existing getLastName];
				NSComparisonResult result = [lastName compare:existingLast];
				if( result == NSOrderedAscending ) {
					inserted = YES;
					[array insertObject:client atIndex:i];
					break;
				}
			} else {
				NSString *existingFirst = [existing getFirstName];
				NSComparisonResult result = [firstName compare:existingFirst];
				if( result == NSOrderedAscending ) {
					inserted = YES;
					[array insertObject:client atIndex:i];
					break;
				}
			}
		}
		if( !inserted ) {
			[array addObject:client];
		}

		[key release];
		key = nil;
		firstName = nil;
		lastName = nil;
	}
	return dict;
}

/*
 *	removeClient
 *	Removes from DB and from client array
 */
- (void) removeClient:(Client*)client {
	[client deleteClient];
	// Remove from db
	[dbManager removeClient:client.clientID];
	// Remove from clients array
	//[clients removeObject:client];
}

/*
 *	saveNewClient
 *	Saves to the DB, and adds to the client array
 */
- (void) saveNewClient:(Client*)client {
	[dbManager insertClient:client];
	// Add the client to our array
	//[clients addObject:client];
}

/*
 *	updateClient
 *	Updates the client in the database
 */
- (void) updateClient:(Client*)client {
	[dbManager updateClient:client];
}


#pragma mark -
#pragma mark Company Methods
#pragma mark -

/*
 *	getCompany
 *	Gets the first company in the DB... I'd imagine there'd only be 1
 *	Need to release when done!
 */
- (Company*) getCompany {
	return [dbManager getCompany];
}

/*
 *	saveCompany
 *	Inserts a company into the DB.
 */
- (void) saveCompany:(Company*)theCompany {
	//[dbManager saveCompany:theCompany];
}

/*
 *	updateCompany
 *	Updates the company in the DB.
 */
- (void) updateCompany:(Company*)theCompany {
	[dbManager updateCompany:theCompany];
}

#pragma mark -
#pragma mark Email Methods
#pragma mark -
/*
 *	Must release when done!
 */
- (Email*) getAnniversaryEmail {
	return [dbManager getEmailOfType:PSAEmailTypeAnniversary];
}

/*
 *	Must release when done!
 */
- (Email*) getAppointmentReminderEmail {
	return [dbManager getEmailOfType:PSAEmailTypeAppointmentReminder];
}

/*
 *	Must release when done!
 */
- (Email*) getBirthdayEmail {
	return [dbManager getEmailOfType:PSAEmailTypeBirthday];
}

- (void) saveEmail:(Email*)theEmail {
	if( theEmail.emailID > -1 ) {
		[dbManager updateEmail:theEmail];
	} else {
		// Insert not needed yet...
	}
}


#pragma mark -
#pragma mark Product Methods
#pragma mark -
/*
 *	getDictionaryOfProductsByType
 *	Must release when done!
 */
- (void) getDictionaryOfProductsByTypeWithActiveFlag:(BOOL)active {
	NSNumber *activeFlag = [[NSNumber alloc] initWithBool:active];
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getDictionaryOfProductsByTypeWithActiveFlag:) object:activeFlag];
	[self.operationQueue addOperation:op];
	[op release];
	[activeFlag release];
}

/*
 *	Must release when done!
 */
- (void) getProductAdjustmentsForReport:(Report*)theReport {
	BOOL invoke = NO;
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getProductAdjustmentsFromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getProductAdjustmentsFromDate:toDate:)];
	
	if( theReport ) {
		if( theReport.isEntireHistory ) {
			invoke = YES;
			//[invocation setArgument:nil atIndex:2];
			//[invocation setArgument:nil atIndex:3];
		} else {
			invoke = YES;
			NSDate *start = theReport.dateStart;
			NSDate *end = theReport.dateEnd;
			[invocation setArgument:&start atIndex:2];
			[invocation setArgument:&end atIndex:3];
		}
	} else {
		invoke = YES;
		//[invocation setArgument:nil atIndex:2];
		//[invocation setArgument:nil atIndex:3];
	}
	
	if( invoke ) {
		NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
		if( op ) {
			[self.operationQueue addOperation:op];
		}
		[op release];
	} else {
		[self dbReturnedArray:nil];
	}
}

/*
 *	getProductTypes
 *	Must release when done!
 */
- (NSArray*) getProductTypes {
	return [dbManager getProductTypes];
}

/*
 *	getProductWithID
 *	Must release when done!
 */
- (Product*) getProductWithID:(NSInteger)theID {
	return [dbManager getProductWithID:theID];
}

/*
 *
 *	Inserts a product adjustment. (More for use with the ProductInventoryViewController...)
 */
- (void) insertProductAdjustment:(ProductAdjustment*)theAdjustment {
	[dbManager insertProductAdjustment:theAdjustment];
}

/*
 *
 */
- (void) removeProduct:(Product*)theProduct {
	theProduct.isActive = NO;
	[dbManager updateProduct:theProduct];
}

- (void) removeProductAdjustmentWithID:(NSInteger)theID {
	[dbManager deleteProductAdjustmentWithID:theID];
}

/*
 *
 */
- (void) removeProductType:(ProductType*)theType {
	[dbManager removeProductType:theType];
	[dbManager bulkUpdateProductTypeToDefaultFromType:theType];
}

/*
 *	saveProductType
 *	Saves or updates the product type in the DB
 */
- (void) saveProductType:(ProductType*)theType {
	if( theType.typeID > -1 ) {
		[dbManager updateProductType:theType];
	} else {
		[dbManager insertProductType:theType];
	}
}

/*
 *	saveProduct
 *	Inserts or updates the product in the DB
 */
- (void) saveProduct:(Product*)theProduct {
	if( theProduct.productID > -1 ) {
		[dbManager updateProduct:theProduct];
	} else {
		[dbManager insertProduct:theProduct];
		for( ProductAdjustment *tmp in theProduct.adjustmentsNeedSaving ) {
			tmp.productID = theProduct.productID;
			[dbManager insertProductAdjustment:tmp];
		}
	}
}

#pragma mark -
#pragma mark Projects
#pragma mark -
/*
 *
 */
- (void) hydrateProject:(Project*)theProject {
	// Appointments
	NSMutableArray *appts = [dbManager getAppointmentsForProject:theProject];
	theProject.appointments = appts;
	[appts release];
	// Products
	NSMutableArray *prods = [dbManager getArrayOfProductsForProject:theProject];
	theProject.products = prods;
	[prods release];
	// Services
	NSMutableArray *servs = [dbManager getArrayOfServicesForProject:theProject];
	theProject.services = servs;
	[servs release];
	// Payments
	NSMutableArray *estimates = [theProject.payments objectForKey:[theProject getKeyForEstimates]];
	NSMutableArray *invoices = [theProject.payments objectForKey:[theProject getKeyForInvoices]];
	
	NSArray *dbPayments = [dbManager getArrayOfInvoicesForProject:theProject];
	for( ProjectInvoice *theInvoice in dbPayments ) {
		// Get Products, matching InvoiceItem with the associated ProjectProduct
		NSMutableArray *invoiceProds = [dbManager getArrayOfInvoiceProductsForInvoice:theInvoice];
		for( ProjectInvoiceItem *tmp in invoiceProds ) {
			for( ProjectProduct *prod in theProject.products ) {
				if( prod.projectProductID == tmp.itemID ) {
					tmp.item = prod;
				}
			}
		}
		theInvoice.products = invoiceProds;
		[invoiceProds release];
		// Get Services, matching InvoiceItem with the associated ProjectService
		NSMutableArray *invoiceServs = [dbManager getArrayOfInvoiceServicesForInvoice:theInvoice];
		for( ProjectInvoiceItem *tmp in invoiceServs ) {
			for( ProjectService *serv in theProject.services ) {
				if( serv.projectServiceID == tmp.itemID ) {
					tmp.item = serv;
				}
			}
		}
		theInvoice.services = invoiceServs;
		[invoiceServs release];
		
		NSMutableArray *pays = [dbManager getTransactionPaymentsForInvoice:theInvoice];
		theInvoice.payments = pays;
		[pays release];
		
		if( theInvoice.type == iBizProjectEstimate ) {
			[estimates addObject:theInvoice];
		} else {
			[invoices addObject:theInvoice];
		}
	}
	[dbPayments release];
	
	NSMutableArray *trannies = [dbManager getTransactionsForProject:theProject];
	// Get Non-Invoiced Transactions, hydrating them to show proper totals on ProjectView
	[theProject.payments setObject:trannies forKey:[theProject getKeyForTransactions]];
	[[theProject.payments objectForKey:[theProject getKeyForTransactions]] makeObjectsPerformSelector:@selector(hydrate)];
	[trannies release];
}

/*
 *	No need to release when done?
 */
- (void) getArrayOfProjectsByType:(NSInteger)type {
	NSNumber *typeFlag = [[NSNumber alloc] initWithInteger:type];
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getArrayOfProjectsByType:) object:typeFlag];
	[self.operationQueue addOperation:op];
	[op release];
	[typeFlag release];
}

/*
 *	No need to release when done?
 */
- (void) getArrayOfProjectsForClient:(Client*)theClient {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getArrayOfProjectsForClient:) object:theClient];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	No release needed...
 */
- (void) getArrayOfInvoicesFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getInvoicesFromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getInvoicesFromDate:toDate:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	No need to release when done?
 */
- (void) getArrayOfUnpaidInvoicesByType:(NSInteger)type {
	NSNumber *typeFlag = [[NSNumber alloc] initWithInteger:type];
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getArrayOfUnpaidInvoicesByType:) object:typeFlag];
	[self.operationQueue addOperation:op];
	[op release];
	[typeFlag release];
}

/*
 *	MUST release when done!
 */
- (NSDictionary*) getDictionaryOfProjectsFromArray:(NSArray*)projects {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSDate *key = nil;
	NSDateComponents *comps = nil;
	for( Project *tmp in projects ) {
		// Key based on activity date
		if( tmp.dateModified ) {
			comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tmp.dateModified];
		} else {
			comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tmp.dateCreated];
		}
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		key = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
		//
		NSMutableArray *array = [dict objectForKey:key];
		if( !array ){
			array = [[NSMutableArray alloc] init];
			[dict setObject:array forKey:key];
			[array release];
		}
		//
		[array addObject:tmp];
		key = nil;
	}
	return dict;
}

/*
 *	MUST release when done!
 */
- (ProjectInvoice*)	getInvoiceWithPaymentID:(NSInteger)paymentID {
	return [dbManager getInvoiceWithPaymentID:paymentID];
}

/*
 *	MUST release when done!
 */
- (Project*) getProjectWithID:(NSInteger)projectID {
	return [dbManager getProjectWithID:projectID];
}

/*
 *	MUST release when done!
 */
- (Project*) getProjectWithInvoiceID:(NSInteger)invoiceID {
	return [dbManager getProjectWithInvoiceID:invoiceID];
}

/*
 *
 */
- (void) removeInvoice:(ProjectInvoice*)theInvoice {
	// Delete From DB
	for( ProjectInvoiceItem *tmp in theInvoice.products ) {
		if( tmp.invoiceItemID > -1 ) {
			[self removeInvoiceProduct:tmp];
		}
	}
	for( ProjectInvoiceItem *tmp in theInvoice.services ) {
		if( tmp.invoiceItemID > -1 ) {
			[self removeInvoiceService:tmp];
		}
	}
	for( TransactionPayment *tmp in theInvoice.payments ) {
		if( tmp.transactionPaymentID > -1 ) {
			// Refund any gift certificates
			if( tmp.paymentType == PSATransactionPaymentGiftCertificate && tmp.amountOriginal ) {
				if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] > 0.0 ) {
					NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amountOriginal doubleValue]-[tmp.amount doubleValue]];
					[[PSADataManager sharedInstance] refundAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
					[num release];
					tmp.amountOriginal = nil;
				}
			}
			[self removeTransactionPayment:tmp];
			[self removeInvoicePaymentFromCloseouts:tmp];
		}
	}
	// Invoice itself
	[dbManager deleteProjectInvoiceWithID:theInvoice.invoiceID];
}

/*
 *
 */
- (void) removeInvoicePaymentFromCloseouts:(TransactionPayment*)thePayment {
	[dbManager deleteProjectInvoicePaymentFromCloseouts:thePayment];
}

/*
 *
 */
- (void) removeInvoiceProduct:(ProjectInvoiceItem*)theItem {
	[dbManager deleteProjectInvoiceProduct:theItem.invoiceItemID];
}

/*
 *
 */
- (void) removeInvoiceService:(ProjectInvoiceItem*)theItem {
	[dbManager deleteProjectInvoiceService:theItem.invoiceItemID];
}


/*
 *	Make sure to propogate the deletion to any products, services, etc for the Project.
 */
- (void) removeProject:(Project*)theProject {
	// Remove any standing appointments... the appointments themselves are deleted in deleteProjectWithID:
	for( Appointment *tmp in theProject.appointments ) {
		[dbManager deleteStandingAppointment:tmp];
	}
	// Estimates/Invoices ARE NOT REMOVED, but should be before the project can be deleted.
	[dbManager deleteProjectWithID:theProject.projectID];
}

/*
 *
 */
- (void) removeProjectProduct:(ProjectProduct*)projectProduct fromProject:(Project*)theProject {
	[dbManager deleteProductAdjustmentWithID:projectProduct.productAdjustment.productAdjustmentID];
	[dbManager deleteProjectProductWithID:projectProduct.projectProductID];
	// Remove from Invoices
	NSMutableArray *removeProducts = [[NSMutableArray alloc] init];
	for( ProjectInvoice *theInvoice in [theProject.payments objectForKey:[theProject getKeyForEstimates]] ) {
		for( ProjectInvoiceItem *tmp in theInvoice.products ) {
			if( tmp.item == projectProduct ) {
				[self removeInvoiceProduct:tmp];
				[removeProducts addObject:tmp];
			}
		}
		for( ProjectInvoiceItem *tmp in removeProducts ) {
			[theInvoice.products removeObject:tmp];
		}
		[removeProducts removeAllObjects];
	}
	for( ProjectInvoice *theInvoice in [theProject.payments objectForKey:[theProject getKeyForInvoices]] ) {
		for( ProjectInvoiceItem *tmp in theInvoice.products ) {
			if( tmp.item == projectProduct ) {
				[self removeInvoiceProduct:tmp];
				[removeProducts addObject:tmp];
			}
		}
		for( ProjectInvoiceItem *tmp in removeProducts ) {
			[theInvoice.products removeObject:tmp];
		}
		[removeProducts removeAllObjects];
	}
	[removeProducts release];
}

/*
 *
 */
- (void) removeProjectService:(ProjectService*)projectService fromProject:(Project*)theProject {
	[dbManager deleteProjectServiceWithID:projectService.projectServiceID];
	// Remove from Invoices
	NSMutableArray *removeServices = [[NSMutableArray alloc] init];
	for( ProjectInvoice *theInvoice in [theProject.payments objectForKey:[theProject getKeyForEstimates]] ) {
		for( ProjectInvoiceItem *tmp in theInvoice.services ) {
			if( tmp.item == projectService ) {
				[self removeInvoiceService:tmp];
				[removeServices addObject:tmp];
			}
		}
		for( ProjectInvoiceItem *tmp in removeServices ) {
			[theInvoice.services removeObject:tmp];
		}
		[removeServices removeAllObjects];
	}
	for( ProjectInvoice *theInvoice in [theProject.payments objectForKey:[theProject getKeyForInvoices]] ) {
		for( ProjectInvoiceItem *tmp in theInvoice.services ) {
			if( tmp.item == projectService ) {
				[self removeInvoiceService:tmp];
				[removeServices addObject:tmp];
			}
		}
		for( ProjectInvoiceItem *tmp in removeServices ) {
			[theInvoice.services removeObject:tmp];
		}
		[removeServices removeAllObjects];
	}
	[removeServices release];
}

/*
 *
 */
- (void) saveInvoice:(ProjectInvoice*)theInvoice {
	// Update the total
	theInvoice.totalForTable = [theInvoice getTotal];
	//
	if( theInvoice.invoiceID > -1 ) {
		// Check Paid
		//DebugLog( @"Change: %f", round([[theTransaction getChangeDue] doubleValue]*100)/100 );
		if( round([[theInvoice getChangeDue] doubleValue]*100)/100 >= 0.00 && theInvoice.datePaid == nil && theInvoice.type == iBizProjectInvoice) {
			// Close (should only happen once)
			theInvoice.datePaid = [NSDate date];
		}
		// Update
		[dbManager updateInvoice:theInvoice];
	} else {
		// Open
		theInvoice.dateOpened = [NSDate date];
		// Check Paid
		if( round([[theInvoice getChangeDue] doubleValue]*100)/100 >= 0.00 && theInvoice.type == iBizProjectInvoice ) {
			// Close (should only happen once)
			theInvoice.datePaid = [NSDate date];
		}
		// Insert, getting back the invoiceID for setting
		[dbManager insertInvoice:theInvoice];
	}

	// Products
	for( ProjectInvoiceItem *tmp in theInvoice.products ) {
		// Save the InvoiceItem... no update should be needed, since the InvoiceItem only stores
		// a reference to the projectInvoiceID and projectProductID
		if( tmp.invoiceItemID == -1 ) {
			tmp.invoiceID = theInvoice.invoiceID;
			[dbManager insertInvoiceProduct:tmp];
		}
	}

	// Services
	for( ProjectInvoiceItem *tmp in theInvoice.services ) {
		// Save the InvoiceItem... no update should be needed, since the InvoiceItem only stores
		// a reference to the projectInvoiceID and projectProductID
		if( tmp.invoiceItemID == -1 ) {
			tmp.invoiceID = theInvoice.invoiceID;
			[dbManager insertInvoiceService:tmp];
		}
	}

	// Payments
	for( TransactionPayment *tmp in theInvoice.payments ) {
		if( tmp.transactionPaymentID > -1 ) {
			// Update Payment
			[dbManager updateTransactionPayment:tmp];
			// Adjust the amountUsed from a GiftCertificate
			if( tmp.paymentType == PSATransactionPaymentGiftCertificate && tmp.amountOriginal ) {
				if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] > 0.0 ) {
					NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amountOriginal doubleValue]-[tmp.amount doubleValue]];
					[dbManager refundAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
					[num release];
					tmp.amountOriginal = nil;
				} else if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] < 0.0 ) {
					NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amount doubleValue]-[tmp.amountOriginal doubleValue]];
					[dbManager deductAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
					[num release];
					tmp.amountOriginal = nil;
				}
			}
		} else {
			// Insert Payment
			[dbManager insertTransactionPayment:tmp forInvoiceID:theInvoice.invoiceID];
			// Deduct from GiftCertificate
			if( tmp.paymentType == PSATransactionPaymentGiftCertificate ) {
				[dbManager deductAmount:tmp.amount fromCertificateID:[tmp.extraInfo integerValue]];
			}
		}
	}

}

/*
 *
 */
- (void) saveProject:(Project*)theProject {
	theProject.totalForTable = [theProject getInvoiceTotals];
	if( theProject.projectID > -1 ) {
		theProject.dateModified = [NSDate date];
		[dbManager updateProject:theProject];
	} else {
		theProject.dateCreated = [NSDate date];
		theProject.dateModified = theProject.dateCreated;
		[dbManager insertProject:theProject];
	}
}

/*
 *
 */
- (void) saveProjectProduct:(ProjectProduct*)theProjectProduct {
	// Do the productAdjustment first to get it's ID if inserted
	if( theProjectProduct.productAdjustment ) {
		if( theProjectProduct.productAdjustment.productAdjustmentID > -1 ) {
			[dbManager updateProductAdjustment:theProjectProduct.productAdjustment];
		} else {
			theProjectProduct.productAdjustment.productID = theProjectProduct.productID;
			[dbManager insertProductAdjustment:theProjectProduct.productAdjustment];
		}
	}
	// Save the ProjectProduct itself
	if( theProjectProduct.projectProductID > -1 ) {
		[dbManager updateProjectProduct:theProjectProduct];
	} else {
		[dbManager insertProjectProduct:theProjectProduct];
	}
}

/*
 *
 */
- (void) saveProjectService:(ProjectService*)theProjectService {
	if( theProjectService.projectServiceID > -1 ) {
		[dbManager updateProjectService:theProjectService];
	} else {
		[dbManager insertProjectService:theProjectService];
	}
}

/*
 *
 */
- (void) updateAllInvoicesAndProject:(Project*)theProject {
	// Update Invoice & Project totals
	for( ProjectInvoice *tmp in [theProject.payments objectForKey:[theProject getKeyForInvoices]] ) {
		[self updateInvoiceTotal:tmp];
	}
	for( ProjectInvoice *tmp in [theProject.payments objectForKey:[theProject getKeyForEstimates]] ) {
		[self updateInvoiceTotal:tmp];
	}
	[self updateProjectTotal:theProject];
}

/*
 *
 */
- (void) updateInvoiceTotal:(ProjectInvoice*)theInvoice {
	theInvoice.totalForTable = [theInvoice getTotal];
	[dbManager updateInvoiceTotal:theInvoice];
}

/*
 *
 */
- (void) updateProjectTotal:(Project*)theProject {
	theProject.dateModified = [NSDate date];
	theProject.totalForTable = [theProject getInvoiceTotals];
	[dbManager updateProjectTotal:theProject];
}

#pragma mark -
#pragma mark Register
#pragma mark -

/*
 *
 */
- (void) deductAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID {
	[dbManager deductAmount:amount fromCertificateID:theID];
}

/*
 *
 */
- (void) deleteGiftCertificate:(GiftCertificate*)theCert {
	
}

/*
 *
 */
- (void) refundAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID {
	[dbManager refundAmount:amount fromCertificateID:theID];
}

/*
 *	MUST release when done!
 */
- (void) getArrayOfCloseoutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getArrayOfCloseoutsFromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getArrayOfCloseoutsFromDate:toDate:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsForClient:(Client*)theClient {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getTransactionsForClient:) object:theClient];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	MUST release when done!
 */
- (NSDictionary*) getDictionaryOfTransactionsFromArray:(NSArray*)transactions {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSDate *key = nil;
	NSDateComponents *comps = nil;
	for( Transaction *tmp in transactions ) {
		// Key based on activity date
		if( tmp.dateVoided ) {
			comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tmp.dateVoided];
		} else if( tmp.dateClosed ) {
			comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tmp.dateClosed];
		} else if( tmp.dateOpened ) {
			comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tmp.dateOpened];
		}
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		key = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
		//
		NSMutableArray *array = [dict objectForKey:key];
		if( !array ){
			array = [[NSMutableArray alloc] init];
			[dict setObject:array forKey:key];
			[array release];
		}
		//
		[array addObject:tmp];
		key = nil;
	}
	return dict;
}

/*
 *	THREADED
 */
- (void) getAllTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSATransactionStatusType type = PSATransactionStatusAll;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsFromDate:toDate:withStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsFromDate:toDate:withStatus:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	[invocation setArgument:&type atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getClosedTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSATransactionStatusType type = PSATransactionStatusClosed;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsFromDate:toDate:withStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsFromDate:toDate:withStatus:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	[invocation setArgument:&type atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getOpenTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end {	
	PSATransactionStatusType type = PSATransactionStatusOpen;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsFromDate:toDate:withStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsFromDate:toDate:withStatus:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	[invocation setArgument:&type atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getVoidedTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSATransactionStatusType type = PSATransactionStatusVoid;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsFromDate:toDate:withStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsFromDate:toDate:withStatus:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	[invocation setArgument:&type atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getAllTransactionsSinceLastCloseout {
	PSATransactionStatusType type = PSATransactionStatusAll;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getOpenTransactionsSinceLastCloseout {
	PSATransactionStatusType type = PSATransactionStatusOpen;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getClosedTransactionsSinceLastCloseout {
	PSATransactionStatusType type = PSATransactionStatusClosed;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	THREADED
 */
- (void) getVoidTransactionsSinceLastCloseout {
	PSATransactionStatusType type = PSATransactionStatusVoid;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsSinceLastCloseoutWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	MUST release when done!
 */
- (Transaction*) getTransactionForAppointment:(Appointment*)theAppointment {
	return [dbManager getTransactionForAppointment:theAppointment];
}

/*
 *	No release when done? Don't think the others (threaded void return) need it either...
 */
- (void) getInvoiceIDsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getInvoiceIDsForCloseOutsFromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getInvoiceIDsForCloseOutsFromDate:toDate:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	No release when done? Don't think the others (threaded void return) need it either...
 */
- (void) getInvoiceIDsForCloseOut:(CloseOut*)theCloseOut {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getInvoiceIDsForCloseOut:) object:theCloseOut];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	THREADED
 */
- (void) getInvoiceIDsForNextCloseOut {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getInvoiceIDsForNextCloseOut) object:nil];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	MUST RELEASE WHEN DONE!
 */
- (NSArray*) getInvoiceIDsUnthreadedForCloseOut:(CloseOut*)theCloseOut {
	return [dbManager getInvoiceIDsUnthreadedForCloseOut:theCloseOut];
}


/*
 *	No release when done? Don't think the others (threaded void return) need it either...
 */
- (void) getInvoicePaymentsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getInvoicePaymentsForCloseOutsFromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getInvoicePaymentsForCloseOutsFromDate:toDate:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	No release when done? Don't think the others (threaded void return) need it either...
 */
- (void) getInvoicePaymentsForCloseOut:(CloseOut*)theCloseOut {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getInvoicePaymentsForCloseOut:) object:theCloseOut];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	THREADED
 */
- (void) getInvoicePaymentsForNextCloseOut {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getInvoicePaymentsForNextCloseOut) object:nil];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	MUST RELEASE WHEN DONE!
 */
- (NSArray*) getInvoicePaymentsUnthreadedForCloseOut:(CloseOut*)theCloseOut {
	return [dbManager getInvoicePaymentsUnthreadedForCloseOut:theCloseOut];
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsForCloseOut:(CloseOut*)theCloseOut {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getTransactionsForCloseOut:) object:theCloseOut];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	MUST release when done!
 */
- (NSArray*) getTransactionsUnthreadedForCloseOut:(CloseOut*)theCloseOut {
	return [dbManager getTransactionsUnthreadedForCloseOut:theCloseOut];
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getTransactionsForCloseOutsFromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getTransactionsForCloseOutsFromDate:toDate:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	MUST release when done!
 */
- (NSArray*) getGiftCertificates {
	return [dbManager getGiftCertificates];
}

/*
 *	MUST release when done!
 */
- (GiftCertificate*) getGiftCertificateWithID:(NSInteger)theID {
	return [dbManager getGiftCertificateWithID:theID];
}

/*
 *
 */
- (void) hydrateTransaction:(Transaction*)theTransaction {
	// Get all items
	NSArray	*items = [dbManager getTransactionItemsForTransaction:theTransaction];
	
	for( TransactionItem *tmp in items ) {
		if( tmp.itemType == PSATransactionItemGiftCertificate ){
			[theTransaction.giftCertificates addObject:tmp];
		} else if( tmp.itemType == PSATransactionItemProduct ) {
			[theTransaction.products addObject:tmp];
		} else if( tmp.itemType == PSATransactionItemService ) {
			[theTransaction.services addObject:tmp];
		}
	}
	[items release];
	
	// Get all payments
	NSArray *payments = [dbManager getTransactionPaymentsForTransaction:theTransaction];
	for( TransactionPayment *tmp in payments ) {
		[theTransaction.payments addObject:tmp];
	}
	[payments release];
	
	// Get any Project Name
	[dbManager getTransactionProjectData:theTransaction];
}

/*
 *
 */
- (void) insertDailyCloseoutForTransactions:(NSArray*)transactions andInvoicePayments:(NSArray*)payments andInvoices:(NSArray*)invoices {
	// Insert the closeout
	NSInteger closeoutID = [dbManager insertDailyCloseout];
	// Insert the closeout_transaction for each
	for( Transaction *tmp in transactions ) {
		// If the transaction wasn't closed, close it!... not anymore!
		if( tmp.dateVoided ) {
			// Check for project data (versus a full hydration)
			[dbManager getTransactionProjectData:tmp];
			// Remove from project
			if( tmp.projectID > -1 ) {
				[dbManager removeTransactionID:tmp.transactionID fromProjectID:tmp.projectID];
			}
			[dbManager deleteTransactionAndChildren:tmp];
		} else {
			// Only closed transactions are added to the CloseOut
			if( tmp.dateClosed ) {
				[dbManager insertCloseout:closeoutID Transaction:tmp];
			}
		}
	}
	// Insert the closeout_payment for each
	for( TransactionPayment *tmp in payments ) {
		[dbManager insertCloseout:closeoutID InvoicePayment:tmp];
	}
	
	for( NSNumber *tmp in invoices ) {
		[dbManager insertCloseout:closeoutID InvoiceID:tmp];
	}
	
	// CHANGED 1/18/10: Get the rest of any voided transactions
	NSArray	*voids = [dbManager getVoidedTransactions];
	for( Transaction *tmp in voids ) {
		// Check for project data (versus a full hydration)
		[dbManager getTransactionProjectData:tmp];
		// Remove from project
		if( tmp.projectID > -1 ) {
			[dbManager removeTransactionID:tmp.transactionID fromProjectID:tmp.projectID];
		}
		[dbManager deleteTransactionAndChildren:tmp];
	}
	[voids release];
}

/*
 *
 */
- (void) removeGiftCertificate:(GiftCertificate*)theCert {
	[dbManager deleteGiftCertificateWithID:theCert.certificateID];
	// If this cert has been used as payment, set payment cert ID to -2...
	[dbManager updateTransactionPaymentsRemovingCertificateID:theCert.certificateID];
}

/*
 *
 */
- (void) removeGiftCertificateWithID:(NSInteger)theID {
	[dbManager deleteGiftCertificateWithID:theID];
	// If this cert has been used as payment, set payment cert ID to -2...
	[dbManager updateTransactionPaymentsRemovingCertificateID:theID];
}

/*
 *
 */
- (void) removeTransactionItem:(TransactionItem*)theItem {
	[dbManager deleteTransactionItem:theItem];
}

/*
 *
 */
- (void) removeTransactionPayment:(TransactionPayment*)thePayment {
	[dbManager deleteTransactionPayment:thePayment];
}

/*
 *
 */
- (void) saveTransaction:(Transaction*)theTransaction {
	
	//DebugLog( @"Change: %f", [[theTransaction getChangeDue] doubleValue] );
	NSNumber *oldTotal = [[NSNumber alloc] initWithDouble:[theTransaction.totalForTable doubleValue]];
	theTransaction.totalForTable = [theTransaction getTotal];
	// The Transaction itself
	if( theTransaction.transactionID > -1 ) {
		//DebugLog( @"Change: %f", round([[theTransaction getChangeDue] doubleValue]*100)/100 );
		if( round([[theTransaction getChangeDue] doubleValue]*100)/100 >= 0.00 && theTransaction.dateClosed == nil ) {
			// Close (should only happen once)
			theTransaction.dateClosed = [NSDate date];
		}
		// Update
		[dbManager updateTransaction:theTransaction];
	} else {
		// Open
		theTransaction.dateOpened = [NSDate date];
		//DebugLog( @"Change: %f", round([[theTransaction getChangeDue] doubleValue]*100)/100 );
		if( round([[theTransaction getChangeDue] doubleValue]*100)/100 >= 0.00 ) {
			// Close (should only happen once)
			theTransaction.dateClosed = [NSDate date];
		}
		// Insert
		[dbManager insertTransaction:theTransaction];
	}
		
	// Gift Certificates
	for( TransactionItem *tmp in theTransaction.giftCertificates ) {
		if( tmp.transactionItemID > -1 ) {
			// Update
			[dbManager updateTransactionItem:tmp];
			//
			GiftCertificate *certificate = (GiftCertificate*)tmp.item;
			[dbManager updateGiftCertificate:certificate];
		} else {
			// Insert
			GiftCertificate *certificate = (GiftCertificate*)tmp.item;
			certificate.purchaseDate = [NSDate date];
			certificate.purchaser = theTransaction.client;
			[dbManager insertGiftCertificate:certificate];
			// Save each Gift Certificate as TransactionItem
			[dbManager insertTransactionItem:tmp forTransactionID:theTransaction.transactionID];
		}
	}
	
	// Products
	for( TransactionItem *tmp in theTransaction.products ) {
		// Do the productAdjustment first to get it's ID if inserted
		if( tmp.productAdjustment ) {
			if( tmp.productAdjustment.productAdjustmentID > -1 ) {
				[dbManager updateProductAdjustment:tmp.productAdjustment];
			} else {
				tmp.productAdjustment.productID = ((Product*)tmp.item).productID;
				[dbManager insertProductAdjustment:tmp.productAdjustment];
			}
		}
		// Then save the TransactionItem
		if( tmp.transactionItemID > -1 ) {
			[dbManager updateTransactionItem:tmp];
		} else {
			[dbManager insertTransactionItem:tmp forTransactionID:theTransaction.transactionID];
		}
	}
	
	// Services
	for( TransactionItem *tmp in theTransaction.services ) {
		if( tmp.transactionItemID > -1 ) {
			[dbManager updateTransactionItem:tmp];
		} else {
			[dbManager insertTransactionItem:tmp forTransactionID:theTransaction.transactionID];
		}
	}
	
	// Payments
	for( TransactionPayment *tmp in theTransaction.payments ) {
		if( tmp.transactionPaymentID > -1 ) {
			// Update Payment
			[dbManager updateTransactionPayment:tmp];
			// Adjust the amountUsed from a GiftCertificate
			if( tmp.paymentType == PSATransactionPaymentGiftCertificate && tmp.amountOriginal ) {
				if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] > 0.0 ) {
					NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amountOriginal doubleValue]-[tmp.amount doubleValue]];
					[dbManager refundAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
					[num release];
					tmp.amountOriginal = nil;
				} else if( [tmp.amountOriginal doubleValue]-[tmp.amount doubleValue] < 0.0 ) {
					NSNumber *num = [[NSNumber alloc] initWithDouble:[tmp.amount doubleValue]-[tmp.amountOriginal doubleValue]];
					[dbManager deductAmount:num fromCertificateID:[tmp.extraInfo integerValue]];
					[num release];
					tmp.amountOriginal = nil;
				}
			}
		} else {
			// Insert Payment
			[dbManager insertTransactionPayment:tmp forTransactionID:theTransaction.transactionID];
			// Deduct from GiftCertificate
			if( tmp.paymentType == PSATransactionPaymentGiftCertificate ) {
				[dbManager deductAmount:tmp.amount fromCertificateID:[tmp.extraInfo integerValue]];
			}
		}
	}
	
	// Add the Transaction to a project if it has a projectID and no name
	// Name would be set when the transaction is hydrated in TransactionViewController
	if( theTransaction.projectID > -1 ) {
		if( !theTransaction.projectName ) {
			[dbManager addTransactionID:theTransaction.transactionID toProjectID:theTransaction.projectID];
		}
		if( theTransaction.dateVoided ) {
			// Remove the total
			[dbManager updateProjectTotalForID:theTransaction.projectID amountToSubtract:[oldTotal doubleValue]];
		} else {
			// Update Project Total
			double amt = ([oldTotal doubleValue]-[theTransaction.totalForTable doubleValue]);
			if( amt > 0 ) {
				[dbManager updateProjectTotalForID:theTransaction.projectID amountToSubtract:amt];
			} else {
				[dbManager updateProjectTotalForID:theTransaction.projectID amountToAdd:(amt*-1)];
			}
		}
	}
	[oldTotal release];
	
}

/*
 *	Just the tip!
 */
- (void) saveTransactionTip:(Transaction*)theTransaction {
	// Only if the transaction exists...
	if( theTransaction.transactionID > -1 ) {
		[dbManager updateTransactionTip:theTransaction];
	}
}

/*
 *
 */
- (void) voidTransaction:(Transaction*)theTransaction {
	if( !theTransaction.dateClosed ) {
		theTransaction.dateClosed = [NSDate date];
	}
	if( !theTransaction.dateVoided ) {
		theTransaction.dateVoided = [NSDate date];
	}
	// CHANGED 1/28/10: Remove the appointment reference, so pressing Check Out from the appointment doesn't 
	// go to this voided transaction.
	theTransaction.appointmentID = -1;
	// CHANGED 1/18/10: Refund gift certificates
	for( TransactionPayment *tmp in theTransaction.payments ) {
		if( tmp.paymentType == PSATransactionPaymentGiftCertificate ) {
			[self refundAmount:tmp.amount fromCertificateID:((GiftCertificate*)tmp.extraInfo).certificateID];
		}
	}
	// Remove Products' adjustments
	for( TransactionItem *tmp in theTransaction.products ) {
		[[PSADataManager sharedInstance] removeProductAdjustmentWithID:tmp.productAdjustment.productAdjustmentID];
	}
	// Delete any gift certificates purchased
	for( TransactionItem *tmp in theTransaction.giftCertificates ) {
		// If this cert has been used as payment, set payment cert ID to -2...
		[[PSADataManager sharedInstance] removeGiftCertificate:(GiftCertificate*)tmp.item];
	}
	// Save the transaction
	[[PSADataManager sharedInstance] saveTransaction:theTransaction];
	[theTransaction dehydrate];
}



/*
 *	MUST release when done!
 */
- (NSDictionary*) getDictionaryOfCreditPaymentsFromArray:(NSArray*)payments {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSDate *key = nil;
	NSDateComponents *comps = nil;
	for( CreditCardPayment *tmp in payments ) {
		// Key based on activity date
		comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:tmp.date];
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		key = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
		//
		NSMutableArray *array = [dict objectForKey:key];
		if( !array ){
			array = [[NSMutableArray alloc] init];
			[dict setObject:array forKey:key];
			[array release];
		}
		//
		[array addObject:tmp];
		key = nil;
	}
	return dict;
}

/*
 *	Puts the credit card payment object for the given TransactionPayment
 *	Unthreaded
 */
- (void) getCreditCardPaymentForPayment:(TransactionPayment*)thePayment {
	[dbManager getCreditCardPaymentForPayment:thePayment];
}

/*
 *	Gets all the credit card payments that have not appeared in a daily closeout (and not refunded/voided)
 *	Threaded
 */
- (void) getAllCCPaymentsUnclosed {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusAll;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the approved credit card payments that have not appeared in a daily closeout (and not refunded/voided)
 *	Threaded
 */
- (void) getApprovedCCPaymentsUnclosed {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusApproved;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the refunded credit card payments that have not appeared in a daily closeout (and not refunded/voided)
 *	Threaded
 */
- (void) getRefundedCCPaymentsUnclosed {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusRefunded;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the voided credit card payments that have not appeared in a daily closeout (and not refunded/voided)
 *	Threaded
 */
- (void) getVoidedCCPaymentsUnclosed {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusVoided;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsUnclosedWithStatus:)];
	[invocation setArgument:&type atIndex:2];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the credit card payments in the time period
 *	Threaded
 */
- (void) getAllCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusAll;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)];
	[invocation setArgument:&type atIndex:2];
	[invocation setArgument:&start atIndex:3];
	[invocation setArgument:&end atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the approved credit card payments in the time period
 *	Threaded
 */
- (void) getApprovedCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusApproved;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)];
	[invocation setArgument:&type atIndex:2];
	[invocation setArgument:&start atIndex:3];
	[invocation setArgument:&end atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the refunded credit card payments in the time period
 *	Threaded
 */
- (void) getRefundedCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusRefunded;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)];
	[invocation setArgument:&type atIndex:2];
	[invocation setArgument:&start atIndex:3];
	[invocation setArgument:&end atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	Gets all the voided credit card payments in the time period
 *	Threaded
 */
- (void) getVoidedCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end {
	PSACreditCardPaymentStatusType type = PSACreditCardPaymentStatusVoided;
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getCreditCardPaymentsWithStatus:fromDate:toDate:)];
	[invocation setArgument:&type atIndex:2];
	[invocation setArgument:&start atIndex:3];
	[invocation setArgument:&end atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *
 */
- (void) saveCreditCardPayment:(CreditCardPayment*)thePayment {
	if( thePayment.ccPaymentID == -1 ) {
		if( thePayment.response && [thePayment.response.authCode isEqualToString:@"000000"] ) {
			thePayment.response.transID = @"0";
		}
		[dbManager insertCreditCardPayment:thePayment];
	} else {
		[dbManager updateCreditCardPayment:thePayment];
	}
}

#pragma mark -
#pragma mark Schedule Methods
#pragma mark -
/*
 *	checkAppointmentAvailability:
 *	Returns TRUE if appointment is available. Returns FALSE if there is another appointment
 *	that would coincide with the given one.
 */
- (BOOL) checkAppointmentAvailability:(Appointment*)theAppointment {
	return [dbManager isFree:theAppointment];
}

/*
 *	deleteAppointment
 *	Deletes the appointment from the database.
 */
- (void) deleteAppointment:(Appointment*)theAppointment deleteStanding:(BOOL)standing {
	[dbManager deleteAppointment:theAppointment deleteStanding:standing];
}

/*
 *	Deletes standing appointments that aren't referenced by any appointment
 */
- (void) deleteOrphanedStandingAppointments {
	[dbManager deleteOrphanedStandingAppointments];
}

/*
 *	Deletes the standing appointment reference from the DB
 */
- (void) deleteStandingAppointment:(Appointment *)theAppointment {
	[dbManager deleteStandingAppointment:theAppointment];
	theAppointment.standingAppointmentID = -1;
}

/*
 *	getAppointmentsForClient
 *	Returns an array of appointments for the given client
 *	Must release when done!
 */
- (void) getAppointmentsForClient:(Client*)theClient {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getAppointmentsForClient:) object:theClient];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	getAppointmentsForDay
 *	Returns an array of appointments for the given day
 *	Must release when done!
 */
- (void) getAppointmentsForDay:(NSDate*)theDate {
	// Set minimum date to the current time rounded to the nearest 15 minutes
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	NSDateComponents *comps = [gregorian components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:theDate];
	// Get the date reference for 00:00 on theDate
	[comps setSecond:0];
	[comps setMinute:0];
	[comps setHour:0];
	NSDate *startDate = [gregorian dateFromComponents:comps];
	// Get the date reference for 00:00:00 - 23:59:59 on theDate
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	NSDate *endDate = [gregorian dateFromComponents:comps];
	[gregorian release];
	// Get the appointments
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getAppointmentsFrom:to:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getAppointmentsFrom:to:)];
	[invocation setArgument:&startDate atIndex:2];
	[invocation setArgument:&endDate atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	No need to release...
 */
- (void) getAppointmentsForProject:(Project*)theProject {
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getAppointmentsThreadedForProject:) object:theProject];
	[self.operationQueue addOperation:op];
	[op release];
}

/*
 *	getAppointmentsFromDate:toDate:
 *	Returns an array of appointments for the given span of dates
 *	THREADED, no release!
 */
- (void) getAppointmentsFromDate:(NSDate*)start toDate:(NSDate*)end {
	// Get the appointments
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getAppointmentsFrom:to:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getAppointmentsFrom:to:)];
	[invocation setArgument:&start atIndex:2];
	[invocation setArgument:&end atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	
 *	Must release when done!
 */
- (NSDictionary*) getDictionaryOfAppointmentsForArray:(NSArray*)theArray {
	NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
	for( Appointment *tmp in theArray ) {
		NSString *key = [self getStringForAppointmentListHeader:tmp.dateTime];
		
		NSMutableArray *array = [returnDict objectForKey:key];
		if( !array ){
			array = [[NSMutableArray alloc] init];
			[returnDict setObject:array forKey:key];
			[array release];
		}
		[array addObject:tmp];
	}
	return returnDict;
}


/*
 *	
 *	Must release when done!
 */
- (void) getDictionaryOfAppointmentsFor30DaysStarting:(NSDate*)theDate {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	NSDateComponents *comps = [gregorian components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:theDate];
	NSDate *startDate = [gregorian dateFromComponents:comps];
	// Get the date reference for 00:00 on theDate + 1 day
	[comps setDay:[comps day]+30];
	NSDate *endDate = [gregorian dateFromComponents:comps];
	[gregorian release];
	// Get the appointments
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getAppointmentsFrom:to:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getAppointmentsFrom:to:)];
	[invocation setArgument:&startDate atIndex:2];
	[invocation setArgument:&endDate atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	
 *	Must release when done!
 */
- (void) getDictionaryOfAppointmentsForMonth:(NSDate*)theDate {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	NSDateComponents *comps = [gregorian components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:theDate];
	NSDate *startDate = [gregorian dateFromComponents:comps];
	// Get the date reference for 00:00 on theDate + 1 day
	[comps setMonth:[comps month]+1];
	NSDate *endDate = [gregorian dateFromComponents:comps];
	[gregorian release];
	// Get the appointments
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getAppointmentsFrom:to:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getAppointmentsFrom:to:)];
	[invocation setArgument:&startDate atIndex:2];
	[invocation setArgument:&endDate atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *	
 *	Must release when done!
 */
- (void) getDictionaryOfAppointmentsForOneYear {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	NSDateComponents *comps = [gregorian components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	// Get the date reference for 00:00 on theDate
	[comps setSecond:0];
	[comps setMinute:0];
	[comps setHour:0];
	NSDate *startDate = [gregorian dateFromComponents:comps];
	// Get the date reference for 00:00 on theDate + 1 day
	[comps setYear:[comps year]+1];
	NSDate *endDate = [gregorian dateFromComponents:comps];
	[gregorian release];
	// Get the appointments
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[dbManager methodSignatureForSelector:@selector(getAppointmentsFrom:to:)]];
	[invocation setTarget:dbManager];
	[invocation setSelector:@selector(getAppointmentsFrom:to:)];
	[invocation setArgument:&startDate atIndex:2];
	[invocation setArgument:&endDate atIndex:3];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

/*
 *
 */
- (void) insertAppointment:(Appointment*)theAppointment {
	[dbManager insertAppointment:theAppointment];
}

/*
 *	No need to release returned NSDate.
 */
- (NSDate*) getNextRepeatDateForAppointment:(Appointment*)theAppointment {
	NSDate *returnDate = nil;
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	switch ( theAppointment.standingRepeat ) {
		case iBizAppointmentRepeatDaily:
			[comps setDay:1];
			break;
		case iBizAppointmentRepeatWeekly:
			[comps setWeekOfMonth:1];
			break;
		case iBizAppointmentRepeatMonthly:
			[comps setMonth:1];
			break;
		case iBizAppointmentRepeatYearly:
			[comps setYear:1];
			break;
		case iBizAppointmentRepeatEvery2Weeks:
			[comps setWeekOfMonth:2];
			break;
		case iBizAppointmentRepeatEvery3Weeks:
			[comps setWeekOfMonth:3];
			break;
		case iBizAppointmentRepeatEvery4Weeks:
			[comps setWeekOfMonth:4];
			break;
	}
	returnDate = [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:comps toDate:theAppointment.dateTime options:0];
	[comps release];
	return returnDate;
}

/*
 *	saveAppointment
 *	Inserts or updates the [standing] appointment in the DB
 *	Returns an array of appoints that have conflicts. This array does NOT need to be released manually.
 */
- (NSArray*) saveAppointment:(Appointment*)theAppointment updateStanding:(BOOL)updateStanding ignoreConflicts:(BOOL)ignoreConflicts {
	NSMutableArray *collisions = [[NSMutableArray alloc] init];
	
	// Appointment does exist
	if( theAppointment.appointmentID > -1 ) {
		if( updateStanding ) {
			// Standing Appointment exists and needs update
			if( theAppointment.standingAppointmentID > -1 ) {
				//DebugLog( @"UPDATE standing A" );
				[dbManager updateStandingAppointment:theAppointment];
				// Update all of the appointments that exist with this standingAppointmentID,
				// By deleting all of the appointments under this standing
				[self deleteAppointment:theAppointment deleteStanding:NO];
				[self deleteAppointment:theAppointment deleteStanding:YES];
				// ReInsert them all... yes, this code is reused throughout this method
				
				
				// From appointment.dateTime until appointment.standingRepeatUntilDate
				while( [theAppointment.standingRepeatUntilDate compare:theAppointment.dateTime] > 0 ) {
					if( ignoreConflicts || [self checkAppointmentAvailability:theAppointment] ) {
						// Insert appointment
						[dbManager insertAppointment:theAppointment];
					} else {
						// Copy to collisions array
						Appointment *tmpAppointment = [[Appointment alloc] initWithAppointment:theAppointment];
						tmpAppointment.appointmentID = -1;
						[collisions addObject:tmpAppointment];
						[tmpAppointment release];
					}
					// Increment by the # weeks in standingRepeat interval
					theAppointment.dateTime = [self getNextRepeatDateForAppointment:theAppointment];
					//DebugLog( @"A %@", theAppointment.dateTime );
				}

			}
			// Standing Appointment doesn't exist, needs creation
			else if( theAppointment.standingAppointmentID == -1 && theAppointment.standingRepeat != iBizAppointmentRepeatNever && theAppointment.standingRepeatUntilDate != nil ) {
				[dbManager insertStandingAppointment:theAppointment];
				
				// Update this occurrence because it exists
				if( ignoreConflicts || [self checkAppointmentAvailability:theAppointment] ) {
					// Update appointment
					[dbManager updateAppointment:theAppointment];
				} else {
					// Copy to collisions array
					Appointment *tmpAppointment = [[Appointment alloc] initWithAppointment:theAppointment];
					[collisions addObject:tmpAppointment];
					[tmpAppointment release];
				}
				theAppointment.dateTime = [self getNextRepeatDateForAppointment:theAppointment];
				// From appointment.dateTime until appointment.standingRepeatUntilDate
				while( [theAppointment.standingRepeatUntilDate compare:theAppointment.dateTime] > 0 ) {
					if( ignoreConflicts || [self checkAppointmentAvailability:theAppointment] ) {
						// Insert appointment
						[dbManager insertAppointment:theAppointment];
					} else {
						// Copy to collisions array
						Appointment *tmpAppointment = [[Appointment alloc] initWithAppointment:theAppointment];
						tmpAppointment.appointmentID = -1;
						[collisions addObject:tmpAppointment];
						[tmpAppointment release];
					}
					// Increment by the # weeks in standingRepeat interval
					theAppointment.dateTime = [self getNextRepeatDateForAppointment:theAppointment];
					//DebugLog( @"B %@", theAppointment.dateTime );
				}

			}
		} else {
			//DebugLog( @"UPDATE appointment B" );
			theAppointment.standingAppointmentID = -1;
			if( ignoreConflicts || [self checkAppointmentAvailability:theAppointment] ) {
				// Update appointment
				[dbManager updateAppointment:theAppointment];
			} else {
				// Copy to collisions array
				Appointment *tmpAppointment = [[Appointment alloc] initWithAppointment:theAppointment];
				[collisions addObject:tmpAppointment];
				[tmpAppointment release];
			}
		}	
	}
	// Appointment does not exist
	else {
		// If standing is filled out
		if( theAppointment.standingRepeat != iBizAppointmentRepeatNever && theAppointment.standingRepeatUntilDate != nil && !ignoreConflicts ) {
			// Create a new standing appointment, return the inserted standing ID
			//DebugLog( @"INSERT standing B" );
			[dbManager insertStandingAppointment:theAppointment];
			
			// From appointment.dateTime until appointment.standingRepeatUntilDate
			while( [theAppointment.standingRepeatUntilDate compare:theAppointment.dateTime] > 0 ) {
				if( ignoreConflicts || [self checkAppointmentAvailability:theAppointment] ) {
					// Insert appointment
					[dbManager insertAppointment:theAppointment];
				} else {
					// Copy to collisions array
					Appointment *tmpAppointment = [[Appointment alloc] initWithAppointment:theAppointment];
					tmpAppointment.appointmentID = -1;
					[collisions addObject:tmpAppointment];
					[tmpAppointment release];
				}
				// Increment by the # weeks in standingRepeat interval
				theAppointment.dateTime = [self getNextRepeatDateForAppointment:theAppointment];
				//DebugLog( @"C %@", theAppointment.dateTime );
			}

		}
		// New single Appointment
		else {
			//DebugLog( @"INSERT appointment B" );
			if( ignoreConflicts || [self checkAppointmentAvailability:theAppointment] ) {
				// Insert appointment
				[dbManager insertAppointment:theAppointment];
			} else {
				// Copy to collisions array
				Appointment *tmpAppointment = [[Appointment alloc] initWithAppointment:theAppointment];
				[collisions addObject:tmpAppointment];
				[tmpAppointment release];
			}
		}
	}
	// Return any collisions
	if( collisions.count > 0 ) {
		NSArray *returnArray = [NSArray arrayWithArray:collisions];
		[collisions release];
		return returnArray;
	}
	// Otherwise return nothing
	[collisions release];
	return nil;
}

/*
 *	This is the method that is called as an NSInvocationOperation from the threaded method.
 *	Returns the results of the nonthreaded saveAppointment: to the delegate.
 */
- (void) _saveAppointment:(Appointment*)theAppointment updateStanding:(BOOL)updateStanding ignoreConflicts:(BOOL)ignoreConflicts {
	NSArray *conflicts = [self saveAppointment:theAppointment updateStanding:updateStanding ignoreConflicts:ignoreConflicts];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dataManagerReturnedArray:) withObject:conflicts waitUntilDone:YES];
	//[self.delegate dataManagerReturnedArray:[self saveAppointment:theAppointment updateStanding:updateStanding ignoreConflicts:ignoreConflicts]];
}

/*
 *
 */
- (void) saveAppointmentThreaded:(Appointment*)theAppointment updateStanding:(BOOL)updateStanding ignoreConflicts:(BOOL)ignoreConflicts {
    //Create reminders.
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    
    UILocalNotification * theNotification = [[UILocalNotification alloc] init];
    NSString *strEmail = theAppointment.client.getEmailAddressHome;
    if(strEmail.length < 1)
    {
        strEmail = theAppointment.client.getEmailAddressWork;
        if (strEmail.length<1) {
            strEmail = theAppointment.client.getEmailAddressAny;
        }
    }
    NSString *strPhone = theAppointment.client.getPhoneCell;
    if(strPhone.length<1)
    {
        strPhone = theAppointment.client.getPhoneHome;
        if(strPhone.length<1) {
            strPhone = theAppointment.client.getPhoneWork;
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDay = [formatter stringFromDate:theAppointment.dateTime];
    [formatter setDateFormat:@"HH:mm"];
    NSString *strHour = [formatter stringFromDate:theAppointment.dateTime];
    [formatter release];
    
    
    
    Email *mail = [[PSADataManager sharedInstance] getAppointmentReminderEmail];
    NSString *strContent = [NSString stringWithFormat:@"%@", mail.message];
    strContent = [strContent stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:theAppointment.client.getClientName];
    strContent = [strContent stringByReplacingOccurrencesOfString:@"<<APPT_DATE>>" withString:strDay];
    strContent = [strContent stringByReplacingOccurrencesOfString:@"<<APPT_TIME>>" withString:strHour];
    NSDictionary * dict = nil;
    dict = @{
             @"email" : [NSString stringWithFormat:@"%@", strEmail]
             , @"phone" : [NSString stringWithFormat:@"%@", strPhone]
             , @"title" : [NSString stringWithFormat:@"%@", mail.subject]
             };
    
    
    theNotification.userInfo = [[NSDictionary  alloc] initWithDictionary:dict];
    theNotification.alertBody = [NSString stringWithFormat:@"%@", strContent];
    theNotification.alertAction = @"Ok";
    theNotification.fireDate = [theAppointment.dateTime dateByAddingTimeInterval:-3600];
    theNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:theNotification];
    
    theNotification.fireDate = theAppointment.dateTime;
    theNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:theNotification];
    
	// Create invocation for the threaded method
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(_saveAppointment:updateStanding:ignoreConflicts:)]];
	[invocation setTarget:self];
	[invocation setSelector:@selector(_saveAppointment:updateStanding:ignoreConflicts:)];
	[invocation setArgument:&theAppointment atIndex:2];
	[invocation setArgument:&updateStanding atIndex:3];
	[invocation setArgument:&ignoreConflicts atIndex:4];
	
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	if( op ) {
		[self.operationQueue addOperation:op];
	}
	[op release];
}

- (void) updateAppointment:(Appointment*)theAppointment {
	[dbManager updateAppointment:theAppointment];
}

#pragma mark -
#pragma mark Service Methods
#pragma mark -
/*
 *	getDictionaryOfProductsByType
 *	Must release when done!
 */
- (void) getDictionaryOfServicesByGroupWithActiveFlag:(BOOL)active {
	NSNumber *activeFlag = [[NSNumber alloc] initWithBool:active];
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:dbManager selector:@selector(getDictionaryOfServicesByGroupWithActiveFlag:) object:activeFlag];
	[self.operationQueue addOperation:op];
	[op release];
	[activeFlag release];
}

/*
 *	getServiceGroups
 *	Must release when done!
 */
- (NSArray*) getServiceGroups {
	return [dbManager getServiceGroups];
}

/*
 *	getServiceWithID
 *	Must release when done!
 */
- (Service*) getServiceWithID:(NSInteger)theID {
	return nil;
}

- (void) removeService:(Service*)theService {
	theService.isActive = NO;
	[dbManager updateService:theService];
}

- (void) removeServiceGroup:(ServiceGroup*)theGroup {
	[dbManager removeServiceGroup:theGroup];
	[dbManager bulkUpdateServiceGroupToDefaultFromGroup:theGroup];
}

/*
 *	saveService
 *	Inserts or updates the product in the DB
 */
- (void) saveService:(Service*)theService {
	if( theService.serviceID > -1 ) {
		[dbManager updateService:theService];
	} else {
		[dbManager insertService:theService];
	}
}

- (void) saveServiceGroup:(ServiceGroup*)theGroup {
	if( theGroup.groupID > -1 ) {
		[dbManager updateServiceGroup:theGroup];
	} else {
		[dbManager insertServiceGroup:theGroup];
	}
}

#pragma mark -
#pragma mark Settings Methods
#pragma mark -
/*
 *	Sets the sort option, unthreaded.
 */
- (void) setClientNameSortSetting:(NSInteger)sortOption {
	[dbManager updateClientNameSortSetting:sortOption];
	clientNameSortOption = sortOption;
}
/*
 *	Sets the view option, unthreaded.
 */
- (void) setClientNameViewSetting:(NSInteger)sortOption {
	[dbManager updateClientNameViewSetting:sortOption];
	clientNameViewOption = sortOption;
}

/*
 *	getWorkHoursFormat
 *	Returns the format of date that is stored as a string in our DB
 */
- (NSDateFormatterStyle) getWorkHoursDateFormat {
	return NSDateFormatterShortStyle;
}

/*
 *	getCreditCardSettings
 *	Must release this object when done!
 */
- (CreditCardSettings*) getCreditCardSettings {
	CreditCardSettings *settings = [[CreditCardSettings alloc] init];
	[dbManager getCreditCardSettings:settings];
	return settings;
}

- (void) updateCreditCardSettings:(CreditCardSettings*)theSettings {
	[dbManager updateCreditCardSettings:theSettings];
}

/*
 *	getSettings
 *	Must release this object when done!
 */
- (Settings*) getSettings {
	return [dbManager getSettings];
}

/*
 *	saveSettings
 *	Saves (inserts) new settings to the database
 */
- (void) saveSettings:(Settings*)settings {
	//[dbManager saveSettings:settings];
}

/*
 *	updateSettings
 *	Updates the settings in the database
 */
- (void) updateSettings:(Settings*)settings {
	[dbManager updateSettings:settings];
}

#pragma mark -
#pragma mark Vendors
#pragma mark -
/*
 *
 *	Must release when done!
 */
- (NSArray*) getVendors {
	return [dbManager getVendors];
}

/*
 *
 *
 */
- (void) removeVendor:(Vendor*)theVendor {
	[dbManager removeVendor:theVendor];
}

/*
 *
 *
 */
- (void) saveVendor:(Vendor*)theVendor {
	if( theVendor.vendorID == -1 ) {
		[dbManager insertVendor:theVendor];
	} else {
		[dbManager updateVendor:theVendor];
	}
}

#pragma mark -
#pragma mark Helper Methods
#pragma mark -
/*
 *	getTimeForString:
 *	Returns a date for the given string in our format.
 *	Date does NOT require release when finished.
 */
- (NSDate*)	getDateForString:(NSString*)date withFormat:(NSDateFormatterStyle)style {
	NSDate *returnValue = nil;
	// Date formatter does what we want
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = style;
	returnValue = [formatter dateFromString:date];
	[formatter release];
	return returnValue;
}

/*
 *	getTimeForString:
 *	Returns a date for the given string in our format.
 *	Date does NOT require release when finished.
 */
- (NSDate*)	getTimeForString:(NSString*)date withFormat:(NSDateFormatterStyle)style {
	NSDate *returnValue = nil;
	// Date formatter does what we want
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.timeStyle = style;
	returnValue = [formatter dateFromString:date];
	[formatter release];
	return returnValue;
}

/*
 *	getStringForAppointmentDate:
 *	Returns a string in Appointment view format for the given date.
 *	String does NOT require release when finished.
 */
- (NSString*) getStringForAppointmentDate:(NSDate*)date {
	NSString *returnValue = nil;
	// Date formatter does what we want
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	if( [[formatter dateFormat] hasSuffix:@"a"] ) {
		[formatter setTimeStyle:NSDateFormatterNoStyle];
		[formatter setDateFormat:@"EEE MMM d h:mm a"];
	} else {
		[formatter setTimeStyle:NSDateFormatterNoStyle];
		[formatter setDateFormat:@"EEE MMM d H:mm"];
	}
	returnValue = [formatter stringFromDate:date];
	[formatter release];
	return returnValue;
}

/*
 *	getStringForAppointmentListHeader:
 *	Returns a string in Appointment view format for the given date.
 *	String does NOT require release when finished.
 */
- (NSString*) getStringForAppointmentListHeader:(NSDate*)date {
	NSString *returnValue = nil;
	// Date formatter does what we want
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd_MMM d yyyy_EEEE"];
	returnValue = [formatter stringFromDate:date];
	[formatter release];
	return returnValue;
}

/*
 *	getStringForDate:
 *	Returns a string in our format for the given date.
 *	String does NOT require release when finished.
 */
- (NSString*) getStringForDate:(NSDate*)date withFormat:(NSDateFormatterStyle)style {
	NSString *returnValue = nil;
	// Date formatter does what we want
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = style;
	returnValue = [formatter stringFromDate:date];
	[formatter release];
	return returnValue;
}

/*
 *	getStringForTime:
 *	Returns a string in our format for the given date.
 *	String does NOT require release when finished.
 */
- (NSString*) getStringForTime:(NSDate*)date withFormat:(NSDateFormatterStyle)style {
	NSString *returnValue = nil;
	// Date formatter does what we want
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.timeStyle = style;
	returnValue = [formatter stringFromDate:date];
	[formatter release];
	return returnValue;
}

/*
 *	getStringOfHoursAndMinutesForSeconds:
 *	Returns a string in the form of "%d Hrs. %d Min." for the given number of seconds
 *	String does NOT require release when finished.
 */
- (NSString*) getStringOfHoursAndMinutesForSeconds:(NSInteger)seconds {
	NSInteger hours = seconds / 3600;
	NSInteger minutes = (seconds % 3600) / 60;
	NSString *str = [NSString stringWithFormat:@"%ld %@ %ld min.", (long)hours, (hours==1) ? @"hr." : @"hrs.", (long)minutes];
	return str;
}

/*
 *	getShortStringOfHoursAndMinutesForSeconds:
 *	Returns a string in the form of "hr:mi" (0:00) for the given number of seconds
 *	String does NOT require release when finished.
 */
- (NSString*) getShortStringOfHoursAndMinutesForSeconds:(NSInteger)seconds {
	NSInteger hours = seconds / 3600;
	NSInteger minutes = (seconds % 3600) / 60;
	NSString *str = [NSString stringWithFormat:@"%2ld:%02ld", (long)hours, (long)minutes];
	return str;
}

/*
 *	Hides the activity indicator shown from the app delegate.
 */
- (void) hideActivityIndicator {
	[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] hideActivityIndicator];
}

/*
 *	Shows the activity indicator setup in the app delegate.
 */
- (void) showActivityIndicator {
	[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] showActivityIndicator];
}

/*
 *	Displays an alert for any database problems that may (shouldn't) occur
 */
- (void) showError:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];	
	[alert release];
}

#pragma mark -
#pragma mark Singleton Object Methods
#pragma mark -
+ (PSADataManager *)sharedInstance {
    @synchronized(self) {
        if (mySharedDelegate == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return mySharedDelegate;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (mySharedDelegate == nil) {
            mySharedDelegate = [super allocWithZone:zone];
            return mySharedDelegate;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
