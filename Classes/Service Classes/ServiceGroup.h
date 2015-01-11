//
//  Group.h
//  myBusiness
//
//  Created by David J. Maier on 6/12/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceGroup : NSObject {
    // Attributes.
	NSString *groupDescription;
	NSInteger groupID;
}


@property (nonatomic, retain) NSString *groupDescription;
@property (assign, nonatomic) NSInteger groupID;

- (id) init;
- (id) initWithGroupData:(NSString *)gp key:(NSInteger)key;

@end
