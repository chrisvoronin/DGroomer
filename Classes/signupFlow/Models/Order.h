//
//  Cart.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderItem.h"

//TODO: move to some other place one day.
typedef enum OrderPopupType : int {
    OrderPopupTypeNone = 0,
    OrderPopupTypeWeight = 1,
    OrderPopupTypeDiscountValue = 2,
    OrderPopupTypeDiscountPercent = 3,
    OrderPopupTypeItemDetail = 4,
    OrderPopupTypeAddNotes = 5
} OrderPopupType;

@interface Order : NSObject

@property (nonatomic, assign) long orderID;
@property (nonatomic, assign) long userID;
@property (nonatomic, copy) NSString * date;

@property (nonatomic, strong) NSMutableArray * orderItems;

@property (nonatomic, strong) NSMutableArray * orderNotes;

@property (nonatomic, assign) double tipAmount;
@property (nonatomic, assign) double subTotal;
@property (nonatomic, assign) double taxTotal;
@property (nonatomic, assign) double total;

@property (nonatomic, copy) NSString * email;
@property (nonatomic, strong) NSString * phone;

-(id)initWithResponseDictionary:(NSDictionary*)dictionary;
- (id)initWithDummyData;

-(void)addCartItem:(OrderItem*)item;

-(double)getOrderTotal:(double)taxRate;
-(double)getItemTotal:(double)taxRate;
-(double)getItemSubTotal;


@end
