//
//  PSADataManager.h
//  myBusiness
//
//  Created by David J. Maier on 10/14/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADatabaseManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Foundation/Foundation.h>

@class Appointment, Client, CloseOut, Company, CreditCardPayment, CreditCardSettings, Email, GiftCertificate, Product, ProductAdjustment, ProductType, Report;
@class Service, ServiceGroup, Settings, Transaction, TransactionItem, TransactionPayment, Vendor;
@class Project, ProjectInvoice, ProjectInvoiceItem, ProjectProduct, ProjectService;

// Protocol Definition
@protocol PSADataManagerDelegate <NSObject>
@optional
- (void) dataManagerReturnedArray:(NSArray*)theArray;
- (void) dataManagerReturnedDictionary:(NSDictionary*)theDictionary;
- (void) dataManagerReturnedNothing;
@end

@interface PSADataManager : NSObject <PSADatabaseManagerDelegate> {
	// Properties
	ABAddressBookRef	addressBook;
	ABRecordRef			addressBookGroup;
	// Private
	PSADatabaseManager	*dbManager;
	// Threading
	NSOperationQueue	*operationQueue;
	id					delegate;
	//
	BOOL				askAboutRecoveringClients;
	NSInteger			clientNameSortOption;
	NSInteger			clientNameViewOption;
	BOOL				isRecoveringClients;
}

// Properties
@property (nonatomic, assign) ABAddressBookRef	addressBook;
@property (nonatomic, assign) ABRecordRef		addressBookGroup;
// Threading
@property (nonatomic, retain, readonly) NSOperationQueue	*operationQueue;
@property (nonatomic, assign) id <PSADataManagerDelegate>	delegate;
//
@property (nonatomic, assign) BOOL		askAboutRecoveringClients;
@property (nonatomic, assign, readonly) NSInteger	clientNameSortOption;
@property (nonatomic, assign, readonly) NSInteger	clientNameViewOption;

#pragma mark -
#pragma mark Database Methods
#pragma mark -
- (void) loadDatabase;
- (void) prepareForExit;

#pragma mark -
#pragma mark Database Manager Delegate Methods
#pragma mark -
- (void) dbReturnedArray:(NSArray*)theArray;
- (void) dbReturnedDictionary:(NSDictionary*)theDictionary;
- (void) dbReturnedError:(NSString*)theMessage;

#pragma mark -
#pragma mark Clients
#pragma mark -

- (BOOL)	attemptRecoveryForClient:(Client*)theClient;
- (void)	attemptRecoveryForAllClients:(NSDictionary*)theClients;

- (NSDateFormatterStyle)	getClientDateFormat;
- (void)					getClientsWithActiveFlag:(BOOL)active;
//- (NSDictionary*)			getClientsAnniversaryDictionaryWithArray:(NSArray*)theArray;
- (NSDictionary*)			getClientsDictionaryWithArray:(NSArray*)theArray isBirthday:(BOOL)isBirthday;
- (NSDictionary*)			getClientsDictionaryWithArray:(NSArray*)theArray;
- (void)					removeClient:(Client*)client;
- (void)					saveNewClient:(Client*)client;
- (void)					updateClient:(Client*)client;
// Address Book
- (void)					createAddressBookGroupIfNecessary;

#pragma mark -
#pragma mark Company
#pragma mark -
- (Company*)	getCompany;
- (void)		saveCompany:(Company*)theCompany;
- (void)		updateCompany:(Company*)theCompany;

#pragma mark -
#pragma mark Email
#pragma mark -
- (Email*)	getAnniversaryEmail;
- (Email*)	getAppointmentReminderEmail;
- (Email*)	getBirthdayEmail;
- (void)	saveEmail:(Email*)theEmail;

#pragma mark -
#pragma mark Products
#pragma mark -
- (void)			getDictionaryOfProductsByTypeWithActiveFlag:(BOOL)active;
- (NSArray*)		getProductTypes;
- (Product*)		getProductWithID:(NSInteger)theID;
- (void)			removeProduct:(Product*)theProduct;
- (void)			removeProductType:(ProductType*)theType;
- (void)			saveProduct:(Product*)theProduct;
- (void)			saveProductType:(ProductType*)theType;
// Adjustment
- (void)			getProductAdjustmentsForReport:(Report*)theReport;
- (void)			insertProductAdjustment:(ProductAdjustment*)theAdjustment;
- (void)			removeProductAdjustmentWithID:(NSInteger)theID;

#pragma mark -
#pragma mark Projects
#pragma mark -
- (void)			hydrateProject:(Project*)theProject;

- (void)			getArrayOfProjectsByType:(NSInteger)type;
- (void)			getArrayOfProjectsForClient:(Client*)theClient;
- (void)			getArrayOfInvoicesFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)			getArrayOfUnpaidInvoicesByType:(NSInteger)type;
- (NSDictionary*)	getDictionaryOfProjectsFromArray:(NSArray*)projects;
- (ProjectInvoice*)	getInvoiceWithPaymentID:(NSInteger)paymentID;
- (Project*)		getProjectWithID:(NSInteger)projectID;
- (Project*)		getProjectWithInvoiceID:(NSInteger)invoiceID;

- (void)			removeInvoice:(ProjectInvoice*)theInvoice;
- (void)			removeInvoicePaymentFromCloseouts:(TransactionPayment*)thePayment;
- (void)			removeInvoiceProduct:(ProjectInvoiceItem*)theItem;
- (void)			removeInvoiceService:(ProjectInvoiceItem*)theItem;
- (void)			removeProject:(Project*)theProject;
- (void)			removeProjectProduct:(ProjectProduct*)projectProduct fromProject:(Project*)theProject;
- (void)			removeProjectService:(ProjectService*)projectService fromProject:(Project*)theProject;

- (void)			saveInvoice:(ProjectInvoice*)theInvoice;
- (void)			saveProject:(Project*)theProject;
- (void)			saveProjectProduct:(ProjectProduct*)theProjectProduct;
- (void)			saveProjectService:(ProjectService*)theProjectService;

- (void)			updateAllInvoicesAndProject:(Project*)theProject;
- (void)			updateInvoiceTotal:(ProjectInvoice*)theInvoice;
- (void)			updateProjectTotal:(Project*)theProject;

#pragma mark -
#pragma mark Register
#pragma mark -
// Closeouts
- (void)		getArrayOfCloseoutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)		getInvoiceIDsForCloseOut:(CloseOut*)theCloseOut;
- (void)		getInvoiceIDsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)		getInvoiceIDsForNextCloseOut;
- (NSArray*)	getInvoiceIDsUnthreadedForCloseOut:(CloseOut*)theCloseOut;
- (void)		getInvoicePaymentsForCloseOut:(CloseOut*)theCloseOut;
- (void)		getInvoicePaymentsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)		getInvoicePaymentsForNextCloseOut;
- (NSArray*)	getInvoicePaymentsUnthreadedForCloseOut:(CloseOut*)theCloseOut;
- (void)		insertDailyCloseoutForTransactions:(NSArray*)transactions andInvoicePayments:(NSArray*)payments andInvoices:(NSArray*)invoices;
- (void)		autoDailyCloseoutForTransactions:(Transaction*)transactions theDate:(NSDate*)today;
- (void)        autoCloseout:(NSDate*)date;
// Transaction Fetchers
//	 Threaded

- (void)	getAllTransactionsSinceLastCloseout;
- (void)	getAllTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)	getClosedTransactionsSinceLastCloseout;
- (void)	getClosedTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)	getOpenTransactionsSinceLastCloseout;
- (void)	getOpenTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)	getVoidTransactionsSinceLastCloseout;
- (void)	getVoidedTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)	getTransactionsForClient:(Client*)theClient;
- (void)	getTransactionsForCloseOut:(CloseOut*)theCloseOut;
- (void)	getTransactionsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end;
//	 Unthreaded...
- (NSDictionary*)		getDictionaryOfTransactionsFromArray:(NSArray*)transactions;
- (Transaction*)		getTransactionForAppointment:(Appointment*)theAppointment;
- (NSArray*)			getTransactionsUnthreadedForCloseOut:(CloseOut*)theCloseOut;
// Other Fetchers
- (NSArray*)			getGiftCertificates;
- (GiftCertificate*)	getGiftCertificateWithID:(NSInteger)theID;
// Certificate Adjustments
- (void)				deductAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID;
- (void)				refundAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID;
// Lazy Loading
- (void)				hydrateTransaction:(Transaction*)theTransaction;
// Removes
- (void)				removeGiftCertificate:(GiftCertificate*)theCert;
- (void)				removeGiftCertificateWithID:(NSInteger)theID;
- (void)				removeTransactionItem:(TransactionItem*)theItem;
- (void)				removeTransactionPayment:(TransactionPayment*)thePayment;
// Inserts or updates the transaction and all of it's specific data
- (void)				saveTransaction:(Transaction*)theTransaction isOnlySave:(BOOL)isSave;
- (void)				saveTransactionTip:(Transaction*)theTransaction;
- (void)				voidTransaction:(Transaction*)theTransaction;
// Credit Cards
- (NSDictionary*)		getDictionaryOfCreditPaymentsFromArray:(NSArray*)payments;
- (void)				getCreditCardPaymentForPayment:(TransactionPayment*)thePayment;
- (void)				getAllCCPaymentsUnclosed;
- (void)				getAllCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)				getApprovedCCPaymentsUnclosed;
- (void)				getApprovedCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)				getRefundedCCPaymentsUnclosed;
- (void)				getRefundedCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)				getVoidedCCPaymentsUnclosed;
- (void)				getVoidedCCPaymentsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)				saveCreditCardPayment:(CreditCardPayment*)thePayment;

#pragma mark -
#pragma mark Schedule
#pragma mark -
- (BOOL)			checkAppointmentAvailability:(Appointment*)theAppointment;
- (void)			deleteAppointment:(Appointment*)theAppointment deleteStanding:(BOOL)standing;
- (void)			deleteStandingAppointment:(Appointment*)theAppointment;
- (void)			deleteOrphanedStandingAppointments;
- (void)			getAppointmentsForClient:(Client*)theClient;
- (void)			getAppointmentsForDay:(NSDate*)theDate;
- (void)			getAppointmentsForProject:(Project*)theProject;
- (void)			getAppointmentsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (NSDictionary*)	getDictionaryOfAppointmentsForArray:(NSArray*)theArray;
- (void)			getDictionaryOfAppointmentsFor30DaysStarting:(NSDate*)theDate;
- (void)			getDictionaryOfAppointmentsForMonth:(NSDate*)theDate;
- (void)			getDictionaryOfAppointmentsForOneYear;
- (NSDate*)			getNextRepeatDateForAppointment:(Appointment*)theAppointment;
- (void)			insertAppointment:(Appointment*)theAppointment;
- (NSArray*)		saveAppointment:(Appointment*)theAppointment updateStanding:(BOOL)updateStanding ignoreConflicts:(BOOL)ignoreConflicts;
- (void)			_saveAppointment:(Appointment*)theAppointment updateStanding:(BOOL)updateStanding ignoreConflicts:(BOOL)ignoreConflicts;
- (void)			saveAppointmentThreaded:(Appointment*)theAppointment updateStanding:(BOOL)updateStanding ignoreConflicts:(BOOL)ignoreConflicts;
- (void)			updateAppointment:(Appointment*)theAppointment;

#pragma mark -
#pragma mark Services
#pragma mark -
- (void)			getDictionaryOfServicesByGroupWithActiveFlag:(BOOL)active;
- (NSArray*)		getServiceGroups;
- (Service*)		getServiceWithID:(NSInteger)theID;
- (void)			removeService:(Service*)theService;
- (void)			removeServiceGroup:(ServiceGroup*)theGroup;
- (void)			saveService:(Service*)theService;
- (void)			saveServiceGroup:(ServiceGroup*)theGroup;

#pragma mark -
#pragma mark Settings
#pragma mark -
- (void)					setClientNameSortSetting:(NSInteger)sortOption;
- (void)					setClientNameViewSetting:(NSInteger)sortOption;
- (NSDateFormatterStyle)	getWorkHoursDateFormat;
- (CreditCardSettings*)		getCreditCardSettings;
- (Settings*)				getSettings;
- (void)					saveSettings:(Settings*)settings;
- (void)					updateCreditCardSettings:(CreditCardSettings*)theSettings;
- (void)					updateSettings:(Settings*)settings;

#pragma mark -
#pragma mark Vendors
#pragma mark -
- (NSArray*)	getVendors;
- (void)		removeVendor:(Vendor*)theVendor;
- (void)		saveVendor:(Vendor*)theVendor;

#pragma mark -
#pragma mark Helper Methods
#pragma mark -
//- (NSString*)	formatPhoneNumber:(NSString*)number;
- (NSDate*)		getDateForString:(NSString*)date withFormat:(NSDateFormatterStyle)style;
- (NSDate*)		getTimeForString:(NSString*)date withFormat:(NSDateFormatterStyle)style;
- (NSString*)	getStringForAppointmentDate:(NSDate*)date;
- (NSString*)	getStringForAppointmentListHeader:(NSDate*)date;
- (NSString*)	getStringForDate:(NSDate*)date withFormat:(NSDateFormatterStyle)style;
- (NSString*)	getStringForTime:(NSDate*)date withFormat:(NSDateFormatterStyle)style;
- (NSString*)	getShortStringOfHoursAndMinutesForSeconds:(NSInteger)seconds;
- (NSString*)	getStringOfHoursAndMinutesForSeconds:(NSInteger)seconds;

- (void)		hideActivityIndicator;
- (void)		showActivityIndicator;
- (void)		showError:(NSString*)message;
- (NSDate *)todayModifiedWithHours:(NSString *)strTime;
#pragma mark -
#pragma mark Singleton Accessor
#pragma mark -
+ (PSADataManager *) sharedInstance;

@end
