//
//  CreditCardSettings.h
//  PSA
//
//  Created by David J. Maier on 5/4/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeychainItemWrapper;

typedef enum CreditCardProcessingType {
	CreditCardProcessingTypeCardPresent,
	CreditCardProcessingTypeCardNotPresent
} CreditCardProcessingType;

@interface CreditCardSettings : NSObject {
	NSString	*apiLogin;
	CreditCardProcessingType processingType;
	BOOL		sendEmailFromGateway;
	NSString	*transactionKey;
	// Keychain Items
	KeychainItemWrapper	*apiWrapper;
	KeychainItemWrapper	*keyWrapper;
}

@property (nonatomic, retain) NSString	*apiLogin;
@property (nonatomic, assign) CreditCardProcessingType processingType;
@property (nonatomic, assign) BOOL		sendEmailFromGateway;
@property (nonatomic, retain) NSString	*transactionKey;

- (NSString*)	getGatewayURL;
- (id)			init;
- (void)		save;

@end
