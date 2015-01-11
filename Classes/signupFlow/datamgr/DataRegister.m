//
//  DataRegister.m
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/16/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "DataRegister.h"

@implementation DataRegister
static DataRegister * _register;

+(NSString*)getStringFrom:(double)value
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [f stringFromNumber:[NSNumber numberWithDouble:value]];
}
+(NSString*)getPercentStringFrom:(double)value
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [NSString stringWithFormat:@"%@%%",[f stringFromNumber:[NSNumber numberWithDouble:value]]];

}
+(NSString*)getDollarStringFrom:(double)value
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [NSString stringWithFormat:@"$%@",[f stringFromNumber:[NSNumber numberWithDouble:value]]];

}
- (id)init
{
    self = [super init];
    if(self){
        self.m_hasSignture = YES;
        self.m_hasTip = YES;
    }
    return self;
}
+(id)instance
{
    if(!_register){
        _register = [[DataRegister alloc] init];
        
        _register.loginOrderItem = [[Order new] retain];
        _register.loginOrderItem.orderItems = [[NSMutableArray new] retain];
        _register.loginOrderItem.orderNotes = [[NSMutableArray new] retain];
        _register.loginTransaction = [[Transaction new] retain];
        _register.loginMerchant = [[Merchant new] retain];
        _register.loginBussinessInfo = [[BusinessInfo new] retain];
        _register.loginBussinessInfo.addressModel = [[AddressModel new] retain];
        _register.loginPrincipalInfo = [[PrincipalInfo new] retain];
        _register.loginBankInfo = [[BankInfo new] retain];
        _register.m_historyArray = [[NSMutableArray new] retain];
    }
    return _register;
}
///
- (void)setLoginResult:(LoginResultModel *)loginResultModel
{
    _register.loginResultModel = [loginResultModel retain];
}
- (Order*)getOrder
{
    return self.loginOrderItem;
}
- (Transaction*)getTransactionItem;
{
    return self.loginTransaction;
}
- (Merchant*)getMerchantItem
{
    return self.loginMerchant;
}
- (BusinessInfo*)getBussinessItem
{
    return self.loginBussinessInfo;
}
- (PrincipalInfo*)getPrincipalItem
{
    return self.loginPrincipalInfo;
}
- (BankInfo*)getBankItem
{
    return self.loginBankInfo;
}
- (NSMutableArray *)getHistoryArray
{
    return self.m_historyArray;
}
///
- (int)generateMiscItemId
{
    int defaultID = -1;
    while (defaultID) {
        BOOL res = NO;
        for(Item * subItem in self.loginResultModel.items){
            if(subItem.itemID == defaultID){
                res = YES;
                break;
            }
        }
        if(!res)
            return defaultID;
        defaultID--;
    }
    return defaultID;
}
- (int)generateModifyCategoryId
{
    int defaultID = -1;
    while (defaultID) {
        BOOL res = NO;
        for(ItemModifierCategory * subItem in self.loginResultModel.itemModifierCategories){
            if(subItem.modifierCategoryID == defaultID){
                res = YES;
                break;
            }
        }
        if(!res)
            return defaultID;
        defaultID--;
    }
    return defaultID;
}
- (int)generateModiferId
{
    int defaultID = -1;
    while (defaultID) {
        BOOL res = NO;
        for(ItemModifier * subItem in self.loginResultModel.itemModifiers){
            if(subItem.modifierID == defaultID){
                res = YES;
                break;
            }
        }
        if(!res)
            return defaultID;
        defaultID--;
    }
    return defaultID;
}
- (int)generateItemCategoryId
{
    int defaultID = -1;
    while (defaultID) {
        BOOL res = NO;
        for(ItemCategory * subItem in self.loginResultModel.itemCategories){
            if(subItem.categoryID == defaultID){
                res = YES;
                break;
            }
        }
        if(!res)
            return defaultID;
        defaultID--;
    }
    return defaultID;
}
- (int)generateNewOrderItemId
{
    int defaultID = -1;
    while (defaultID) {
        BOOL res = NO;
        for(OrderItem * subItem in self.loginOrderItem.orderItems){
            if(subItem.orderItemID == defaultID){
                res = YES;
                break;
            }
        }
        if(!res)
            return defaultID;
        defaultID--;
    }
    return defaultID;
}
- (OrderItem*)getOrderItemFrom:(Item*)item
{
    for(OrderItem * subItem in self.loginOrderItem.orderItems){
        if(subItem.item.itemID == item.itemID)
            return subItem;
    }
    return nil;
}
//
- (NSMutableArray *)getItemCategoryList
{
    return self.loginResultModel.itemCategories;
}
- (NSMutableArray *)getModifierCategoryList
{
    return self.loginResultModel.itemModifierCategories;
}
- (NSMutableArray *)getToTalItemList:(int)categoryId;
{
    if(categoryId == -1)
        return self.loginResultModel.items;
    NSMutableArray * m_tmpArray = [NSMutableArray new];
    for(Item * subItem in self.loginResultModel.items){
        if(subItem.itemCategoryID == categoryId){
            [m_tmpArray addObject:subItem];
        }
    }
    return m_tmpArray;
}
- (ItemCategory*)AddItemCategory:(NSString*)name
{
    ItemCategory * item = [ItemCategory new];
    item.categoryID = [self generateItemCategoryId];
    item.categoryName = name;
    [self.loginResultModel.itemCategories addObject:item];
    return item;
}
- (Item*)AddMiscItem:(Item*)miscitem
{
    miscitem.itemID = [self generateMiscItemId];
    [self.loginResultModel.items addObject:miscitem];
    return miscitem;
}
- (ItemModifierCategory*)AddModifyCategory:(NSString*)name
{
    ItemModifierCategory * item = [ItemModifierCategory new];
    item.modifierCategoryID = [self generateModifyCategoryId];
    item.modifierCategoryName = name;
    [self.loginResultModel.itemModifierCategories addObject:item];
    return item;
}
- (ItemModifier*)AddModifier:(ItemModifier*)item
{
    item.modifierID = [self generateModiferId];
    [self.loginResultModel.itemModifiers addObject:item];
    return item;
}

- (ItemModifierCategory*)getItemModifierCategory:(int)itemModfierCategoryId;
{
    for(ItemModifierCategory* item in self.loginResultModel.itemModifierCategories){
        if(item.modifierCategoryID == itemModfierCategoryId)
            return item;
    }
    return nil;
}
- (NSMutableArray *)getItemModifierAtModifierCategoryId:(int)mcId
{
    NSMutableArray * itemList = [NSMutableArray new];
    for(ItemModifier * item in self.loginResultModel.itemModifiers){
        if(item.modifierCategoryID == mcId)
            [itemList addObject:item];
    }
    return itemList;
}
- (OrderItem*)AddNewOrderItem:(Item*)item
{
    OrderItem * orderItem = [self getOrderItemFrom:item];
    if(orderItem)
        return orderItem;
    orderItem = [[OrderItem alloc] initWithItem:item quantity:0];
    orderItem.orderItemID = [self generateNewOrderItemId];
    [self.loginOrderItem.orderItems addObject:orderItem];
    return orderItem;
}
- (Order*)getOrderInfo
{
    return self.loginOrderItem;
}
////action
-(void)ItemSort:(int)reftOption :(int)right
{
    if(reftOption == 0)/// alphabetic
    {
        NSSortDescriptor * sortDes = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:!right];
        [self.loginResultModel.items sortUsingDescriptors:[NSArray arrayWithObject:sortDes]];
    }else if(reftOption == 1)//price
    {
        if(right == 0){
            [self.loginResultModel.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                Item * d1 = obj1;
                Item * d2 = obj2;
                if(d1.price > d2.price)
                    return 1;
                else
                    return -1;
            }];
        }else{
            [self.loginResultModel.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                Item * d1 = obj1;
                Item * d2 = obj2;
                if(d1.price > d2.price)
                    return -1;
                else
                    return 1;
            }];

        }
    }else if(reftOption ==2)//popular
    {
        if(right == 0){
            [self.loginResultModel.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                Item * d1 = obj1;
                Item * d2 = obj2;
                if(d1.itemID > d2.itemID)
                    return 1;
                else
                    return -1;
            }];
        }else{
            [self.loginResultModel.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                Item * d1 = obj1;
                Item * d2 = obj2;
                if(d1.itemID > d2.itemID)
                    return -1;
                else
                    return 1;
            }];
            
        }
    }else if(reftOption == 3)//date added
    {
        if(right == 0){
            [self.loginResultModel.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                Item * d1 = obj1;
                Item * d2 = obj2;
                if([d1.createdDate timeIntervalSinceNow] > [d2.createdDate timeIntervalSinceNow])
                    return 1;
                else
                    return -1;
            }];
        }else{
            [self.loginResultModel.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                Item * d1 = obj1;
                Item * d2 = obj2;
                if([d1.createdDate timeIntervalSinceNow] > [d2.createdDate timeIntervalSinceNow])
                    return -1;
                else
                    return 1;
            }];
            
        }
    }
}
- (void)removeItemValue:(Item*)item
{
    [self.loginResultModel.items removeObject:item];
}
- (void)removeItemModifierCategoryItem:(ItemModifierCategory*)item
{
    [self.loginResultModel.itemModifierCategories removeObject:item];
}
- (void)removeItemModifierItem:(ItemModifier*)item
{
    [self.loginResultModel.itemModifiers removeObject:item];
}
- (void)removeItemCategoryItem:(ItemCategory*)item
{
    [self.loginResultModel.itemCategories removeObject:item];
}
@end
