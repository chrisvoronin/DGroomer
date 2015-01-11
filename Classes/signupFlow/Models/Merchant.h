//
//  Merchant.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/14/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchant : NSObject
@property (nonatomic, assign) int MerchantID;
@property (nonatomic, copy) NSString *FirstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *BussinessName;
@property (nonatomic, copy) NSString *EMail;
@property (nonatomic, copy) NSString *PhoneNum;
@property (nonatomic, copy) NSString *Password;

-(id)initWithDictionary:(NSDictionary*)dict;
@end
