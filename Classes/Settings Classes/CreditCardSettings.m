//
//  CreditCardSettings.m
//  PSA
//
//  Created by David J. Maier on 5/4/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "KeychainItemWrapper.h"
#import "PSADataManager.h"
#import "CreditCardSettings.h"

@implementation CreditCardSettings

@synthesize apiLogin, processingType, sendEmailFromGateway, transactionKey;

- (id) init {
	// Get values from keychain
	apiWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"API Login" accessGroup:nil];
	self.apiLogin = [apiWrapper objectForKey:(id)kSecValueData];
	
	keyWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Transaction Key" accessGroup:nil];
	self.transactionKey = [keyWrapper objectForKey:(id)kSecValueData];
	//
	return self;
}

- (void) dealloc {
	[apiWrapper release];
	[keyWrapper release];
	//
	[apiLogin release];
	[transactionKey release];
	[super dealloc];
}

/*
 *
 */
- (NSString*) getGatewayURL {	
	// Test Account
#ifdef DEBUG_LOGGING_ENABLED
	return @"https://test.authorize.net/gateway/transact.dll";
	// Var Dump
	//return @"https://developer.authorize.net/param_dump.asp";
#endif
	
	// Normal Operation (LIVE!)
	if( processingType == CreditCardProcessingTypeCardPresent ) {
		return @"https://cardpresent.authorize.net/gateway/transact.dll";
	} else {
		return @"https://secure.authorize.net/gateway/transact.dll";
	}
}

/*
 *
 */
- (void) save {
	// Save to Keychain
	if( ![[apiWrapper objectForKey:(id)kSecAttrAccount] isEqualToString:@"Authorize.Net"] && ![[apiWrapper objectForKey:(id)kSecAttrService] isEqualToString:@"API Login"] ) {
		[apiWrapper resetKeychainItem];
		[apiWrapper setObject:@"Authorize.Net" forKey:(id)kSecAttrAccount];
		[apiWrapper setObject:@"API Login" forKey:(id)kSecAttrService];
	}
	[apiWrapper setObject:apiLogin forKey:(id)kSecValueData];
	//[loginWrapper resetKeychainItem];
	
	if( ![[keyWrapper objectForKey:(id)kSecAttrAccount] isEqualToString:@"Authorize.Net"] && ![[keyWrapper objectForKey:(id)kSecAttrService] isEqualToString:@"Transaction Key"] ) {
		[keyWrapper resetKeychainItem];
		[keyWrapper setObject:@"Authorize.Net" forKey:(id)kSecAttrAccount];
		[keyWrapper setObject:@"Transaction Key" forKey:(id)kSecAttrService];
	}
	[keyWrapper setObject:transactionKey forKey:(id)kSecValueData];
	//[keyWrapper resetKeychainItem];

	// Save to DB
	[[PSADataManager sharedInstance] updateCreditCardSettings:self];
}

@end
