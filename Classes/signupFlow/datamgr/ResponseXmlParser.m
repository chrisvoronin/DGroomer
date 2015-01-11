//
//  ResponseXmlParser.m
//  SmartSwipe
//
//  Created by IOS7 on 2/3/14.
//  Copyright (c) 2014 Chris Voronin. All rights reserved.
//

#import "ResponseXmlParser.h"

@implementation ResponseXmlParser
+(NSString*)getResponseDataForKey:(NSString*)key :(NSDictionary*)response
{
    NSDictionary * responseDate = [response objectForKey:@"rsd"];
    return [responseDate objectForKey:key];
}
@end
