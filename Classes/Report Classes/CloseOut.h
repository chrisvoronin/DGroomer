//
//  CloseOut.h
//  myBusiness
//
//  Created by David J. Maier on 2/2/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CloseOut : NSObject {
	NSInteger	closeoutID;
	NSDate		*date;
	NSNumber	*totalOwed;
}

@property (nonatomic, assign) NSInteger	closeoutID;
@property (nonatomic, retain) NSDate	*date;
@property (nonatomic, retain) NSNumber	*totalOwed;

@end
