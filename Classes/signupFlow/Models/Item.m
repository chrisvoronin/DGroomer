//
//  Item.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "Item.h"

@implementation Item

-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.itemID = [[dict objectForKey:@"ItemID"] intValue];
        self.name = [dict objectForKey:@"Name"];
        self.color = [[dict objectForKey:@"Color"] intValue];
        self.barcode = [dict objectForKey:@"Barcode"];
        self.photoURL = [dict objectForKey:@"PhotoURL"];
        self.price = [[dict objectForKey:@"ItemCategoryID"] doubleValue];
        self.priceType = (PriceType)[[dict objectForKey:@"PriceType"] intValue];
        self.itemCategoryID = [[dict objectForKey:@"IsTaxable"] intValue];
        self.itemModiferCategories = [dict objectForKey:@"ItemModiferCategories"];
    }
    return self;
}

-(id)initWithID:(int)itemID categoryID:(int)itemCategoryID imageURL:(NSString*)imageUrl name:(NSString*)name price:(double)price priceType:(PriceType)priceType modCatList:(NSArray*)modCatIDList
{
    
    self = [super init];
    if (self)
    {
        self.itemID = itemID;
        self.itemCategoryID = itemCategoryID;
        self.photoURL = imageUrl;
        self.name = name;
        self.price = price;
        self.priceType = priceType;
        self.barcode = @"";
        self.itemModiferCategories = [NSMutableArray arrayWithArray: modCatIDList];
        self.isTaxable = NO;
        self.priceType = PriceTypeKiloGram;
        self.barcode = @"4012345678901";
        self.itemShippingWeight = 0;
    }
    return self;
}

+(NSMutableArray*)objectArrayFromJson:(NSArray *)arrayJson
{
    NSMutableArray * objectArray = [NSMutableArray array];
    for(int i = 0; i < arrayJson.count; i++)
    {
        Item * item = [[Item alloc] initWithDictionary:arrayJson[i]];
        [objectArray addObject:item];
    }
    return objectArray;
}

-(bool)isSoldByWeight
{
    return self.priceType != PriceTypeEach;
}
-(NSString*)priceTypeToString
{
    NSString * pts;
    switch (self.priceType) {
        case PriceTypeEach:
            pts = @"Count";
            break;
        case PriceTypePound:
            pts = @"Pounds";
            break;
        case PriceTypeOunce:
            pts = @"Ounces";
            break;
        case PriceTypeGram:
            pts = @"Grams";
            break;
        case PriceTypeKiloGram:
            pts = @"Kg";
            break;
        default:
            pts = @"";
            break;
    }
    return pts;
}
+(NSMutableArray *)getPriceTypeStringList
{
    return [[NSMutableArray alloc] initWithObjects:@"Count",@"Pounds",@"Ounces",@"Grams",@"Kg", nil];
}
@end
