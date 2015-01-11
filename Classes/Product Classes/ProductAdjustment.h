//
//  ProductAdjustment.h
//  myBusiness
//
//  Created by David J. Maier on 1/12/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PSAProductAdjustmentType {
	PSAProductAdjustmentAdd,
	PSAProductAdjustmentProfessional,
	PSAProductAdjustmentRetail
} PSAProductAdjustmentType;

@interface ProductAdjustment : NSObject {
	NSInteger	productAdjustmentID;
	NSDate		*adjustmentDate;
	NSInteger	productID;
	NSInteger	quantity;
	PSAProductAdjustmentType	type;
	// For Product History, needs name
	NSString	*productName;
}

@property (nonatomic, assign) NSInteger	productAdjustmentID;
@property (nonatomic, retain) NSDate	*adjustmentDate;
@property (nonatomic, assign) NSInteger	productID;
@property (nonatomic, assign) NSInteger	quantity;
@property (nonatomic, assign) PSAProductAdjustmentType	type;

@property (nonatomic, retain) NSString	*productName;

- (NSString*) getStringForType;

@end
