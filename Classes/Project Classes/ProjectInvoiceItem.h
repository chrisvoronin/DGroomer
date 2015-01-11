//
//  ProjectInvoiceItem.h
//  myBusiness
//
//  Created by David J. Maier on 3/31/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProjectInvoiceItem : NSObject {
	NSInteger	invoiceItemID;
	NSInteger	invoiceID;
	NSInteger	itemID;
	NSObject	*item;
}

@property (nonatomic, assign) NSInteger	invoiceID;
@property (nonatomic, assign) NSInteger	invoiceItemID;
@property (nonatomic, assign) NSInteger	itemID;
@property (nonatomic, retain) NSObject	*item;

@end
