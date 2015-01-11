//
//  ItemCategory.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ItemCategory.h"

@implementation ItemCategory

-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.categoryID = [[dict objectForKey:@"CategoryID"] integerValue];
        self.categoryName = [dict objectForKey:@"CategoryName"];
    }
    return self;
}

-(id)initWithID:(int)categoryID andName:(NSString*)categoryName
{
    self = [super init];
    if (self)
    {
        self.categoryID = categoryID;
        self.categoryName = categoryName;
    }
    return self;
}

+(NSMutableArray*)objectArrayFromJson:(NSArray *)arrayJson
{
    NSMutableArray * objectArray = [NSMutableArray array];
    for(int i = 0; i < arrayJson.count; i++)
    {
        ItemCategory * cat = [[ItemCategory alloc] initWithDictionary:arrayJson[i]];
        [objectArray addObject:cat];
    }
    return objectArray;
}

@end
