//
//  ProjectService.m
//  myBusiness
//
//  Created by David J. Maier on 3/23/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "ProjectService.h"


@implementation ProjectService

@synthesize cost, discountAmount, price, setupFee;
@synthesize isFlatRate, isPercentDiscount, isTimed, projectID, projectServiceID, secondsEstimated, secondsWorked, taxed;
@synthesize dateTimerStarted, isTiming;

- (id) init {
	cost = nil;
	discountAmount = nil;
	price = nil;
	setupFee = nil;
	isFlatRate = YES;
	isPercentDiscount = YES;
	isTimed = NO;
	projectID = -1;
	projectServiceID = -1;
	secondsEstimated = 0;
	secondsWorked = 0;
	taxed = YES;
	dateTimerStarted = nil;
	isTiming = NO;
	return self;
}

- (id) initWithService:(Service*)theService {
	self = [self init];
	self.serviceID = theService.serviceID;
	self.groupID = theService.groupID;
	self.serviceName = theService.serviceName;
	self.servicePrice = theService.servicePrice;
	self.cost = theService.serviceCost;
	self.taxable = theService.taxable;
	self.duration = theService.duration;
	self.isActive = theService.isActive;
	self.groupName = theService.groupName;
	self.color = theService.color;
	self.serviceIsFlatRate = theService.serviceIsFlatRate;
	self.serviceSetupFee = theService.serviceSetupFee;
	return self;
}

- (void) dealloc {
	[cost release];
	[dateTimerStarted release];
	[discountAmount release];
	[price release];
	[setupFee release];
	[super dealloc];
}

/*
 *	No need to release the returned...
 */
- (NSNumber*) getDiscountAmount {
	if( isPercentDiscount ) {
		double disc = [price doubleValue]*([discountAmount doubleValue]/100);
		double discSetup = [setupFee doubleValue]*([discountAmount doubleValue]/100);
		if( !isFlatRate ) {
			return [NSNumber numberWithDouble:disc*((double)secondsWorked/3600)+discSetup];
		} else {
			return [NSNumber numberWithDouble:disc+discSetup];
		}
	} else {
		return discountAmount;
	}
	return [NSNumber numberWithInt:0];
}

/*
 *	No need to release the returned...
 */
- (NSNumber*) getEstimateDiscountAmount {
	if( isPercentDiscount ) {
		double disc = [price doubleValue]*([discountAmount doubleValue]/100);
		double discSetup = [setupFee doubleValue]*([discountAmount doubleValue]/100);
		if( !isFlatRate ) {
			return [NSNumber numberWithDouble:disc*((double)secondsEstimated/3600)+discSetup];
		} else {
			return [NSNumber numberWithDouble:disc+discSetup];
		}
	} else {
		return discountAmount;
	}
	return [NSNumber numberWithInt:0];
}

/*
 *	Total before discounts and tax.
 *	No need to release the returned...
 */
- (NSNumber*) getEstimateSubTotal {
	if( !isFlatRate ) {
		return [NSNumber numberWithDouble:[price doubleValue]*((double)secondsEstimated/3600)+[setupFee doubleValue]];
	} else {
		return [NSNumber numberWithDouble:[price doubleValue]+[setupFee doubleValue]];
	}
}

/*
 *	Total before discounts and tax.
 *	No need to release the returned...
 */
- (NSNumber*) getSubTotal {
	if( !isFlatRate ) {
		return [NSNumber numberWithDouble:[price doubleValue]*((double)secondsWorked/3600)+[setupFee doubleValue]];
	} else {
		return [NSNumber numberWithDouble:[price doubleValue]+[setupFee doubleValue]];
	}
}

/*
 *	Certificates are not taxed.
 */
- (NSNumber*) getTaxableEstimateAmount {
	double tax = 0;
	if( taxed ) {
		if( !isFlatRate ) {
			tax += ([price doubleValue]*((double)secondsEstimated/3600))+[setupFee doubleValue];
		} else {
			tax += [price doubleValue]+[setupFee doubleValue];
		}
	}
	if( tax > 0 ) {
		return [NSNumber numberWithDouble:(tax-[[self getEstimateDiscountAmount] doubleValue])];
	}
	return [NSNumber numberWithInt:0];
}

/*
 *	Certificates are not taxed.
 */
- (NSNumber*) getTaxableAmount {
	double tax = 0;
	if( taxed ) {
		if( !isFlatRate ) {
			tax += ([price doubleValue]*((double)secondsWorked/3600))+[setupFee doubleValue];
		} else {
			tax += [price doubleValue]+[setupFee doubleValue];
		}
	}
	if( tax > 0 ) {
		return [NSNumber numberWithDouble:(tax-[[self getDiscountAmount] doubleValue])];
	}
	return [NSNumber numberWithInt:0];
}

#pragma mark -
#pragma mark Timing
#pragma mark -

- (NSInteger) getSecondsWorkedForTimer {
	if( isTimed ) {
		return (secondsWorked + (NSInteger)round([dateTimerStarted timeIntervalSinceNow]*-1));
	} else {
		return secondsWorked;
	}
	return 0;
}

- (void) resetTimer {
	if( isTiming ) {
		// Stop Timing
		isTiming = NO;
		self.dateTimerStarted = nil;
	}
	secondsWorked = 0;
	// (Handled in the ProjectServiceTimerViewController -- Save ProjectService
	//[[PSADataManager sharedInstance] saveProjectService:self];
}

- (void) startTiming {
	self.dateTimerStarted = [NSDate date];
	isTiming = YES;
	// (Handled in the ProjectServiceTimerViewController -- Save ProjectService
	//[[PSADataManager sharedInstance] saveProjectService:self];
}

- (void) stopTiming {
	secondsWorked += (NSInteger)round([dateTimerStarted timeIntervalSinceNow]*-1);
	isTiming = NO;
	self.dateTimerStarted = nil;
	// (Handled in the ProjectServiceTimerViewController -- Save ProjectService
	//[[PSADataManager sharedInstance] saveProjectService:self];
}


@end
