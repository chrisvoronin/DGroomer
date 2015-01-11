//
//  Cart.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "Order.h"

@implementation Order

-(id)init
{
    self = [super init];
    if (self)
    {
        self.orderItems = [NSMutableArray array];
    }
    return self;
}
-(id)initWithResponseDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        //TODO: self.printers;
    }
    return self;
}

- (id)initWithDummyData
{
    self = [super init];
    if (self)
    {
        NSDateFormatter * dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.orderItems = [NSMutableArray array];
        self.orderNotes = [[NSMutableArray alloc] initWithObjects:@"aaaa",@"bbbb",@"cccc", nil];

        self.orderID = 1;
        self.userID = 1;
        self.date = [dateFormatter stringFromDate:[NSDate date]];
        
        Item * item1 = [[Item alloc] initWithID:1 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 1" price:10.0 priceType:PriceTypeEach modCatList:@[@1, @2, @3]];
        item1.itemShippingWeight = 10;
        item1.isTaxable = YES;
        Item * item2 = [[Item alloc] initWithID:2 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 2" price:11.0 priceType:PriceTypeEach modCatList:@[@1, @2]];
        item2.itemShippingWeight = 9;
        item2.isTaxable = YES;
        Item * item3 = [[Item alloc] initWithID:3 categoryID:2 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 3" price:12.0 priceType:PriceTypeEach modCatList:@[@1]];
        item3.itemShippingWeight = 8;
        item3.isTaxable = NO;
        Item * item4 = [[Item alloc] initWithID:4 categoryID:1 imageURL:@"https://www.iconfinder.com/icons/49243/download/ico" name:@"Item 4" price:13.0 priceType:PriceTypeEach modCatList:@[@1, @2, @3]];
        item4.itemShippingWeight = 7;
        
        OrderItem * order_item1 = [[OrderItem alloc] initWithItem:item1 quantity:2];
        order_item1.orderID =
        order_item1.discountTotal = 32;
        order_item1.notes = [[NSMutableArray alloc] initWithObjects:@"item1 note in OrderItem",@"item1 note in OrderItem",@"item1 note in OrderItem", nil];
        
        OrderItem * order_item2 = [[OrderItem alloc] initWithItem:item2 quantity:3];
        order_item2.notes = [[NSMutableArray alloc] initWithObjects:@"item2 note in OrderItem",@"item2 note in OrderItem",@"item2 note in OrderItem", nil];
        
        OrderItem * order_item3 = [[OrderItem alloc] initWithItem:item3 quantity:4];
        order_item3.discountTotal = 32;
        
        
        [self.orderItems addObject:order_item1];
        [self.orderItems addObject:order_item2];
        [self.orderItems addObject:order_item3];
        [self.orderItems addObject:order_item1];
        
        self.tipAmount = 200.03;
        self.subTotal = 30.78;
        self.taxTotal = 23.45;
        self.total = 100.03;
        self.email = @"galaxy198939@hotmail.com";
        self.phone = @"8618642525173";
        
    }
    return self;
}

-(void)addCartItem:(OrderItem *)item
{
    [self.orderItems addObject:item];
}

-(double)getOrderTotal:(double)taxRate
{
    double total = [self getItemTotal:taxRate];
    
    return total;
}

-(double)getItemTotal:(double)taxRate
{
    double total = 0.0;
    for(OrderItem * i in self.orderItems)
    {
        total += [i getLineItemTotal:taxRate];
    }
    return total;
}

-(double)getItemSubTotal
{
    double total = 0.0;
    for(OrderItem * i in self.orderItems)
    {
        total += [i getItemSubTotal];
    }
    return total;
}

@end
