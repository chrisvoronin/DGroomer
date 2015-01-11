//
//  BusinessInfo.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "BusinessInfo.h"

@implementation BusinessInfo

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.businessName = [dict objectForKey:@"BusinessName"];
        self.photoURL = [dict objectForKey:@"PhotoURL"];
        self.addressModel = [[AddressModel alloc] initWithDictionary:[dict objectForKey:@"AddressModel"]];
        self.phone = [dict objectForKey:@"Phone"];
        self.website = [dict objectForKey:@"Website"];
        self.email = [dict objectForKey:@"Email"];
    }
    return self;
}

@end
