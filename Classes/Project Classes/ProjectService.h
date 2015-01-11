//
//  ProjectService.h
//  myBusiness
//
//  Created by David J. Maier on 3/23/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Service.h"
#import <Foundation/Foundation.h>


@interface ProjectService : Service {
	NSInteger	projectServiceID;
	NSInteger	projectID;
	NSNumber	*cost;
	NSNumber	*price;
	NSNumber	*setupFee;
	NSInteger	secondsEstimated;
	NSInteger	secondsWorked;
	NSNumber	*discountAmount;
	BOOL		isFlatRate;
	BOOL		isPercentDiscount;
	BOOL		isTimed;
	BOOL		taxed;
	// Timer
	NSDate		*dateTimerStarted;
	BOOL		isTiming;
}

@property (nonatomic, retain) NSNumber	*cost;
@property (nonatomic, retain) NSNumber	*discountAmount;
@property (nonatomic, retain) NSNumber	*price;
@property (nonatomic, retain) NSNumber	*setupFee;

@property (nonatomic, assign) NSInteger	projectID;
@property (nonatomic, assign) NSInteger	projectServiceID;
@property (nonatomic, assign) NSInteger	secondsEstimated;
@property (nonatomic, assign) NSInteger	secondsWorked;
@property (nonatomic, assign) BOOL		isFlatRate;
@property (nonatomic, assign) BOOL		isPercentDiscount;
@property (nonatomic, assign) BOOL		isTimed;
@property (nonatomic, assign) BOOL		taxed;

@property (nonatomic, retain) NSDate	*dateTimerStarted;
@property (nonatomic, assign) BOOL		isTiming;

- (id) init;
- (id) initWithService:(Service*)theService;

- (NSNumber*) getDiscountAmount;
- (NSNumber*) getEstimateDiscountAmount;
- (NSNumber*) getEstimateSubTotal;
- (NSInteger) getSecondsWorkedForTimer;
- (NSNumber*) getSubTotal;
- (NSNumber*) getTaxableAmount;
- (NSNumber*) getTaxableEstimateAmount;

- (void) resetTimer;
- (void) startTiming;
- (void) stopTiming;

@end
