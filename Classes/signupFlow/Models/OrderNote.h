//
//  OrderNote.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderNote : NSObject


@property (nonatomic, assign) int noteID;
@property (nonatomic, assign) int orderID;
@property (nonatomic, assign) int orderItemID;
@property (nonatomic, copy) NSString* text;

-(id)initWithDictionary:(NSDictionary*)dict;

@end
