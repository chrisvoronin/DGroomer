
//
//  LoginDAL.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/23/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ServiceDAL.h"
#import "Reachability.h"
#import "URLRequestBuilder.h"
#import "DataRegister.h"
#import "ConfigurationUtility.h"
#import "ErrorXmlParser.h"
//#import "AppDelegate.h"

#define SENDREQUEST_TYPE_POST       0
#define SENDREQUEST_TYPE_GET        1
#define SENDREQUEST_TYPE_DELETE     2


@implementation ServiceDAL
{
    __strong NSMutableDictionary * postData;
    __strong NSURLConnection *urlConnection;
	__strong NSMutableData *receivedData;
    __strong id<ServiceProtocol> delegate;
    __strong NSString * url;
    
    int send_request_type;
}


- (NSNumber*)getMerchantIdForUrl:(NSString*)urlStr
{
    if([urlStr isEqualToString:URL_MERCHANT_REGISTER])
        return [NSNumber numberWithInt:987];
    if([urlStr isEqualToString:URL_MERCHANT_BUSINESSINFO] ||
       [urlStr isEqualToString:URL_MERCHANT_PRINCIPALINFO] ||
       [urlStr isEqualToString:URL_MERCHANT_ACCOUNTINFO])
    {
        return [NSNumber numberWithInt:[[DataRegister instance] getMerchantItem].MerchantID];
    }

    return [NSNumber numberWithInt:8];
}

- (NSString*)getEmailAddressForUrl:(NSString*)urlStr
{


    if([urlStr isEqualToString:URL_MERCHANT_BUSINESSINFO] ||
       [urlStr isEqualToString:URL_MERCHANT_PRINCIPALINFO] ||
       [urlStr isEqualToString:URL_MERCHANT_ACCOUNTINFO])
        return [[DataRegister instance] getMerchantItem].EMail;

    return @"aa@aa.com";
}
- (NSNumber*)getUserIdForUrl:(NSString*)urlStr
{
    if([urlStr isEqualToString:URL_MERCHANT_BUSINESSINFO] || [urlStr isEqualToString:URL_MERCHANT_REGISTER])
        [NSNumber numberWithInt:987];

    return [NSNumber numberWithInt:987];
}

-(id)initWiThPostData:(NSDictionary*)data urlString:(NSString*)urlString delegate:(id<ServiceProtocol>)del
{
    self = [super init];
    if (self)
    {
    
        send_request_type = SENDREQUEST_TYPE_POST;
        
        
        
        postData = [NSMutableDictionary new];
        /*NSDictionary * dict2 = @{
                                 @"mid" : [self getMerchantIdForUrl:urlString],
                                 @"uem" : [self getEmailAddressForUrl:urlString] != nil ? [self getEmailAddressForUrl:urlString] : @"",
                                 @"uid" : [self getUserIdForUrl:urlString],
                                 @"ldk" : [ConfigurationUtility getLeadKey],
                                 };*/
        [postData setObject:data forKey:@""];
        //[postData setObject:dict2 forKey:@"sd"];

        delegate = del;
        url = urlString;
    }
    return self;
}
-(id)initWiThGetData:(NSDictionary*)data urlString:(NSString*)urlString delegate:(id<ServiceProtocol>)del
{
    self = [super init];
    if (self)
    {
        send_request_type = SENDREQUEST_TYPE_GET;
        
        postData = [NSMutableDictionary new];
        NSDictionary * dict2 = @{
                                 @"mid" : [self getMerchantIdForUrl:urlString],
                                 @"ldk" : [ConfigurationUtility getLeadKey],
//                                 @"uem" : [self getEmailAddressForUrl:urlString],
//                                 @"uid" : [self getUserIdForUrl:urlString],

                                 };
        [postData setObject:data forKey:@"rqd"];
        [postData setObject:dict2 forKey:@"sd"];
        
        delegate = del;
        url = urlString;
    }
    return self;
}
-(id)initWiThDelData:(NSDictionary*)data urlString:(NSString*)urlString delegate:(id<ServiceProtocol>)del
{
    self = [super init];
    if (self)
    {
        send_request_type = SENDREQUEST_TYPE_DELETE;
        
        postData = [NSMutableDictionary new];
        NSDictionary * dict2 = @{
                                 @"mid" : [self getMerchantIdForUrl:urlString],
                                 @"uem" : [self getEmailAddressForUrl:urlString],
                                 @"uid" : [self getUserIdForUrl:urlString],
                                 @"ldk" : [ConfigurationUtility getLeadKey],
                                 };
        [postData setObject:data forKey:@"rqd"];
        [postData setObject:dict2 forKey:@"sd"];
        
        delegate = del;
        url = urlString;
    }
    return self;

}

-(void)startAsync
{
    
    /// test for v3
    /*if([DeviceMgr is_SmartSwipeV3_Version]){
        [delegate handleServiceResponseWithDict:nil];return;
    }*/
    
    
    receivedData = [[NSMutableData alloc]init];
    // build request
    NSMutableURLRequest * request;
    
    switch(send_request_type){
            
        case SENDREQUEST_TYPE_POST:
            request = [URLRequestBuilder createRequestWithURLString:url postData:postData];
            break;
            
        case SENDREQUEST_TYPE_GET:
            request = [URLRequestBuilder createRequestWithURLString:url getData:postData];
            break;
            
        case SENDREQUEST_TYPE_DELETE:
            request = [URLRequestBuilder createRequestWithURLString:url delData:postData];
            break;
            
        default:
            request = nil;
            return;
            break;
            
    }
    
//    if(send_request_type == SENDREQUEST_TYPE_POST || send_request_type == SENDREQUEST_TYPE_GET){
//        request = [URLRequestBuilder createRequestWithURLString:url postData:postData];
//    }else if(send_request_type == SENDREQUEST_TYPE_DELETE){
//        request = [URLRequestBuilder createRequestWithURLString:url delData:postData];
//    }

// start url connection
    urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if(!urlConnection)
    {
        // call error block.
		urlConnection = nil;
        if (delegate)
        {
            [delegate handleServiceResponseErrorMessage:@"Failed to create NSURLConnection"];
            return;
        }
    }
}
-(void)cancelAsync
{
    [urlConnection cancel];
}

#pragma mark - NSURLConnectionDelegate

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return YES;
//}
//
//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    if ([challenge previousFailureCount] > 0) {
//        // do something may be alert message
//    }
//    else
//    {
//        
//        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"username"
//                                                                 password:@"password"
//                                                              persistence:NSURLCredentialPersistenceForSession];
//        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//    }
//
//}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    urlConnection = nil;
    [delegate handleServiceResponseErrorMessage:error.localizedDescription];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    urlConnection = nil;
    NSString *responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"response - %@",responseString);
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
    
    bool success = YES;
    
    
    if (!delegate)
        return;
    
    if (success)
    {
        [delegate handleServiceResponseWithDict:response];
    }
    else
    {
        NSString * message = @"YES";
        [delegate handleServiceResponseErrorMessage:message];
    }
}


@end
