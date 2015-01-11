//
//  ProductType.h
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductType : NSObject {
	NSString *typeDescription;
	NSInteger typeID;
}

@property (nonatomic, retain) NSString *typeDescription;
@property (nonatomic, assign) NSInteger typeID;

- (id)	init;
- (id)	initWithTypeData:(NSString *)tp key:(NSInteger)key;

@end
