//
//  Company.h
//  myBusiness
//
//  Created by David J. Maier on 8/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject {
	NSInteger companyID;
	NSString *companyName;
	NSNumber *salesTax;
	NSString *companyAddress1;
	NSString *companyAddress2;
	NSString *companyCity;
	NSString *companyState;
	NSInteger companyZipCode;
	NSString *companyEmail;
	NSString *companyPhone;
	NSString *companyFax;
	NSInteger monthsOldAppointments;
	NSString *ownerName;
	NSNumber *commissionRate;
}

@property (nonatomic, assign) NSInteger companyID;
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSNumber *salesTax;
@property (nonatomic, retain) NSNumber *commissionRate;
@property (nonatomic, retain) NSString *companyAddress1;
@property (nonatomic, retain) NSString *companyAddress2;
@property (nonatomic, retain) NSString *companyCity;
@property (nonatomic, retain) NSString *companyState;
@property (nonatomic, retain) NSString *ownerName;
@property (nonatomic, retain) NSString *companyEmail;
@property (nonatomic, retain) NSString *companyPhone;
@property (nonatomic, retain) NSString *companyFax;
@property (nonatomic, assign) NSInteger companyZipCode;
@property (nonatomic, assign) NSInteger monthsOldAppointments;



- (id)initWithCompanyData:(NSInteger)key name:(NSString*)compName tax:(NSNumber*)tax addr1:(NSString*)addr1 addr2:(NSString*)addr2 city:(NSString*)city state:(NSString*)state zip:(NSInteger)zip email:(NSString*)email phone:(NSString*)phone fax:(NSString*)fax appts:(NSInteger)appts owner:(NSString*)owner commissionRate:(NSNumber*)commission;

- (NSString*) getMutlilineHTMLString;

@end
