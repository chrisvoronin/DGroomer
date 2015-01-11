//
//  ConfigurationUtility.h
//  SmartSwipe
//
//  Created by Chris Voronin on 11/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define URL_MERCHANT_REGISTER @"/services/merchants"
#define URL_MERCHANT_BUSINESSINFO @"/services/businessinfo/"
#define URL_MERCHANT_PRINCIPALINFO @"/services/principalinfo/"
#define URL_MERCHANT_ACCOUNTINFO @"/services/bankinfo/"
#define URL_MERCHANT_LOGIN @"/services/login"
#define URL_MERCHANT_SIGNATURE @"/services/signature/"
#define URL_ITEMCATEGORY_EDIT @"/services/itemcategory/"
#define URL_ITEMMODICATEGORY_EDIT @"/services/itemmodifiercategory/"
#define URL_ITEMMODI_EDIT @"/services/itemmodifier/"

///test define
#define UTL_MERCHANT_ORDERINFO  @"/services/order/"

@interface ConfigurationUtility : NSObject

+(NSString*)getBaseURL;
+(NSString*)getPhoneNumber;
+(NSString*)getEmail;
+(NSString*)getITunesURL;
+(NSString*)getWebsiteURL;
+(NSString*)getLeadKey;
+(NSString*)getCompanyName;

@end
