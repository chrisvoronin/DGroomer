//
//  ProjectServiceViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/23/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectEstimateInvoicePickerViewController.h"
#import "ProjectService.h"
#import "PSADataManager.h"
#import "ProjectServicePriceDetailViewController.h"


@implementation ProjectServicePriceDetailViewController

@synthesize isModal, project, projectService;
@synthesize lbDiscount, lbDollarSign, lbDollarSignSetup, lbTotal, segFlatRate, segPercent, txtDiscount, txtPrice, txtSetupFee;

- (void) viewDidLoad {
	if( projectService ) {
		self.title = projectService.serviceName;
	} else {
		self.title = @"Service Details";
	}
	//
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	lbDollarSign.text = [currencyFormatter currencySymbol];
	lbDollarSignSetup.text = [currencyFormatter currencySymbol];
	[segPercent setTitle:[currencyFormatter currencySymbol] forSegmentAtIndex:1];
	[currencyFormatter release];
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Cancel Button if modalViewController
	if( isModal ) {
		UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
		self.navigationItem.leftBarButtonItem = cancel;
		[cancel release];
	}
	// Save button
	if( !project.dateCompleted ) {
		UIBarButtonItem *save  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		self.navigationItem.rightBarButtonItem = save;
		[save release];
	}
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( projectService ) {
		if( projectService.isPercentDiscount ) {
			segPercent.selectedSegmentIndex = 0;
		} else {
			segPercent.selectedSegmentIndex = 1;
		}
		
		if( projectService.isFlatRate ) {
			segFlatRate.selectedSegmentIndex = 0;
		} else {
			segFlatRate.selectedSegmentIndex = 1;
		}
		
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setCurrencySymbol:@""];
		if( projectService.discountAmount ) {
			txtDiscount.text = [formatter stringFromNumber:projectService.discountAmount];
		} else {
			txtDiscount.text = @"0";
		}
		
		if( projectService.price ) {
			txtPrice.text = [formatter stringFromNumber:projectService.price];
		} else {
			txtPrice.text = @"0";
		}
		
		if( projectService.setupFee ) {
			txtSetupFee.text = [formatter stringFromNumber:projectService.setupFee];
		} else {
			txtSetupFee.text = @"0";
		}
		[formatter release];
	}
	[self relabel];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.lbDiscount = nil;
	self.lbDollarSign = nil;
	self.lbDollarSignSetup = nil;
	self.lbTotal = nil;
	self.segFlatRate = nil;
	self.segPercent = nil;
	self.txtDiscount = nil;
	self.txtPrice = nil;
	self.txtSetupFee = nil;
	[project release];
	[projectService release];
    [super dealloc];
}

/*
 *	
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == 0 ) {
		// Show picker
		ProjectEstimateInvoicePickerViewController *cont = [[ProjectEstimateInvoicePickerViewController alloc] initWithNibName:@"ProjectEstimateInvoicePickerView" bundle:nil];
		cont.project = project;
		cont.service = projectService;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else {
		// Should always be modal
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void) save {
	BOOL allOK = YES;
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	NSNumber *disc = nil;
	if( [txtDiscount.text hasPrefix:@" "] ) {
		disc = [formatter numberFromString:[txtDiscount.text substringFromIndex:1]];
	} else {
		disc = [formatter numberFromString:txtDiscount.text];
	}
	NSNumber *price = nil;
	if( [txtPrice.text hasPrefix:@" "] ) {
		price = [formatter numberFromString:[txtPrice.text substringFromIndex:1]];
	} else {
		price = [formatter numberFromString:txtPrice.text];
	}
	NSNumber *setup = nil;
	if( txtSetupFee ) {
		if( [txtSetupFee.text hasPrefix:@" "] ) {
			setup = [formatter numberFromString:[txtSetupFee.text substringFromIndex:1]];
		} else {
			setup = [formatter numberFromString:txtSetupFee.text];
		}
	}
	[formatter release];
	
	if( disc && [disc doubleValue] >= 0.0  ) {
		//
		if( price && [price doubleValue] >= 0.0 ) {
			//
			if( setup && [setup doubleValue] >= 0.0 ) {
				// Values set below
			} else {
				allOK = NO;
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Setup Fee" message:@"Setup Fee must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];	
				[alert release];
			}
		} else {
			allOK = NO;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Price" message:@"Service price must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];	
			[alert release];
		}
	} else {
		allOK = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Discount" message:@"Service discount must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
	
	if( allOK ) {
		// Set values
		if( segPercent.selectedSegmentIndex == 0 ) {
			projectService.isPercentDiscount = YES;
		} else {
			projectService.isPercentDiscount = NO;
		}
		if( segFlatRate.selectedSegmentIndex == 0 ) {
			projectService.isFlatRate = YES;
		} else {
			projectService.isFlatRate = NO;
		}
		projectService.discountAmount = disc;
		projectService.price = price;
		projectService.setupFee = setup;
		// Save to DB
		NSInteger originalID = projectService.projectServiceID;
		[[PSADataManager sharedInstance] saveProjectService:projectService];
		
		// Add to our array
		if( ![project.services containsObject:projectService] ) {
			BOOL inserted = NO;
			for( NSInteger i=0; i<project.services.count; i++ ) {
				ProjectService *existing = [project.services objectAtIndex:i];
				if( [projectService.serviceName compare:existing.serviceName] != NSOrderedDescending ) {
					[project.services insertObject:projectService atIndex:i];
					inserted = YES;
					break;
				}
			}
			if( !inserted )	[project.services addObject:projectService];
		}
		// Update Invoice & Project totals
		[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
		// Transition views
		if( isModal ) {
			if( originalID == -1 ) {
				if( [[project.payments objectForKey:[project getKeyForEstimates]] count] > 0 || [[project.payments objectForKey:[project getKeyForInvoices]] count] > 0 ) {
					UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to choose any existing estimates or invoices to add this service to?" delegate:self cancelButtonTitle:@"Don't Add" destructiveButtonTitle:nil otherButtonTitles:@"Add", nil];
					[action showInView:self.view];
					[action release];
				} else {
					[self dismissViewControllerAnimated:YES completion:nil];
				}
			} else {
				[self dismissViewControllerAnimated:YES completion:nil];
			}
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

#pragma mark -
#pragma mark 
#pragma mark -

- (void) relabel {
	[self relabelWithDiscount:txtDiscount.text setup:txtSetupFee.text price:txtPrice.text];
}

- (void) relabelWithDiscount:(NSString*)discountText {
	[self relabelWithDiscount:discountText setup:txtSetupFee.text price:txtPrice.text];
}

- (void) relabelWithPrice:(NSString*)priceText {
	[self relabelWithDiscount:txtDiscount.text setup:txtSetupFee.text price:priceText];
}

- (void) relabelWithSetup:(NSString *)setupText {
	[self relabelWithDiscount:txtDiscount.text setup:setupText price:txtPrice.text];
}

- (void) relabelWithDiscount:(NSString*)discountText setup:(NSString*)setupText price:(NSString*)priceText {
	double total = 0;
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	
	NSNumber *pri = nil;
	if( priceText ){
		if( [priceText hasPrefix:@" "] ) {
			pri = [formatter numberFromString:[priceText substringFromIndex:1]];
		} else {
			pri = [formatter numberFromString:priceText];
		}
	}
	
	NSNumber *setup = nil;
	if( setupText ) {
		if( [setupText hasPrefix:@" "] ) {
			setup = [formatter numberFromString:[setupText substringFromIndex:1]];
		} else {
			setup = [formatter numberFromString:setupText];
		}
	}
	
	if( segFlatRate.selectedSegmentIndex == 0 ) {
		total = [pri doubleValue]+[setup doubleValue];
	} else {
		total = [setup doubleValue];
	}
	
	double disc = total;
	NSNumber *discNum = nil;
	if( [discountText hasPrefix:@" "] ) {
		discNum = [formatter numberFromString:[discountText substringFromIndex:1]];
	} else {
		discNum = [formatter numberFromString:discountText];
	}
	if( segPercent.selectedSegmentIndex == 0 ) {
		disc = total * ( [discNum doubleValue]/100 );
	} else {
		disc = [discNum doubleValue];
	}
	
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	lbDiscount.text = [formatter stringFromNumber:[NSNumber numberWithFloat:disc]];
	[lbDiscount setNeedsDisplay];
	
	NSString *totalStr = nil;
	if( segFlatRate.selectedSegmentIndex == 0 ) {
		totalStr = [formatter stringFromNumber:[NSNumber numberWithFloat:(total-disc)]];
	} else {
		totalStr = @"Based on Hours";
	}
	lbTotal.text = totalStr;
	[lbTotal setNeedsDisplay];
	[formatter release];
}

#pragma mark -
#pragma mark Control Methods
#pragma mark -

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( textField == txtDiscount ) {
		[self relabelWithDiscount:[txtDiscount.text stringByReplacingCharactersInRange:range withString:string]];
	} else if( textField == txtSetupFee ) {
		[self relabelWithSetup:[txtSetupFee.text stringByReplacingCharactersInRange:range withString:string]];
	} else if( textField == txtPrice ) {
		[self relabelWithPrice:[txtPrice.text stringByReplacingCharactersInRange:range withString:string]];
	}
	return YES;
}

/*
 *	Resign all responders (dismiss keyboard)
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[txtDiscount resignFirstResponder];
	[txtPrice resignFirstResponder];
	[txtSetupFee resignFirstResponder];
}

- (IBAction) valueChanged:(id)sender {
	[self relabel];
}


@end
