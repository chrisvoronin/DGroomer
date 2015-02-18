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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"This gives you the ability to add inventory, record it if you use it in the store or record it if you forgot to add it to a transaction."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)dealloc {
    [_lblText release];
    [super dealloc];
}
@end
