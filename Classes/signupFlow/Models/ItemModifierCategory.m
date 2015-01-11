//
//  ItemModifierCategory.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/20/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ItemModifierCategory.h"

@implementation ItemModifierCategory

-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.modifierCategoryID = [[dict objectForKey:@"ModifierCategoryID"] integerValue];
        self.modifierCategoryName = [dict objectForKey:@"ModifierCategoryName"];
    }
    return self;
}

-(id)initWithID:(int)modifierCategoryID andName:(NSString*)modifierCategoryName
{
    self = [super init];
    if (self)
    {
        self.modifierCategoryID = modifierCategoryID;
        self.modifierCategoryName = modifierCategoryName;
    }
    return self;
}

+(NSMutableArray*)objectArrayFromJson:(NSArray *)arrayJson
{
    NSMutableArray * objectArray = [NSMutableArray array];
    for(int i = 0; i < arrayJson.count; i++)
    {
        ItemModifierCategory * mod = [[ItemModifierCategory alloc] initWithDictionary:arrayJson[i]];
        [objectArray addObject:mod];
    }
    return objectArray;
}

@end
