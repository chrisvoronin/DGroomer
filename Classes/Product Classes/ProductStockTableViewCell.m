//
//  ProductStockTableViewCell.m
//  iBiz
//
//  Created by johnny on 2/12/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "ProductStockTableViewCell.h"

@implementation ProductStockTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clicked_infoBtn:(id)sender {
}

- (void)dealloc {
    [_lblText release];
    [super dealloc];
}
@end
