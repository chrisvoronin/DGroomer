//
//  Merchant.m
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/14/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "Merchant.h"

@implementation Merchant
-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.MerchantID = 987;
    }
    return self;
}
@end
