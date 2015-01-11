//
//  PrincipalInfo.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/14/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrincipalInfo : NSObject
@property (nonatomic, assign) int MerchantID;
@property (nonatomic, copy) NSString *Address;
@property (nonatomic, copy) NSString *Address2;
@property (nonatomic, copy) NSString *City;
@property (nonatomic, copy) NSString *State;
@property (nonatomic, copy) NSString *Zip;
@property (nonatomic, copy) NSString *DOB;
@property (nonatomic, copy) NSString *SSN;

-(id)initWithDictionary:(NSDictionary*)dict;

@end
