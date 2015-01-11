//
//  URLRequestBuilder.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/23/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "URLRequestBuilder.h"

@implementation URLRequestBuilder

+(NSMutableURLRequest*)createRequestWithURLString:(NSString*)urlString postData:(NSMutableDictionary*)postData
{
    // build json data
    NSData * json = [NSJSONSerialization dataWithJSONObject:postData options:0 error:nil];
    NSString *responseString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSLog(@"request:%@ - %@",urlString,responseString);
    // build request
    NSString *baseURLString =  @"Http://";
    
    NSURL * baseURL = [NSURL URLWithString:baseURLString];
    NSURL * url = baseURL;
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)json.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:json];
    
    return request;
}
+(NSMutableURLRequest*)createRequestWithURLString:(NSString*)urlString getData:(NSMutableDictionary*)getData
{
    // build json data
    NSData * json = [NSJSONSerialization dataWithJSONObject:getData options:0 error:nil];
    NSString *responseString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSLog(@"request:%@ - %@",urlString,responseString);
    // build request
    NSString *baseURLString = @"Http://";
    baseURLString = [baseURLString stringByAppendingString:urlString];
//    baseURLString = [baseURLString stringByAppendingFormat:@"?%@",responseString];
    
    NSURL * baseURL = [NSURL URLWithString:baseURLString];
    NSURL * url = baseURL;
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)json.length] forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBody:json];
    
    return request;
}
@end
