//
//  Tax.h
//  myBusiness
//
//  Created by David J. Maier on 8/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tax : NSObject {
	NSInteger taxID;
	NSString *taxName;
	NSString *taxDescription;
	NSNumber *taxRate;
	NSInteger isPercentage;
	NSNumber *commissionRate;
}

@property (nonatomic, assign) NSInteger taxID;
@property (nonatomic, assign) NSString *taxName;
@property (nonatomic, assign) NSString *taxDescription;
@property (nonatomic, assign) NSNumber *taxRate;
@property (nonatomic, assign) NSInteger isPercentage;
@property (assign, nonatomic) NSNumber *commissionRate;


- (id)initWithTaxData:(NSInteger)key name:(NSString*)name desc:(NSString*)desc rate:(NSNumber*)rate pct:(NSInteger)pct comm:(NSNumber*)comm;

@end
