//
//  User.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/14/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, assign) int UserID;
@property (nonatomic, assign) int MerchantID;
@property (nonatomic, copy) NSString *Email;
@property (nonatomic, copy) NSString *Password;

-(id)initWithDictionary:(NSDictionary*)dict;

@end
