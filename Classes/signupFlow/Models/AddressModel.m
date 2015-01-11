//
//  AddressModel.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/29/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "AddressModel.h"

@implementation AddressModel

-(id)initWithAddress:(NSString*)adr city:(NSString*)city state:(NSString*)state zip:(NSString*)zip
{
    self = [super init];
    if (self)
    {
        self.address = adr;
        self.city = city;
        self.state = state;
        self.zip = zip;
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.address = [dict objectForKey:@"Address"];
        self.city = [dict objectForKey:@"City"];
        self.state = [dict objectForKey:@"State"];
        self.zip = [dict objectForKey:@"Zip"];       
    }
    return self;
}

@end
