//
//  BusinessInfo.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressModel.h"

@interface BusinessInfo : NSObject

@property (nonatomic, copy) NSString * businessName;
@property (nonatomic, copy) NSString * photoURL;
@property (nonatomic, strong) AddressModel * addressModel;
@property (nonatomic, copy) NSString * phone;
@property (nonatomic, copy) NSString * website;
@property (nonatomic, copy) NSString * email;
@property (nonatomic, copy) NSString * federalTaxID;

-(id)initWithDictionary:(NSDictionary*)dict;

@end
