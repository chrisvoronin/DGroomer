//
//  Report.h
//  myBusiness
//
//  Created by David J. Maier on 1/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PSAReportType {
	PSAReportTypeNone,
	PSAReportTypeCloseoutHistory,
	PSAReportTypeConsolidatedCloseout,
	PSAReportTypeCreditPaymentsHistory,
	PSAReportTypeInvoiceHistory,
	PSAReportTypeProductHistory,
	PSAReportTypeProductInventory,
	PSAReportTypeServiceHistory,
	PSAReportTypeTransactionHistory
} PSAReportType;

@interface Report : NSObject {
	NSDate			*dateEnd;
	NSDate			*dateStart;
	BOOL			isEntireHistory;
	PSAReportType	type;
}

@property (nonatomic, retain) NSDate		*dateEnd;
@property (nonatomic, retain) NSDate		*dateStart;
@property (nonatomic, assign) BOOL			isEntireHistory;
@property (nonatomic, assign) PSAReportType	type;

@end
