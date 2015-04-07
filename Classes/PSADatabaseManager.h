//
//  PSADatabaseManager.h
//  myBusiness
//
//  Created by David J. Maier on 10/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Email.h"
#import <sqlite3.h>
#import <Foundation/Foundation.h>

@class Appointment, Client, CloseOut, Company, CreditCardPayment, CreditCardSettings, Email, GiftCertificate, Product, ProductAdjustment, ProductType;
@class Service, ServiceGroup, Settings, Tax, Transaction, TransactionItem, TransactionPayment, Vendor;
@class Project, ProjectInvoice, ProjectInvoiceItem, ProjectProduct, ProjectService;

typedef enum PSATransactionStatusType {
	PSATransactionStatusAll,
	PSATransactionStatusOpen,
	PSATransactionStatusClosed,
	PSATransactionStatusVoid
} PSATransactionStatusType;

typedef enum PSACreditCardPaymentStatusType {
	PSACreditCardPaymentStatusAll,
	PSACreditCardPaymentStatusApproved,
	PSACreditCardPaymentStatusRefunded,
	PSACreditCardPaymentStatusVoided
} PSACreditCardPaymentStatusType;

// Protocol Definition
@protocol PSADatabaseManagerDelegate <NSObject>
@required
- (void) dbReturnedArray:(NSArray*)theArray;
- (void) dbReturnedDictionary:(NSDictionary*)theDictionary;
- (void) dbReturnedNothing;
- (void) dbReturnedError:(NSString*)theMessage;
@end

@interface PSADatabaseManager : NSObject {
	// Opaque reference to the SQLite database.
	sqlite3 *database;
	id		delegate;
}

@property (nonatomic, assign) id <PSADatabaseManagerDelegate> delegate;

#pragma mark -
#pragma mark Helper Methods
#pragma mark -
// Time Zone help
- (NSTimeInterval)	getTimeIntervalForGMT:(NSDate*)date;
- (NSDate*)			getDateForTimeInterval:(NSTimeInterval)interval;
//
- (NSString*)		escapeSQLCharacters:(NSString*)theString;

#pragma mark -
#pragma mark Database Initialization
#pragma mark -
- (void)	closeDatabase;
- (void)	initializeDatabase;
- (void)	upgradeWithClientSortSetting;
- (void)	upgradeWithClientViewSetting;
- (void)	upgradeCreditSettingsToThreePointOne;
- (void)	upgradeCreditAddressToFourPointThree;

#pragma mark -
#pragma mark Clients
#pragma mark -
- (Client*)				getClientWithID:(NSInteger)theID;
- (void)				getClientsWithActiveFlag:(NSNumber*)active;
- (NSArray*)			getAllClientsUnthreadedExcludeNameColumns;
- (void)				insertClient:(Client*)client;
- (void)				removeClient:(NSInteger)key;
- (void)				updateClient:(Client*)client;

#pragma mark -
#pragma mark Company
#pragma mark -
- (Company*)	getCompany;
- (void)		updateCompany:(Company*)theCompany;

#pragma mark -
#pragma mark Email
#pragma mark -
- (Email*)	getEmailOfType:(PSAEmailType)type;
- (void)	updateEmail:(Email*)theEmail;

#pragma mark -
#pragma mark Product Type
#pragma mark -
- (NSArray*)	getProductTypes;
- (void)		insertProductType:(ProductType*)theType;
- (void)		removeProductType:(ProductType*)theType;
- (void)		updateProductType:(ProductType*)theType;

#pragma mark -
#pragma mark Products
#pragma mark -
- (void)			bulkUpdateProductTypeToDefaultFromType:(ProductType*)theType;
- (void)			getDictionaryOfProductsByTypeWithActiveFlag:(NSNumber*)active;
- (Product*)		getProductWithID:(NSInteger)theID;
- (void)			insertProduct:(Product*)theProduct;
- (void)			removeProduct:(Product*)theProduct;
- (void)			updateProduct:(Product*)theProduct;
// Adjustments
- (void)				deleteProductAdjustmentWithID:(NSInteger)theID;
- (void)				getProductAdjustmentsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (ProductAdjustment*)	getProductAdjustmentWithID:(NSInteger)theID;
- (void)				insertProductAdjustment:(ProductAdjustment*)theAdjustment;
- (void)				updateProductAdjustment:(ProductAdjustment*)theAdjustment;




#pragma mark -
#pragma mark Projects
#pragma mark -
// Select
- (NSMutableArray*)		getArrayOfInvoiceProductsForInvoice:(ProjectInvoice*)theInvoice;
- (NSMutableArray*)		getArrayOfInvoiceServicesForInvoice:(ProjectInvoice*)theInvoice;
- (NSArray*)		getArrayOfInvoicesForProject:(Project*)theProject;
- (void)			getArrayOfProjectsByType:(NSNumber*)type;
- (void)			getArrayOfProjectsForClient:(Client*)theClient;
- (NSMutableArray*)	getArrayOfProductsForProject:(Project*)theProject;
- (NSMutableArray*) getArrayOfServicesForProject:(Project*)theProject;
- (void)			getArrayOfUnpaidInvoicesByType:(NSNumber*)type;
- (void)			getInvoicesFromDate:(NSDate*)start toDate:(NSDate*)end;
- (ProjectInvoice*) getInvoiceWithPaymentID:(NSInteger)paymentID;
- (Project*)		getProjectWithID:(NSInteger)theID;
- (Project*)		getProjectWithInvoiceID:(NSInteger)invoiceID;
// Insert
- (void)	insertInvoice:(ProjectInvoice*)theInvoice;
- (void)	insertInvoiceProduct:(ProjectInvoiceItem*)theItem;
- (void)	insertInvoiceService:(ProjectInvoiceItem*)theItem;
- (void)	insertProject:(Project*)theProject;
- (void)	insertProjectProduct:(ProjectProduct*)theProduct;
- (void)	insertProjectService:(ProjectService*)theService;
// Update
- (void)	updateInvoice:(ProjectInvoice*)theInvoice;
- (void)	updateProject:(Project*)theProject;
- (void)	updateInvoiceTotal:(ProjectInvoice*)theInvoice;
- (void)	updateProjectTotal:(Project*)theProject;
- (void)	updateProjectTotalForID:(NSInteger)projectID amountToSubtract:(double)theAmount;
- (void)	updateProjectTotalForID:(NSInteger)projectID amountToAdd:(double)theAmount;
- (void)	updateProjectProduct:(ProjectProduct*)theProduct;
- (void)	updateProjectService:(ProjectService*)theService;
// Delete
- (void)	deleteProjectWithID:(NSInteger)projectID;
- (void)	deleteProjectInvoiceWithID:(NSInteger)invoiceID;
- (void)	deleteProjectInvoicePaymentFromCloseouts:(TransactionPayment*)thePayment;
- (void)	deleteProjectInvoiceProduct:(NSInteger)pipID;
- (void)	deleteProjectInvoiceService:(NSInteger)pisID;
- (void)	deleteProjectProductWithID:(NSInteger)projectProductID;
- (void)	deleteProjectServiceWithID:(NSInteger)projectServiceID;

- (void)	addTransactionID:(NSInteger)theTransaction toProjectID:(NSInteger)theProject;
- (void)	removeTransactionID:(NSInteger)theTransaction fromProjectID:(NSInteger)theProject;

#pragma mark -
#pragma mark Register
#pragma mark -
// Closeout
- (void)		getArrayOfCloseoutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)		getInvoiceIDsForCloseOut:(CloseOut*)theCloseOut;
- (void)		getInvoiceIDsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)		getInvoiceIDsForNextCloseOut;
- (NSArray*)	getInvoiceIDsUnthreadedForCloseOut:(CloseOut*)theCloseOut;
- (void)		getInvoicePaymentsForCloseOut:(CloseOut*)theCloseOut;
- (void)		getInvoicePaymentsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)		getInvoicePaymentsForNextCloseOut;
- (NSArray*)	getInvoicePaymentsUnthreadedForCloseOut:(CloseOut*)theCloseOut;
- (NSInteger)	insertDailyCloseout;
-(NSInteger)    getTodayCloseout:(NSDate*)today;
- (void)        AutoInsertTransactionsSinceLastCloseout:(NSDate*)date;
- (void)		insertCloseout:(NSInteger)closeoutID Transaction:(Transaction*)theTransaction;
- (void)		insertCloseout:(NSInteger)closeoutID InvoicePayment:(TransactionPayment*)thePayment;
- (void)		insertCloseout:(NSInteger)closeoutID InvoiceID:(NSNumber*)theInvoice;
// Gift Certificates
- (void)				deductAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID;
- (void)				refundAmount:(NSNumber*)amount fromCertificateID:(NSInteger)theID;
- (void)				deleteGiftCertificateWithID:(NSInteger)theID;
- (NSArray*)			getGiftCertificates;
- (GiftCertificate*)	getGiftCertificateWithID:(NSInteger)theID;
- (void)				insertGiftCertificate:(GiftCertificate*)theCert;
- (void)				updateGiftCertificate:(GiftCertificate*)theCert;
// Payment
- (void)		deleteTransactionPayment:(TransactionPayment*)thePayment;
- (NSMutableArray*)		getTransactionPaymentsForInvoice:(ProjectInvoice*)theInvoice;
- (NSArray*)			getTransactionPaymentsForTransaction:(Transaction*)theTransaction;
- (void)		insertTransactionPayment:(TransactionPayment*)thePayment forInvoiceID:(NSInteger)invoiceID;
- (void)		insertTransactionPayment:(TransactionPayment*)thePayment forTransactionID:(NSInteger)transID;
- (void)		updateTransactionPayment:(TransactionPayment*)thePayment;
- (void)		updateTransactionPaymentsRemovingCertificateID:(NSInteger)theID;

// Transactions
- (void)			deleteTransactionAndChildren:(Transaction*)theTransaction;
- (Transaction*)	getTransactionForAppointment:(Appointment*)theAppointment;
- (void)			getTransactionsFromDate:(NSDate*)start toDate:(NSDate*)end withStatus:(PSATransactionStatusType)status;
- (void)			getTransactionsForClient:(Client*)theClient;
- (NSMutableArray*)	getTransactionsForProject:(Project*)theProject;
- (void)			getTransactionsForCloseOut:(CloseOut*)theCloseOut;
- (void)			getTransactionsForCloseOutsFromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)			getTransactionProjectData:(Transaction*)theTransaction;
- (void)			getTransactionsSinceLastCloseoutWithStatus:(PSATransactionStatusType)status;
- (NSArray*)		getTransactionsUnthreadedForCloseOut:(CloseOut*)theCloseOut;
- (NSArray*)		getVoidedTransactions;
- (void)			insertTransaction:(Transaction*)theTransaction;
- (void)			updateTransaction:(Transaction*)theTransaction;
- (void)			updateTransactionTip:(Transaction*)theTransaction;

// Transaction Items
- (void)		deleteTransactionItem:(TransactionItem*)theItem;
- (NSArray*)	getTransactionItemsForTransaction:(Transaction*)theTransaction;
- (void)		insertTransactionItem:(TransactionItem*)theItem forTransactionID:(NSInteger)transactionID;
- (void)		updateTransactionItem:(TransactionItem*)theItem;

// Credit Cards
- (void)	getCreditCardPaymentForPayment:(TransactionPayment*)thePayment;
- (void)	getCreditCardPaymentsWithStatus:(PSACreditCardPaymentStatusType)status fromDate:(NSDate*)start toDate:(NSDate*)end;
- (void)	getCreditCardPaymentsUnclosedWithStatus:(PSACreditCardPaymentStatusType)status;
- (void)	insertCreditCardPayment:(CreditCardPayment*)thePayment;
- (void)	updateCreditCardPayment:(CreditCardPayment*)thePayment;

#pragma mark -
#pragma mark Schedule
#pragma mark -
// Getters
- (void)			getAppointmentsForClient:(Client*)theClient;
- (NSMutableArray*)	getAppointmentsForProject:(Project*)theProject;
- (void)			getAppointmentsThreadedForProject:(Project*)theProject;
- (void)			getAppointmentsFrom:(NSDate*)startDate to:(NSDate*)endDate;
// Setters
- (void)		deleteAppointment:(Appointment*)theAppointment deleteStanding:(BOOL)standing;
- (void)		deleteOrphanedStandingAppointments;
- (void)		deleteStandingAppointment:(Appointment*)theAppointment;
- (BOOL)		isFree:(Appointment*)theAppt;
- (void)		insertAppointment:(Appointment*)theAppt;
- (void)		insertStandingAppointment:(Appointment*)theAppt;
- (void)		updateAppointment:(Appointment*)theAppt;
- (void)		updateStandingAppointment:(Appointment*)theAppt;


#pragma mark -
#pragma mark Services
#pragma mark -
// ServiceGroup
- (NSArray*)	getServiceGroups;
- (void)		insertServiceGroup:(ServiceGroup*)theGroup;
- (void)		removeServiceGroup:(ServiceGroup*)theGroup;
- (void)		updateServiceGroup:(ServiceGroup*)theGroup;

// Service
- (void)			bulkUpdateServiceGroupToDefaultFromGroup:(ServiceGroup*)theGroup;
- (void)			getDictionaryOfServicesByGroupWithActiveFlag:(NSNumber*)active;
- (Service*)		getServiceWithID:(NSInteger)theID;
- (void)			insertService:(Service*)theService;
- (void)			removeService:(Service*)theService;
- (void)			updateService:(Service*)theService;


#pragma mark -
#pragma mark Settings
#pragma mark -
- (NSInteger)	getClientNameSortSetting;
- (void)		updateClientNameSortSetting:(NSInteger)sortOption;
- (NSInteger)	getClientNameViewSetting;
- (void)		updateClientNameViewSetting:(NSInteger)viewOption;

- (Settings*)	getSettings;
- (void)		updateSettings:(Settings*)settings;

- (void)		getCreditCardSettings:(CreditCardSettings*)theSettings;
- (void)		updateCreditCardSettings:(CreditCardSettings*)theSettings;

#pragma mark -
#pragma mark Vendors
#pragma mark -
- (NSArray*)	getVendors;
- (void)		insertVendor:(Vendor*)theVendor;
- (void)		removeVendor:(Vendor*)theVendor;
- (void)		updateVendor:(Vendor*)theVendor;



@end
