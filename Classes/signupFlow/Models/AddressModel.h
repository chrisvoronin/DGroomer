//
//  AddressModel.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/29/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressModel : NSObject

@property (nonatomic, copy) NSString * address;
@property (nonatomic, copy) NSString * address2;
@property (nonatomic, copy) NSString * city;
@property (nonatomic, copy) NSString * state;
@property (nonatomic, copy) NSString * zip;

-(id)initWithAddress:(NSString*)adr city:(NSString*)city state:(NSString*)state zip:(NSString*)zip;

-(id)initWithDictionary:(NSDictionary*)dict;

@end
