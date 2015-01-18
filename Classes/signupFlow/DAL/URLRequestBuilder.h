//
//  URLRequestBuilder.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/23/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLRequestBuilder : NSObject

+(NSMutableURLRequest*)createRequestWithURLString:(NSString*)urlString postData:(NSMutableDictionary*)postData;
+(NSMutableURLRequest*)createRequestWithURLString:(NSString*)urlString getData:(NSMutableDictionary*)getData;
+(NSMutableURLRequest*)createRequestWithURLString:(NSString*)urlString delData:(NSMutableDictionary*)delData;


@end
