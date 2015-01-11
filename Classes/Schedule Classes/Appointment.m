//
//  Appointments.m
//  myBusiness
//
//  Created by David J. Maier on 5/31/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Service.h"
#import "Appointment.h"


@implementation Appointment

@synthesize appointmentID, notes, object, standingAppointmentID, standingRepeat, standingRepeatCustom, standingRepeatUntilDate;
@synthesize dateTime, duration;
@synthesize client, type;

- (id) init {
	self.appointmentID = -1;
	self.standingAppointmentID = -1;
	self.client = nil;
	self.dateTime = nil;
	self.duration = -1;
	self.notes = nil;
	self.type = iBizAppointmentTypeSingleService;
	self.object = nil;
	self.standingRepeat = iBizAppointmentRepeatNever;
	self.standingRepeatCustom = nil;
	self.standingRepeatUntilDate = nil;
	return self;
}

- (id) initWithAppointment:(Appointment*)theAppointment {
	self.appointmentID = theAppointment.appointmentID;
	self.standingAppointmentID = theAppointment.standingAppointmentID;
	self.client = theAppointment.client;
	self.dateTime = [NSDate dateWithTimeIntervalSinceReferenceDate:[theAppointment.dateTime timeIntervalSinceReferenceDate]];
	self.duration = theAppointment.duration;
	self.notes = (theAppointment.notes) ? [NSString stringWithString:theAppointment.notes] : nil;
	self.object = theAppointment.object;
	self.standingRepeat = theAppointment.standingRepeat;
	self.standingRepeatCustom = theAppointment.standingRepeatCustom;
	self.standingRepeatUntilDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[theAppointment.standingRepeatUntilDate timeIntervalSinceReferenceDate]];
	self.type = theAppointment.type;
	return self;
}

- (void) dealloc {
	[client release];
	[dateTime release];
	[notes release];
	[object release];
	[standingRepeatCustom release];
	[standingRepeatUntilDate release];
	[super dealloc];
}

@end
