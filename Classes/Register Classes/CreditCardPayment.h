//
//  CreditCardPayment.h
//  PSA
//
//  Created by David J. Maier on 5/3/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "CreditCardConnectionManager.h"
#import <Foundation/Foundation.h>

@class Client, CreditCardResponse;

@interface CreditCardPayment : NSObject {
	
	CreditCardConnectionManager *conn;
	
	NSInteger	ccPaymentID;
	Client		*client;
	NSString	*nameFirst;
	NSString	*nameMiddle;
	NSString	*nameLast;
	NSString	*clientEmail;
	NSString	*clientPhone;
	NSString	*notes;
	NSString	*addressStreet;
	NSString	*addressCity;
	NSString	*addressState;
	NSString	*addressZip;
	
	NSString	*ccCVV;
	NSString	*ccExpirationMonth;
	NSString	*ccExpirationYear;
	NSString	*ccNumber;
	
	NSNumber	*amount;
	NSNumber	*tip;
	
	NSDate		*date;
	CreditCardResponse	*response;
	
	// Need stuff for errors...
	CreditCardProcessingStatus	milestoneStatus;	// Approved, Refunded, Voided ONLY
	CreditCardProcessingStatus	status;
}

@property (nonatomic, assign) NSInteger	ccPaymentID;
@property (nonatomic, retain) Client	*client;
@property (nonatomic, retain) NSString	*clientEmail;
@property (nonatomic, retain) NSString	*clientPhone;
@property (nonatomic, retain) NSString	*nameFirst;
@property (nonatomic, retain) NSString	*nameMiddle;
@property (nonatomic, retain) NSString	*nameLast;
@property (nonatomic, retain) NSString	*notes;
@property (nonatomic, retain) NSString	*addressStreet;
@property (nonatomic, retain) NSString	*addressCity;
@property (nonatomic, retain) NSString	*addressState;
@property (nonatomic, retain) NSString	*addressZip;

@property (nonatomic, retain) NSString	*ccCVV;
@property (nonatomic, retain) NSString	*ccExpirationMonth;
@property (nonatomic, retain) NSString	*ccExpirationYear;
@property (nonatomic, retain) NSString	*ccNumber;
@property (nonatomic, retain) NSNumber	*amount;
@property (nonatomic, retain) NSNumber	*tip;

@property (nonatomic, retain) NSDate	*date;
@property (nonatomic, retain) CreditCardResponse	*response;

@property (nonatomic, assign) CreditCardProcessingStatus milestoneStatus;
@property (nonatomic, assign) CreditCardProcessingStatus status;

// Credit Card Processing
- (void)		cancel;
- (void)		chargeWithDelegate:(id)theDelegate;
- (void)		extractDataFromClientContact;
- (NSString*)	getCityStateZip;
- (NSString*)	getName;
- (void)		refundWithDelegate:(id)theDelegate;
- (void)		resetStatus;
- (void)		voidWithDelegate:(id)theDelegate;

@end
