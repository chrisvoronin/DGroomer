//
//  CartItem.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "ItemModifier.h"

typedef enum OderItemStatus : int {
    None = 0,
    Paid = 1,
    Refunded = 2
} OderItemStatus;

@interface OrderItem : NSObject

@property (nonatomic, assign) int orderItemID;
@property (nonatomic, assign) int orderID;
@property (nonatomic, strong) Item * item;
@property (nonatomic, assign) double quantity;
@property (nonatomic, assign) double orderPrice;

@property (nonatomic, assign) double discountTotal;
@property (nonatomic, assign) double taxAmount;
@property (nonatomic, assign) double lineItemTotal;
@property (nonatomic, strong) NSMutableArray * notes;
@property (nonatomic, strong) NSMutableArray * modifierList;
@property (nonatomic, strong) NSMutableArray * discountList;
@property (nonatomic, assign) OderItemStatus oderItemStatus;
@property (nonatomic, strong) NSMutableDictionary * m_modifierQuantities;

-(double)getItemSubTotal;
-(double)getLineItemTotal:(double)taxRate;

-(void)addModifierItem:(ItemModifier*)item :(double)quantity;
-(void)editModifierItem:(ItemModifier*)item :(double)quantity;
-(void)removeModifierItem:(ItemModifier*)item;
-(NSNumber*)getQuantityOf:(ItemModifier*)item;

-(id)initWithItem:(Item*)item quantity:(double)quantity;


@end
