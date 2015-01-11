//
//  ItemModifierCategory.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/20/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemModifierCategory : NSObject

@property (nonatomic, assign) int modifierCategoryID;
@property (nonatomic, copy) NSString * modifierCategoryName;

-(id)initWithDictionary:(NSDictionary*)dict;

-(id)initWithID:(int)modifierCategoryID andName:(NSString*)modifierCategoryName;

+(NSMutableArray*)objectArrayFromJson:(NSArray*)arrayJson;

@end
