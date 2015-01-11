//
//  HistoryDetailModel.h
//  SmartSwipe
//
//  Created by irfan yousaf on 9/12/12.
//
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface HistoryDetailModel : NSObject

@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *ccNumber;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *transactionNumber;

@property (strong, nonatomic) NSString *signature;

@property (strong, nonatomic) Order *itemsOrderArray;

@property (strong, nonatomic) NSString *checkNumber;

@property (strong, nonatomic) NSDate *dateTimeStamp;

@property (strong, nonatomic) NSString *ReferenceId;

@property (strong, nonatomic) NSString *transactionId;

@property (strong, nonatomic) NSString *EmailId; //to which the receipt was sent

@property (strong, nonatomic) NSString *MobileNo; //to which the receipt was sent

@property (strong, nonatomic) NSString *transactionStatus;

@end
