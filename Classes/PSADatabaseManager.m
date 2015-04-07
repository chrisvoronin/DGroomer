//
//  PSADatabaseManager.m
//  myBusiness
//
//  Created by David J. Maier on 10/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Appointment.h"
#import "Client.h"
#import "CloseOut.h"
#import "Company.h"
#import "CreditCardConnectionManager.h"
#import "CreditCardPayment.h"
#import "CreditCardResponse.h"
#import "CreditCardSettings.h"
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
#import "PSADataManager.h"
#import "Service.h"
#import "ServiceGroup.h"
#import "Settings.h"
#import "Tax.h"
#import "Transaction.h"
#import "TransactionItem.h"
#import "TransactionPayment.h"
#import "Vendor.h"
#import "PSADatabaseManager.h"

@implementation PSADatabaseManager

@synthesize delegate;

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Helper Methods
#pragma mark -
/*
 *	Used to sort an array of strings, treating them as integers.
 */
static NSInteger compareStringsAsNumbers(id a, id b, void *context) {
	if( [(NSString*)a intValue] > [(NSString*)b intValue] ) {
		// First is larger than second
		return NSOrderedDescending;
	} else if( [(NSString*)a intValue] < [(NSString*)b intValue] ) {
		// Second is larger than first
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

/*
 *	Escapes any characters necessary for proper SQLite insertion
 *	Do not need to release the returned string.
 */
- (NSString*) escapeSQLCharacters:(NSString*)theString {
	NSString *returnString = [theString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	return returnString;
}

/*
 *
 */
- (NSTimeInterval) getTimeIntervalForGMT:(NSDate*)date {
	if( !date ) return 0;
	NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
	return (NSTimeInterval)([date timeIntervalSinceReferenceDate]+[timeZone secondsFromGMTForDate:date]);
}

/*
 *
 */
- (NSDate*) getDateForTimeInterval:(NSTimeInterval)interval {
	NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
	NSDate *tmp = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];	
	return [NSDate dateWithTimeIntervalSinceReferenceDate:(interval-[timeZone secondsFromGMTForDate:tmp])];
}

#pragma mark -
#pragma mark Client Methods
#pragma mark -
/*
 *
 *	Must release Client when done!
 */
- (Client*) getClientWithID:(NSInteger)theID {
	Client *returnClient = nil;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT clientID, notes, ABPersonRefID, isActive FROM iBiz_client WHERE clientID=%ld", (long)theID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		if (sqlite3_step(statement) == SQLITE_ROW) {
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the array.
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSInteger personID = sqlite3_column_int(statement, 2);
			NSInteger activeFlag = sqlite3_column_int(statement, 3);
			Client *client = [[Client alloc] initWithID:newKey personID:personID isActive:activeFlag];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				client.notes = nil;
			} else {
				client.notes = notes;
			}
			[notes release];
			client.isActive = activeFlag;
			// If the Client has a valid AddressBook record
			if( client.personID == -1 || [client getPerson] ) {
				returnClient = client;
			} else {
				[client release];
			}
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem fetching your clients.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnClient;
}

/*
 *	getActiveClients
 *	Loads the active clients and returns them in an array.
 */
- (void) getClientsWithActiveFlag:(NSNumber*)active {
	// The array to return
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	if( [active boolValue] ) {
		sql = @"SELECT clientID, notes, ABPersonRefID, isActive, firstName, lastName FROM iBiz_client WHERE isActive=1;";
	} else {
		sql = @"SELECT clientID, notes, ABPersonRefID, isActive, firstName, lastName FROM iBiz_client;";
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSInteger personID = sqlite3_column_int(statement, 2);
			NSInteger activeFlag = sqlite3_column_int(statement, 3);
			NSString *first = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			NSString *last = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			
			Client *client = [[Client alloc] initWithID:newKey personID:personID isActive:[active boolValue]];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				client.notes = nil;
			} else {
				client.notes = notes;
			}
			
			if( !first || [first isEqualToString:@"(null)"] ) {
				client.firstName = nil;
			} else {
				client.firstName = first;
			}
			
			if( !last || [last isEqualToString:@"(null)"] ) {
				client.lastName = nil;
			} else {
				client.lastName = last;
			}
			
			//DebugLog( @"Client: %d %@ %@", client.clientID, client.firstName, client.lastName );
			
			client.isActive = activeFlag;
			[returnArray addObject:client];
			[client release];
			[notes release];
			[first release];
			[last release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem fetching your clients.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:returnArray];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:returnArray waitUntilDone:YES];
	[returnArray release];
}

/*
 *	getActiveClients
 *	Loads the active clients and returns them in an array
 *	Need to release the returned array when finished!
 */
- (NSArray*) getAllClientsUnthreadedExcludeNameColumns {
	// The array to return
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = @"SELECT clientID, notes, ABPersonRefID, isActive FROM iBiz_client;";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSInteger personID = sqlite3_column_int(statement, 2);
			NSInteger activeFlag = sqlite3_column_int(statement, 3);

			Client *client = [[Client alloc] initWithID:newKey personID:personID isActive:activeFlag];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				client.notes = nil;
			} else {
				client.notes = notes;
			}

			//DebugLog( @"Client: %d", client.clientID );
			
			client.isActive = activeFlag;
			[returnArray addObject:client];
			[client release];
			[notes release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem fetching your clients.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:returnArray];
	return returnArray;
}

/*
 *	removeClient
 *	Sets the isActive column to 1
 */
- (void)removeClient:(NSInteger)key {
	//NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_client WHERE clientID='%i'", key];
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_client SET isActive=0 WHERE clientID=%ld", (long)key];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem trying to delete your client.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// Do the query
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting this client.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	saveClient
 *	Adds a client to the datsqlite3_column_int(statement, 14);abase
 */
- (void) insertClient:(Client*)client {
	//NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_client (firstname, lastName, workPhone, homePhone, cellPhone, address1, address2, city, stateID, zipCode, email, birthdate, anniversary, notes) VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", [client.firstName UTF8String], [client.lastName UTF8String], [client.workPhone UTF8String], [client.homePhone UTF8String], [client.cellPhone UTF8String], [client.address1 UTF8String], [client.address2 UTF8String], [client.city UTF8String], [client.stateID UTF8String], [client.zipcode UTF8String], [client.email UTF8String], [client.birthdate UTF8String], [client.anniversary UTF8String], [client.notes UTF8String]];
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_client ( ABPersonRefID, notes, firstName, lastName ) VALUES( %ld, '%@', '%@', '%@' )", (long)client.personID, [self escapeSQLCharacters:client.notes], [self escapeSQLCharacters:client.firstName], [self escapeSQLCharacters:client.lastName]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to save this client.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];

	// Do the query
	int success = sqlite3_step(statement);	
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem saving this client.\n\nPlease restart the app and report this message to our support if it reappears."];
	} else if( success == SQLITE_CONSTRAINT ) {
		// Set the active flag and do an update instead
		client.isActive = YES;
		[self updateClient:client];		
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	updateClient
 *	Updates a client (in DB)
 */
- (void) updateClient:(Client*)client {
	//NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_client SET firstname='%s', lastName='%s', workPhone='%s', homePhone='%s', cellPhone='%s', address1='%s', address2='%s', city='%s', stateID='%s', zipCode='%s', email='%s', birthdate='%s', anniversary='%s', notes='%s' WHERE clientID='%d'", [client.firstName UTF8String], [client.lastName UTF8String], [client.workPhone UTF8String], [client.homePhone UTF8String], [client.cellPhone UTF8String], [client.address1 UTF8String], [client.address2 UTF8String], [client.city UTF8String], [client.stateID UTF8String], [client.zipcode UTF8String], [client.email UTF8String], client.birthdate, client.anniversary, [client.notes UTF8String], client.clientID];
	NSString *sql = nil;
	if( client.clientID == -1 && client.personID > -1 ) {
		// In this situation there should be a person ID that we can update the row on (because it is UNIQUE).
		// Essentially this just sets the isActive column (make sure to set this as desired before you pass in Client).
		// TODO: I forgot what situations this is used for!
		sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_client SET isActive=%d, firstName='%@', lastName='%@' WHERE ABPersonRefID=%ld", client.isActive, [self escapeSQLCharacters:client.firstName], [self escapeSQLCharacters:client.lastName], (long)client.personID];
	} else if( client.clientID > -1 ) {
		// Else do the normal update with the clientID
		sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_client SET ABPersonRefID=%ld, notes='%@', firstName='%@', lastName='%@' WHERE clientID = %ld", (long)client.personID, [self escapeSQLCharacters:client.notes], [self escapeSQLCharacters:client.firstName], [self escapeSQLCharacters:client.lastName], (long)client.clientID];
	}

	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a client.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a client.\n\nPlease restart the app and report this message to our support if it reappears."];
	} else if( success == SQLITE_CONSTRAINT ) {
		[self.delegate dbReturnedError:@"The chosen Contact is already associated with a client! Please select a unique Contact from the list."];
	}
	
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Company Methods
#pragma mark -
/*
 *	loadCompany
 *	Returns the last company from a general SELECT
 *	Must release when done!
 */
- (Company*) getCompany  {
	Company *returnCompany = nil;
	NSString *sql = @"SELECT * FROM iBiz_company ORDER BY companyID ASC LIMIT 1";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			//int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the array.
			NSInteger newKey = sqlite3_column_int(statement, 0);
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			if( !name || [name isEqualToString:@"(null)"] || [name isEqualToString:@""] ) {
				[name release];
				name = nil;
			}
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			NSString *addr1 = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( !addr1 || [addr1 isEqualToString:@"(null)"] || [addr1 isEqualToString:@""] ) {
				[addr1 release];
				addr1 = nil;
			}
			NSString *addr2 = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			if( !addr2 || [addr2 isEqualToString:@"(null)"] || [addr2 isEqualToString:@""] ) {
				[addr2 release];
				addr2 = nil;
			}
			NSString *compCity = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( !compCity || [compCity isEqualToString:@"(null)"] || [compCity isEqualToString:@""] ) {
				[compCity release];
				compCity = nil;
			}
			NSString *compState = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
			if( !compState || [compState isEqualToString:@"(null)"] || [compState isEqualToString:@""] ) {
				[compState release];
				compState = nil;
			}
			NSInteger zipCode = sqlite3_column_int(statement, 7);
			NSString *compEmail = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
			if( !compEmail || [compEmail isEqualToString:@"(null)"] || [compEmail isEqualToString:@""] ) {
				[compEmail release];
				compEmail = nil;
			}
			NSString *phone = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( !phone || [phone isEqualToString:@"(null)"] || [phone isEqualToString:@""] ) {
				[phone release];
				phone = nil;
			}
			NSString *fax = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
			if( !fax || [fax isEqualToString:@"(null)"] || [fax isEqualToString:@""] ) {
				[fax release];
				fax = nil;
			}
			NSInteger months = sqlite3_column_int(statement, 11);
			NSString *owner = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
			if( !owner || [owner isEqualToString:@"(null)"] || [owner isEqualToString:@""] ) {
				[owner release];
				owner = nil;
			}
			NSNumber *commission = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 13)];

			if( returnCompany != nil )	[returnCompany release];
			returnCompany = [[Company alloc] initWithCompanyData:newKey name:name tax:tax addr1:addr1 addr2:addr2 city:compCity state:compState zip:zipCode email:compEmail phone:phone fax:fax appts:months owner:owner commissionRate:commission];
			
			// Release the allocated values
			[name release];
			[tax release];
			[addr1 release];
			[addr2 release];
			[compCity release];
			[compState release];
			[compEmail release];
			[phone release];
			[fax release];
			[owner release];
			[commission release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem fetching your company information.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	// Return
	return returnCompany;
}

/*
 *	updateCompany
 *	UPDATEs a company in the DB
 */
- (void) updateCompany:(Company*)theCompany {	
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_company SET companyName='%@', salesTax='%.2f', companyAddress1='%@', companyAddress2='%@', companyCity='%@', stateID='%@', companyZipCode='%li', companyEmail='%@', companyPhone='%@', companyFax='%@', MonthsOldAppointments='%li', OwnerName='%@', commissionRate='%.2f' WHERE companyID='%li';", [self escapeSQLCharacters:theCompany.companyName], [theCompany.salesTax doubleValue], [self escapeSQLCharacters:theCompany.companyAddress1], [self escapeSQLCharacters:theCompany.companyAddress2], [self escapeSQLCharacters:theCompany.companyCity], [self escapeSQLCharacters:theCompany.companyState], (long)theCompany.companyZipCode, [self escapeSQLCharacters:theCompany.companyEmail], [self escapeSQLCharacters:theCompany.companyPhone], [self escapeSQLCharacters:theCompany.companyFax], (long)theCompany.monthsOldAppointments, [self escapeSQLCharacters:theCompany.ownerName], [theCompany.commissionRate doubleValue], (long)theCompany.companyID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your company information.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating your company information.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

#pragma mark -
#pragma mark Email
#pragma mark -
/*
 *	Must release this array when done!
 */
- (Email*) getEmailOfType:(PSAEmailType)type {
	Email *returnEmail = nil;
	NSString *sql = nil;
	if( type == PSAEmailTypeAnniversary ) {
		sql = @"SELECT emailID, bccSelf, subject, message, type FROM iBiz_email WHERE emailID=0";
	} else if( type == PSAEmailTypeBirthday ) {
		sql = @"SELECT emailID, bccSelf, subject, message, type FROM iBiz_email WHERE emailID=1";
	} else if( type == PSAEmailTypeAppointmentReminder ) {
		sql = @"SELECT emailID, bccSelf, subject, message, type FROM iBiz_email WHERE emailID=2";
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			
			returnEmail = [[Email alloc] init];
			returnEmail.emailID = sqlite3_column_int(statement, 0);
			returnEmail.bccCompany = sqlite3_column_int(statement, 1);
			//
			NSString *subject = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !subject || [subject isEqualToString:@"(null)"] || [subject isEqualToString:@""] ) {
				[subject release];
				subject = nil;
			}
			returnEmail.subject = subject;
			//
			NSString *message = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( !message || [message isEqualToString:@"(null)"] || [message isEqualToString:@""] ) {
				[message release];
				message = nil;
			}
			// For some reason, originally populating the database with '\n' doesn't work, so I set the messages to use <<NEWLINE>> instead.
			returnEmail.message = [message stringByReplacingOccurrencesOfString:@"<<NEWLINE>>" withString:@"\n"];
			//
			returnEmail.type = sqlite3_column_int(statement, 4);
			// Release the allocated values
			[subject release];
			[message release];
			
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem fetching your email message.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	// Return
	return returnEmail;
}

/*
 *
 */
- (void) updateEmail:(Email*)theEmail {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_email SET bccSelf=%d, subject='%@', message='%@' WHERE emailID=%ld;", theEmail.bccCompany, [self escapeSQLCharacters:theEmail.subject], [self escapeSQLCharacters:theEmail.message], (long)theEmail.emailID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your email message.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating your company email message.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Product Type Methods
#pragma mark -

/*
 *	Returns an array of all ProductType objects
 *	Must release when done!
 */
- (NSArray*) getProductTypes {
	NSMutableArray *typesArray = [[NSMutableArray alloc] init];
	
	// Get all values.
	NSString *sql = [[NSString alloc] initWithString:@"SELECT * FROM iBiz_productType ORDER BY productDescription;"];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Get the values
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *newType = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			// Add the product
			ProductType *tp = [[ProductType alloc] initWithTypeData:newType key:newKey];
			[typesArray addObject:tp];
			[tp release];
			[newType release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch product types.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return typesArray;
}

/*
 *
 *	Removes a ProductType record from the DB (and all the products under it?)
 */
- (void) removeProductType:(ProductType*)theType {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_productType WHERE productTypeID=%ld;", (long)theType.typeID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a product type.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a product type.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *	Inserts a new ProductType record into the DB
 */
- (void) insertProductType:(ProductType*)theType {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_productType ( productDescription ) VALUES ( '%@' );", [self escapeSQLCharacters:theType.typeDescription]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a product type.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a product type.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *	Updates a ProductType record in the DB
 */
- (void) updateProductType:(ProductType*)theType {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_productType SET productDescription='%@' WHERE productTypeID=%ld;", [self escapeSQLCharacters:theType.typeDescription], (long)theType.typeID];
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a product type.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a product type.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Product Methods
#pragma mark -
/*
 *	Sets all ProductType IDs to 0 for Products with the given type ID.
 */
- (void) bulkUpdateProductTypeToDefaultFromType:(ProductType*)theType {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_products SET productTypeID=0 WHERE productTypeID=%ld;", (long)theType.typeID];	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update products for the deleted type.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating products for the deleted type.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Returns a dictionary of keys (type name) and arrays of Product objects (for that type name)
 *	Must release when done!
 */
- (void) getDictionaryOfProductsByTypeWithActiveFlag:(NSNumber*)active {
	NSMutableDictionary *productsDict = [[NSMutableDictionary alloc] init];
	NSString *sql = nil;
	if( [active boolValue] ) {
		sql = [[NSString alloc] initWithString:@"SELECT productID, productNumber, productName, cost, price, productMin, productMax, (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=0), iBiz_products.vendorID, iBiz_products.productTypeID, taxable, iBiz_productType.productDescription, iBiz_vendor.vendorName, isActive, (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=1), (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=2) FROM iBiz_products INNER JOIN iBiz_productType USING (productTypeID) LEFT OUTER JOIN iBiz_vendor ON iBiz_products.vendorID = iBiz_vendor.vendorID WHERE isActive=1 ORDER BY productName"];
	} else {
		sql = [[NSString alloc] initWithString:@"SELECT productID, productNumber, productName, cost, price, productMin, productMax, (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=0), iBiz_products.vendorID, iBiz_products.productTypeID, taxable, iBiz_productType.productDescription, iBiz_vendor.vendorName, isActive, (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=1), (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=2) FROM iBiz_products INNER JOIN iBiz_productType USING (productTypeID) LEFT OUTER JOIN iBiz_vendor ON iBiz_products.vendorID = iBiz_vendor.vendorID ORDER BY productName"];		
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Values from DB
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *sNum = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			if( !sNum || [sNum isEqualToString:@"(null)"] ) {
				[sNum release];
				sNum = nil;
			}
			NSString *sName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !sName || [sName isEqualToString:@"(null)"] ) {
				[sName release];
				sName = [[NSString alloc] initWithString:@"No Name"];
			}
			NSNumber *sCost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			NSNumber *sPrice = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			NSInteger prodMin = sqlite3_column_int(statement, 5);
			NSInteger prodMax = sqlite3_column_int(statement, 6);
			// Inventory, quantity added
			NSInteger amountAdded = sqlite3_column_int(statement, 7);
			NSInteger vId = sqlite3_column_int(statement, 8);
			NSInteger prdTypeID = sqlite3_column_int(statement, 9);

			NSInteger tax = sqlite3_column_int(statement, 10);
			// Our key
			NSString *key = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
			//
			NSString *vendorName = nil;
			if( sqlite3_column_type(statement, 12) != SQLITE_NULL ) {
				vendorName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
			}
			//
			NSInteger activeFlag = sqlite3_column_int(statement, 13);
			
			NSInteger professionalUsed = sqlite3_column_int(statement, 14);			
			NSInteger retailSold = sqlite3_column_int(statement, 15);
			NSInteger onH = amountAdded-professionalUsed-retailSold;
			
			NSMutableArray *array = [productsDict objectForKey:key];
			if( !array ){
				array = [[NSMutableArray alloc] init];
				[productsDict setObject:array forKey:key];
				[array release];
			}
			
			Product *prd = [[Product alloc] initWithProductData:newKey prodNum:sNum prodName:sName prodCost:sCost prodPrice:sPrice prodMin:prodMin prodMax:prodMax prodOnHand:onH vendor:vId prodTyID:prdTypeID tax:tax];
			prd.productTypeName = key;
			prd.isActive = activeFlag;
			prd.productVendorName = vendorName;
			[array addObject:prd];
			[prd release];
			
			// Releases
			[sName release];
			[sNum release];
			[sCost release];
			[sPrice release];
			[vendorName release];
			[key release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch products.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedDictionary:) withObject:productsDict waitUntilDone:YES];
	[productsDict release];
}

/*
 *	MUST release when done!
 */
- (Product*) getProductWithID:(NSInteger)theID {
	Product *returnProduct = nil;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT productID, productNumber, productName, cost, price, productMin, productMax, (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=0), iBiz_products.vendorID, iBiz_products.productTypeID, taxable, iBiz_productType.productDescription, iBiz_vendor.vendorName, isActive, (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=1), (SELECT SUM(adjustmentQuantity) FROM iBiz_productAdjustment WHERE iBiz_productAdjustment.productID=iBiz_products.productID AND adjustmentTypeID=2) FROM iBiz_products INNER JOIN iBiz_productType USING (productTypeID) LEFT OUTER JOIN iBiz_vendor ON iBiz_products.vendorID = iBiz_vendor.vendorID WHERE productID=%ld;", (long)theID];
	sqlite3_stmt *statement;     
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// 1 row needed
		if (sqlite3_step(statement) == SQLITE_ROW) {
			// Values from DB
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *sNum = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			if( !sNum || [sNum isEqualToString:@"(null)"] ) {
				[sNum release];
				sNum = nil;
			}
			NSString *sName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !sName || [sName isEqualToString:@"(null)"] ) {
				[sName release];
				sName = [[NSString alloc] initWithString:@"No Name"];
			}
			NSNumber *sCost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			NSNumber *sPrice = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			NSInteger prodMin = sqlite3_column_int(statement, 5);
			NSInteger prodMax = sqlite3_column_int(statement, 6);
			// Inventory, quantity added
			NSInteger amountAdded = sqlite3_column_int(statement, 7);
			NSInteger vId = sqlite3_column_int(statement, 8);
			NSInteger prdTypeID = sqlite3_column_int(statement, 9);
			
			NSInteger tax = sqlite3_column_int(statement, 10);
			// Our key
			NSString *key = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
			//
			NSString *vendorName = nil;
			if( sqlite3_column_type(statement, 12) != SQLITE_NULL ) {
				vendorName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
			}
			//
			NSInteger activeFlag = sqlite3_column_int(statement, 13);
			
			NSInteger professionalUsed = sqlite3_column_int(statement, 14);			
			NSInteger retailSold = sqlite3_column_int(statement, 15);
			NSInteger onH = amountAdded-professionalUsed-retailSold;
			
			Product *prd = [[Product alloc] initWithProductData:newKey prodNum:sNum prodName:sName prodCost:sCost prodPrice:sPrice prodMin:prodMin prodMax:prodMax prodOnHand:onH vendor:vId prodTyID:prdTypeID tax:tax];
			prd.productTypeName = key;
			prd.isActive = activeFlag;
			prd.productVendorName = vendorName;
			returnProduct = prd;
			
			// Releases
			[sName release];
			[sNum release];
			[sCost release];
			[sPrice release];
			[vendorName release];
			[key release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnProduct;
}

/*
 *
 *
 */
- (void) removeProduct:(Product*)theProduct {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_products WHERE productID=%ld;", (long)theProduct.productID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) insertProduct:(Product*)theProduct {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_products ( productNumber, productName, cost, price, productMin, productMax, onHand, vendorID, productTypeID, taxable ) VALUES ( '%@', '%@', '%.2f', '%.2f', %ld, %ld, %ld, %ld, %ld, %ld );", [self escapeSQLCharacters:theProduct.productNumber], [self escapeSQLCharacters:theProduct.productName], [theProduct.productCost doubleValue], [theProduct.productPrice doubleValue], (long)theProduct.productMin, (long)theProduct.productMax, (long)theProduct.productInStock, (long)theProduct.vendorID, (long)theProduct.productTypeID, (long)theProduct.productTaxable];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theProduct.productID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) updateProduct:(Product*)theProduct {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_products SET productNumber='%@', productName='%@', cost='%.2f', price='%.2f', productMin=%ld, productMax=%ld, onHand=%ld, vendorID=%ld, productTypeID=%ld, taxable=%ld, isActive=%d WHERE productID=%ld;", [self escapeSQLCharacters:theProduct.productNumber], [self escapeSQLCharacters:theProduct.productName], [theProduct.productCost doubleValue], [theProduct.productPrice doubleValue], (long)theProduct.productMin, (long)theProduct.productMax, (long)theProduct.productInStock, (long)theProduct.vendorID, (long)theProduct.productTypeID, (long)theProduct.productTaxable, theProduct.isActive, (long)theProduct.productID];	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a product.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

#pragma mark -
#pragma mark ProductAdjustment Methods
#pragma mark -

- (void) deleteProductAdjustmentWithID:(NSInteger)theID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_productAdjustment WHERE productAdjustmentID=%ld;", (long)theID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a product adjustment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a product adjustment.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	MUST release when done!
 */
- (void) getProductAdjustmentsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	if( start && end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT productAdjustmentID, iBiz_productAdjustment.productID, adjustmentTypeID, adjustmentDate, adjustmentQuantity, productName FROM iBiz_productAdjustment LEFT OUTER JOIN iBiz_products ON iBiz_productAdjustment.productID=iBiz_products.productID WHERE adjustmentDate>=%f AND adjustmentDate<=%f ORDER BY adjustmentDate DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
	} else if( start ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT productAdjustmentID, iBiz_productAdjustment.productID, adjustmentTypeID, adjustmentDate, adjustmentQuantity, productName FROM iBiz_productAdjustment LEFT OUTER JOIN iBiz_products ON iBiz_productAdjustment.productID=iBiz_products.productID WHERE adjustmentDate>=%f ORDER BY adjustmentDate DESC;", [self getTimeIntervalForGMT:start]];
	} else if( end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT productAdjustmentID, iBiz_productAdjustment.productID, adjustmentTypeID, adjustmentDate, adjustmentQuantity, productName FROM iBiz_productAdjustment LEFT OUTER JOIN iBiz_products ON iBiz_productAdjustment.productID=iBiz_products.productID WHERE adjustmentDate<=%f ORDER BY adjustmentDate DESC;", [self getTimeIntervalForGMT:end]];
	} else {
		sql = [[NSString alloc] initWithString:@"SELECT productAdjustmentID, iBiz_productAdjustment.productID, adjustmentTypeID, adjustmentDate, adjustmentQuantity, productName FROM iBiz_productAdjustment LEFT OUTER JOIN iBiz_products ON iBiz_productAdjustment.productID=iBiz_products.productID ORDER BY adjustmentDate DESC;"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			ProductAdjustment *tmp = [[ProductAdjustment alloc] init];
			tmp.productAdjustmentID = sqlite3_column_int(statement, 0);
			tmp.productID = sqlite3_column_int(statement, 1);
			tmp.type = sqlite3_column_int(statement, 2);
			
			double date = sqlite3_column_double(statement, 3);
			if( date > 0 ) {
				tmp.adjustmentDate = [self getDateForTimeInterval:date];
			}
			
			tmp.quantity = sqlite3_column_int(statement, 4);
			
			NSString *sName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( !sName || [sName isEqualToString:@"(null)"] ) {
				[sName release];
				sName = [[NSString alloc] initWithString:@"No Name"];
			}
			tmp.productName = sName;
			[sName release];
			
			[returnArray addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a product adjustment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:returnArray waitUntilDone:YES];
	[returnArray release];
}

/*
 *	MUST release when done!
 */
- (ProductAdjustment*) getProductAdjustmentWithID:(NSInteger)theID {
	ProductAdjustment *tmp = nil;
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT productAdjustmentID, productID, adjustmentTypeID, adjustmentDate, adjustmentQuantity FROM iBiz_productAdjustment WHERE productAdjustmentID=%ld;", (long)theID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			tmp = [[ProductAdjustment alloc] init];
			tmp.productAdjustmentID = sqlite3_column_int(statement, 0);
			tmp.productID = sqlite3_column_int(statement, 1);
			tmp.type = sqlite3_column_int(statement, 2);
			
			double date = sqlite3_column_double(statement, 3);
			if( date > 0 ) {
				tmp.adjustmentDate = [self getDateForTimeInterval:date];
			}
			
			tmp.quantity = sqlite3_column_int(statement, 4);	
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a product adjustment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return tmp;
}

- (void) insertProductAdjustment:(ProductAdjustment*)theAdjustment {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_productAdjustment ( productID, adjustmentTypeID, adjustmentDate, adjustmentQuantity ) VALUES ( %ld, %d, %f, %ld );", (long)theAdjustment.productID, theAdjustment.type, [self getTimeIntervalForGMT:theAdjustment.adjustmentDate], (long)theAdjustment.quantity];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theAdjustment.productAdjustmentID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

- (void) updateProductAdjustment:(ProductAdjustment*)theAdjustment {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_productAdjustment SET productID=%ld, adjustmentTypeID=%d, adjustmentDate=%f, adjustmentQuantity=%ld WHERE productAdjustmentID=%ld;", (long)theAdjustment.productID, theAdjustment.type, [self getTimeIntervalForGMT:theAdjustment.adjustmentDate], (long)theAdjustment.quantity, (long)theAdjustment.productAdjustmentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Projects
#pragma mark -
/*
 *	Deletes the project, and it's products and services.
 */
- (void) deleteProjectWithID:(NSInteger)projectID {
	/*
	 *	PROJECT
	 */
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_projects WHERE projectID=%ld;", (long)projectID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
	/*
	 *	PRODUCTS
	 */
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_products WHERE projectID=%ld;", (long)projectID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a project's product.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a project's product.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
	/*
	 *	SERVICES
	 */
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_services WHERE projectID=%ld;", (long)projectID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a project's service.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a project's service.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
	/*
	 *	APPOINTMENTS
	 */
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_appointments WHERE type=%d AND typeID=%ld;", iBizAppointmentTypeProject, (long)projectID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a project's appointments.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a project's appointments.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
}

/*
 * Deletes the invoice, and removes it from closeouts
 */
- (void) deleteProjectInvoiceWithID:(NSInteger)invoiceID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_invoice WHERE projectInvoiceID=%ld;", (long)invoiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
	/*
	 *	Closeouts
	 */
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_closeout_invoice WHERE invoiceID=%ld;", (long)invoiceID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteProjectInvoicePaymentFromCloseouts:(TransactionPayment*)thePayment {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_closeout_payment WHERE paymentID=%ld;", (long)thePayment.transactionPaymentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete an invoice payment from closeouts.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an invoice payment from closeouts.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteProjectInvoiceProduct:(NSInteger)pipID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_invoice_product WHERE pipID=%ld;", (long)pipID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a product from an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a product from an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteProjectInvoiceService:(NSInteger)pisID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_invoice_service WHERE pisID=%ld;", (long)pisID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a product from an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a service from an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteProjectProductWithID:(NSInteger)projectProductID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_products WHERE projectProductID=%ld;", (long)projectProductID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a product from this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a product from this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteProjectServiceWithID:(NSInteger)projectServiceID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_services WHERE projectServiceID=%ld;", (long)projectServiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a service from this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a service from this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	MUST release when done!
 */
- (NSMutableArray*) getArrayOfInvoiceProductsForInvoice:(ProjectInvoice*)theInvoice {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT pipID, projectProductID FROM iBiz_project_invoice_product WHERE projectInvoiceID=%ld;", (long)theInvoice.invoiceID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			ProjectInvoiceItem *ii = [[ProjectInvoiceItem alloc] init];
			ii.invoiceItemID = sqlite3_column_int(statement, 0);
			ii.itemID = sqlite3_column_int(statement, 1);
			ii.invoiceID = theInvoice.invoiceID;
			[returnArray addObject:ii];
			[ii release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoice products.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *	MUST release when done!
 */
- (NSMutableArray*) getArrayOfInvoiceServicesForInvoice:(ProjectInvoice*)theInvoice {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT pisID, projectServiceID FROM iBiz_project_invoice_service WHERE projectInvoiceID=%ld;", (long)theInvoice.invoiceID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			ProjectInvoiceItem *ii = [[ProjectInvoiceItem alloc] init];
			ii.invoiceItemID = sqlite3_column_int(statement, 0);
			ii.itemID = sqlite3_column_int(statement, 1);
			ii.invoiceID = theInvoice.invoiceID;
			[returnArray addObject:ii];
			[ii release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoice services.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *	MUST release when done!
 */
- (NSArray*) getArrayOfInvoicesForProject:(Project*)theProject {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes FROM iBiz_project_invoice WHERE projectID=%ld ORDER BY name;", (long)theProject.projectID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			ProjectInvoice *invoice = [[ProjectInvoice alloc] init];
			invoice.invoiceID = sqlite3_column_int(statement, 0);
			invoice.type = sqlite3_column_int(statement, 1);
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			invoice.name = name;
			[name release];
			
			// Dates
			double due = sqlite3_column_double(statement, 3);
			if( due > 0 ) {
				invoice.dateDue = [self getDateForTimeInterval:due];
			}
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				invoice.dateOpened = [self getDateForTimeInterval:created];
			}
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				invoice.datePaid = [self getDateForTimeInterval:paid];
			}
			
			NSNumber *comm = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			invoice.commissionAmount = comm;
			[comm release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			invoice.taxPercent = tax;
			[tax release];
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			invoice.totalForTable = tot;
			[tot release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			invoice.notes = notes;
			[notes release];
			
			[returnArray addObject:invoice];
			[invoice release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *	No need to release when done!
 */
- (void) getArrayOfProjectsByType:(NSNumber*)type {
	NSMutableArray *projectsDict = [[NSMutableArray alloc] init];
	NSString *sql = nil;
	switch ( [type integerValue] ) {
		case iBizProjectStatusAll:
			sql = [[NSString alloc] initWithString:@"SELECT projectID, clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects ORDER BY name;"];
			break;
		case iBizProjectStatusOpen:
			sql = [[NSString alloc] initWithString:@"SELECT projectID, clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects WHERE dateCreated>0 AND dateCompleted=0 ORDER BY name;"];
			break;
		case iBizProjectStatusCompleted:
			sql = [[NSString alloc] initWithString:@"SELECT projectID, clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects WHERE dateCompleted>0 ORDER BY name;"];
			break;
		case iBizProjectStatusUnpaid:
			sql = [[NSString alloc] initWithFormat:@"SELECT projectID, clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects WHERE projectID IN (SELECT projectID FROM iBiz_project_invoice WHERE type=%d AND dateOpened>0 AND datePaid=0) ORDER BY name;", iBizProjectInvoice];
			break;
	}

	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {			
			Project *project = [[Project alloc] init];
			// Data
			NSInteger projectID = sqlite3_column_int(statement, 0);
			project.projectID = projectID;
			NSInteger clientID = sqlite3_column_int(statement, 1);
			Client *cl = [self getClientWithID:clientID];
			project.client = cl;
			[cl release];
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			project.name = name;
			[name release];

			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			project.notes = notes;
			[notes release];
			
			// Dates
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				project.dateCreated = [self getDateForTimeInterval:created];
			}
			double completed = sqlite3_column_double(statement, 5);
			if( completed > 0 ) {
				project.dateCompleted = [self getDateForTimeInterval:completed];
			}
			double due = sqlite3_column_double(statement, 6);
			if( due > 0 ) {
				project.dateDue = [self getDateForTimeInterval:due];
			}
			double modified = sqlite3_column_double(statement, 7);
			if( modified > 0 ) {
				project.dateModified = [self getDateForTimeInterval:modified];
			}
			
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			project.totalForTable = tot;
			[tot release];

			[projectsDict addObject:project];
			[project release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch projects.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:projectsDict waitUntilDone:YES];
	[projectsDict release];
}

/*
 *	No need to release when done!
 */
- (void) getArrayOfProjectsForClient:(Client*)theClient {
	NSMutableArray *projectsDict = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectID, clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects WHERE clientID=%ld ORDER BY dateModified DESC;", (long)theClient.clientID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {			
			Project *project = [[Project alloc] init];
			// Data
			NSInteger projectID = sqlite3_column_int(statement, 0);
			project.projectID = projectID;
			project.client = theClient;
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			project.name = name;
			[name release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			project.notes = notes;
			[notes release];
			
			// Dates
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				project.dateCreated = [self getDateForTimeInterval:created];
			}
			double completed = sqlite3_column_double(statement, 5);
			if( completed > 0 ) {
				project.dateCompleted = [self getDateForTimeInterval:completed];
			}
			double due = sqlite3_column_double(statement, 6);
			if( due > 0 ) {
				project.dateDue = [self getDateForTimeInterval:due];
			}
			double modified = sqlite3_column_double(statement, 7);
			if( modified > 0 ) {
				project.dateModified = [self getDateForTimeInterval:modified];
			}
			
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			project.totalForTable = tot;
			[tot release];
			
			[projectsDict addObject:project];
			[project release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch projects.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:projectsDict waitUntilDone:YES];
	[projectsDict release];
}

/*
 *	No release when done.
 */
- (void) getInvoicesFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql;
	if( start && end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes, projectID FROM iBiz_project_invoice WHERE type=%d AND dateOpened>=%f AND dateOpened<=%f ORDER BY name;", iBizProjectInvoice, [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
	} else if( start ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes, projectID FROM iBiz_project_invoice WHERE type=%d AND dateOpened>=%f ORDER BY name;", iBizProjectInvoice, [self getTimeIntervalForGMT:start]];
	} else if( end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes, projectID FROM iBiz_project_invoice WHERE type=%d AND dateOpened<=%f ORDER BY name;", iBizProjectInvoice, [self getTimeIntervalForGMT:end]];
	} else {
		sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes, projectID FROM iBiz_project_invoice WHERE type=%d ORDER BY name;", iBizProjectInvoice];
	}
	sqlite3_stmt *statement;
	
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			ProjectInvoice *invoice = [[ProjectInvoice alloc] init];
			invoice.invoiceID = sqlite3_column_int(statement, 0);
			invoice.type = sqlite3_column_int(statement, 1);
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			invoice.name = name;
			[name release];
			
			// Dates
			double due = sqlite3_column_double(statement, 3);
			if( due > 0 ) {
				invoice.dateDue = [self getDateForTimeInterval:due];
			}
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				invoice.dateOpened = [self getDateForTimeInterval:created];
			}
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				invoice.datePaid = [self getDateForTimeInterval:paid];
			}
			
			NSNumber *comm = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			invoice.commissionAmount = comm;
			[comm release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			invoice.taxPercent = tax;
			[tax release];
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			invoice.totalForTable = tot;
			[tot release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			invoice.notes = notes;
			[notes release];
			
			invoice.projectID = sqlite3_column_int(statement, 10);
			
			[returnArray addObject:invoice];
			[invoice release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:returnArray waitUntilDone:YES];
	[returnArray release];
}

/*
 *	MUST release when done!
 */
- (ProjectInvoice*) getInvoiceWithPaymentID:(NSInteger)paymentID {
	ProjectInvoice *invoice = nil;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes, projectID FROM iBiz_project_invoice WHERE projectInvoiceID IN (SELECT invoiceID FROM iBiz_transactionPayment WHERE transactionPaymentID=%ld) ORDER BY name;", (long)paymentID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			invoice = [[ProjectInvoice alloc] init];
			invoice.invoiceID = sqlite3_column_int(statement, 0);
			invoice.type = sqlite3_column_int(statement, 1);
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			invoice.name = name;
			[name release];
			
			// Dates
			double due = sqlite3_column_double(statement, 3);
			if( due > 0 ) {
				invoice.dateDue = [self getDateForTimeInterval:due];
			}
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				invoice.dateOpened = [self getDateForTimeInterval:created];
			}
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				invoice.datePaid = [self getDateForTimeInterval:paid];
			}
			
			NSNumber *comm = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			invoice.commissionAmount = comm;
			[comm release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			invoice.taxPercent = tax;
			[tax release];
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			invoice.totalForTable = tot;
			[tot release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			invoice.notes = notes;
			[notes release];
			
			invoice.projectID = sqlite3_column_int(statement, 10);
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return invoice;
}

/*
 *	MUST release when done!
 */
- (Project*) getProjectWithID:(NSInteger)theID {
	Project *theProject = nil;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects WHERE projectID=%ld LIMIT 1;", (long)theID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		if (sqlite3_step(statement) == SQLITE_ROW) {			
			theProject = [[Project alloc] init];
			// Data
			theProject.projectID = theID;
			NSInteger clientID = sqlite3_column_int(statement, 0);
			Client *cl = [self getClientWithID:clientID];
			theProject.client = cl;
			[cl release];
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			theProject.name = name;
			[name release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			theProject.notes = notes;
			[notes release];
			
			// Dates
			double created = sqlite3_column_double(statement, 3);
			if( created > 0 ) {
				theProject.dateCreated = [self getDateForTimeInterval:created];
			}
			double completed = sqlite3_column_double(statement, 4);
			if( completed > 0 ) {
				theProject.dateCompleted = [self getDateForTimeInterval:completed];
			}
			double due = sqlite3_column_double(statement, 5);
			if( due > 0 ) {
				theProject.dateDue = [self getDateForTimeInterval:due];
			}
			double modified = sqlite3_column_double(statement, 6);
			if( modified > 0 ) {
				theProject.dateModified = [self getDateForTimeInterval:modified];
			}
			
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			theProject.totalForTable = tot;
			[tot release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return theProject;
}

/*
 *	MUST release when done!
 */
- (Project*) getProjectWithInvoiceID:(NSInteger)invoiceID {
	Project *theProject = nil;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectID, clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable FROM iBiz_projects WHERE projectID=(SELECT projectID FROM iBiz_project_invoice WHERE projectInvoiceID=%ld) LIMIT 1;", (long)invoiceID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		if (sqlite3_step(statement) == SQLITE_ROW) {			
			theProject = [[Project alloc] init];
			// Data
			theProject.projectID = sqlite3_column_int(statement, 0);
			NSInteger clientID = sqlite3_column_int(statement, 1);
			Client *cl = [self getClientWithID:clientID];
			theProject.client = cl;
			[cl release];
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			theProject.name = name;
			[name release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			theProject.notes = notes;
			[notes release];
			
			// Dates
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				theProject.dateCreated = [self getDateForTimeInterval:created];
			}
			double completed = sqlite3_column_double(statement, 5);
			if( completed > 0 ) {
				theProject.dateCompleted = [self getDateForTimeInterval:completed];
			}
			double due = sqlite3_column_double(statement, 6);
			if( due > 0 ) {
				theProject.dateDue = [self getDateForTimeInterval:due];
			}
			double modified = sqlite3_column_double(statement, 7);
			if( modified > 0 ) {
				theProject.dateModified = [self getDateForTimeInterval:modified];
			}
			
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			theProject.totalForTable = tot;
			[tot release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return theProject;
}

/*
 *	No need to release when done!
 */
- (NSMutableArray*) getArrayOfProductsForProject:(Project*)theProject {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectProductID, productID, price, productAdjustmentID, discountAmount, isPercentDiscount, taxed, cost FROM iBiz_project_products WHERE projectID=%ld;", (long)theProject.projectID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			NSInteger ppID = sqlite3_column_int(statement, 0);
			Product *product = [self getProductWithID:sqlite3_column_int(statement, 1)];
			ProjectProduct *pp = [[ProjectProduct alloc] initWithProduct:product];
			[product release];
			pp.projectProductID = ppID;
			pp.projectID = theProject.projectID;
			
			NSNumber *price = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			pp.price = price;
			[price release];
			ProductAdjustment *pa = [self getProductAdjustmentWithID:sqlite3_column_int(statement, 3)];
			pp.productAdjustment = pa;
			[pa release];
			NSNumber *disc = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			pp.discountAmount = disc;
			[disc release];
			pp.isPercentDiscount = sqlite3_column_int(statement, 5);
			pp.taxed = sqlite3_column_int(statement, 6);
			NSNumber *cost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			pp.cost = cost;
			[cost release];
			
			BOOL inserted = NO;
			for( NSInteger i=0; i<returnArray.count; i++ ) {
				ProjectProduct *existing = [returnArray objectAtIndex:i];
				if( [pp.productName compare:existing.productName] != NSOrderedDescending ) {
					[returnArray insertObject:pp atIndex:i];
					inserted = YES;
					break;
				}
			}
			
			if( !inserted )	[returnArray addObject:pp];
			[pp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch project products.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *
 */
- (NSMutableArray*) getArrayOfServicesForProject:(Project*)theProject {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectServiceID, serviceID, price, setupFee, secondsEstimated, secondsWorked, discountAmount, isFlatRate, isPercentDiscount, isTimed, taxed, dateTimerStarted, isTiming, cost FROM iBiz_project_services WHERE projectID=%ld;", (long)theProject.projectID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			NSInteger psID = sqlite3_column_int(statement, 0);
			Service *service = [self getServiceWithID:sqlite3_column_int(statement, 1)];
			ProjectService *ps = [[ProjectService alloc] initWithService:service];
			[service release];
			ps.projectServiceID = psID;
			ps.projectID = theProject.projectID;
			
			NSNumber *price = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			ps.price = price;
			[price release];
			NSNumber *setup = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			ps.setupFee = setup;
			[setup release];
			ps.secondsEstimated = sqlite3_column_int(statement, 4);
			ps.secondsWorked = sqlite3_column_int(statement, 5);
			
			NSNumber *disc = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			ps.discountAmount = disc;
			[disc release];
			ps.isFlatRate = sqlite3_column_int(statement, 7);
			ps.isPercentDiscount = sqlite3_column_int(statement, 8);
			ps.isTimed = sqlite3_column_int(statement, 9);
			ps.taxed = sqlite3_column_int(statement, 10);
			
			double timerStarted = sqlite3_column_double(statement, 11);
			if( timerStarted > 0 ) {
				ps.dateTimerStarted = [self getDateForTimeInterval:timerStarted];
			}
			ps.isTiming = sqlite3_column_int(statement, 12);
			NSNumber *cost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 13)];
			ps.cost = cost;
			[cost release];
			
			BOOL inserted = NO;
			for( NSInteger i=0; i<returnArray.count; i++ ) {
				ProjectService *existing = [returnArray objectAtIndex:i];
				if( [ps.serviceName compare:existing.serviceName] != NSOrderedDescending ) {
					[returnArray insertObject:ps atIndex:i];
					inserted = YES;
					break;
				}
			}
			
			if( !inserted )	[returnArray addObject:ps];
			[ps release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch project services.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *
 */
- (void) getArrayOfUnpaidInvoicesByType:(NSNumber*)type {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes, projectID FROM iBiz_project_invoice WHERE datePaid=0 AND type=%ld ORDER BY name;", (long)[type integerValue]];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			ProjectInvoice *invoice = [[ProjectInvoice alloc] init];
			invoice.invoiceID = sqlite3_column_int(statement, 0);
			invoice.type = sqlite3_column_int(statement, 1);
			
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = [[NSString alloc] initWithString:@"No Name"];
			}
			invoice.name = name;
			[name release];
			
			// Dates
			double due = sqlite3_column_double(statement, 3);
			if( due > 0 ) {
				invoice.dateDue = [self getDateForTimeInterval:due];
			}
			double created = sqlite3_column_double(statement, 4);
			if( created > 0 ) {
				invoice.dateOpened = [self getDateForTimeInterval:created];
			}
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				invoice.datePaid = [self getDateForTimeInterval:paid];
			}
			
			NSNumber *comm = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			invoice.commissionAmount = comm;
			[comm release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			invoice.taxPercent = tax;
			[tax release];
			NSNumber *tot = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			invoice.totalForTable = tot;
			[tot release];
			
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( !notes || [notes isEqualToString:@"(null)"] ) {
				[notes release];
				notes = nil;
			}
			invoice.notes = notes;
			[notes release];
			
			invoice.projectID = sqlite3_column_int(statement, 10);
			
			[returnArray addObject:invoice];
			[invoice release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:returnArray waitUntilDone:YES];
	[returnArray release];
}

/*
 *
 */
- (void) insertProject:(Project*)theProject {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_projects ( clientID, name, notes, dateCreated, dateCompleted, dateDue, dateModified, totalForTable ) VALUES ( %ld, '%@', '%@', %f, %f, %f, %f, %.2f );", (long)theProject.client.clientID, [self escapeSQLCharacters:theProject.name], [self escapeSQLCharacters:theProject.notes], [self getTimeIntervalForGMT:theProject.dateCreated], [self getTimeIntervalForGMT:theProject.dateCompleted], [self getTimeIntervalForGMT:theProject.dateDue], [self getTimeIntervalForGMT:theProject.dateModified], [theProject.totalForTable doubleValue]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theProject.projectID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateProject:(Project*)theProject {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_projects SET clientID=%ld, name='%@', notes='%@', dateCreated=%f, dateCompleted=%f, dateDue=%f, dateModified=%f, totalForTable=%.2f WHERE projectID=%ld;", (long)theProject.client.clientID, [self escapeSQLCharacters:theProject.name], [self escapeSQLCharacters:theProject.notes], [self getTimeIntervalForGMT:theProject.dateCreated], [self getTimeIntervalForGMT:theProject.dateCompleted], [self getTimeIntervalForGMT:theProject.dateDue], [self getTimeIntervalForGMT:theProject.dateModified], [theProject.totalForTable doubleValue], (long)theProject.projectID];	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertProjectProduct:(ProjectProduct*)theProduct {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_project_products ( productID, projectID, price, productAdjustmentID, discountAmount, isPercentDiscount, taxed, cost ) VALUES ( %ld, %ld, %.2f, %ld, %.2f, %d, %d, %@ );", (long)theProduct.productID, (long)theProduct.projectID, [theProduct.price doubleValue], (long)theProduct.productAdjustment.productAdjustmentID, [theProduct.discountAmount doubleValue], theProduct.isPercentDiscount, theProduct.taxed, theProduct.cost];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a product to this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theProduct.projectProductID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a product to this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateProjectProduct:(ProjectProduct*)theProduct {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_project_products SET price=%.2f, productAdjustmentID=%ld, discountAmount=%.2f, isPercentDiscount=%d, taxed=%d, cost=%.2f WHERE projectProductID=%ld;", [theProduct.price doubleValue], (long)theProduct.productAdjustment.productAdjustmentID, [theProduct.discountAmount doubleValue], theProduct.isPercentDiscount, theProduct.taxed, [theProduct.cost doubleValue], (long)theProduct.projectProductID];	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a product for this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a product for this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertProjectService:(ProjectService*)theService {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_project_services ( projectID, serviceID, price, setupFee, secondsEstimated, secondsWorked, discountAmount, isFlatRate, isPercentDiscount, isTimed, taxed, dateTimerStarted, isTiming, cost ) VALUES ( %ld, %ld, %.2f, %.2f, %ld, %ld, %.2f, %d, %d, %d, %d, %f, %d, %.2f );", (long)theService.projectID, (long)theService.serviceID, [theService.price doubleValue], [theService.setupFee doubleValue], (long)theService.secondsEstimated, (long)theService.secondsWorked, [theService.discountAmount doubleValue], theService.isFlatRate, theService.isPercentDiscount, theService.isTimed, theService.taxed, [self getTimeIntervalForGMT:theService.dateTimerStarted], theService.isTiming, [theService.cost doubleValue]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a service to this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theService.projectServiceID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a service to this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateProjectService:(ProjectService*)theService {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_project_services SET price=%.2f, setupFee=%.2f, secondsEstimated=%ld, secondsWorked=%ld, discountAmount=%.2f, isFlatRate=%d, isPercentDiscount=%d, isTimed=%d, taxed=%d, dateTimerStarted=%f, isTiming=%d, cost=%.2f WHERE projectServiceID=%ld;", [theService.price doubleValue], [theService.setupFee doubleValue], (long)theService.secondsEstimated, (long)theService.secondsWorked, [theService.discountAmount doubleValue], theService.isFlatRate, theService.isPercentDiscount, theService.isTimed, theService.taxed, [self getTimeIntervalForGMT:theService.dateTimerStarted], theService.isTiming, [theService.cost doubleValue], (long)theService.projectServiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a service for this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a service for this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


/*
 *
 */
- (void) insertInvoice:(ProjectInvoice*)theInvoice {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_project_invoice ( projectID, type, name, dateDue, dateOpened, datePaid, commissionPercent, taxPercent, totalForTable, notes ) VALUES ( %ld, %d, '%@', %f, %f, %f, (SELECT commissionRate FROM iBiz_company LIMIT 1), (SELECT salesTax FROM iBiz_company LIMIT 1), %.2f, '%@' );", (long)theInvoice.projectID, theInvoice.type, [self escapeSQLCharacters:theInvoice.name], [self getTimeIntervalForGMT:theInvoice.dateDue], [self getTimeIntervalForGMT:theInvoice.dateOpened], [self getTimeIntervalForGMT:theInvoice.datePaid], [theInvoice.totalForTable doubleValue], [self escapeSQLCharacters:theInvoice.notes]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		if( theInvoice.type == iBizProjectEstimate ) {
			[self.delegate dbReturnedError:@"There was an internal problem attempting to add an estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
		} else {
			[self.delegate dbReturnedError:@"There was an internal problem attempting to add an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
		}
	}
	[sql release];
	int success = sqlite3_step(statement);
	theInvoice.invoiceID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		if( theInvoice.type == iBizProjectEstimate ) {
			[self.delegate dbReturnedError:@"There was an internal problem adding an estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
		} else {
			[self.delegate dbReturnedError:@"There was an internal problem adding an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateInvoice:(ProjectInvoice*)theInvoice {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_project_invoice SET type=%d, name='%@', dateDue=%f, dateOpened=%f, datePaid=%f, commissionPercent=(SELECT commissionRate FROM iBiz_company LIMIT 1), taxPercent=(SELECT salesTax FROM iBiz_company LIMIT 1), totalForTable=%.2f, notes='%@' WHERE projectInvoiceID=%ld;", theInvoice.type, [self escapeSQLCharacters:theInvoice.name], [self getTimeIntervalForGMT:theInvoice.dateDue], [self getTimeIntervalForGMT:theInvoice.dateOpened], [self getTimeIntervalForGMT:theInvoice.datePaid], [theInvoice.totalForTable doubleValue], [self escapeSQLCharacters:theInvoice.notes], (long)theInvoice.invoiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		if( theInvoice.type == iBizProjectEstimate ) {
			[self.delegate dbReturnedError:@"There was an internal problem attempting to update an estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
		} else {
			[self.delegate dbReturnedError:@"There was an internal problem attempting to update an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
		}
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		if( theInvoice.type == iBizProjectEstimate ) {
			[self.delegate dbReturnedError:@"There was an internal problem updating an estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
		} else {
			[self.delegate dbReturnedError:@"There was an internal problem updating an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertInvoiceProduct:(ProjectInvoiceItem*)theItem {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_project_invoice_product ( projectProductID, projectInvoiceID ) VALUES ( %ld, %ld );", (long)[(ProjectProduct*)theItem.item projectProductID], (long)theItem.invoiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a product to an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theItem.invoiceItemID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a product to an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertInvoiceService:(ProjectInvoiceItem*)theItem {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_project_invoice_service ( projectServiceID, projectInvoiceID ) VALUES ( %ld, %ld );", (long)[(ProjectService*)theItem.item projectServiceID], (long)theItem.invoiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a service to an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theItem.invoiceItemID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a service to an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateInvoiceTotal:(ProjectInvoice*)theInvoice {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_project_invoice SET totalForTable=%.2f WHERE projectInvoiceID=%ld;", [theInvoice.totalForTable doubleValue], (long)theInvoice.invoiceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		if( theInvoice.type == iBizProjectEstimate ) {
			[self.delegate dbReturnedError:@"There was an internal problem attempting to update an estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
		} else {
			[self.delegate dbReturnedError:@"There was an internal problem attempting to update an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
		}
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		if( theInvoice.type == iBizProjectEstimate ) {
			[self.delegate dbReturnedError:@"There was an internal problem updating an estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
		} else {
			[self.delegate dbReturnedError:@"There was an internal problem updating an invoice.\n\nPlease restart the app and report this message to our support if it reappears."];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateProjectTotal:(Project*)theProject {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_projects SET dateModified=%f, totalForTable=%.2f WHERE projectID=%ld;", [self getTimeIntervalForGMT:theProject.dateModified], [theProject.totalForTable doubleValue], (long)theProject.projectID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateProjectTotalForID:(NSInteger)projectID amountToAdd:(double)theAmount {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_projects SET dateModified=%f, totalForTable=totalForTable+%.2f WHERE projectID=%ld;", [self getTimeIntervalForGMT:[NSDate date]], theAmount, (long)projectID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateProjectTotalForID:(NSInteger)projectID amountToSubtract:(double)theAmount {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_projects SET dateModified=%f, totalForTable=totalForTable-%.2f WHERE projectID=%ld;", [self getTimeIntervalForGMT:[NSDate date]], theAmount, (long)projectID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) addTransactionID:(NSInteger)theTransaction toProjectID:(NSInteger)theProject {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_project_transaction ( transactionID, projectID ) VALUES ( %ld, %ld );", (long)theTransaction, (long)theProject];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction to a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction to a project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) removeTransactionID:(NSInteger)theTransaction fromProjectID:(NSInteger)theProject {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_project_transaction WHERE projectID=%ld AND transactionID=%ld;", (long)theProject, (long)theTransaction];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an invoice or estimate.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

#pragma mark -
#pragma mark Register
#pragma mark -
/*
 *
 */
- (void) deductAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_giftCertificate SET amountUsed=amountUsed+%.2f WHERE giftCertificateID=%ld;", [amount doubleValue], (long)theID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to deduct a gift certificate amount.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deducting a gift certificate amount.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) refundAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_giftCertificate SET amountUsed=amountUsed-%.2f WHERE giftCertificateID=%ld;", [amount doubleValue], (long)theID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to refund a gift certificate amount.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem refunding a gift certificate amount.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteGiftCertificateWithID:(NSInteger)theID {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_giftCertificate WHERE giftCertificateID=%ld;", (long)theID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteTransactionItem:(TransactionItem*)theItem {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_transactionItem WHERE transactionItemID=%ld;", (long)theItem.transactionItemID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete an item from this transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an item from this transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteTransactionPayment:(TransactionPayment*)thePayment {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_transactionPayment WHERE transactionPaymentID=%ld;", (long)thePayment.transactionPaymentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Should ONLY be used to delete transactions that are void!
 *	CHANGED: 1/28/10 -- Apparently, you can't do multiple commands... split them into 3 separate non-queries.
 */
- (void) deleteTransactionAndChildren:(Transaction*)theTransaction {
	/*
	 *	TRANSACTION
	 */
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_transaction WHERE transactionID=%ld;", (long)theTransaction.transactionID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a voided transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a voided transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
	
	/*
	 *	TRANSACTION ITEMS
	 */	
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_transactionItem WHERE transactionID=%ld;", (long)theTransaction.transactionID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a voided transaction item.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a voided transaction item.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	statement = nil;
	
	/*
	 *	TRANSACTION PAYMENTS
	 */
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_transactionPayment WHERE transactionID=%ld;", (long)theTransaction.transactionID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a voided transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a voided transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	/*
	 *	TRANSACTION CLOSEOUT RECORD
	 */
	sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_closeout_transaction WHERE transactionID=%ld;", (long)theTransaction.transactionID];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a voided transaction from a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a voided transaction from a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	MUST release when done!
 */
- (void) getArrayOfCloseoutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	// Changed to show amount paid instead of amount of prod/serv/cert
	if( start && end ) {
		//sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, SUM(totalForTable) FROM iBiz_closeout INNER JOIN iBiz_closeout_transaction ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID INNER JOIN iBiz_transaction ON iBiz_closeout_transaction.transactionID=iBiz_transaction.transactionID WHERE closeoutDate>=%f AND closeoutDate<=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [start timeIntervalSinceReferenceDate], [end timeIntervalSinceReferenceDate]];
		sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, TOTAL(t.totalForTable)+TOTAL(i.totalForTable) FROM iBiz_closeout LEFT OUTER JOIN iBiz_closeout_transaction USING(closeoutID) LEFT OUTER JOIN iBiz_transaction AS t USING(transactionID) LEFT OUTER JOIN iBiz_closeout_invoice ON iBiz_closeout.closeoutID=iBiz_closeout_invoice.closeoutID LEFT OUTER JOIN iBiz_project_invoice AS i ON iBiz_closeout_invoice.invoiceID=i.projectInvoiceID WHERE closeoutDate>=%f AND closeoutDate<=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
	} else if( start ) {
		//sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, SUM(totalForTable) FROM iBiz_closeout INNER JOIN iBiz_closeout_transaction ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID INNER JOIN iBiz_transaction ON iBiz_closeout_transaction.transactionID=iBiz_transaction.transactionID WHERE closeoutDate>=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [start timeIntervalSinceReferenceDate]];
		sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, TOTAL(t.totalForTable)+TOTAL(i.totalForTable) FROM iBiz_closeout LEFT OUTER JOIN iBiz_closeout_transaction USING(closeoutID) LEFT OUTER JOIN iBiz_transaction AS t USING(transactionID) LEFT OUTER JOIN iBiz_closeout_invoice ON iBiz_closeout.closeoutID=iBiz_closeout_invoice.closeoutID LEFT OUTER JOIN iBiz_project_invoice AS i ON iBiz_closeout_invoice.invoiceID=i.projectInvoiceID WHERE closeoutDate>=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [self getTimeIntervalForGMT:start]];
	} else if( end ) {
		//sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, SUM(totalForTable) FROM iBiz_closeout INNER JOIN iBiz_closeout_transaction ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID INNER JOIN iBiz_transaction ON iBiz_closeout_transaction.transactionID=iBiz_transaction.transactionID WHERE closeoutDate<=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [end timeIntervalSinceReferenceDate]];
		sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, TOTAL(t.totalForTable)+TOTAL(i.totalForTable) FROM iBiz_closeout LEFT OUTER JOIN iBiz_closeout_transaction USING(closeoutID) LEFT OUTER JOIN iBiz_transaction AS t USING(transactionID) LEFT OUTER JOIN iBiz_closeout_invoice ON iBiz_closeout.closeoutID=iBiz_closeout_invoice.closeoutID LEFT OUTER JOIN iBiz_project_invoice AS i ON iBiz_closeout_invoice.invoiceID=i.projectInvoiceID WHERE closeoutDate<=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [self getTimeIntervalForGMT:end]];
	} else {
		//sql = [[NSString alloc] initWithString:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, SUM(totalForTable) FROM iBiz_closeout INNER JOIN iBiz_closeout_transaction ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID INNER JOIN iBiz_transaction ON iBiz_closeout_transaction.transactionID=iBiz_transaction.transactionID GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;"];
		sql = [[NSString alloc] initWithString:@"SELECT iBiz_closeout.closeoutID, iBiz_closeout.closeoutDate, TOTAL(t.totalForTable)+TOTAL(i.totalForTable) FROM iBiz_closeout LEFT OUTER JOIN iBiz_closeout_transaction USING(closeoutID) LEFT OUTER JOIN iBiz_transaction AS t USING(transactionID) LEFT OUTER JOIN iBiz_closeout_invoice ON iBiz_closeout.closeoutID=iBiz_closeout_invoice.closeoutID LEFT OUTER JOIN iBiz_project_invoice AS i ON iBiz_closeout_invoice.invoiceID=i.projectInvoiceID GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Create a CloseOut object
			CloseOut *tmp = [[CloseOut alloc] init];
			tmp.closeoutID = sqlite3_column_int(statement, 0);
			// Date
			double date = sqlite3_column_double(statement, 1);
			if( date > 0 ) {
				tmp.date = [self getDateForTimeInterval:date];
			}
			// Monies
			NSNumber *total = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			tmp.totalOwed = total;
			[total release];
			// Save it
			[returnArray addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch closeouts.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:returnArray waitUntilDone:YES];
	[returnArray release];
}

/*
 *	MUST release when done!
 */
- (NSArray*) getGiftCertificates {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = @"SELECT giftCertificateID, purchaser, recipientFirst, recipientLast, purchaseDate, expiration, amountUsed, amountPurchased, message, notes FROM iBiz_giftCertificate;";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
			GiftCertificate *certificate = [[GiftCertificate alloc] init];
			
			// ID
			certificate.certificateID = sqlite3_column_int(statement, 0);
			// Purchaser
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 1)];
			certificate.purchaser = client;
			[client release];
			// Name
			NSString *fname = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( fname && ![fname isEqualToString:@"(null)"] ) {
				certificate.recipientFirst = fname;
			} else {
				certificate.recipientFirst = nil;
			}
			[fname release];
			NSString *lname = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( lname && ![lname isEqualToString:@"(null)"] ) {
				certificate.recipientLast = lname;
			} else {
				certificate.recipientLast = nil;
			}
			[lname release];
			// Purchase date
			double date = sqlite3_column_double(statement, 4);
			if( date > 0 ) {
				certificate.purchaseDate = [self getDateForTimeInterval:date];
			}
			// Expiration date
			double exp = sqlite3_column_double(statement, 5);
			if( exp > 0 ) {
				certificate.expiration = [self getDateForTimeInterval:exp];
			}
			// Amount Used
			NSNumber *used = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			certificate.amountUsed = used;
			[used release];
			// Amount Purchased
			NSNumber *purchased = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			certificate.amountPurchased = purchased;
			[purchased release];
			// Message
			NSString *msg = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
			if( msg && ![msg isEqualToString:@"(null)"] ) {
				certificate.message = msg;
			}
			[msg release];
			// Notes
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( notes && ![notes isEqualToString:@"(null)"] ) {
				certificate.notes = notes;
			}
			[notes release];
			
			// Done
			[returnArray addObject:certificate];
			[certificate release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch gift certificates.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *	MUST release when done!
 */
- (GiftCertificate*) getGiftCertificateWithID:(NSInteger)theID {
	GiftCertificate *returnCertificate = nil;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT giftCertificateID, purchaser, recipientFirst, recipientLast, purchaseDate, expiration, amountUsed, amountPurchased, message, notes FROM iBiz_giftCertificate WHERE giftCertificateID=%ld;", (long)theID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			
			GiftCertificate *certificate = [[GiftCertificate alloc] init];
			
			// ID
			certificate.certificateID = sqlite3_column_int(statement, 0);
			// Purchaser
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 1)];
			certificate.purchaser = client;
			[client release];
			// Name
			NSString *fname = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( fname && ![fname isEqualToString:@"(null)"] ) {
				certificate.recipientFirst = fname;
			} else {
				certificate.recipientFirst = nil;
			}
			[fname release];
			NSString *lname = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( lname && ![lname isEqualToString:@"(null)"] ) {
				certificate.recipientLast = lname;
			} else {
				certificate.recipientLast = nil;
			}
			[lname release];
			// Purchase date
			double date = sqlite3_column_double(statement, 4);
			if( date > 0 ) {
				certificate.purchaseDate = [self getDateForTimeInterval:date];
			}
			// Expiration date
			double exp = sqlite3_column_double(statement, 5);
			if( exp > 0 ) {
				certificate.expiration = [self getDateForTimeInterval:exp];
			}
			// Amount Used
			NSNumber *used = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			certificate.amountUsed = used;
			[used release];
			// Amount Purchased
			NSNumber *purchased = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			certificate.amountPurchased = purchased;
			[purchased release];
			// Message
			NSString *msg = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
			if( msg && ![msg isEqualToString:@"(null)"] ) {
				certificate.message = msg;
			}
			[msg release];
			// Notes
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( notes && ![notes isEqualToString:@"(null)"] ) {
				certificate.notes = notes;
			}
			[notes release];
			
			// Done
			returnCertificate = certificate;
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch gift certificates.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnCertificate;
}




/*
 *	THREADED
 *	Get the invoices that are in the CloseOut.
 *	No need to release? I don't think the other threaded methods need it either...
 */
- (void) getInvoiceIDsForCloseOut:(CloseOut*)theCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT invoiceID FROM iBiz_closeout_invoice WHERE closeoutID=%ld;", (long)theCloseOut.closeoutID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSNumber *inv = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
			// Done
			[array addObject:inv];
			[inv release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices for a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	UNTHREADED
 *	Get the invoices that are in the CloseOut.
 *	RELEASE when done!
 */
- (NSArray*) getInvoiceIDsUnthreadedForCloseOut:(CloseOut*)theCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT invoiceID FROM iBiz_closeout_invoice WHERE closeoutID=%ld;", (long)theCloseOut.closeoutID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSNumber *inv = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
			// Done
			[array addObject:inv];
			[inv release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices for a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return array;
}

/*
 *	MUST release when done!
 */
- (void) getInvoiceIDsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get values.
	NSString *sql = nil;
	if( start && end ) {
		// Between
		sql = [[NSString alloc] initWithFormat:@"SELECT invoiceID FROM iBiz_closeout_invoice INNER JOIN iBiz_closeout USING(closeoutID) WHERE closeoutDate>=%f AND closeoutDate<=%f;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
	} else if( start ) {
		// After
		sql = [[NSString alloc] initWithFormat:@"SELECT invoiceID FROM iBiz_closeout_invoice INNER JOIN iBiz_closeout USING(closeoutID) WHERE closeoutDate>=%f;", [self getTimeIntervalForGMT:start]];
	} else if( end ) {
		// Before
		sql = [[NSString alloc] initWithFormat:@"SELECT invoiceID FROM iBiz_closeout_invoice INNER JOIN iBiz_closeout USING(closeoutID) WHERE closeoutDate<=%f;", [self getTimeIntervalForGMT:end]];
	} else {
		// All
		sql = [[NSString alloc] initWithFormat:@"SELECT invoiceID FROM iBiz_closeout_invoice;"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSNumber *inv = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
			// Done
			[array addObject:inv];
			[inv release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices for closeouts.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	THREADED
 *	Get the invoices that aren't in a CloseOut.
 *	No need to release? I don't think the other threaded methods need it either...
 */
- (void) getInvoiceIDsForNextCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	//NSString *sql = [[NSString alloc] initWithString:@"SELECT projectInvoiceID FROM iBiz_project_invoice WHERE datePaid>0 AND projectInvoiceID NOT IN (SELECT invoiceID FROM iBiz_closeout_invoice);"];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT projectInvoiceID FROM iBiz_project_invoice WHERE type=%d AND datePaid>0 AND projectInvoiceID NOT IN (SELECT invoiceID FROM iBiz_closeout_invoice);", iBizProjectInvoice];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSNumber *inv = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
			// Done
			[array addObject:inv];
			[inv release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoices for the next closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];	
}







/*
 *	THREADED
 *	Get the invoice payments that are in the CloseOut.
 *	No need to release? I don't think the other threaded methods need it either...
 */
- (void) getInvoicePaymentsForCloseOut:(CloseOut*)theCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionPaymentID IN (SELECT paymentID FROM iBiz_closeout_payment WHERE closeoutID=%ld);", (long)theCloseOut.closeoutID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			TransactionPayment *payment = [[TransactionPayment alloc] init];
			// ID
			payment.transactionPaymentID = sqlite3_column_int(statement, 0);
			// Invoice ID
			payment.invoiceID = sqlite3_column_int(statement, 1);
			// Type
			payment.paymentType = sqlite3_column_int(statement, 2);
			// Amount 
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			payment.amount = amt;
			[amt release];
			// Extra Info.
			NSString *extra = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			if( extra && ![extra isEqualToString:@"(null)"] ) {
				payment.extraInfo = extra;
			} else {
				payment.extraInfo = nil;
			}
			[extra release];
			
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				payment.datePaid = [self getDateForTimeInterval:paid];
			}
			
			// Done
			[array addObject:payment];
			[payment release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoice payments for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	UNTHREADED
 *	Get the invoice payments that are in the CloseOut.
 *	RELEASE when done!
 */
- (NSArray*) getInvoicePaymentsUnthreadedForCloseOut:(CloseOut*)theCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionPaymentID IN (SELECT paymentID FROM iBiz_closeout_payment WHERE closeoutID=%ld);", (long)theCloseOut.closeoutID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			TransactionPayment *payment = [[TransactionPayment alloc] init];
			// ID
			payment.transactionPaymentID = sqlite3_column_int(statement, 0);
			// Invoice ID
			payment.invoiceID = sqlite3_column_int(statement, 1);
			// Type
			payment.paymentType = sqlite3_column_int(statement, 2);
			// Amount 
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			payment.amount = amt;
			[amt release];
			// Extra Info.
			NSString *extra = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			if( extra && ![extra isEqualToString:@"(null)"] ) {
				payment.extraInfo = extra;
			} else {
				payment.extraInfo = nil;
			}
			[extra release];
			
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				payment.datePaid = [self getDateForTimeInterval:paid];
			}
			
			// Done
			[array addObject:payment];
			[payment release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoice payments for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return array;
}

/*
 *	MUST release when done!
 */
- (void) getInvoicePaymentsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	if( start && end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionPaymentID IN (SELECT paymentID FROM iBiz_closeout_payment INNER JOIN iBiz_closeout USING(closeoutID) WHERE closeoutDate>=%f AND closeoutDate<=%f);", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
	} else if( start ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionPaymentID IN (SELECT paymentID FROM iBiz_closeout_payment INNER JOIN iBiz_closeout USING(closeoutID) WHERE closeoutDate>=%f);", [self getTimeIntervalForGMT:start]];
	} else if( end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionPaymentID IN (SELECT paymentID FROM iBiz_closeout_payment INNER JOIN iBiz_closeout USING(closeoutID) WHERE closeoutDate<=%f);", [self getTimeIntervalForGMT:end]];
	} else {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionPaymentID IN (SELECT paymentID FROM iBiz_closeout_payment);"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			TransactionPayment *payment = [[TransactionPayment alloc] init];
			// ID
			payment.transactionPaymentID = sqlite3_column_int(statement, 0);
			// Invoice ID
			payment.invoiceID = sqlite3_column_int(statement, 1);
			// Type
			payment.paymentType = sqlite3_column_int(statement, 2);
			// Amount 
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			payment.amount = amt;
			[amt release];
			// Extra Info.
			NSString *extra = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			if( extra && ![extra isEqualToString:@"(null)"] ) {
				payment.extraInfo = extra;
			} else {
				payment.extraInfo = nil;
			}
			[extra release];
			
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				payment.datePaid = [self getDateForTimeInterval:paid];
			}
			
			// Done
			[array addObject:payment];
			[payment release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoice payments for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	THREADED
 *	Get the invoice payments that aren't in a CloseOut.
 *	No need to release? I don't think the other threaded methods need it either...
 */
- (void) getInvoicePaymentsForNextCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithString:@"SELECT transactionPaymentID, invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionID = -1 AND invoiceID > -1 AND transactionPaymentID NOT IN (SELECT paymentID FROM iBiz_closeout_payment) ORDER BY datePaid DESC;"];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			TransactionPayment *payment = [[TransactionPayment alloc] init];
			// ID
			payment.transactionPaymentID = sqlite3_column_int(statement, 0);
			// Invoice ID
			payment.invoiceID = sqlite3_column_int(statement, 1);
			// Type
			payment.paymentType = sqlite3_column_int(statement, 2);
			// Amount 
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			payment.amount = amt;
			[amt release];
			// Extra Info.
			NSString *extra = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			if( extra && ![extra isEqualToString:@"(null)"] ) {
				payment.extraInfo = extra;
			} else {
				payment.extraInfo = nil;
			}
			[extra release];
			
			double paid = sqlite3_column_double(statement, 5);
			if( paid > 0 ) {
				payment.datePaid = [self getDateForTimeInterval:paid];
			}
			
			// Done
			[array addObject:payment];
			[payment release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch invoice payments for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];	
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end withStatus:(PSATransactionStatusType)status {
	NSMutableArray *dict = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	
	if( status == PSATransactionStatusAll ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE (dateClosed=0 AND dateVoided=0 AND dateOpened>=%1$f AND dateOpened<=%2$f) OR (dateVoided=0 AND dateClosed>=%1$f AND dateClosed<=%2$f) OR (dateVoided>=%1$f AND dateVoided<=%2$f) ORDER BY transactionID DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE (dateClosed=0 AND dateVoided=0 AND dateOpened>=%1$f) OR (dateVoided=0 AND dateClosed>=%1$f) OR (dateVoided>=%1$f) ORDER BY transactionID DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE (dateClosed=0 AND dateVoided=0 AND dateOpened<=%1$f) OR (dateVoided=0 AND dateClosed<=%1$f) OR (dateVoided<=%1$f) ORDER BY transactionID DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction ORDER BY transactionID DESC;"];
		}
	} else if( status == PSATransactionStatusOpen ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed=0 AND dateVoided=0 AND dateOpened>=%1$f AND dateOpened<=%2$f ORDER BY dateOpened DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed=0 AND dateVoided=0 AND dateOpened>=%1$f ORDER BY dateOpened DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed=0 AND dateVoided=0 AND dateOpened<=%1$f ORDER BY dateOpened DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed=0 AND dateVoided=0 ORDER BY dateOpened DESC;"];
		}
	} else if( status == PSATransactionStatusClosed ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided=0 AND dateClosed>=%1$f AND dateClosed<=%2$f ORDER BY dateClosed DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided=0 AND dateClosed>=%1$f ORDER BY dateClosed DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided=0 AND dateClosed<=%1$f ORDER BY dateClosed DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed>0 AND dateVoided=0 ORDER BY dateClosed DESC;"];
		}
	} else if( status == PSATransactionStatusVoid ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided>=%1$f AND dateVoided<=%2$f ORDER BY dateVoided DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided>=%1$f ORDER BY dateVoided DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided<=%1$f ORDER BY dateVoided DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided>0 ORDER BY dateVoided DESC;"];
		}
	}
	
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[dict addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:dict waitUntilDone:YES];
	[dict release];
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsForClient:(Client*)theClient {
	NSMutableArray *dict = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE clientID=%ld ORDER BY transactionID DESC;", (long)theClient.clientID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[dict addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:dict];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:dict waitUntilDone:YES];
	[dict release];
}

/*
 *	MUST RELEASE!
 */
- (NSMutableArray*) getTransactionsForProject:(Project*)theProject {
	NSMutableArray *dict = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_transaction.transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction INNER JOIN iBiz_project_transaction USING(transactionID) WHERE projectID=%ld ORDER BY iBiz_transaction.transactionID DESC;", (long)theProject.projectID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			tmp.client = theProject.client;
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[dict addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return dict;
}

/*
 *
 */
- (void) getTransactionProjectData:(Transaction*)theTransaction {
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_project_transaction.projectID, name FROM iBiz_project_transaction INNER JOIN iBiz_projects USING(projectID) WHERE iBiz_project_transaction.transactionID=%ld LIMIT 1;", (long)theTransaction.transactionID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			// LIMIT of 1
			theTransaction.projectID = sqlite3_column_int(statement, 0);
			NSString *name = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			if( !name || [name isEqualToString:@"(null)"] ) {
				[name release];
				name = nil;
			}
			theTransaction.projectName = name;
			[name release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transaction project data.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	MUST release when done!
 */
- (Transaction*) getTransactionForAppointment:(Appointment*)theAppointment {
	Transaction *tmp = nil;
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE appointmentID=%ld;", (long)theAppointment.appointmentID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a transaction for the appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return tmp;
}

/*
 *	MUST release when done!
 */
- (NSArray*) getTransactionItemsForTransaction:(Transaction*)theTransaction {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionItemID, itemID, itemTypeID, discountAmount, isPercentDiscount, productAdjustmentID, itemPrice, cost, setupFee, taxed FROM iBiz_transactionItem WHERE transactionID=%ld;", (long)theTransaction.transactionID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		[sql release];
		while (sqlite3_step(statement) == SQLITE_ROW) {
			TransactionItem *tmp = [[TransactionItem alloc] init];
			tmp.transactionItemID = sqlite3_column_int(statement, 0);
			
			tmp.itemType = sqlite3_column_int(statement, 2);
			if( tmp.itemType == PSATransactionItemGiftCertificate ) {
				// Get GiftCertificate object
				GiftCertificate *cert = [self getGiftCertificateWithID:sqlite3_column_int(statement, 1)];
				if( cert )	tmp.item = cert;
				[cert release];
			} else if( tmp.itemType == PSATransactionItemProduct ) {
				// Get Product Object
				Product *prod = [self getProductWithID:sqlite3_column_int(statement, 1)];
				if( prod )	tmp.item = prod;
				[prod release];
			} else if( tmp.itemType == PSATransactionItemService ) {
				// Get Service Object
				Service	*serv = [self getServiceWithID:sqlite3_column_int(statement, 1)];
				if( serv )	tmp.item = serv;
				[serv release];
			}
			
			NSNumber *discount = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.discountAmount = discount;
			[discount release];
			tmp.isPercentDiscount = sqlite3_column_int(statement, 4);
			
			ProductAdjustment *adj = [self getProductAdjustmentWithID:sqlite3_column_int(statement, 5)];
			tmp.productAdjustment = adj;
			[adj release];
			
			NSNumber *price = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 6)];
			tmp.itemPrice = price;
			[price release];
			
			NSNumber *cost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 7)];
			tmp.cost = cost;
			[cost release];
			
			NSNumber *setup = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 8)];
			tmp.setupFee = setup;
			[setup release];
			
			tmp.taxed = sqlite3_column_int(statement, 9);
			
			[returnArray addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transaction items.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnArray;
}

/*
 *	MUST release when done!
 */
- (NSMutableArray*) getTransactionPaymentsForInvoice:(ProjectInvoice*)theInvoice {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE invoiceID=%ld;", (long)theInvoice.invoiceID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {				
			TransactionPayment *payment = [[TransactionPayment alloc] init];
			// ID
			payment.transactionPaymentID = sqlite3_column_int(statement, 0);
			// Type
			payment.paymentType = sqlite3_column_int(statement, 1);
			// Amount 
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			payment.amount = amt;
			[amt release];
			// Extra Info.
			NSString *extra = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( extra && ![extra isEqualToString:@"(null)"] ) {
				payment.extraInfo = extra;
			} else {
				payment.extraInfo = nil;
			}
			[extra release];

			double paid = sqlite3_column_double(statement, 4);
			if( paid > 0 ) {
				payment.datePaid = [self getDateForTimeInterval:paid];
			}

			payment.invoiceID = theInvoice.invoiceID;
			
			// Done
			[returnArray addObject:payment];
			[payment release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch gift certificates.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return returnArray;
}

/*
 *	MUST release when done!
 */
- (NSArray*) getTransactionPaymentsForTransaction:(Transaction*)theTransaction {
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionPaymentID, transactionPaymentTypeID, amount, extraInfo, datePaid FROM iBiz_transactionPayment WHERE transactionID=%ld;", (long)theTransaction.transactionID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {				
			TransactionPayment *payment = [[TransactionPayment alloc] init];
			// ID
			payment.transactionPaymentID = sqlite3_column_int(statement, 0);
			// Type
			payment.paymentType = sqlite3_column_int(statement, 1);
			// Amount 
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			payment.amount = amt;
			[amt release];
			// Extra Info.
			NSString *extra = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( extra && ![extra isEqualToString:@"(null)"] ) {
				payment.extraInfo = extra;
			} else {
				payment.extraInfo = nil;
			}
			[extra release];

			double paid = sqlite3_column_double(statement, 4);
			if( paid > 0 ) {
				payment.datePaid = [self getDateForTimeInterval:paid];
			}
			
			// Done
			[returnArray addObject:payment];
			[payment release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch gift certificates.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return returnArray;
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsForCloseOut:(CloseOut*)theCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID IN (SELECT transactionID FROM iBiz_closeout_transaction WHERE closeoutID=%ld);", (long)theCloseOut.closeoutID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	MUST release when done!
 */
- (NSArray*) getTransactionsUnthreadedForCloseOut:(CloseOut*)theCloseOut {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID IN (SELECT transactionID FROM iBiz_closeout_transaction WHERE closeoutID=%ld);", (long)theCloseOut.closeoutID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return array;
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	if( start && end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID IN (SELECT transactionID FROM iBiz_closeout_transaction INNER JOIN iBiz_closeout ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID WHERE closeoutDate>=%f AND closeoutDate<=%f);", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
	} else if( start ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID IN (SELECT transactionID FROM iBiz_closeout_transaction INNER JOIN iBiz_closeout ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID WHERE closeoutDate>=%f);", [self getTimeIntervalForGMT:start]];
	} else if( end ) {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID IN (SELECT transactionID FROM iBiz_closeout_transaction INNER JOIN iBiz_closeout ON iBiz_closeout.closeoutID=iBiz_closeout_transaction.closeoutID WHERE closeoutDate<=%f);", [self getTimeIntervalForGMT:end]];
	} else {
		sql = [[NSString alloc] initWithFormat:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID IN (SELECT transactionID FROM iBiz_closeout_transaction);"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	MUST release when done!
 */
- (void) getTransactionsSinceLastCloseoutWithStatus:(PSATransactionStatusType)status {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	if( status == PSATransactionStatusAll ) {
		sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction) ORDER BY transactionID DESC;"];
	} else if( status == PSATransactionStatusOpen ) {
		sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed=0 AND dateVoided=0 AND transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction) ORDER BY dateOpened DESC;"];
	} else if( status == PSATransactionStatusClosed	) {
		sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed>0 AND dateVoided=0 AND transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction) ORDER BY dateClosed DESC;"];
	} else if( status == PSATransactionStatusVoid ) {
		sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided>0 AND transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction) ORDER BY dateVoided DESC;"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/////////
- (void) AutoInsertTransactionsSinceLastCloseout:(NSDate*)date {
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger closeID = [self getTodayCloseout:date];
    // Get all values.
    NSString *sql = nil;
    sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateClosed>0 AND dateVoided=0 AND transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction) ORDER BY dateClosed DESC;"];

    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Transaction *tmp = [[Transaction alloc] init];
            tmp.transactionID = sqlite3_column_int(statement, 0);
            
            [self insertCloseout:closeID Transaction:tmp];
            
            //[array addObject:tmp];
            [tmp release];
        }
    } else {
        [self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
    }
    [sql release];
    // "Finalize" the statement - releases the resources associated with the statement.
    sqlite3_finalize(statement);

    //[array release];
}

/*
 *	Returns an array of all voided transactions in the DB
 *	MUST release when done!
 */
- (NSArray*) getVoidedTransactions {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = [[NSString alloc] initWithString:@"SELECT transactionID, appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided FROM iBiz_transaction WHERE dateVoided>0;"];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Transaction *tmp = [[Transaction alloc] init];
			tmp.transactionID = sqlite3_column_int(statement, 0);
			tmp.appointmentID = sqlite3_column_int(statement, 1);
			Client *client = [self getClientWithID:sqlite3_column_int(statement, 2)];
			tmp.client = client;
			[client release];
			NSNumber *tax = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			tmp.taxAmount = tax;
			[tax release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			tmp.tip = tip;
			[tip release];
			NSNumber *totalForTable = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 5)];
			tmp.totalForTable = totalForTable;
			[totalForTable release];
			//
			double open = sqlite3_column_double(statement, 6);
			if( open > 0 ) {
				tmp.dateOpened = [self getDateForTimeInterval:open];
			}
			//
			double close = sqlite3_column_double(statement, 7);
			if( close > 0 ) {
				tmp.dateClosed = [self getDateForTimeInterval:close];
			}
			//
			double voided = sqlite3_column_double(statement, 8);
			if( voided > 0 ) {
				tmp.dateVoided = [self getDateForTimeInterval:voided];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch transactions for closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return array;
}

/*
 *	Returns the closeoutID on success
 */
- (NSInteger) insertDailyCloseout {
	NSInteger closeoutID = -1;	
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_closeout ( closeoutDate ) VALUES ( %f );", [self getTimeIntervalForGMT:[NSDate date]]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a daily closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	closeoutID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a daily closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return closeoutID;
}

//////
-(NSInteger) getTodayCloseout:(NSDate*)today{
    NSInteger closeoutID = -1;
    NSString *sql = nil;
    sql = [[NSString alloc] initWithFormat:@"SELECT iBiz_closeout.closeoutID FROM iBiz_closeout WHERE closeoutDate>=%f AND closeoutDate<=%f GROUP BY iBiz_closeout.closeoutID ORDER BY closeoutDate DESC;", [self getTimeIntervalForGMT:today]-(24*3600), [self getTimeIntervalForGMT:today]];
    
    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            closeoutID = sqlite3_column_int(statement, 0);
        }
    } else {
        [self.delegate dbReturnedError:@"There was an internal problem attempting to fetch closeoutID.\n\nPlease restart the app and report this message to our support if it reappears."];
    }
    [sql release];
    // "Finalize" the statement - releases the resources associated with the statement.
    sqlite3_finalize(statement);
    
    if (closeoutID<0) {
        closeoutID = [self insertDailyCloseout];
    }
    return closeoutID;
}

/*
 *	Inserts a transaction for a closeout
 */
- (void) insertCloseout:(NSInteger)closeoutID Transaction:(Transaction*)theTransaction {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_closeout_transaction ( closeoutID, transactionID ) VALUES ( %ld, %ld );", (long)closeoutID, (long)theTransaction.transactionID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction to a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction to a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Inserts an invoice payment for a closeout
 */
- (void) insertCloseout:(NSInteger)closeoutID InvoicePayment:(TransactionPayment*)thePayment {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_closeout_payment ( closeoutID, paymentID ) VALUES ( %ld, %ld );", (long)closeoutID, (long)thePayment.transactionPaymentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add an invoice payment to a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding an invoice payment to a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Inserts a paid invoice for a closeout
 */
- (void) insertCloseout:(NSInteger)closeoutID InvoiceID:(NSNumber*)theInvoiceID {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_closeout_invoice ( closeoutID, invoiceID ) VALUES ( %ld, %ld );", (long)closeoutID, (long)[theInvoiceID integerValue]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add an invoice to a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding an invoice to a closeout.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertGiftCertificate:(GiftCertificate*)theCert {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_giftCertificate ( purchaser, recipientFirst, recipientLast, purchaseDate, expiration, amountUsed, amountPurchased, message, notes ) VALUES ( %ld, '%@', '%@', %f, %f, 0.00, %.2f, '%@', '%@' );", (long)theCert.purchaser.clientID, [self escapeSQLCharacters:theCert.recipientFirst], [self escapeSQLCharacters:theCert.recipientLast], [self getTimeIntervalForGMT:theCert.purchaseDate], [self getTimeIntervalForGMT:theCert.expiration], [theCert.amountPurchased doubleValue], [self escapeSQLCharacters:theCert.message], [self escapeSQLCharacters:theCert.notes]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theCert.certificateID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) insertTransaction:(Transaction*)theTransaction {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_transaction ( appointmentID, clientID, taxPercent, tip, totalForTable, dateOpened, dateClosed, dateVoided, commissionPercent ) VALUES ( %ld, %ld, (SELECT salesTax FROM iBiz_company LIMIT 1), %.2f, %.2f, %f, %f, %f, (SELECT commissionRate FROM iBiz_company LIMIT 1) );", (long)theTransaction.appointmentID, (long)theTransaction.client.clientID, [theTransaction.tip doubleValue], [[theTransaction getTotal] doubleValue], [self getTimeIntervalForGMT:theTransaction.dateOpened], [self getTimeIntervalForGMT:theTransaction.dateClosed], [self getTimeIntervalForGMT:theTransaction.dateVoided] ];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theTransaction.transactionID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) insertTransactionItem:(TransactionItem*)theItem forTransactionID:(NSInteger)transactionID {
	NSInteger itemID = -1;
	if( theItem.itemType == PSATransactionItemProduct ) {
		itemID = ((Product*)theItem.item).productID;
	} else if( theItem.itemType == PSATransactionItemService ) {
		itemID = ((Service*)theItem.item).serviceID;
	} else if( theItem.itemType == PSATransactionItemGiftCertificate ) {
		itemID = ((GiftCertificate*)theItem.item).certificateID;
	}
	
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_transactionItem ( transactionID, itemID, itemTypeID, discountAmount, isPercentDiscount, productAdjustmentID, itemPrice, cost, setupFee, taxed ) VALUES ( %ld, %ld, %d, %.2f, %d, %ld, %.2f, %.2f, %.2f, %d );", (long)transactionID, (long)itemID, theItem.itemType, [theItem.discountAmount doubleValue], theItem.isPercentDiscount, (long)((theItem.productAdjustment) ? theItem.productAdjustment.productAdjustmentID : -1), [theItem.itemPrice doubleValue], [theItem.cost doubleValue], [theItem.setupFee doubleValue], theItem.taxed];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction item.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theItem.transactionItemID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction item.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertTransactionPayment:(TransactionPayment*)thePayment forInvoiceID:(NSInteger)invoiceID {	
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_transactionPayment ( invoiceID, transactionPaymentTypeID, amount, extraInfo, datePaid ) VALUES ( %ld, %d, %.2f, '%@', %f );", (long)invoiceID, thePayment.paymentType, [thePayment.amount doubleValue], [self escapeSQLCharacters:thePayment.extraInfo], [self getTimeIntervalForGMT:thePayment.datePaid]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	thePayment.transactionPaymentID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) insertTransactionPayment:(TransactionPayment*)thePayment forTransactionID:(NSInteger)transID {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_transactionPayment ( transactionID, transactionPaymentTypeID, amount, extraInfo, datePaid ) VALUES ( %ld, %d, %.2f, '%@', %f );", (long)transID, thePayment.paymentType, [thePayment.amount doubleValue], [self escapeSQLCharacters:thePayment.extraInfo], [self getTimeIntervalForGMT:thePayment.datePaid]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	thePayment.transactionPaymentID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a transaction payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	
 *	
 */
- (void) updateGiftCertificate:(GiftCertificate*)theCert {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_giftCertificate SET recipientFirst='%@', recipientLast='%@', expiration=%f, amountUsed=%.2f, amountPurchased=%.2f, message='%@', notes='%@' WHERE giftCertificateID=%ld;", [self escapeSQLCharacters:theCert.recipientFirst], [self escapeSQLCharacters:theCert.recipientLast], [self getTimeIntervalForGMT:theCert.expiration], [theCert.amountUsed doubleValue], [theCert.amountPurchased doubleValue], [self escapeSQLCharacters:theCert.message], [self escapeSQLCharacters:theCert.notes], (long)theCert.certificateID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) updateTransaction:(Transaction*)theTransaction {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_transaction SET appointmentID=%ld, clientID=%ld, taxPercent=(SELECT salesTax FROM iBiz_company LIMIT 1), tip=%.2f, totalForTable=%.2f, dateOpened=%f, dateClosed=%f, dateVoided=%f, commissionPercent=(SELECT commissionRate FROM iBiz_company LIMIT 1) WHERE transactionID=%ld;", (long)theTransaction.appointmentID, (long)theTransaction.client.clientID, [theTransaction.tip doubleValue], [[theTransaction getTotal] doubleValue], [self getTimeIntervalForGMT:theTransaction.dateOpened], [self getTimeIntervalForGMT:theTransaction.dateClosed], [self getTimeIntervalForGMT:theTransaction.dateVoided],  (long)theTransaction.transactionID ];	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a transaction.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	
 *	The itemID, itemTypeID, transactionItemID, and transactionID should never change...
 */
- (void) updateTransactionItem:(TransactionItem*)theItem {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_transactionItem SET discountAmount=%.2f, isPercentDiscount=%d, itemPrice=%.2f, cost=%.2f, setupFee=%.2f, taxed=%d WHERE transactionItemID=%ld;", [theItem.discountAmount doubleValue], theItem.isPercentDiscount, [theItem.itemPrice doubleValue], [theItem.cost doubleValue], [theItem.setupFee doubleValue], theItem.taxed, (long)theItem.transactionItemID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a transaction item.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a transaction item.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	
 *
 */
- (void) updateTransactionPayment:(TransactionPayment*)thePayment {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_transactionPayment SET transactionPaymentTypeID=%d, amount=%.2f, extraInfo='%@', datePaid=%f WHERE transactionPaymentID=%ld;", thePayment.paymentType, [thePayment.amount doubleValue], [self escapeSQLCharacters:thePayment.extraInfo], [self getTimeIntervalForGMT:thePayment.datePaid], (long)thePayment.transactionPaymentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Sets extraInfo to -2 for the given certificate ID
 *
 */
- (void) updateTransactionPaymentsRemovingCertificateID:(NSInteger)theID {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_transactionPayment SET extraInfo='-2' WHERE transactionPaymentTypeID=4 AND extraInfo='%ld' ;", (long)theID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a payment for a removed gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a payment for a removed gift certificate.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Updates the tip column only!
 */
- (void) updateTransactionTip:(Transaction*)theTransaction {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_transaction SET tip=%.2f WHERE transactionID=%ld;", [theTransaction.tip doubleValue], (long)theTransaction.transactionID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a transaction's tip.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a transaction's tip.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


/*
 *	Gets the credit card payment object for the given TransactionPayment
 *	Unthreaded
 */
- (void) getCreditCardPaymentForPayment:(TransactionPayment*)thePayment {
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE creditCardPaymentID=%@;", thePayment.extraInfo];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
			CreditCardPayment *tmp = [[CreditCardPayment alloc] init];
			CreditCardResponse *tmpResp = [[CreditCardResponse alloc] init];
			tmp.response = tmpResp;
			[tmpResp release];
			
			tmp.ccPaymentID = sqlite3_column_int(statement, 0);
			
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 1)];
			tmp.amount = amt;
			[amt release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			tmp.tip = tip;
			[tip release];
			
			NSString *ccNum = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			tmp.ccNumber = ccNum;
			[ccNum release];
			
			NSString *gtID = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			tmp.response.transID = gtID;
			[gtID release];
			
			double paid = sqlite3_column_double(statement, 5);
			double refunded = sqlite3_column_double(statement, 6);
			double voided = sqlite3_column_double(statement, 7);
			if( voided > 0 ) {
				tmp.date = [self getDateForTimeInterval:voided];
				tmp.milestoneStatus = CreditCardProcessingVoided;
				tmp.status = CreditCardProcessingVoided;
			} else if( refunded > 0 ) {
				tmp.date = [self getDateForTimeInterval:refunded];
				tmp.milestoneStatus = CreditCardProcessingRefunded;
				tmp.status = CreditCardProcessingRefunded;
			} else if( paid > 0 ) {
				tmp.date = [self getDateForTimeInterval:paid];
				tmp.milestoneStatus = CreditCardProcessingApproved;
				tmp.status = CreditCardProcessingApproved;
			} else {
				tmp.date = nil;
				tmp.milestoneStatus = CreditCardProcessingNotProcessed;
				tmp.status = CreditCardProcessingNotProcessed;
			}
			
			Client *cl = [self getClientWithID:sqlite3_column_int(statement, 8)];
			tmp.client = cl;
			[cl release];
			
			char *first = (char *)sqlite3_column_text(statement, 9);
			if( first != NULL ) {
				NSString *fName = [[NSString alloc] initWithUTF8String:first];
				tmp.nameFirst = ( !fName || [fName isEqualToString:@"(null)"] || [fName isEqualToString:@""] ) ? nil : fName;
				[fName release];
			}
			
			char *mid = (char *)sqlite3_column_text(statement, 10);
			if( mid != NULL ) {
				NSString *mName = [[NSString alloc] initWithUTF8String:mid];
				tmp.nameMiddle = ( !mName || [mName isEqualToString:@"(null)"] || [mName isEqualToString:@""] ) ? nil : mName;
				[mName release];
			}
			
			char *last = (char *)sqlite3_column_text(statement, 11);
			if( last != NULL ) {
				NSString *lName = [[NSString alloc] initWithUTF8String:last];
				tmp.nameLast = ( !lName || [lName isEqualToString:@"(null)"] || [lName isEqualToString:@""] ) ? nil : lName;
				[lName release];
			}
			
			char *pho = (char *)sqlite3_column_text(statement, 12);
			if( pho != NULL ) {
				NSString *phone = [[NSString alloc] initWithUTF8String:pho];
				tmp.clientPhone = ( !phone || [phone isEqualToString:@"(null)"] || [phone isEqualToString:@""] ) ? nil : phone;
				[phone release];
			}
			
			char *em = (char *)sqlite3_column_text(statement, 13);
			if( em != NULL ) {
				NSString *email = [[NSString alloc] initWithUTF8String:em];
				tmp.clientEmail = ( !email || [email isEqualToString:@"(null)"] || [email isEqualToString:@""] ) ? nil : email;
				[email release];
			}
			
			char *no = (char *)sqlite3_column_text(statement, 14);
			if( no != NULL ) {
				NSString *notes = [[NSString alloc] initWithUTF8String:no];
				tmp.notes = ( !notes || [notes isEqualToString:@"(null)"] || [notes isEqualToString:@""] ) ? nil : notes;
				[notes release];
			}
			
			char *au = (char *)sqlite3_column_text(statement, 15);
			if( au != NULL ) {
				NSString *auth = [[NSString alloc] initWithUTF8String:au];
				tmp.response.authCode = ( !auth || [auth isEqualToString:@"(null)"] || [auth isEqualToString:@""] ) ? nil : auth;
				[auth release];
			}
			
			char *th = (char *)sqlite3_column_text(statement, 16);
			if( th != NULL ) {
				NSString *tHash = [[NSString alloc] initWithUTF8String:th];
				tmp.response.transHash = ( !tHash || [tHash isEqualToString:@"(null)"] || [tHash isEqualToString:@""] ) ? nil : tHash;
				[tHash release];
			}
			
			char *st = (char *)sqlite3_column_text(statement, 17);
			if( st != NULL ) {
				NSString *st1 = [[NSString alloc] initWithUTF8String:st];
				tmp.addressStreet = ( !st1 || [st1 isEqualToString:@"(null)"] || [st1 isEqualToString:@""] ) ? nil : st1;
				[st1 release];
			}
			
			char *ci = (char *)sqlite3_column_text(statement, 18);
			if( ci != NULL ) {
				NSString *city = [[NSString alloc] initWithUTF8String:ci];
				tmp.addressCity = ( !city || [city isEqualToString:@"(null)"] || [city isEqualToString:@""] ) ? nil : city;
				[city release];
			}
			
			char *sta = (char *)sqlite3_column_text(statement, 19);
			if( sta != NULL ) {
				NSString *state = [[NSString alloc] initWithUTF8String:sta];
				tmp.addressState = ( !state || [state isEqualToString:@"(null)"] || [state isEqualToString:@""] ) ? nil : state;
				[state release];
			}
			
			char *zi = (char *)sqlite3_column_text(statement, 20);
			if( zi != NULL ) {
				NSString *zip = [[NSString alloc] initWithUTF8String:zi];
				tmp.addressZip = ( !zip || [zip isEqualToString:@"(null)"] || [zip isEqualToString:@""] ) ? nil : zip;
				[zip release];
			}
			
			thePayment.creditCardPayment = tmp;
			thePayment.ccHydrated = YES;
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a credit card payment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Gets the credit card payments within a date range.
 *	Threaded
 */
- (void) getCreditCardPaymentsWithStatus:(PSACreditCardPaymentStatusType)status fromDate:(NSDate*)start toDate:(NSDate*)end {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	
	if( status == PSACreditCardPaymentStatusAll ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE (dateRefunded=0 AND dateVoided=0 AND datePaid>=%1$f AND datePaid<=%2$f) OR (dateVoided=0 AND dateRefunded>=%1$f AND dateRefunded<=%2$f) OR (dateVoided>=%1$f AND dateVoided<=%2$f) ORDER BY creditCardPaymentID DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE (dateRefunded=0 AND dateVoided=0 AND datePaid>=%1$f) OR (dateVoided=0 AND dateRefunded>=%1$f) OR (dateVoided>=%1$f) ORDER BY creditCardPaymentID DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE (dateRefunded=0 AND dateVoided=0 AND datePaid<=%1$f) OR (dateVoided=0 AND dateRefunded<=%1$f) OR (dateVoided<=%1$f) ORDER BY creditCardPaymentID DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment ORDER BY creditCardPaymentID DESC;"];
		}
	} else if( status == PSACreditCardPaymentStatusApproved ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded=0 AND dateVoided=0 AND datePaid>=%1$f AND datePaid<=%2$f ORDER BY datePaid DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded=0 AND dateVoided=0 AND datePaid>=%1$f ORDER BY datePaid DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded=0 AND dateVoided=0 AND datePaid<=%1$f ORDER BY datePaid DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded=0 AND dateVoided=0 ORDER BY datePaid DESC;"];
		}
	} else if( status == PSACreditCardPaymentStatusRefunded ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded>=%1$f AND dateRefunded<=%2$f ORDER BY dateRefunded DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded>=%1$f ORDER BY dateRefunded DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded<=%1$f ORDER BY dateRefunded DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateRefunded>0 ORDER BY dateRefunded DESC;"];
		}
	} else if( status == PSACreditCardPaymentStatusVoided ) {
		if( start && end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateVoided>=%1$f AND dateVoided<=%2$f ORDER BY dateVoided DESC;", [self getTimeIntervalForGMT:start], [self getTimeIntervalForGMT:end]];
		} else if( start ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateVoided>=%1$f ORDER BY dateVoided DESC;", [self getTimeIntervalForGMT:start]];
		} else if( end ) {
			sql = [[NSString alloc] initWithFormat:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateVoided<=%1$f ORDER BY dateVoided DESC;", [self getTimeIntervalForGMT:end]];
		} else {
			sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE dateVoided>0 ORDER BY dateVoided DESC;"];
		}
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
			CreditCardPayment *tmp = [[CreditCardPayment alloc] init];
			CreditCardResponse *tmpResp = [[CreditCardResponse alloc] init];
			tmp.response = tmpResp;
			[tmpResp release];
			
			tmp.ccPaymentID = sqlite3_column_int(statement, 0);
			
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 1)];
			tmp.amount = amt;
			[amt release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			tmp.tip = tip;
			[tip release];
			
			NSString *ccNum = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			tmp.ccNumber = ccNum;
			[ccNum release];
			
			NSString *gtID = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			tmp.response.transID = gtID;
			[gtID release];
			
			double paid = sqlite3_column_double(statement, 5);
			double refunded = sqlite3_column_double(statement, 6);
			double voided = sqlite3_column_double(statement, 7);
			if( voided > 0 ) {
				tmp.date = [self getDateForTimeInterval:voided];
				tmp.milestoneStatus = CreditCardProcessingVoided;
				tmp.status = CreditCardProcessingVoided;
			} else if( refunded > 0 ) {
				tmp.date = [self getDateForTimeInterval:refunded];
				tmp.milestoneStatus = CreditCardProcessingRefunded;
				tmp.status = CreditCardProcessingRefunded;
			} else if( paid > 0 ) {
				tmp.date = [self getDateForTimeInterval:paid];
				tmp.milestoneStatus = CreditCardProcessingApproved;
				tmp.status = CreditCardProcessingApproved;
			} else {
				tmp.date = nil;
				tmp.milestoneStatus = CreditCardProcessingNotProcessed;
				tmp.status = CreditCardProcessingNotProcessed;
			}
			
			Client *cl = [self getClientWithID:sqlite3_column_int(statement, 8)];
			tmp.client = cl;
			[cl release];
			
			char *first = (char *)sqlite3_column_text(statement, 9);
			if( first != NULL ) {
				NSString *fName = [[NSString alloc] initWithUTF8String:first];
				tmp.nameFirst = ( !fName || [fName isEqualToString:@"(null)"] || [fName isEqualToString:@""] ) ? nil : fName;
				[fName release];
			}
			
			char *mid = (char *)sqlite3_column_text(statement, 10);
			if( mid != NULL ) {
				NSString *mName = [[NSString alloc] initWithUTF8String:mid];
				tmp.nameMiddle = ( !mName || [mName isEqualToString:@"(null)"] || [mName isEqualToString:@""] ) ? nil : mName;
				[mName release];
			}
			
			char *last = (char *)sqlite3_column_text(statement, 11);
			if( last != NULL ) {
				NSString *lName = [[NSString alloc] initWithUTF8String:last];
				tmp.nameLast = ( !lName || [lName isEqualToString:@"(null)"] || [lName isEqualToString:@""] ) ? nil : lName;
				[lName release];
			}
			
			char *pho = (char *)sqlite3_column_text(statement, 12);
			if( pho != NULL ) {
				NSString *phone = [[NSString alloc] initWithUTF8String:pho];
				tmp.clientPhone = ( !phone || [phone isEqualToString:@"(null)"] || [phone isEqualToString:@""] ) ? nil : phone;
				[phone release];
			}
			
			char *em = (char *)sqlite3_column_text(statement, 13);
			if( em != NULL ) {
				NSString *email = [[NSString alloc] initWithUTF8String:em];
				tmp.clientEmail = ( !email || [email isEqualToString:@"(null)"] || [email isEqualToString:@""] ) ? nil : email;
				[email release];
			}
			
			char *no = (char *)sqlite3_column_text(statement, 14);
			if( no != NULL ) {
				NSString *notes = [[NSString alloc] initWithUTF8String:no];
				tmp.notes = ( !notes || [notes isEqualToString:@"(null)"] || [notes isEqualToString:@""] ) ? nil : notes;
				[notes release];
			}
			
			char *au = (char *)sqlite3_column_text(statement, 15);
			if( au != NULL ) {
				NSString *auth = [[NSString alloc] initWithUTF8String:au];
				tmp.response.authCode = ( !auth || [auth isEqualToString:@"(null)"] || [auth isEqualToString:@""] ) ? nil : auth;
				[auth release];
			}
			
			char *th = (char *)sqlite3_column_text(statement, 16);
			if( th != NULL ) {
				NSString *tHash = [[NSString alloc] initWithUTF8String:th];
				tmp.response.transHash = ( !tHash || [tHash isEqualToString:@"(null)"] || [tHash isEqualToString:@""] ) ? nil : tHash;
				[tHash release];
			}
			
			char *st = (char *)sqlite3_column_text(statement, 17);
			if( st != NULL ) {
				NSString *st1 = [[NSString alloc] initWithUTF8String:st];
				tmp.addressStreet = ( !st1 || [st1 isEqualToString:@"(null)"] || [st1 isEqualToString:@""] ) ? nil : st1;
				[st1 release];
			}
			
			char *ci = (char *)sqlite3_column_text(statement, 18);
			if( ci != NULL ) {
				NSString *city = [[NSString alloc] initWithUTF8String:ci];
				tmp.addressCity = ( !city || [city isEqualToString:@"(null)"] || [city isEqualToString:@""] ) ? nil : city;
				[city release];
			}
			
			char *sta = (char *)sqlite3_column_text(statement, 19);
			if( sta != NULL ) {
				NSString *state = [[NSString alloc] initWithUTF8String:sta];
				tmp.addressState = ( !state || [state isEqualToString:@"(null)"] || [state isEqualToString:@""] ) ? nil : state;
				[state release];
			}
			
			char *zi = (char *)sqlite3_column_text(statement, 20);
			if( zi != NULL ) {
				NSString *zip = [[NSString alloc] initWithUTF8String:zi];
				tmp.addressZip = ( !zip || [zip isEqualToString:@"(null)"] || [zip isEqualToString:@""] ) ? nil : zip;
				[zip release];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch credit card payments.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	Gets the credit card payments that have not appeared in a daily closeout.
 *	Threaded
 */
- (void) getCreditCardPaymentsUnclosedWithStatus:(PSACreditCardPaymentStatusType)status {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	// Get all values.
	NSString *sql = nil;
	
	if( status == PSACreditCardPaymentStatusAll ) {
		sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE "
			   // Not in a closeout
			   @"(creditCardPaymentID IN (SELECT extraInfo FROM iBiz_transactionPayment WHERE transactionPaymentTypeID=5 AND (transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction)) AND transactionPaymentID NOT IN (SELECT paymentID FROM iBiz_closeout_payment)) ) "
			   @"OR "
			   // Recent activity (otherwise the void/refunds stick around because they're removed from closeouts)
			   @"(datePaid>(SELECT closeoutDate FROM iBiz_closeout ORDER BY closeoutDate DESC LIMIT 1) OR dateRefunded>(SELECT closeoutDate FROM iBiz_closeout ORDER BY closeoutDate DESC LIMIT 1) OR dateVoided>(SELECT closeoutDate FROM iBiz_closeout ORDER BY closeoutDate DESC LIMIT 1) ) "
			   @"ORDER BY datePaid DESC;"];
	} else if( status == PSACreditCardPaymentStatusApproved ) {
		sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE "
			   // Not in a closeout
			   @"(creditCardPaymentID IN (SELECT extraInfo FROM iBiz_transactionPayment WHERE transactionPaymentTypeID=5 AND (transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction)) AND transactionPaymentID NOT IN (SELECT paymentID FROM iBiz_closeout_payment)) ) "
			   @"OR "
			   @"datePaid>(SELECT closeoutDate FROM iBiz_closeout ORDER BY closeoutDate DESC LIMIT 1) "
			   @"AND dateVoided=0 AND dateRefunded=0 "
			   @"ORDER BY datePaid DESC;"];
	} else if( status == PSACreditCardPaymentStatusRefunded ) {
		sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE "
			   // Not in a closeout
			   @"(creditCardPaymentID IN (SELECT extraInfo FROM iBiz_transactionPayment WHERE transactionPaymentTypeID=5 AND (transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction)) AND transactionPaymentID NOT IN (SELECT paymentID FROM iBiz_closeout_payment)) ) "
			   @"OR "
			   @"dateRefunded>(SELECT closeoutDate FROM iBiz_closeout ORDER BY closeoutDate DESC LIMIT 1) "
			   @"AND dateVoided=0 "
			   @"ORDER BY dateRefunded DESC;"];
	} else if( status == PSACreditCardPaymentStatusVoided ) {
		sql = [[NSString alloc] initWithString:@"SELECT creditCardPaymentID, amount, tip, ccNumber, gatewayTransID, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, phone, email, notes, authCode, transHash, addressStreet, addressCity, addressState, addressZip FROM iBiz_creditCardPayment WHERE "
			   // Not in a closeout
			   @"(creditCardPaymentID IN (SELECT extraInfo FROM iBiz_transactionPayment WHERE transactionPaymentTypeID=5 AND (transactionID NOT IN (SELECT transactionID FROM iBiz_closeout_transaction)) AND transactionPaymentID NOT IN (SELECT paymentID FROM iBiz_closeout_payment)) ) "
			   @"OR "
			   @"dateVoided>(SELECT closeoutDate FROM iBiz_closeout ORDER BY closeoutDate DESC LIMIT 1) "
			   @"AND dateRefunded=0 "
			   @"ORDER BY dateVoided DESC;"];
	}
	
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
			CreditCardPayment *tmp = [[CreditCardPayment alloc] init];
			CreditCardResponse *tmpResp = [[CreditCardResponse alloc] init];
			tmp.response = tmpResp;
			[tmpResp release];
			
			tmp.ccPaymentID = sqlite3_column_int(statement, 0);
			
			NSNumber *amt = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 1)];
			tmp.amount = amt;
			[amt release];
			NSNumber *tip = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 2)];
			tmp.tip = tip;
			[tip release];
			
			NSString *ccNum = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			tmp.ccNumber = ccNum;
			[ccNum release];
			
			NSString *gtID = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			tmp.response.transID = gtID;
			[gtID release];
			
			double paid = sqlite3_column_double(statement, 5);
			double refunded = sqlite3_column_double(statement, 6);
			double voided = sqlite3_column_double(statement, 7);
			if( voided > 0 ) {
				tmp.date = [self getDateForTimeInterval:voided];
				tmp.milestoneStatus = CreditCardProcessingVoided;
				tmp.status = CreditCardProcessingVoided;
			} else if( refunded > 0 ) {
				tmp.date = [self getDateForTimeInterval:refunded];
				tmp.milestoneStatus = CreditCardProcessingRefunded;
				tmp.status = CreditCardProcessingRefunded;
			} else if( paid > 0 ) {
				tmp.date = [self getDateForTimeInterval:paid];
				tmp.milestoneStatus = CreditCardProcessingApproved;
				tmp.status = CreditCardProcessingApproved;
			} else {
				tmp.date = nil;
				tmp.milestoneStatus = CreditCardProcessingNotProcessed;
				tmp.status = CreditCardProcessingNotProcessed;
			}
			
			Client *cl = [self getClientWithID:sqlite3_column_int(statement, 8)];
			tmp.client = cl;
			[cl release];
			
			char *first = (char *)sqlite3_column_text(statement, 9);
			if( first != NULL ) {
				NSString *fName = [[NSString alloc] initWithUTF8String:first];
				tmp.nameFirst = ( !fName || [fName isEqualToString:@"(null)"] || [fName isEqualToString:@""] ) ? nil : fName;
				[fName release];
			}
			
			char *mid = (char *)sqlite3_column_text(statement, 10);
			if( mid != NULL ) {
				NSString *mName = [[NSString alloc] initWithUTF8String:mid];
				tmp.nameMiddle = ( !mName || [mName isEqualToString:@"(null)"] || [mName isEqualToString:@""] ) ? nil : mName;
				[mName release];
			}
			
			char *last = (char *)sqlite3_column_text(statement, 11);
			if( last != NULL ) {
				NSString *lName = [[NSString alloc] initWithUTF8String:last];
				tmp.nameLast = ( !lName || [lName isEqualToString:@"(null)"] || [lName isEqualToString:@""] ) ? nil : lName;
				[lName release];
			}
			
			char *pho = (char *)sqlite3_column_text(statement, 12);
			if( pho != NULL ) {
				NSString *phone = [[NSString alloc] initWithUTF8String:pho];
				tmp.clientPhone = ( !phone || [phone isEqualToString:@"(null)"] || [phone isEqualToString:@""] ) ? nil : phone;
				[phone release];
			}
			
			char *em = (char *)sqlite3_column_text(statement, 13);
			if( em != NULL ) {
				NSString *email = [[NSString alloc] initWithUTF8String:em];
				tmp.clientEmail = ( !email || [email isEqualToString:@"(null)"] || [email isEqualToString:@""] ) ? nil : email;
				[email release];
			}
			
			char *no = (char *)sqlite3_column_text(statement, 14);
			if( no != NULL ) {
				NSString *notes = [[NSString alloc] initWithUTF8String:no];
				tmp.notes = ( !notes || [notes isEqualToString:@"(null)"] || [notes isEqualToString:@""] ) ? nil : notes;
				[notes release];
			}
			
			char *au = (char *)sqlite3_column_text(statement, 15);
			if( au != NULL ) {
				NSString *auth = [[NSString alloc] initWithUTF8String:au];
				tmp.response.authCode = ( !auth || [auth isEqualToString:@"(null)"] || [auth isEqualToString:@""] ) ? nil : auth;
				[auth release];
			}
			
			char *th = (char *)sqlite3_column_text(statement, 16);
			if( th != NULL ) {
				NSString *tHash = [[NSString alloc] initWithUTF8String:th];
				tmp.response.transHash = ( !tHash || [tHash isEqualToString:@"(null)"] || [tHash isEqualToString:@""] ) ? nil : tHash;
				[tHash release];
			}
			
			char *st = (char *)sqlite3_column_text(statement, 17);
			if( st != NULL ) {
				NSString *st1 = [[NSString alloc] initWithUTF8String:st];
				tmp.addressStreet = ( !st1 || [st1 isEqualToString:@"(null)"] || [st1 isEqualToString:@""] ) ? nil : st1;
				[st1 release];
			}
			
			char *ci = (char *)sqlite3_column_text(statement, 18);
			if( ci != NULL ) {
				NSString *city = [[NSString alloc] initWithUTF8String:ci];
				tmp.addressCity = ( !city || [city isEqualToString:@"(null)"] || [city isEqualToString:@""] ) ? nil : city;
				[city release];
			}
			
			char *sta = (char *)sqlite3_column_text(statement, 19);
			if( sta != NULL ) {
				NSString *state = [[NSString alloc] initWithUTF8String:sta];
				tmp.addressState = ( !state || [state isEqualToString:@"(null)"] || [state isEqualToString:@""] ) ? nil : state;
				[state release];
			}
			
			char *zi = (char *)sqlite3_column_text(statement, 20);
			if( zi != NULL ) {
				NSString *zip = [[NSString alloc] initWithUTF8String:zi];
				tmp.addressZip = ( !zip || [zip isEqualToString:@"(null)"] || [zip isEqualToString:@""] ) ? nil : zip;
				[zip release];
			}
			
			[array addObject:tmp];
			[tmp release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch credit card payments.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	//[self.delegate dbReturnedArray:array];
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:array waitUntilDone:YES];
	[array release];
}

/*
 *	Inserted only when approved, so the amount, tip, and datePaid probably aren't updated ever
 */
- (void) insertCreditCardPayment:(CreditCardPayment*)thePayment {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_creditCardPayment ( amount, tip, ccNumber, authCode, gatewayTransID, transHash, datePaid, dateRefunded, dateVoided, clientID, firstName, middleName, lastName, email, phone, notes, addressStreet, addressCity, addressState, addressZip ) VALUES ( %.2f, %.2f, '%@', '%@', '%@', '%@', %f, %f, %f, %ld, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@' );", [thePayment.amount doubleValue], [thePayment.tip doubleValue], [self escapeSQLCharacters:thePayment.ccNumber], [self escapeSQLCharacters:thePayment.response.authCode], [self escapeSQLCharacters:thePayment.response.transID], [self escapeSQLCharacters:thePayment.response.transHash], [thePayment.date timeIntervalSinceReferenceDate], 0.0, 0.0, (long)thePayment.client.clientID, [self escapeSQLCharacters:thePayment.nameFirst], [self escapeSQLCharacters:thePayment.nameMiddle], [self escapeSQLCharacters:thePayment.nameLast], [self escapeSQLCharacters:thePayment.clientEmail], [self escapeSQLCharacters:thePayment.clientPhone], [self escapeSQLCharacters:thePayment.notes], [self escapeSQLCharacters:thePayment.addressStreet], [self escapeSQLCharacters:thePayment.addressCity], [self escapeSQLCharacters:thePayment.addressState], [self escapeSQLCharacters:thePayment.addressZip]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a credit card payment to our database.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	thePayment.ccPaymentID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a credit card payment to our database.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Amount, tip, datePaid are probably only set when inserted...
 */
- (void) updateCreditCardPayment:(CreditCardPayment*)thePayment {
	// if status == refunded, update refunded date to thePayment.date
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_creditCardPayment SET authCode='%@', transHash='%@', dateRefunded=%f, dateVoided=%f, notes='%@' WHERE creditCardPaymentID=%ld;", [self escapeSQLCharacters:thePayment.response.authCode], [self escapeSQLCharacters:thePayment.response.transHash], (thePayment.status==CreditCardProcessingRefunded) ? [thePayment.date timeIntervalSinceReferenceDate] : 0.0, (thePayment.status==CreditCardProcessingVoided) ? [thePayment.date timeIntervalSinceReferenceDate] : 0.0, [self escapeSQLCharacters:thePayment.notes], (long)thePayment.ccPaymentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a credit card payment in our database.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a credit card payment in our database.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Schedule
#pragma mark -
/*
 *
 */
- (void) deleteAppointment:(Appointment*)theAppointment deleteStanding:(BOOL)standing {
	NSString *sql = nil;
	if( standing ) {
		sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_appointments WHERE standingAppointmentID=%ld AND startDateTime>=%f;", (long)theAppointment.standingAppointmentID, [self getTimeIntervalForGMT:theAppointment.dateTime]];
	} else {
		sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_appointments WHERE appointmentID=%ld;", (long)theAppointment.appointmentID];
	}
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete an appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Deletes standing appointments that aren't referenced by any appointment
 */
- (void) deleteOrphanedStandingAppointments {
	NSString *sql = [[NSString alloc] initWithString:@"DELETE FROM iBiz_standingAppointment WHERE standingAppointmentID NOT IN (SELECT standingAppointmentID FROM iBiz_appointments);"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete orphaned standing appointments.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting an orphaned standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) deleteStandingAppointment:(Appointment*)theAppointment {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_standingAppointment WHERE standingAppointmentID=%ld;", (long)theAppointment.standingAppointmentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	getAppointmentsForClient
 *	Returns an array of appointments for the given client
 *	Must release when done! -- or has this changed?
 */
- (void) getAppointmentsForClient:(Client*)theClient {
	NSMutableArray *appts = [[NSMutableArray alloc] init];
	// Get all values inbetween the start and end intervals
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT appointmentID, startDateTime, clientID, type, typeID, notes, duration, iBiz_appointments.standingAppointmentID, repeatType, repeatCustom, repeatUntil FROM iBiz_appointments LEFT OUTER JOIN iBiz_standingAppointment USING (standingAppointmentID) WHERE clientID=%ld OR typeID IN (SELECT projectID FROM iBiz_projects WHERE clientID=%ld) ORDER BY startDateTime;", (long)theClient.clientID, (long)theClient.clientID];
	sqlite3_stmt *statement;
	//         
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Get the values
			Appointment *thisAppt = [[Appointment alloc] init];
			thisAppt.appointmentID = sqlite3_column_int( statement, 0 );
			thisAppt.dateTime = [self getDateForTimeInterval:sqlite3_column_double( statement, 1 )];
			// Client
			thisAppt.client = theClient;
			
			// Type
			thisAppt.type = sqlite3_column_int( statement, 3 );
			if( thisAppt.type == iBizAppointmentTypeSingleService ) {
				// Service
				Service *theService = [self getServiceWithID:sqlite3_column_int( statement, 4 )];
				thisAppt.object = theService;
				[theService release];
			} else if( thisAppt.type == iBizAppointmentTypeProject ) {
				// Service
				Project *theProject = [self getProjectWithID:sqlite3_column_int( statement, 4 )];
				thisAppt.object = theProject;
				[theProject release];
				thisAppt.client = nil;
			}
			
			// Rest
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( notes && ![notes isEqualToString:@"(null)"] ) {
				// .notes will be nil unless it is not (null)
				thisAppt.notes = notes;
			}
			[notes release];

			thisAppt.duration = sqlite3_column_int( statement, 6 );
			// Standing Appointment Info
			thisAppt.standingAppointmentID = sqlite3_column_int( statement, 7 );
			if( thisAppt.standingAppointmentID > -1 ) {
				thisAppt.standingRepeat = sqlite3_column_int( statement, 8 );
				NSString *custom = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
				if( custom && ![custom isEqualToString:@"(null)"] ) {
					// .notes will be nil unless it is not (null)
					thisAppt.standingRepeatCustom = custom;
				}
				[custom release];
				thisAppt.standingRepeatUntilDate = [self getDateForTimeInterval:sqlite3_column_double( statement, 10 )];
			}
			
			//DebugLog( @"Found Appointment %d %@ %@ %@", thisAppt.appointmentID, [thisAppt.client getFirstName], [thisAppt.client getLastName], thisAppt.service.serviceName );
			
			// Add it for return
			[appts addObject:thisAppt];
			[thisAppt release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch appointments.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:appts waitUntilDone:YES];
	[appts release];
}

/*
 *	getAppointmentsForProject
 *	Returns an array of appointments for the given Project
 *	Must release when done!
 */
- (NSMutableArray*) getAppointmentsForProject:(Project*)theProject {
	NSMutableArray *appts = [[NSMutableArray alloc] init];
	// Get all values inbetween the start and end intervals
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT appointmentID, startDateTime, clientID, type, typeID, notes, duration, iBiz_appointments.standingAppointmentID, repeatType, repeatCustom, repeatUntil FROM iBiz_appointments LEFT OUTER JOIN iBiz_standingAppointment USING (standingAppointmentID) WHERE type=%d AND typeID=%ld ORDER BY startDateTime;", iBizAppointmentTypeProject, (long)theProject.projectID];
	sqlite3_stmt *statement;
	//         
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Get the values
			Appointment *thisAppt = [[Appointment alloc] init];
			thisAppt.appointmentID = sqlite3_column_int( statement, 0 );
			thisAppt.dateTime = [self getDateForTimeInterval:sqlite3_column_double( statement, 1 )];
			// Client will be taken from the Project
			thisAppt.client = nil;
			thisAppt.type = iBizAppointmentTypeProject;
			thisAppt.object = theProject;
			
			// Rest
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( notes && ![notes isEqualToString:@"(null)"] ) {
				// .notes will be nil unless it is not (null)
				thisAppt.notes = notes;
			}
			[notes release];
			
			thisAppt.duration = sqlite3_column_int( statement, 6 );
			// Standing Appointment Info
			thisAppt.standingAppointmentID = sqlite3_column_int( statement, 7 );
			if( thisAppt.standingAppointmentID > -1 ) {
				thisAppt.standingRepeat = sqlite3_column_int( statement, 8 );
				NSString *custom = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
				if( custom && ![custom isEqualToString:@"(null)"] ) {
					// .notes will be nil unless it is not (null)
					thisAppt.standingRepeatCustom = custom;
				}
				[custom release];
				thisAppt.standingRepeatUntilDate = [self getDateForTimeInterval:sqlite3_column_double( statement, 10 )];
			}
			
			//DebugLog( @"Found Appointment %d %@ %@ %@", thisAppt.appointmentID, [thisAppt.client getFirstName], [thisAppt.client getLastName], thisAppt.service.serviceName );
			
			// Add it for return
			[appts addObject:thisAppt];
			[thisAppt release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch appointments for this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return appts;
}

- (void) getAppointmentsThreadedForProject:(Project*)theProject {
	NSMutableArray *appts = [[NSMutableArray alloc] init];
	// Get all values inbetween the start and end intervals
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT appointmentID, startDateTime, clientID, type, typeID, notes, duration, iBiz_appointments.standingAppointmentID, repeatType, repeatCustom, repeatUntil FROM iBiz_appointments LEFT OUTER JOIN iBiz_standingAppointment USING (standingAppointmentID) WHERE type=%d AND typeID=%ld ORDER BY startDateTime;", iBizAppointmentTypeProject, (long)theProject.projectID];
	sqlite3_stmt *statement;
	//         
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Get the values
			Appointment *thisAppt = [[Appointment alloc] init];
			thisAppt.appointmentID = sqlite3_column_int( statement, 0 );
			thisAppt.dateTime = [self getDateForTimeInterval:sqlite3_column_double( statement, 1 )];
			// Client will be taken from the Project
			thisAppt.client = nil;
			
			// Type
			thisAppt.type = iBizAppointmentTypeProject;
			thisAppt.object = theProject;
			
			// Rest
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( notes && ![notes isEqualToString:@"(null)"] ) {
				// .notes will be nil unless it is not (null)
				thisAppt.notes = notes;
			}
			[notes release];
			
			thisAppt.duration = sqlite3_column_int( statement, 6 );
			// Standing Appointment Info
			thisAppt.standingAppointmentID = sqlite3_column_int( statement, 7 );
			if( thisAppt.standingAppointmentID > -1 ) {
				thisAppt.standingRepeat = sqlite3_column_int( statement, 8 );
				NSString *custom = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
				if( custom && ![custom isEqualToString:@"(null)"] ) {
					// .notes will be nil unless it is not (null)
					thisAppt.standingRepeatCustom = custom;
				}
				[custom release];
				thisAppt.standingRepeatUntilDate = [self getDateForTimeInterval:sqlite3_column_double( statement, 10 )];
			}
			
			//DebugLog( @"Found Appointment %d %@ %@ %@", thisAppt.appointmentID, [thisAppt.client getFirstName], [thisAppt.client getLastName], thisAppt.service.serviceName );
			
			// Add it for return
			[appts addObject:thisAppt];
			[thisAppt release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch appointments for this project.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:appts waitUntilDone:YES];
	[appts release];
}

/*
 *	Returns an array of appointments for the given day
 *	Must release when done!
 */
- (void) getAppointmentsFrom:(NSDate*)startDate to:(NSDate*)endDate {
	NSMutableArray *appts = [[NSMutableArray alloc] init];
	// Get all values inbetween the start and end intervals
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT appointmentID, startDateTime, clientID, type, typeID, notes, duration, iBiz_appointments.standingAppointmentID, repeatType, repeatCustom, repeatUntil FROM iBiz_appointments LEFT OUTER JOIN iBiz_standingAppointment USING (standingAppointmentID) WHERE startDateTime >= %f AND startDateTime <= %f ORDER BY startDateTime;", [self getTimeIntervalForGMT:startDate], [self getTimeIntervalForGMT:endDate]];
	sqlite3_stmt *statement;
	//         
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Get the values
			Appointment *thisAppt = [[Appointment alloc] init];
			thisAppt.appointmentID = sqlite3_column_int( statement, 0 );
			thisAppt.dateTime = [self getDateForTimeInterval:sqlite3_column_double( statement, 1 )];
			// Client
			NSInteger clientID = sqlite3_column_int( statement, 2 );
			if( clientID > -1 ) {
				Client *theClient = [self getClientWithID:clientID];
				thisAppt.client = theClient;
				[theClient release];
			}
			
			// Type
			thisAppt.type = sqlite3_column_int( statement, 3 );
			if( thisAppt.type == iBizAppointmentTypeSingleService ) {
				// Service
				Service *theService = [self getServiceWithID:sqlite3_column_int( statement, 4 )];
				thisAppt.object = theService;
				[theService release];
			} else if( thisAppt.type == iBizAppointmentTypeProject ) {
				// Project
				Project *theProject = [self getProjectWithID:sqlite3_column_int( statement, 4 )];
				thisAppt.object = theProject;
				[theProject release];
				thisAppt.client = theProject.client;
			}
			
			// Rest
			NSString *notes = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( notes && ![notes isEqualToString:@"(null)"] ) {
				// .notes will be nil unless it is not (null)
				thisAppt.notes = notes;
			}
			[notes release];

			thisAppt.duration = sqlite3_column_int( statement, 6 );
			// Standing Appointment Info
			thisAppt.standingAppointmentID = sqlite3_column_int( statement, 7 );
			if( thisAppt.standingAppointmentID > -1 ) {
				thisAppt.standingRepeat = sqlite3_column_int( statement, 8 );
				NSString *custom = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text( statement, 9 )];
				if( custom && ![custom isEqualToString:@"(null)"] ) {
					// will be nil unless it is not (null)
					thisAppt.standingRepeatCustom = custom;
				}
				[custom release];
				thisAppt.standingRepeatUntilDate = [self getDateForTimeInterval:sqlite3_column_double( statement, 10 )];
			}

			//DebugLog( @"Found Appointment %d %@ %@ %@", thisAppt.appointmentID, [thisAppt.client getFirstName], [thisAppt.client getLastName], thisAppt.service.serviceName );
			
			// Add it for return
			[appts addObject:thisAppt];
			[thisAppt release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch appointments.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedArray:) withObject:appts waitUntilDone:YES];
	[appts release];
}

/*
 *	isFree:
 *	Returns TRUE if this appointment does not conflict with any scheduled ones.
 */
- (BOOL) isFree:(Appointment*)theAppt {
	//
	BOOL returnValue = YES;
	// Double data types
	NSTimeInterval startOfStartBlock = [self getTimeIntervalForGMT:theAppt.dateTime];
	NSTimeInterval endOfStartBlock = startOfStartBlock + theAppt.duration;
	// Add 1 to start and end blocks to not include the exact time (an appointment could be ending on that exact time)
	NSString *sql = nil;

	// Only have a single block to check
	sql = [[NSString alloc] initWithFormat:@"SELECT appointmentID FROM iBiz_appointments WHERE appointmentID != %ld AND ( "
												// Check our starting block against other starting blocks 
												@"( (%f BETWEEN startDateTime AND startDateTime+duration)"
													@" OR " 
												@"(%f BETWEEN startDateTime AND startDateTime+duration) )"
												@" OR "
												// Check other starting blocks against our starting block 
												@"( (startDateTime BETWEEN %f AND %f)"
													@" OR " 
												@"(startDateTime+duration BETWEEN %f AND %f ) )"
												@");", (long)theAppt.appointmentID, startOfStartBlock+1, endOfStartBlock-1,
												startOfStartBlock+1, endOfStartBlock-1, startOfStartBlock+1, endOfStartBlock-1 ];
	
	sqlite3_stmt *statement;
	//         
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// No need to step using a while, 1 return is enough to know
		if (sqlite3_step(statement) == SQLITE_ROW) {
			returnValue = NO;			
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to check appointment availability.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnValue;
}

/*
 *	insertAppointment
 *	Inserts a new appointment into the database, adding the created ID to the object
 */
- (void) insertAppointment:(Appointment*)theAppt {
	NSInteger typeID = -1;
	if( theAppt.type == iBizAppointmentTypeSingleService ) {
		typeID = ((Service*)theAppt.object).serviceID;
	} else if( theAppt.type == iBizAppointmentTypeProject ) {
		typeID = ((Project*)theAppt.object).projectID;
	}
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_appointments (startDateTime, clientID, type, typeID, notes, duration, standingAppointmentID) VALUES (%f, %ld, %d, %ld, '%@', %ld, %ld);", [self getTimeIntervalForGMT:theAppt.dateTime], (long)((theAppt.client) ? theAppt.client.clientID : -1), theAppt.type, (long)typeID, [self escapeSQLCharacters:theAppt.notes], (long)theAppt.duration, (long)theAppt.standingAppointmentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add an appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theAppt.appointmentID = sqlite3_last_insert_rowid(database);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding an appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	insertAppointment
 *	Inserts a new standing appointment into the database, adding the created ID to the object
 */
- (void) insertStandingAppointment:(Appointment*)theAppt {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_standingAppointment ( repeatType, repeatCustom, repeatUntil ) VALUES ( %d, '%@', %f );", theAppt.standingRepeat, theAppt.standingRepeatCustom, [self getTimeIntervalForGMT:theAppt.standingRepeatUntilDate]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theAppt.standingAppointmentID = sqlite3_last_insert_rowid(database);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	updateAppointment
 *	Updates the appointment in the database
 */
- (void) updateAppointment:(Appointment*)theAppt {
	NSInteger typeID = -1;
	if( theAppt.type == iBizAppointmentTypeSingleService ) {
		typeID = ((Service*)theAppt.object).serviceID;
	} else if( theAppt.type == iBizAppointmentTypeProject ) {
		typeID = ((Project*)theAppt.object).projectID;
	}
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_appointments SET startDateTime=%f, clientID=%ld, type=%d, typeID=%ld, notes='%@', duration=%ld, standingAppointmentID=%ld WHERE appointmentID=%ld;", [self getTimeIntervalForGMT:theAppt.dateTime], (long)((theAppt.client) ? theAppt.client.clientID : -1), theAppt.type, (long)typeID, [self escapeSQLCharacters:theAppt.notes], (long)theAppt.duration, (long)theAppt.standingAppointmentID, (long)theAppt.appointmentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update an appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating an appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	updateAppointment
 *	Updates the appointment in the database
 */
- (void) updateStandingAppointment:(Appointment*)theAppt {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_standingAppointment SET repeatType=%d, repeatCustom='%@', repeatUntil=%f WHERE standingAppointmentID=%ld;", theAppt.standingRepeat, theAppt.standingRepeatCustom, [self getTimeIntervalForGMT:theAppt.standingRepeatUntilDate], (long)theAppt.standingAppointmentID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a standing appointment.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Service
#pragma mark -
/*
 *	Sets all Service Group IDs to 0 for Services with the given group ID.
 */
- (void) bulkUpdateServiceGroupToDefaultFromGroup:(ServiceGroup*)theGroup {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_services SET groupID=0 WHERE groupID=%ld;", (long)theGroup.groupID];	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update services for the deleted group.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating services for the deleted group.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Returns a dictionary of keys (type name) and arrays of Service objects (for that type name)
 *	Must release when done!
 */
- (void) getDictionaryOfServicesByGroupWithActiveFlag:(NSNumber*)active {
	NSMutableDictionary *servicesDict = [[NSMutableDictionary alloc] init];
	NSString *sql = nil;
	if( [active boolValue] ) {
		sql = [[NSString alloc] initWithString:@"SELECT serviceID, iBiz_services.groupID, serviceName, price, cost, taxable, duration, iBiz_group.groupDescription, isActive, color, isFlatRate, setupFee FROM iBiz_services INNER JOIN iBiz_group USING (groupID) WHERE isActive=1 ORDER BY serviceName;"];
	} else {
		sql = [[NSString alloc] initWithString:@"SELECT serviceID, iBiz_services.groupID, serviceName, price, cost, taxable, duration, iBiz_group.groupDescription, isActive, color, isFlatRate, setupFee FROM iBiz_services INNER JOIN iBiz_group USING (groupID) ORDER BY serviceName;"];
	}
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// Values from DB
			NSInteger serviceID = sqlite3_column_int(statement, 0);
			NSInteger groupID = sqlite3_column_int(statement, 1);
			NSString *sName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !sName || [sName isEqualToString:@"(null)"] ) {
				[sName release];
				sName = [[NSString alloc] initWithString:@"No Name"];
			}
			NSNumber *price = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			NSNumber *cost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			NSInteger tax = sqlite3_column_int(statement, 5);
			NSInteger duration = sqlite3_column_int(statement, 6);
			// Our dictionary key
			NSString *groupName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
			NSInteger activeFlag = sqlite3_column_int(statement, 8);
			// Color string
			NSString *color = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			
			BOOL hourly = sqlite3_column_int(statement, 10);
			NSNumber *setup = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 11)];
			
			NSMutableArray *array = [servicesDict objectForKey:groupName];
			if( !array ){
				array = [[NSMutableArray alloc] init];
				[servicesDict setObject:array forKey:groupName];
				[array release];
			}
			
			Service *srv = [[Service alloc] initWithServiceData:serviceID gID:groupID servName:sName price:price cost:cost taxabe:tax duration:duration];
			srv.isActive = activeFlag;
			srv.groupName = groupName;
			srv.serviceIsFlatRate = hourly;
			srv.serviceSetupFee = setup;
			[srv setColorWithString:color];
			[array addObject:srv];
			[srv release];
			
			// Releases
			[color release];
			[groupName release];
			[sName release];
			[price release];
			[cost release];
			[setup release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch services.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	[((NSObject*)self.delegate) performSelectorOnMainThread:@selector(dbReturnedDictionary:) withObject:servicesDict waitUntilDone:YES];
	[servicesDict release];
}

/*
 *	Returns a service with the given ID
 *	Must release when done!
 */
- (Service*) getServiceWithID:(NSInteger)theID {
	Service *returnService;
	NSString *sql = [[NSString alloc] initWithFormat:@"SELECT serviceID, iBiz_services.groupID, serviceName, price, cost, taxable, duration, iBiz_group.groupDescription, isActive, color, isFlatRate, setupFee FROM iBiz_services INNER JOIN iBiz_group USING (groupID) WHERE serviceID=%ld;", (long)theID];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		if (sqlite3_step(statement) == SQLITE_ROW) {
			// Values from DB
			NSInteger serviceID = sqlite3_column_int(statement, 0);
			NSInteger groupID = sqlite3_column_int(statement, 1);
			NSString *sName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !sName || [sName isEqualToString:@"(null)"] ) {
				[sName release];
				sName = [[NSString alloc] initWithString:@"No Name"];
			}
			NSNumber *price = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 3)];
			NSNumber *cost = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 4)];
			NSInteger tax = sqlite3_column_int(statement, 5);
			NSInteger duration = sqlite3_column_int(statement, 6);
			// Our dictionary key
			NSString *groupName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
			NSInteger activeFlag = sqlite3_column_int(statement, 8);
			// Color string
			NSString *color = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			
			BOOL hourly = sqlite3_column_int(statement, 10);
			NSNumber *setup = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, 11)];
			
			Service *srv = [[Service alloc] initWithServiceData:serviceID gID:groupID servName:sName price:price cost:cost taxabe:tax duration:duration];
			srv.isActive = activeFlag;
			srv.groupName = groupName;
			srv.serviceIsFlatRate = hourly;
			srv.serviceSetupFee = setup;
			[srv setColorWithString:color];
			returnService = srv;
			
			// Releases
			[color release];
			[groupName release];
			[sName release];
			[price release];
			[cost release];
			[setup release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return returnService;
}

/*
 *	Deletes the service from the DB
 */
- (void) removeService:(Service*)theService {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_services WHERE serviceID=%ld;", (long)theService.serviceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Inserts a new Service record into the DB
 */
- (void) insertService:(Service*)theService {
	const CGFloat *c = CGColorGetComponents( theService.color.CGColor );
	NSString *colorString = [[NSString alloc] initWithFormat:@"%f::%f::%f", c[0], c[1], c[2]];
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_services ( groupID, serviceName, price, cost, taxable, duration, color, isFlatRate, setupFee ) VALUES( %ld, '%@', %.2f, %.2f, %ld, %ld, '%@', %d, %.2f );", (long)theService.groupID, [self escapeSQLCharacters:theService.serviceName], [theService.servicePrice doubleValue], [theService.serviceCost doubleValue], (long)theService.taxable, (long)theService.duration, colorString, theService.serviceIsFlatRate, [theService.serviceSetupFee doubleValue]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	[colorString release];
	int success = sqlite3_step(statement);
	theService.serviceID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Updates the Service record in the DB
 *
 */
- (void) updateService:(Service*)theService {
	const CGFloat *c = CGColorGetComponents( theService.color.CGColor );
	NSString *colorString = [[NSString alloc] initWithFormat:@"%f::%f::%f", c[0], c[1], c[2]];
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_services SET groupID=%ld, serviceName='%@', price=%.2f, cost=%.2f, taxable=%ld, duration=%ld, isActive=%d, color='%@', isFlatRate=%d, setupFee=%.2f WHERE serviceID=%ld;", (long)theService.groupID, [self escapeSQLCharacters:theService.serviceName], [theService.servicePrice doubleValue], [theService.serviceCost doubleValue], (long)theService.taxable, (long)theService.duration, theService.isActive, colorString, theService.serviceIsFlatRate, [theService.serviceSetupFee doubleValue], (long)theService.serviceID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	[colorString release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a service.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 

	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark ServiceGroup
#pragma mark -
/*
 *	Returns an array of ServiceGroup objects from the DB
 *	Must release array when done!
 */
- (NSArray*) getServiceGroups {
    NSMutableArray *groupArray = [[NSMutableArray alloc] init];
	NSString *sql = @"SELECT * FROM iBiz_group ORDER BY groupDescription;";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			//int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the array.	
			NSInteger key = sqlite3_column_int(statement, 0);
			NSString *groupName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			
			ServiceGroup *gp = [[ServiceGroup alloc] initWithGroupData:groupName key:key];
			[groupArray addObject:gp];
			[gp release];
			[groupName release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch service groups.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return groupArray;
}

/*
 *	Deletes the ServiceGroup from the DB 
 */
- (void) removeServiceGroup:(ServiceGroup*)theGroup {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_group WHERE groupID=%ld;", (long)theGroup.groupID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a service group.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a service group.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Inserts the ServiceGroup into the DB
 */
- (void) insertServiceGroup:(ServiceGroup*)theGroup {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_group ( groupDescription ) VALUES ( '%@' );", [self escapeSQLCharacters:theGroup.groupDescription]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a service group.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	theGroup.groupID = sqlite3_last_insert_rowid(database);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a service group.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Updates the ServiceGroup into the DB
 */
- (void) updateServiceGroup:(ServiceGroup*)theGroup {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_group SET groupDescription='%@' WHERE groupID=%ld;", [self escapeSQLCharacters:theGroup.groupDescription], (long)theGroup.groupID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a service group.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a service group.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Settings Methods
#pragma mark -
/*
 *	getClientNameViewSetting
 *	Gets the client name sort option
 */
- (NSInteger) getClientNameSortSetting {
	NSInteger returnValue = 0;
	NSString *sql = [[NSString alloc] initWithString:@"SELECT clientNameSort FROM iBiz_settings ORDER BY settingsID ASC LIMIT 1"];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// Just returns 1 row
		if (sqlite3_step(statement) == SQLITE_ROW) {
			returnValue = sqlite3_column_int(statement, 0);
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch the client sort setting.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnValue;
}

/*
 *	updateClientSortSetting
 *	Sets the sort option.
 */
- (void) updateClientNameSortSetting:(NSInteger)sortOption {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_settings SET clientNameSort=%ld WHERE settingsID=0;", (long)sortOption];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update the client sort setting.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating the client sort setting.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	getClientNameViewSetting
 *	Gets the client name view option
 */
- (NSInteger) getClientNameViewSetting {
	NSInteger returnValue = 0;
	NSString *sql = [[NSString alloc] initWithString:@"SELECT clientNameView FROM iBiz_settings ORDER BY settingsID ASC LIMIT 1"];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// Just returns 1 row
		if (sqlite3_step(statement) == SQLITE_ROW) {
			returnValue = sqlite3_column_int(statement, 0);
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch the client view setting.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnValue;
}

/*
 *	updateClientSortSetting
 *	Sets the view option.
 */
- (void) updateClientNameViewSetting:(NSInteger)viewOption {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_settings SET clientNameView=%ld WHERE settingsID=0;", (long)viewOption];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update the client view setting.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating the client view setting.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	getSettings
 *	Gets the last inserted settings (should only be 1)
 *	Must release when finished!
 */
- (Settings*) getSettings {
	Settings *returnValue = nil;
	// Get all values.
	NSString *sql = @"SELECT * FROM iBiz_settings ORDER BY settingsID ASC LIMIT 1";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// Just returns 1 row
		if (sqlite3_step(statement) == SQLITE_ROW) {
			NSInteger newKey = sqlite3_column_int(statement, 0);
			// Skipping the other rows until EMailing is implemented
			NSString *mons = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *monf = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			NSString *tues = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			NSString *tuef = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			NSString *weds = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			NSString *wedf = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
			NSString *thurs = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
			NSString *thurf = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
			NSString *fris = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			NSString *frif = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
			NSString *sats = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 11)];
			NSString *satf = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
			NSString *suns = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
			NSString *sunf = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 14)];
			// Sets
			returnValue = [[Settings alloc] initWithKey:newKey];
			returnValue.mondayStart = ( !mons || [mons isEqualToString:@"(null)"] ) ? nil : mons;
			returnValue.tuesdayStart = ( !tues || [tues isEqualToString:@"(null)"] ) ? nil : tues;
			returnValue.wednesdayStart = ( !weds || [weds isEqualToString:@"(null)"] ) ? nil : weds;
			returnValue.thursdayStart = ( !thurs || [thurs isEqualToString:@"(null)"] ) ? nil : thurs;
			returnValue.fridayStart = ( !fris || [fris isEqualToString:@"(null)"] ) ? nil : fris;
			returnValue.saturdayStart = ( !sats || [sats isEqualToString:@"(null)"] ) ? nil : sats;
			returnValue.sundayStart = ( !suns || [suns isEqualToString:@"(null)"] ) ? nil : suns;
			returnValue.mondayFinish = ( !monf || [monf isEqualToString:@"(null)"] ) ? nil : monf;
			returnValue.tuesdayFinish = ( !tuef || [tuef isEqualToString:@"(null)"] ) ? nil : tuef;
			returnValue.wednesdayFinish = ( !wedf || [wedf isEqualToString:@"(null)"] ) ? nil : wedf;
			returnValue.thursdayFinish = ( !thurf || [thurf isEqualToString:@"(null)"] ) ? nil : thurf;
			returnValue.fridayFinish = ( !frif || [frif isEqualToString:@"(null)"] ) ? nil : frif;
			returnValue.saturdayFinish = ( !satf || [satf isEqualToString:@"(null)"] ) ? nil : satf;
			returnValue.sundayFinish = ( !sunf || [sunf isEqualToString:@"(null)"] ) ? nil : sunf;
			// Releases
			[mons release];
			[monf release];
			[tues release];
			[tuef release];
			[weds release];
			[wedf release];
			[thurs release];
			[thurf release];
			[fris release];
			[frif release];
			[sats release];
			[satf release];
			[suns release];
			[sunf release];
			// Days off
			returnValue.isMondayOff = sqlite3_column_int(statement, 15);
			returnValue.isTuesdayOff = sqlite3_column_int(statement, 16);
			returnValue.isWednesdayOff = sqlite3_column_int(statement, 17);
			returnValue.isThursdayOff = sqlite3_column_int(statement, 18);
			returnValue.isFridayOff = sqlite3_column_int(statement, 19);
			returnValue.isSaturdayOff = sqlite3_column_int(statement, 20);
			returnValue.isSundayOff = sqlite3_column_int(statement, 21);
			returnValue.is15MinuteIntervals = sqlite3_column_int(statement, 22);
            
            //ja
            returnValue.isCloseout = sqlite3_column_int(statement, 25);
            NSString *closeT = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 26)];
            returnValue.closeTime = ( !closeT || [closeT isEqualToString:@"(null)"] ) ? nil : closeT;
            [closeT release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch work hour settings.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return returnValue;
}

/*
 *
 *
 */
- (void) updateSettings:(Settings*)settings {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_settings SET mondayStart='%@', mondayFinish='%@', tuesdayStart='%@', tuesdayFinish='%@', wednesdayStart='%@', wednesdayFinish='%@', thursdayStart='%@', thursdayFinish='%@', fridayStart='%@', fridayFinish='%@', saturdayStart='%@', saturdayFinish='%@', sundayStart='%@', sundayFinish='%@', isMondayOff=%d, isTuesdayOff=%d, isWednesdayOff=%d, isThursdayOff=%d, isFridayOff=%d, isSaturdayOff=%d, isSundayOff=%d, is15MinuteIntervals=%d, isCloseout=%d, closeTime='%@' WHERE settingsID='%li'", settings.mondayStart, settings.mondayFinish, settings.tuesdayStart, settings.tuesdayFinish, settings.wednesdayStart, settings.wednesdayFinish, settings.thursdayStart, settings.thursdayFinish, settings.fridayStart, settings.fridayFinish, settings.saturdayStart, settings.saturdayFinish, settings.sundayStart, settings.sundayFinish, settings.isMondayOff, settings.isTuesdayOff, settings.isWednesdayOff, settings.isThursdayOff, settings.isFridayOff, settings.isSaturdayOff, settings.isSundayOff, settings.is15MinuteIntervals, settings.isCloseout, settings.closeTime, (long)settings.settingsID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update work hour settings.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating work hour settings.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *	Stores the fetched data in the passed object
 */
- (void) getCreditCardSettings:(CreditCardSettings*)theSettings {
	// Get all values.
	NSString *sql = @"SELECT emailGatewayReceipt, processingType FROM iBiz_creditSettings WHERE creditSettingsID=0 LIMIT 1";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// Just returns 1 row
		if (sqlite3_step(statement) == SQLITE_ROW) {
			theSettings.sendEmailFromGateway = sqlite3_column_int(statement, 0);
			theSettings.processingType = sqlite3_column_int(statement, 1);
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch credit card settings.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 */
- (void) updateCreditCardSettings:(CreditCardSettings*)theSettings {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_creditSettings SET emailGatewayReceipt=%d, processingType=%d WHERE creditSettingsID=0", theSettings.sendEmailFromGateway, theSettings.processingType];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update credit card settings.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating credit card settings.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Vendor Methods
#pragma mark -
/*
 *
 *	Must release when done!
 */
- (NSArray*) getVendors {
	NSMutableArray *vendorArray = [[NSMutableArray alloc] init];
	NSString *sql = [[NSString alloc] initWithString:@"SELECT * FROM iBiz_vendor ORDER BY vendorName;"];
	sqlite3_stmt *statement;
	//        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//
			NSInteger newKey = sqlite3_column_int(statement, 0);
			NSString *vname = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			if( !vname || [vname isEqualToString:@"(null)"] ) {
				[vname release];
				vname = nil;
			}
			NSString *vcont = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			if( !vcont || [vcont isEqualToString:@"(null)"] ) {
				[vcont release];
				vcont = nil;
			}
			NSString *vaddr1 = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			if( !vaddr1 || [vaddr1 isEqualToString:@"(null)"] ) {
				[vaddr1 release];
				vaddr1 = nil;
			}
			NSString *vaddr2 = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			if( !vaddr2 || [vaddr2 isEqualToString:@"(null)"] ) {
				[vaddr2 release];
				vaddr2 = nil;
			}
			NSString *vcity = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			if( !vcity || [vcity isEqualToString:@"(null)"] ) {
				[vcity release];
				vcity = nil;
			}
			NSString *vstate = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
			if( !vstate || [vstate isEqualToString:@"(null)"] ) {
				[vstate release];
				vstate = nil;
			}
			NSInteger vzip = sqlite3_column_int(statement, 7);
			NSString *vph = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
			if( !vph || [vph isEqualToString:@"(null)"] ) {
				[vph release];
				vph = nil;
			}
			NSString *vemail = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if( !vemail || [vemail isEqualToString:@"(null)"] ) {
				[vemail release];
				vemail = nil;
			}
			NSString *vfax = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
			if( !vfax || [vfax isEqualToString:@"(null)"] ) {
				[vfax release];
				vfax = nil;
			}
			
			Vendor *vp = [[Vendor alloc] initWithVendorData:newKey name:vname contact:vcont addr1:vaddr1 addr2:vaddr2 city:vcity state:vstate zip:vzip phone:vph email:vemail fax:vfax];			
			[vendorArray addObject:vp];
			[vp release];
			// Data releases
			[vname release];
			[vcont release];
			[vaddr1 release];
			[vaddr2 release];
			[vcity release];
			[vstate release];
			[vph release];
			[vemail release];
			[vfax release];
		}
	} else {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to fetch vendors.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	return vendorArray;
}

/*
 *
 *
 */
- (void) removeVendor:(Vendor*)theVendor {
	NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM iBiz_vendor WHERE vendorID=%ld", (long)theVendor.vendorID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to delete a vendor.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem deleting a vendor.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) insertVendor:(Vendor*)theVendor {
	NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO iBiz_vendor (vendorName, contact, address1, address2, city, stateID, zipCode, telephoneNumber, email, faxNumber) VALUES('%@', '%@', '%@', '%@', '%@', '%@', %ld, '%@', '%@', '%@')", [self escapeSQLCharacters:theVendor.vendorName], [self escapeSQLCharacters:theVendor.vendorContact], [self escapeSQLCharacters:theVendor.vendorAddress1], [self escapeSQLCharacters:theVendor.vendorAddress2], [self escapeSQLCharacters:theVendor.vendorCity], [self escapeSQLCharacters:theVendor.vendorState], (long)theVendor.vendorZipcode, [self escapeSQLCharacters:theVendor.vendorTelephone], [self escapeSQLCharacters:theVendor.vendorEmail], [self escapeSQLCharacters:theVendor.vendorFax]];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to add a vendor.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem adding a vendor.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}

/*
 *
 *
 */
- (void) updateVendor:(Vendor*)theVendor {
	NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE iBiz_vendor SET vendorName='%@', contact='%@', address1='%@', address2='%@', city='%@', stateID='%@', zipCode=%ld, telephoneNumber='%@', email='%@', faxNumber='%@' WHERE vendorID=%ld;", [self escapeSQLCharacters:theVendor.vendorName], [self escapeSQLCharacters:theVendor.vendorContact], [self escapeSQLCharacters:theVendor.vendorAddress1], [self escapeSQLCharacters:theVendor.vendorAddress2], [self escapeSQLCharacters:theVendor.vendorCity], [self escapeSQLCharacters:theVendor.vendorState], (long)theVendor.vendorZipcode, [self escapeSQLCharacters:theVendor.vendorTelephone], [self escapeSQLCharacters:theVendor.vendorEmail], [self escapeSQLCharacters:theVendor.vendorFax], (long)theVendor.vendorID];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update a vendor.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem updating a vendor.\n\nPlease restart the app and report this message to our support if it reappears."];
	} 
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}


#pragma mark -
#pragma mark Database Object Methods
#pragma mark -
/*
 *	Prints the SQLite version number to the command line.
 *	Should be > 3.1.3 for ALTER statements to work.
 *	Last I checked it was 3.6.12.
 */
/*
- (void) getVersionNumber {
	NSString *sql = [[NSString alloc] initWithString:@"SELECT sqlite_version();"];
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		if (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *version = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			DebugLog( @"%@", version );
			[version release];
		}
	}
	[sql release];
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
}
*/
 
/*
 *	closeDatabase
 *	Closes the database.
 */
- (void) closeDatabase {
	int code = sqlite3_close(database);
    if (code != SQLITE_OK) {
        [self.delegate dbReturnedError:@"There was an internal problem attempting to close the database.\n\nPlease report this message to our support if it reappears."];
    }
}


/*
 *	initializeDatabase
 *	The application ships with a default database in its bundle. Copy it to the Documents directory
 *	in order to make the database writable.
 */
- (void) initializeDatabase {
	// Open the database connection and retrieve minimal information for all objects.
    if (database == NULL) {
        // First, test for existence.
        int success;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"btnRegisterBackground.png"];
        if ([fileManager fileExistsAtPath:writableDBPath] == NO) {
            // The writable database does not exist, so copy the default to the appropriate location.
            NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"btnRegisterBackground" ofType:@"png"];
            success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
            if (!success) {
				[self.delegate dbReturnedError:@"Failed to create your database file.\n\nPlease restart the app and report this message to our support if it reappears."];
            }
        }
        // Open the database. The database was prepared outside the application.
        if (sqlite3_open([writableDBPath UTF8String], &database) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(database);
            database = NULL;
            [self.delegate dbReturnedError:@"Failed to open your database.\n\nPlease restart the app and report this message to our support if it reappears."];
            // Additional error handling, as appropriate...
        } else {
			// Attach other databases as needed...
			//
			// Credit Card Settings Tables
			// Version 2.0+ ... 6/2010
			//
			// Create if necessary
			writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"btnMenuBackground.png"];			
			if ([fileManager fileExistsAtPath:writableDBPath] == NO) {
				// The writable database does not exist, so copy the default to the appropriate location.
				NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"btnMenuBackground" ofType:@"png"];
				success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
				if( !success ) {
					[self.delegate dbReturnedError:@"Failed to create your credit card settings database.\n\nPlease restart the app and report this message to our support if it reappears."];
				}
			}
			
			// TODO: COMMENT BEFORE RELEASE!!!!! (Overwrites the cc database file)
			/*
			else {
				NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"btnMenuBackground" ofType:@"png"];
				[fileManager removeItemAtPath:writableDBPath error:nil];
				success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
				if( !success ) {
					[self.delegate dbReturnedError:@"Failed to create your credit card settings database.\n\nPlease restart the app and report this message to our support if it reappears."];
				}
			}
			 */
			
			// Attach
			NSString *sql = [[NSString alloc] initWithFormat:@"ATTACH '%@' AS ccSettingsDB", writableDBPath];
			sqlite3_stmt *statement;
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
				[self.delegate dbReturnedError:@"There was an internal problem attempting to read credit card settings.\n\nPlease restart the app and report this message to our support if it reappears."];
			}
			[sql release];
            success = sqlite3_step(statement);
			sqlite3_reset(statement);
			if (success == SQLITE_ERROR) {
				[self.delegate dbReturnedError:@"There was an internal problem attempting to read credit card settings.\n\nPlease restart the app and report this message to our support if it reappears."];
			}
			sqlite3_finalize(statement);
			
			
			//
			//	Added 7/2010... for version 3.0
			// 
			BOOL updateClientSort = YES;
			BOOL updateClientView = YES;
			// If table iBiz_transactionItem does not have a column named "price"...
			sql = [[NSString alloc] initWithString:@"PRAGMA table_info( iBiz_settings );"];
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				while (sqlite3_step(statement) == SQLITE_ROW) {
					NSString *columnName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					if( [columnName isEqualToString:@"clientNameSort"] ) {
						//DebugLog( @"No need to add the clientNameSort column" );
						updateClientSort = NO;
					} else if( [columnName isEqualToString:@"clientNameView"] ) {
						//DebugLog( @"No need to add the clientNameView column" );
						updateClientView = NO;
					}
					[columnName release];
				}
			} else {
				[self.delegate dbReturnedError:@"There was an internal problem checking to see if your settings database needs to be updated.\n\nPlease restart the app and report this message to our support if it reappears."];
			}
			[sql release];
			sqlite3_finalize(statement);
			
			if( updateClientSort ) {
				[self upgradeWithClientSortSetting];
			}
			if( updateClientView ) {
				[self upgradeWithClientViewSetting];
			}
			
			
			//
			//	Added 8/2010... for version 3.1
			// 
			BOOL updateCreditSettings = YES;
			// If table iBiz_transactionItem does not have a column named "price"...
			sql = [[NSString alloc] initWithString:@"PRAGMA table_info( iBiz_creditSettings );"];
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				while (sqlite3_step(statement) == SQLITE_ROW) {
					NSString *columnName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					if( [columnName isEqualToString:@"processingType"] ) {
						//DebugLog( @"No need to add the updateCreditSettings column" );
						updateCreditSettings = NO;
					}
					[columnName release];
				}
			} else {
				[self.delegate dbReturnedError:@"There was an internal problem checking to see if your settings database needs to be updated.\n\nPlease restart the app and report this message to our support if it reappears."];
			}
			[sql release];
			sqlite3_finalize(statement);
			
			if( updateCreditSettings ) {
				[self upgradeCreditSettingsToThreePointOne];
			}
			
			
			//
			//	Added 10/2010... for version 3.2
			// 
			BOOL updateCreditAddress = YES;
			sql = [[NSString alloc] initWithString:@"PRAGMA table_info( iBiz_creditCardPayment );"];
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
				while (sqlite3_step(statement) == SQLITE_ROW) {
					NSString *columnName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					if( [columnName isEqualToString:@"addressZip"] ) {
						updateCreditAddress = NO;
					}
					[columnName release];
				}
			} else {
				[self.delegate dbReturnedError:@"There was an internal problem checking to see if your credit card database needs to be updated.\n\nPlease restart the app and report this message to our support if it reappears."];
			}
			[sql release];
			sqlite3_finalize(statement);
			
			if( updateCreditAddress ) {
				[self upgradeCreditAddressToFourPointThree];
			}
			
		}
		
    }
}


/*
 *	Creates column 'clientNameSort' in table iBiz_settings
 *	Populates with 0
 */
- (void) upgradeWithClientSortSetting {
	// Let's do a transaction so we can recover from any issues.
	if( sqlite3_exec(database, "BEGIN TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	// ALTER TABLE
	NSString *sql = [[NSString alloc] initWithString:@"ALTER TABLE iBiz_settings ADD COLUMN clientNameSort INTEGER DEFAULT 0;"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	sqlite3_finalize(statement);
	
	// Set the value
	sql = [[NSString alloc] initWithString:@"UPDATE iBiz_settings SET clientNameSort=0 WHERE settingsID=0;"];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	sqlite3_finalize(statement);
	
	// Commit everything we've just done...
	if( sqlite3_exec(database, "COMMIT TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
}

/*
 *	Creates column 'clientNameView' in table iBiz_settings
 *	Populates with 0
 */
- (void) upgradeWithClientViewSetting {
	// Let's do a transaction so we can recover from any issues.
	if( sqlite3_exec(database, "BEGIN TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	// ALTER TABLE
	NSString *sql = [[NSString alloc] initWithString:@"ALTER TABLE iBiz_settings ADD COLUMN clientNameView INTEGER DEFAULT 0;"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	sqlite3_finalize(statement);
	
	// Set the value
	sql = [[NSString alloc] initWithString:@"UPDATE iBiz_settings SET clientNameView=0 WHERE settingsID=0;"];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	sqlite3_finalize(statement);
	
	// Commit everything we've just done...
	if( sqlite3_exec(database, "COMMIT TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.0.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
}

/*
 *	Creates column 'processingType' in table iBiz_creditSettings
 *	Populates with 0
 */
- (void) upgradeCreditSettingsToThreePointOne {
	// Let's do a transaction so we can recover from any issues.
	if( sqlite3_exec(database, "BEGIN TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.1.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	// ALTER TABLE
	NSString *sql = [[NSString alloc] initWithString:@"ALTER TABLE iBiz_creditSettings ADD COLUMN processingType INTEGER DEFAULT 1;"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.1.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	int success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.1.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	sqlite3_finalize(statement);
	
	// Set the value
	sql = [[NSString alloc] initWithString:@"UPDATE iBiz_creditSettings SET processingType=0 WHERE creditSettingsID=0;"];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.1.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	[sql release];
	success = sqlite3_step(statement);
	sqlite3_reset(statement);
	if (success == SQLITE_ERROR) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.1.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	sqlite3_finalize(statement);
	
	// Commit everything we've just done...
	if( sqlite3_exec(database, "COMMIT TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your settings database to version 3.1.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
}

/*
 *	Add the columns for client info and billing address
 */
- (void) upgradeCreditAddressToFourPointThree {
	// Let's do a transaction so we can recover from any issues.
	if( sqlite3_exec(database, "BEGIN TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	// ALTER TABLE
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN firstName TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN middleName TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN lastName TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN email TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN phone TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN notes TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN addressStreet TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN addressCity TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN addressState TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	if( sqlite3_exec(database, "ALTER TABLE iBiz_creditCardPayment ADD COLUMN addressZip TEXT;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
	
	// Commit everything we've just done...
	if( sqlite3_exec(database, "COMMIT TRANSACTION;", NULL, NULL, NULL) != SQLITE_OK ) {
		[self.delegate dbReturnedError:@"There was an internal problem attempting to update your credit card database to version 3.2.\n\nPlease restart the app and report this message to our support if it reappears."];
	}
}


@end
