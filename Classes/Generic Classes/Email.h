//
//  Email.h
//  myBusiness
//
//  Created by David J. Maier on 2/28/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PSAEmailType {
	PSAEmailTypeAnniversary,
	PSAEmailTypeBirthday,
	PSAEmailTypeAppointmentReminder
} PSAEmailType;

@interface Email : NSObject {
	BOOL			bccCompany;
	NSInteger		emailID;
	NSString		*message;
	NSString		*subject;
	PSAEmailType	type;
}

@property (nonatomic, assign) BOOL			bccCompany;
@property (nonatomic, assign) NSInteger		emailID;
@property (nonatomic, retain) NSString		*message;
@property (nonatomic, retain) NSString		*subject;
@property (nonatomic, assign) PSAEmailType	type;

@end
