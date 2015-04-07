//
//  SettingsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 7/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BatchOutTableViewCell.h"
#import "DatePickerTableViewCell.h"
#import "Settings.h"
@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView	*settingsTable;
    NSString      *strDate;
    NSDate      *tDate;
    Settings				*settings;
}

@property (nonatomic, retain) UITableView	*settingsTable;
@property (nonatomic, retain) NSString      *strDate;
@property (nonatomic, assign) BOOL	bBatchOut;
@property (nonatomic, assign) BOOL	isShowDatePicker;
@property (retain, nonatomic) IBOutlet BatchOutTableViewCell *batchBtn;
@property (retain, nonatomic) IBOutlet DatePickerTableViewCell *dateCell;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) Settings		*settings;

- (NSDate *)todayModifiedWithHours:(NSString *)strTime;
@end
