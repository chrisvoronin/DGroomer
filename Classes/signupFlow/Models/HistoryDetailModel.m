//
//  HistoryDetailModel.m
//  SmartSwipe
//
//  Created by irfan yousaf on 9/12/12.
//
//

#import "HistoryDetailModel.h"

@implementation HistoryDetailModel

@synthesize amount;
@synthesize ccNumber;
@synthesize name;
@synthesize date;
@synthesize time;
@synthesize transactionNumber;
@synthesize itemsOrderArray;
@synthesize signature;
@synthesize checkNumber;
@synthesize dateTimeStamp;
@synthesize ReferenceId;
@synthesize transactionId;
@synthesize EmailId;
@synthesize MobileNo;
@synthesize transactionStatus;

-(id)init {

    if(self = [super init]) {
        //custom initialization
        self.amount = @"";
        self.ccNumber = @"";
        self.name = @"";
        self.date = @"";
        self.time = @"";
        self.transactionNumber = @"";
        self.itemsOrderArray = nil;
        self.signature = @"";
        self.checkNumber = @"";
        self.dateTimeStamp = nil;
        self.ReferenceId = @"";
        self.transactionId = @"";
        self.EmailId = @"";
        self.MobileNo = @"";
        self.transactionStatus = @"";
    }
    
    return self;
}

@end
