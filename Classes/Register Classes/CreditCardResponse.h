//
//  CreditCardResponse.h
//  PSA
//
//  Created by David J. Maier on 5/11/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CreditCardResponse : NSObject {
	
	NSString	*authCode;
	NSString	*avsResultCode;
	NSString	*cvvResultCode;
	NSString	*refTransID;
	NSInteger	responseCode;
	NSString	*transHash;
	NSString	*transID;
	
	NSMutableDictionary	*errors;
	NSMutableDictionary	*messages;
}

@property (nonatomic, retain) NSString	*authCode;
@property (nonatomic, retain) NSString	*avsResultCode;
@property (nonatomic, retain) NSString	*cvvResultCode;
@property (nonatomic, retain) NSString	*refTransID;
@property (nonatomic, retain) NSString	*transHash;
@property (nonatomic, retain) NSString	*transID;

@property (nonatomic, assign) NSInteger	responseCode;

@property (nonatomic, retain) NSMutableDictionary	*errors;
@property (nonatomic, retain) NSMutableDictionary	*messages;



@end
