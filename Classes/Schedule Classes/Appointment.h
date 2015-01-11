//
//  Appointments.h
//  myBusiness
//
//  Created by David J. Maier on 5/31/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Client;

typedef enum iBizAppointmentRepeat {
	iBizAppointmentRepeatNever,
	iBizAppointmentRepeatDaily,
	iBizAppointmentRepeatWeekly,
	iBizAppointmentRepeatMonthly,
	iBizAppointmentRepeatYearly,
	iBizAppointmentRepeatEvery2Weeks,
	iBizAppointmentRepeatEvery3Weeks,
	iBizAppointmentRepeatEvery4Weeks
} iBizAppointmentRepeat;

typedef enum iBizAppointmentType {
	iBizAppointmentTypeBlock,
	iBizAppointmentTypeProject,
	iBizAppointmentTypeSingleService
} iBizAppointmentType;

@interface Appointment : NSObject {
	// Appointment Variables
	NSInteger			appointmentID;
	Client				*client;
	NSString			*notes;
	NSObject			*object;
	iBizAppointmentType	type;
	// Standing Appointments
	NSInteger				standingAppointmentID;
	iBizAppointmentRepeat	standingRepeat;
	NSString				*standingRepeatCustom;
	NSDate					*standingRepeatUntilDate;
	// Timing
	NSDate		*dateTime;
	NSInteger	duration;
	// Outside references
	
	
}

// Appointment
@property (nonatomic, assign) NSInteger				appointmentID;
@property (nonatomic, retain) Client				*client;
@property (nonatomic, retain) NSString				*notes;
@property (nonatomic, retain) NSObject				*object;
@property (nonatomic, assign) iBizAppointmentType	type;
// Standing
@property (nonatomic, assign) NSInteger				standingAppointmentID;
@property (nonatomic, assign) iBizAppointmentRepeat	standingRepeat;
@property (nonatomic, retain) NSString				*standingRepeatCustom;
@property (nonatomic, retain) NSDate				*standingRepeatUntilDate;
// Timing
@property (nonatomic, retain) NSDate	*dateTime;
@property (nonatomic, assign) NSInteger duration;


- (id) init;
- (id) initWithAppointment:(Appointment*)theAppointment;



@end
