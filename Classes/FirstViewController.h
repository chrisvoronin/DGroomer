//
//  FirstViewController.h
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController<UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UIPageControl *ctlPage;
@property (retain, nonatomic) IBOutlet UIImageView *imgBackground;
@property (retain, nonatomic) IBOutlet UIButton *btnActivate;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScroll;

-(void)changepage:(id)sender;
@end
