//
//  BatchOutTableViewCell.m
//  iBiz
//
//  Created by johnny on 2/14/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "BatchOutTableViewCell.h"
#import "SettingsViewController.h"
@implementation BatchOutTableViewCell
@synthesize swBatchOut;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [swBatchOut release];
    [super dealloc];
}
@end
