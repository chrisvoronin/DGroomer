//
//  OrderItemModifier.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/14/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItemModifier : NSObject
@property (nonatomic, assign) int orderItemModifierID;
@property (nonatomic, assign) int orderItemID;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) double price;
@end
