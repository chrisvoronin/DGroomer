//
//  Service.h
//  myBusiness
//
//  Created by David J. Maier on 7/11/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Service : NSObject {
    // Attributes.
	NSInteger	serviceID;
	NSInteger	groupID;
	NSString	*serviceName;
	NSNumber	*servicePrice;
	NSNumber	*serviceCost;
	NSInteger	taxable;
	NSInteger	duration;
	BOOL		isActive;
	NSString	*groupName;
	UIColor		*color;
	BOOL		serviceIsFlatRate;
	NSNumber	*serviceSetupFee;
}

@property (nonatomic, retain) NSString	*groupName;
@property (nonatomic, retain) NSString	*serviceName;
@property (nonatomic, retain) NSNumber	*servicePrice;
@property (nonatomic, retain) NSNumber	*serviceCost;
@property (nonatomic, retain) UIColor	*color;
@property (nonatomic, retain) NSNumber	*serviceSetupFee;

@property (nonatomic, assign) BOOL		isActive;
@property (nonatomic, assign) BOOL		serviceIsFlatRate;
@property (assign, nonatomic) NSInteger	serviceID;
@property (assign, nonatomic) NSInteger	groupID;
@property (assign, nonatomic) NSInteger	taxable;
@property (assign, nonatomic) NSInteger	duration;

- (id) init;
- (id) initWithServiceData:(NSInteger)servID gID:(NSInteger)gID servName:(NSString*)servName price:(NSNumber*)p cost:(NSNumber*)c taxabe:(NSInteger)t duration:(NSInteger)s;

- (void) setColorWithString:(NSString*)colorString;


@end
