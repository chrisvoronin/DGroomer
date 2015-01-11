//
//  Item.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PriceType : int {
    PriceTypeEach = 0,
    PriceTypePound = 1,
    PriceTypeOunce = 2,
    PriceTypeGram = 3,
    PriceTypeKiloGram = 4
} PriceType;

@interface Item : NSObject


@property (nonatomic, assign) int itemID;
@property (nonatomic, assign) int itemCategoryID;
@property (nonatomic, assign) double itemShippingWeight;
@property (nonatomic, copy) NSString *photoURL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *barcode;
@property (nonatomic, assign) int color;

@property (nonatomic, assign) double price;
@property (nonatomic, assign) PriceType priceType;
@property (nonatomic, assign) bool isTaxable;
@property (nonatomic, assign) bool isActive;
@property (nonatomic, copy) NSDate * createdDate;

@property (nonatomic, strong) NSMutableArray * itemModiferCategories;


// internal variables
-(bool)isSoldByWeight;

-(id)initWithDictionary:(NSDictionary*)dict;

-(id)initWithID:(int)itemID categoryID:(int)itemCategoryID imageURL:(NSString*)imageUrl name:(NSString*)name price:(double)price priceType:(PriceType)priceType modCatList:(NSArray*)modCatIDList;

+(NSMutableArray*)objectArrayFromJson:(NSArray*)arrayJson;

-(NSString*)priceTypeToString;
+(NSMutableArray *)getPriceTypeStringList;

@end
