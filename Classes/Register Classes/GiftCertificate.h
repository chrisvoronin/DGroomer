//
//  GiftCertificate.h
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Client;

@interface GiftCertificate : NSObject {
	NSInteger	certificateID;
	NSNumber	*amountPurchased;
	NSNumber	*amountUsed;
	NSDate		*expiration;
	NSString	*message;
	NSString	*notes;
	NSDate		*purchaseDate;
	Client		*purchaser;
	NSString	*recipientFirst;
	NSString	*recipientLast;
}

@property (nonatomic, assign) NSInteger	certificateID;
@property (nonatomic, retain) NSNumber	*amountPurchased;
@property (nonatomic, retain) NSNumber	*amountUsed;
@property (nonatomic, retain) NSDate	*expiration;
@property (nonatomic, retain) NSString	*message;
@property (nonatomic, retain) NSString	*notes;
@property (nonatomic, retain) NSDate	*purchaseDate;
@property (nonatomic, retain) Client	*purchaser;
@property (nonatomic, retain) NSString	*recipientFirst;
@property (nonatomic, retain) NSString	*recipientLast;

@end
