//
//  LoginDAL.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/23/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceProtocol.h"

@interface ServiceDAL : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

-(id)initWiThPostData:(NSDictionary*)data urlString:(NSString*)urlString delegate:(id<ServiceProtocol>)del;
-(id)initWiThGetData:(NSDictionary*)data urlString:(NSString*)urlString delegate:(id<ServiceProtocol>)del;
-(void)startAsync;
-(void)cancelAsync;

@end
