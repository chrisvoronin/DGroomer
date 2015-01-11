//
//  BankInfo.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/14/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BankInfo : NSObject
@property (nonatomic, assign) int MerchantID;
@property (nonatomic, copy) NSNumber* SaleTypeID;
@property (nonatomic, copy) NSNumber* AverageSale;
@property (nonatomic, copy) NSNumber* MonthlySales;
@property (nonatomic, copy) NSString *BankName;
@property (nonatomic, copy) NSString *RountingNumber;
@property (nonatomic, copy) NSString *AccountNumber;

-(id)initWithDictionary:(NSDictionary*)dict;

@end
