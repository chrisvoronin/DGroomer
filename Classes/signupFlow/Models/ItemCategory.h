//
//  ItemCategory.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/22/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemCategory : NSObject

@property (nonatomic, assign) int categoryID;
@property (nonatomic, copy) NSString * categoryName;

-(id)initWithDictionary:(NSDictionary*)dict;

-(id)initWithID:(int)categoryID andName:(NSString*)categoryName;

+(NSMutableArray*)objectArrayFromJson:(NSArray*)arrayJson;

@end
