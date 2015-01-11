//
//  ServiceProtocol.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/23/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServiceProtocol <NSObject>

-(void)handleServiceResponseWithDict:(NSDictionary*)dictionary;

-(void)handleServiceResponseErrorMessage:(NSString*)error;

@end
