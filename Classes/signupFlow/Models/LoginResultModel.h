//
//  LoginResultModel.h
//  SmartSwipe
//
//  Created by Chris Voronin on 11/12/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusinessInfo.h"
#import "MerchantLogonModel.h"
#import "ItemCategory.h"
#import "Item.h"
#import "ItemModifier.h"
#import "ItemModifierCategory.h"


@interface LoginResultModel : NSObject

@property (nonatomic, assign) long merchantKey;
@property (nonatomic, assign) long userID;
@property (nonatomic, strong) BusinessInfo * businessModel;
@property (nonatomic, strong) NSMutableArray * itemCategories;
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, strong) NSMutableArray * itemModifierCategories;
@property (nonatomic, strong) NSMutableArray * itemModifiers;
@property (nonatomic, strong) NSDate * dateRead;
@property (nonatomic, assign) float salesTax;
@property (nonatomic, strong) NSMutableArray * printers;

-(id)initWithResponseDictionary:(NSDictionary*)dictionary;

-(id)initWithDummyData;

@end
