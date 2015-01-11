//
//  ErrorXmlParser.m
//  SmartSwipe
//
//  Created by IOS7 on 2/3/14.
//  Copyright (c) 2014 Chris Voronin. All rights reserved.
//

#import "ErrorXmlParser.h"

@implementation ErrorXmlParser
+(BOOL)checkResponseError:(NSDictionary*)dictionary :(NSString*)url
{
    if(dictionary){
        int statecode = [[dictionary objectForKey:@"st"] intValue];
        if(statecode != 0){
            NSDictionary * errorDict = [dictionary objectForKey:@"er"];
            int errorCode = [[errorDict objectForKey:@"ec"] intValue];
            NSString * errorMsg = [errorDict objectForKey:@"em"];
            NSLog(@"%@ -- errorcode:%d error Msg:%@",url,errorCode,errorMsg);
            return NO;
        }
    }
    return YES;
}
+(NSString*)getResponseError:(NSDictionary*)dictionary
{
    NSDictionary * errorDict = [dictionary objectForKey:@"er"];
    NSString * errorMsg = [errorDict objectForKey:@"em"];
    return errorMsg;
}
@end
