//
//  CartItem.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

-(id)initWithItem:(Item*)item quantity:(double)quantity
{
    self = [super init];
    if (self)
    {
        self.orderItemID = item.itemID;
        self.item = item;
        self.quantity = quantity;
        self.discountTotal = 0;
        self.modifierList = [NSMutableArray array];
        self.notes = [NSMutableArray new];
        self.m_modifierQuantities = [NSMutableDictionary new];
    }
    return self;
}

-(double)getModifierTotal
{
    double modTotal = 0.0;
    
    if (!self.modifierList || self.modifierList.count == 0)
        return 0.0;
    
    for(ItemModifier * mod in self.modifierList)
    {
        modTotal += mod.modifierPrice;
    }
    return modTotal * self.quantity;
}

-(double)getItemSubTotal
{
    return  self.quantity * self.item.price + [self getModifierTotal];
}


-(double)getLineItemTotal:(double)taxRate
{
    double total = [self getItemSubTotal];
    total += (total/100 * taxRate);
    
    return total;
}

/////// quantity property
-(void)addModifierItem:(ItemModifier*)item :(double)quantity
{
    [self.modifierList addObject:item];
    [self.m_modifierQuantities setObject:[NSNumber numberWithInt:quantity] forKey:[NSNumber numberWithInt:item.modifierID]];
}
-(void)editModifierItem:(ItemModifier*)item :(double)quantity
{
    [self.m_modifierQuantities removeObjectForKey:[NSNumber numberWithInt:item.modifierID]];
    [self.m_modifierQuantities setObject:[NSNumber numberWithInt:quantity] forKey:[NSNumber numberWithInt:item.modifierID]];
}
-(void)removeModifierItem:(ItemModifier*)item
{
    [self.modifierList removeObject:item];
    [self.m_modifierQuantities removeObjectForKey:[NSNumber numberWithInt:item.modifierID]];
}
-(NSNumber*)getQuantityOf:(ItemModifier*)item
{
    return [NSNumber numberWithDouble:[[self.m_modifierQuantities objectForKey:[NSNumber numberWithInt:item.modifierID]] doubleValue]];
}
@end
