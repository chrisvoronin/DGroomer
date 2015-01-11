//
//  MerchantLogonModel.m
//  SmartSwipe
//
//  Created by Chris Voronin on 11/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "MerchantLogonModel.h"

@implementation MerchantLogonModel

-(id)initWithEmail:(NSString*)email password:(NSString*)password merchantKey:(long)merchantKey
{
    self = [super init];
    if (self)
    {
        self.email = email;
        self.password = password;
        self.merchantKey = merchantKey;
    }
    return self;
}

@end
