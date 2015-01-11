//
//  ConfigurationUtility.m
//  SmartSwipe
//
//  Created by Chris Voronin on 11/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ConfigurationUtility.h"

@implementation ConfigurationUtility

+(NSString*)getBaseURL
{
    return @"https://api.smart-swipe.com/beta";
    return [ConfigurationUtility getValueByKey:@"SSV2_BaseURL"];
}

+(NSString*)getPhoneNumber
{
    return [ConfigurationUtility getValueByKey:@"SSV2_PhoneNumber"];
}

+(NSString*)getEmail
{
    return [ConfigurationUtility getValueByKey:@"SSV2_SupportEmail"];
}

+(NSString*)getITunesURL
{
    return [ConfigurationUtility getValueByKey:@"SSV2_ITunesURL"];
}

+(NSString*)getWebsiteURL
{
    return [ConfigurationUtility getValueByKey:@"SSV2_WebsiteURL"];
}

+(NSString*)getLeadKey
{
    return @"SmartSwipe";
    return [ConfigurationUtility getValueByKey:@"SSV2_LeadKey"];
}

+(NSString*)getCompanyName
{
    return [ConfigurationUtility getValueByKey:@"SSV2_AppName"];
}

+(NSString*)getValueByKey:(NSString*)key
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString *value = [mainBundle objectForInfoDictionaryKey:key];
    return value;
}

@end
