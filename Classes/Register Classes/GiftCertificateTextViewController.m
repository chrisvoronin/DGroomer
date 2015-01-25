//
//  GiftCertificateTextViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "GiftCertificateTextViewController.h"


@implementation GiftCertificateTextViewController

@synthesize certificate, editing, tvText;

- (void)viewDidLoad {
	// Background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
    tvText.layer.cornerRadius = 5.0;
    tvText.clipsToBounds = YES;
	if( editing ) {
		// Done Button
		UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		self.navigationItem.rightBarButtonItem = btnDone;
		[btnDone release];
		//
		tvText.editable = YES;
	} else {
		tvText.editable = NO;
	}
	//
    
    
    // you might have to play around a little with numbers in CGRectMake method
    // they work fine with my settings
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, tvText.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:self.title];
    // placeholderLabel is instance variable retained by view controller
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    //[placeholderLabel setFont:[challengeDescription font]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    
    // textView is UITextView object you want add placeholder text to
    [tvText addSubview:placeholderLabel];
    tvText.delegate = self;
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( certificate ) {
		if( [self.title isEqualToString:@"NOTES"] && certificate.notes ) {
			tvText.text = certificate.notes;
		} else if( [self.title isEqualToString:@"MESSAGE"] && certificate.message ) {
			tvText.text = certificate.message;
		}
	}
}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
- (void)textViewDidChange:(UITextView *)textView
{
    if(![tvText hasText]) {
        [tvText addSubview:placeholderLabel];
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 1.0;
        }];
    } else if ([[tvText subviews] containsObject:placeholderLabel]) {
        
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [placeholderLabel removeFromSuperview];
        }];
    }
    //return YES;
}


- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![tvText hasText]) {
        [tvText addSubview:placeholderLabel];
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 1.0;
        }];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tvText = nil;
	[certificate release];
    [super dealloc];
}

- (void) done {
	if( certificate ) {
		if( [self.title isEqualToString:@"NOTES"] ) {
			certificate.notes = tvText.text;
		} else if( [self.title isEqualToString:@"MESSAGE"] ) {
			certificate.message = tvText.text;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

@end
