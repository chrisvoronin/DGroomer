//
//  ItemModifier.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ItemModifier.h"

@implementation ItemModifier

-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.modifierCategoryID = [[dict objectForKey:@"ModifierCategoryID"] integerValue];
        self.modifierID = [[dict objectForKey:@"ModifierID"] integerValue];
        self.modifierName = [dict objectForKey:@"ModifierName"];
        self.modifierPrice = [[dict objectForKey:@"ModifierPrice"] doubleValue];
    }
    return self;
}

-(id)initWithID:(int)modifierID modCatID:(int)modifierCategoryID name:(NSString*)modifierName price:(double)modifierPrice
{
    self = [super init];
    if (self)
    {
        self.modifierCategoryID = modifierCategoryID;
        self.modifierID = modifierID;
        self.modifierName = modifierName;
        self.modifierPrice = modifierPrice;
    }
    return self;
}

+(NSMutableArray*)objectArrayFromJson:(NSArray *)arrayJson
{
    NSMutableArray * objectArray = [NSMutableArray array];
    for(int i = 0; i < arrayJson.count; i++)
    {
        ItemModifier * mod = [[ItemModifier alloc] initWithDictionary:arrayJson[i]];
        [objectArray addObject:mod];
    }
    return objectArray;
}

@end
