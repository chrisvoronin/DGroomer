//
//  ProjectProductDetailViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/21/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductAdjustment.h"
#import "Project.h"
#import "ProjectEstimateInvoicePickerViewController.h"
#import "ProjectProduct.h"
#import "PSADataManager.h"
#import "ProjectProductDetailViewController.h"


@implementation ProjectProductDetailViewController

@synthesize isModal, project, projectProduct;
@synthesize lbDiscount, lbDollarSign, lbTotal, segPercent, segTax, txtDiscount, txtPrice, txtQuantity;

- (void) viewDidLoad {
	if( projectProduct ) {
		self.title = projectProduct.productName;
	} else {
		self.title = @"Product Details";
	}
	//
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	lbDollarSign.text = [currencyFormatter currencySymbol];
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
	if( !project.dateCompleted ) {
		// Save button
		UIBarButtonItem *save  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		self.navigationItem.rightBarButtonItem = save;
		[save release];
	}
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( projectProduct ) {
		if( projectProduct.isPercentDiscount ) {
			segPercent.selectedSegmentIndex = 0;
		} else {
			segPercent.selectedSegmentIndex = 1;
		}
		
		if( projectProduct.taxed ) {
			segTax.selectedSegmentIndex = 0;
		} else {
			segTax.selectedSegmentIndex = 1;
		}
		
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setCurrencySymbol:@""];
		if( projectProduct.discountAmount ) {
			txtDiscount.text = [formatter stringFromNumber:projectProduct.discountAmount];
		} else {
			txtDiscount.text = @"0";
		}
		txtPrice.text = [formatter stringFromNumber:projectProduct.price];
		NSString *qty = [[NSString alloc] initWithFormat:@"%d", projectProduct.productAdjustment.quantity];
		txtQuantity.text = qty;
		[qty release];
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
	self.lbTotal = nil;
	self.segPercent = nil;
	self.segTax = nil;
	self.txtDiscount = nil;
	self.txtPrice = nil;
	self.txtQuantity = nil;
	[project release];
	[projectProduct release];
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
		cont.product = projectProduct;
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
	[formatter release];
	
	if( disc && [disc doubleValue] >= 0.0  ) {
		//
		if( price && [price doubleValue] >= 0.0 ) {
			// 			
			if( [txtQuantity.text intValue] > 0 ) {
				// Values set below
			} else {
				allOK = NO;
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Quantity" message:@"Product quantity must be greater than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];	
				[alert release];
			}
		} else {
			allOK = NO;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Price" message:@"Product price must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];	
			[alert release];
		}
	} else {
		allOK = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Discount" message:@"Product discount must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}

	if( allOK ) {
		// Set values from UI
		if( segPercent.selectedSegmentIndex == 0 ) {
			projectProduct.isPercentDiscount = YES;
		} else {
			projectProduct.isPercentDiscount = NO;
		}
		if( segTax.selectedSegmentIndex == 0 ) {
			projectProduct.taxed = YES;
		} else {
			projectProduct.taxed = NO;
		}
		projectProduct.discountAmount = disc;
		projectProduct.price = price;
		projectProduct.productAdjustment.quantity = [txtQuantity.text intValue];
		
		// Save to DB
		NSInteger originalID = projectProduct.projectProductID;
		[[PSADataManager sharedInstance] saveProjectProduct:projectProduct];
		// Add to our array
		if( ![project.products containsObject:projectProduct] ) {
			BOOL inserted = NO;
			for( NSInteger i=0; i<project.products.count; i++ ) {
				ProjectProduct *existing = [project.products objectAtIndex:i];
				if( [projectProduct.productName compare:existing.productName] != NSOrderedDescending ) {
					[project.products insertObject:projectProduct atIndex:i];
					inserted = YES;
					break;
				}
			}
			if( !inserted )	[project.products addObject:projectProduct];
		}
		// Update Invoice & Project totals
		[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
		// Transition views
		if( isModal ) {
			if( originalID == -1 ) {
				if( [[project.payments objectForKey:[project getKeyForEstimates]] count] > 0 || [[project.payments objectForKey:[project getKeyForInvoices]] count] > 0 ) {
					UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to choose any existing estimates or invoices to add this product to?" delegate:self cancelButtonTitle:@"Don't Add" destructiveButtonTitle:nil otherButtonTitles:@"Add", nil];
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
#pragma mark Relabelling
#pragma mark -

- (void) relabel {
	[self relabelWithDiscount:txtDiscount.text quantity:txtQuantity.text price:txtPrice.text];
}

- (void) relabelWithPrice:(NSString*)priceText {
	[self relabelWithDiscount:txtDiscount.text quantity:txtQuantity.text price:priceText];
}

- (void) relabelWithQuantity:(NSString*)quantityText {
	[self relabelWithDiscount:txtDiscount.text quantity:quantityText price:txtPrice.text];
}

- (void) relabelWithDiscount:(NSString*)discountText {
	[self relabelWithDiscount:discountText quantity:txtQuantity.text price:txtPrice.text];
}

- (void) relabelWithDiscount:(NSString*)discountText quantity:(NSString*)quantityText price:(NSString*)priceText {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	double total = 0;

	if( priceText ){
		NSNumber *pri = nil;
		if( [priceText hasPrefix:@" "] ) {
			pri = [formatter numberFromString:[priceText substringFromIndex:1]];
		} else {
			pri = [formatter numberFromString:priceText];
		}
		total = [pri doubleValue]*[quantityText intValue];
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
	
	lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithFloat:(total-disc)]];
	[lbTotal setNeedsDisplay];
	[formatter release];
}

#pragma mark -
#pragma mark Control Methods
#pragma mark -

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( textField == txtDiscount ) {
		[self relabelWithDiscount:[txtDiscount.text stringByReplacingCharactersInRange:range withString:string]];
	} else if( textField == txtQuantity ) {
		[self relabelWithQuantity:[txtQuantity.text stringByReplacingCharactersInRange:range withString:string]];
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
	[txtQuantity resignFirstResponder];
}

- (IBAction) valueChanged:(id)sender {
	[self relabel];
}

@end
