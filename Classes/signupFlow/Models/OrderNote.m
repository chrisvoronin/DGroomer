//
//  OrderNote.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "OrderNote.h"

@implementation OrderNote

-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.noteID = [[dict objectForKey:@"NoteID"] integerValue];
        self.orderID = [[dict objectForKey:@"OrderID"] integerValue];
        self.orderItemID = [[dict objectForKey:@"OrderItemID"] integerValue];
        self.text = [dict objectForKey:@"Text"];
    }
    return self;
}

@end
