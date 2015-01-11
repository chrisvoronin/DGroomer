//
//  MerchantLogonModel.h
//  SmartSwipe
//
//  Created by Chris Voronin on 11/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MerchantLogonModel : NSObject

@property (nonatomic, copy) NSString * email;
@property (nonatomic, copy) NSString * password;
@property (nonatomic, assign) long merchantKey;

-(id)initWithEmail:(NSString*)email password:(NSString*)password merchantKey:(long)merchantKey;

@end
