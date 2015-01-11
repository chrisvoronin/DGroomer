//
//  CreditCardConnectionManager.h
//  myBusiness
//
//  Created by David J. Maier on 3/15/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import <Foundation/Foundation.h>

@class CreditCardPayment, CreditCardSettings;

typedef enum CreditCardProcessingStatus {
	CreditCardProcessingNotProcessed,
	CreditCardProcessingCancelled,
	CreditCardProcessingConnecting,
	CreditCardProcessingRequestSent,
	CreditCardProcessingResponseReceived,
	CreditCardProcessingParsingResponse,
	CreditCardProcessingApproved,
	CreditCardProcessingDeclined,
	CreditCardProcessingError,
	CreditCardProcessingRefunded,
	CreditCardProcessingVoided
} CreditCardProcessingStatus;

// Protocol Definition
@protocol CreditCardProcessingViewDelegate <NSObject>
@optional
- (void) processingDidChangeState;
@end

@interface CreditCardConnectionManager : NSObject <NSXMLParserDelegate> {
	//
	NSURLConnection		*theConnection;
	NSMutableData		*connData;
	// The Payment
	CreditCardPayment	*ccPayment;
	CreditCardSettings	*ccSettings;
	//
	id					delegate;
	//
	NSObject	*currentObject;
	NSString	*previousElement;
	//
	BOOL	refundFailed;
}

@property (nonatomic, retain) NSMutableData		*connData;
@property (nonatomic, assign) CreditCardPayment	*ccPayment;
@property (nonatomic, assign) id <CreditCardProcessingViewDelegate>	delegate;

- (void) cancel;
- (void) charge;
- (void) parseResponseDelimited:(NSData*)data;
- (void) refund;
- (void) voidTransaction;

@end
