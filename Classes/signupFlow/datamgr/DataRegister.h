//
//  DataRegister.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/16/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginResultModel.h"
#import "Order.h"
#import "Transaction.h"
#import "Merchant.h"
#import "BusinessInfo.h"
#import "PrincipalInfo.h"
#import "BankInfo.h"
#import "HistoryDetailModel.h"
#import "ErrorXmlParser.h"
#import "ResponseXmlParser.h"

@interface DataRegister : NSObject
@property (strong, nonatomic) LoginResultModel * loginResultModel;
@property (strong, nonatomic) Order            * loginOrderItem;
@property (strong, nonatomic) Transaction      * loginTransaction;
@property (strong, nonatomic) Merchant          * loginMerchant;
@property (strong, nonatomic) BusinessInfo      * loginBussinessInfo;
@property (strong, nonatomic) PrincipalInfo     * loginPrincipalInfo;
@property (strong, nonatomic) BankInfo          * loginBankInfo;
@property (strong, nonatomic) NSMutableArray    * m_historyArray;

@property (nonatomic, assign) BOOL          m_hasTip;
@property (nonatomic, assign) BOOL          m_hasSignture;


+(id)instance;

/// get items functions
- (OrderItem*)AddNewOrderItem:(Item*)item;
- (ItemCategory*)AddItemCategory:(NSString*)name;
- (Item*)AddMiscItem:(Item*)miscitem;
- (ItemModifierCategory*)AddModifyCategory:(NSString*)name;
- (ItemModifier*)AddModifier:(ItemModifier*)item;

- (void)setLoginResult:(LoginResultModel *)loginResultModel;
- (Order*)getOrder;
- (Transaction*)getTransactionItem;
- (Merchant*)getMerchantItem;
- (BusinessInfo*)getBussinessItem;
- (PrincipalInfo*)getPrincipalItem;
- (BankInfo*)getBankItem;
- (NSMutableArray *)getHistoryArray;

- (NSMutableArray *)getItemCategoryList;
- (NSMutableArray *)getModifierCategoryList;
- (NSMutableArray *)getToTalItemList:(int)categoryId;
- (ItemModifierCategory*)getItemModifierCategory:(int)itemModfierCategoryId;
- (NSMutableArray *)getItemModifierAtModifierCategoryId:(int)mcId;
- (Order*)getOrderInfo;
///action
-(void)ItemSort:(int)reftOption :(int)right;
- (void)removeItemValue:(Item*)item;
- (void)removeItemModifierCategoryItem:(ItemModifierCategory*)item;
- (void)removeItemModifierItem:(ItemModifier*)item;
- (void)removeItemCategoryItem:(ItemCategory*)item;

+(NSString*)getStringFrom:(double)value;
+(NSString*)getPercentStringFrom:(double)value;
+(NSString*)getDollarStringFrom:(double)value;


@end
