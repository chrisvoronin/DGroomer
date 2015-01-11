//
//  LoginResultModel.m
//  SmartSwipe
//
//  Created by Chris Voronin on 11/12/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "LoginResultModel.h"


@implementation LoginResultModel

-(id)initWithResponseDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        self.userID = [[dictionary objectForKey:@"UserID"] longValue];
        self.merchantKey = [[dictionary objectForKey:@"MerchantKey"] longValue];
        
        self.businessModel = [[BusinessInfo alloc] initWithDictionary:[dictionary objectForKey:@"BusinessModel"]];
        self.dateRead = [NSDate date];
        self.salesTax = [[dictionary objectForKey:@"SalesTax"] floatValue];
        
        self.itemCategories = [ItemCategory objectArrayFromJson:[dictionary objectForKey:@"ItemCategories"]];
        self.items = [Item objectArrayFromJson:[dictionary objectForKey:@"Items"]];
        self.itemModifierCategories = [ItemModifierCategory objectArrayFromJson:[dictionary objectForKey:@"ItemModifierCategories"]];
        self.itemModifiers = [ItemModifier objectArrayFromJson:[dictionary objectForKey:@"ItemModifiers"]];
        
        //TODO: self.printers;
    }
    return self;
}

-(id)initWithDummyData
{
    self = [super init];
    if (self)
    {
        self.userID = 1;
        self.merchantKey = 1;
        
        self.businessModel = [[BusinessInfo alloc] init];
        self.dateRead = [NSDate date];
        self.salesTax = 0.10;

        self.itemCategories = [NSMutableArray array];
        self.items = [NSMutableArray array];
        self.itemModifierCategories = [NSMutableArray array];
        self.itemModifiers = [NSMutableArray array];

        // business model
        self.businessModel.businessName = @"Loopnet";
        self.businessModel.photoURL = @"http://www.loopnet.com/images/logoHolidayFall.png";
        self.businessModel.addressModel = [[AddressModel alloc] initWithAddress:@"123 Main St" city:@"Glendora" state:@"CA" zip:@"91111"];
        self.businessModel.phone = @"(818)333-4444";
        self.businessModel.website = @"http://www.loopnet.com";
        self.businessModel.email = @"help@loopnet.com";
        self.businessModel.federalTaxID = @"";
        
        ItemCategory * all = [[ItemCategory alloc] initWithID:-1 andName:@"ALL"];
        ItemCategory * ic1 = [[ItemCategory alloc] initWithID:1 andName:@"First Cat"];
        ItemCategory * ic2 = [[ItemCategory alloc] initWithID:2 andName:@"Second Cat"];
        
        ItemModifierCategory * imc1 = [[ItemModifierCategory alloc] initWithID:1 andName:@"Mod 1 Cat"];
        ItemModifierCategory * imc2 = [[ItemModifierCategory alloc] initWithID:2 andName:@"Mod 2 Cat"];
        ItemModifierCategory * imc3 = [[ItemModifierCategory alloc] initWithID:3 andName:@"Mod 3 Cat"];
        
        ItemModifier * im1 = [[ItemModifier alloc] initWithID:1 modCatID:1 name:@"Mod1" price:1.0];
        ItemModifier * im2 = [[ItemModifier alloc] initWithID:2 modCatID:2 name:@"Mod2" price:1.1];
        ItemModifier * im3 = [[ItemModifier alloc] initWithID:3 modCatID:3 name:@"Mod3" price:1.2];
        ItemModifier * im4 = [[ItemModifier alloc] initWithID:4 modCatID:1 name:@"Mod4" price:1.3];
        ItemModifier * im5 = [[ItemModifier alloc] initWithID:5 modCatID:2 name:@"Mod5" price:1.4];
        ItemModifier * im6 = [[ItemModifier alloc] initWithID:6 modCatID:3 name:@"Mod6" price:1.5];
        ItemModifier * im7 = [[ItemModifier alloc] initWithID:7 modCatID:1 name:@"Mod7" price:1.6];
        
        Item * item1 = [[Item alloc] initWithID:1 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 1" price:0.0 priceType:PriceTypeEach modCatList:@[@1, @2, @3]];
        item1.itemShippingWeight = 10;
        item1.isTaxable = YES;
        Item * item2 = [[Item alloc] initWithID:2 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 2" price:1.0 priceType:PriceTypeEach modCatList:@[@1, @2]];
        item2.itemShippingWeight = 9;
        item2.isTaxable = YES;
        Item * item3 = [[Item alloc] initWithID:3 categoryID:2 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 3" price:2.0 priceType:PriceTypeEach modCatList:@[@1]];
        item3.itemShippingWeight = 8;
        item3.isTaxable = NO;
        Item * item4 = [[Item alloc] initWithID:4 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 4" price:3.0 priceType:PriceTypeEach modCatList:@[@1, @2, @3]];
        item4.itemShippingWeight = 7;
        Item * item5 = [[Item alloc] initWithID:5 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 5" price:4.0 priceType:PriceTypeEach modCatList:@[@1, @2]];
        item5.itemShippingWeight = 6;
        Item * item6 = [[Item alloc] initWithID:6 categoryID:2 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 6" price:5.0 priceType:PriceTypeEach modCatList:@[@1]];
        Item * item7 = [[Item alloc] initWithID:7 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 7" price:6.0 priceType:PriceTypeEach modCatList:@[@1, @2, @3]];
        Item * item8 = [[Item alloc] initWithID:8 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 8" price:7.0 priceType:PriceTypeEach modCatList:@[@1, @2]];
        
        
        [self.itemCategories addObject:all];
        [self.itemCategories addObject:ic1];
        [self.itemCategories addObject:ic2];
        
        [self.itemModifierCategories addObject:imc1];
        [self.itemModifierCategories addObject:imc2];
        [self.itemModifierCategories addObject:imc3];
        
        [self.itemModifiers addObject:im1];
        [self.itemModifiers addObject:im2];
        [self.itemModifiers addObject:im3];
        [self.itemModifiers addObject:im4];
        [self.itemModifiers addObject:im5];
        [self.itemModifiers addObject:im6];
        [self.itemModifiers addObject:im7];
        
        [self.items addObject:item1];
        [self.items addObject:item2];
        [self.items addObject:item3];
        [self.items addObject:item4];
        [self.items addObject:item5];
        [self.items addObject:item6];
        [self.items addObject:item7];
        [self.items addObject:item8];
        
        //TODO: self.printers;
    }
    return self;
}

@end
