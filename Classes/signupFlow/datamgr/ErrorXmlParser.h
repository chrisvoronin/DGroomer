//
//  ErrorXmlParser.h
//  SmartSwipe
//
//  Created by IOS7 on 2/3/14.
//  Copyright (c) 2014 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorXmlParser : NSObject
+(BOOL)checkResponseError:(NSDictionary*)dictionary :(NSString*)url;
+(NSString*)getResponseError:(NSDictionary*)dictionary;
@end
