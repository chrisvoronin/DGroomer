//
//  ResponseXmlParser.h
//  SmartSwipe
//
//  Created by IOS7 on 2/3/14.
//  Copyright (c) 2014 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseXmlParser : NSObject
+(NSString*)getResponseDataForKey:(NSString*)key :(NSDictionary*)response;
@end
