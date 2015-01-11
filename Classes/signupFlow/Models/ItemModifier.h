//
//  ItemModifier.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemModifier : NSObject

@property (nonatomic, assign) int modifierID;
@property (nonatomic, assign) int modifierCategoryID;
@property (nonatomic, copy) NSString * modifierName;
@property (nonatomic, assign) double modifierPrice;

-(id)initWithDictionary:(NSDictionary*)dict;

-(id)initWithID:(int)modifierID modCatID:(int)modifierCategoryID name:(NSString*)modifierName price:(double)modifierPrice;

+(NSMutableArray*)objectArrayFromJson:(NSArray*)arrayJson;

@end
