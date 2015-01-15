//
//  TransactionAdjustmentViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "Product.h"
#import "ProductAdjustment.h"
#import "Service.h"
#import "Transaction.h"
#import "TransactionItem.h"
#import "TransactionAdjustmentViewController.h"


@implementation TransactionAdjustmentViewController

@synthesize transactionItem, transaction, segPercent, segTax, txtDiscount, txtPrice, txtQuantity, txtSetupFee;
@synthesize lbDiscount, lbDollarSign, lbSetup, lbSetupDollarSign, lbTotal;

- (void)viewDidLoad {
	// Localize money symbols
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	lbDollarSign.text = [currencyFormatter currencySymbol];
	lbSetupDollarSign.text = [currencyFormatter currencySymbol];
	[segPercent setTitle:[currencyFormatter currencySymbol] forSegmentAtIndex:1];
	[currencyFormatter release];
	//
	if( transactionItem.item ) {
		if( [transactionItem.item isKindOfClass:[Product class]] ) {
			self.title = ((Product*)transactionItem.item).productName;
		} else if( [transactionItem.item isKindOfClass:[Service class]] ) {
			self.title = ((Service*)transactionItem.item).serviceName;
		} else if( [transactionItem.item isKindOfClass:[GiftCertificate class]] ) {
			self.title = @"GIFT CERTIFICATE";
			lbSetup.hidden = YES;
			lbSetupDollarSign.hidden = YES;
			txtSetupFee.hidden = YES;
		}
	}
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {

	if( transactionItem.isPercentDiscount ) {
		segPercent.selectedSegmentIndex = 0;
	}
	if( transactionItem.taxed ) {
		segTax.selectedSegmentIndex = 0;
	} else {
		segTax.selectedSegmentIndex = 1;
	}
	if( txtQuantity ) {
		if( transactionItem.productAdjustment ) {
			txtQuantity.text = [NSString stringWithFormat:@"%d", transactionItem.productAdjustment.quantity];
		} else {
			txtQuantity.text = @"1";
		}
	}
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setCurrencySymbol:@""];
	txtDiscount.text = [formatter stringFromNumber:transactionItem.discountAmount];
	txtPrice.text = [formatter stringFromNumber:transactionItem.itemPrice];
	if( txtSetupFee ) {
		if( transactionItem.setupFee ) {
			txtSetupFee.text = [formatter stringFromNumber:transactionItem.setupFee];
		}
	}
	[formatter release];

	[self relabel];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.lbDiscount = nil;
	self.lbDollarSign = nil;
	self.lbSetup = nil;
	self.lbSetupDollarSign = nil;
	self.lbTotal = nil;
	self.segPercent = nil;
	self.segTax = nil;
	self.txtDiscount = nil;
	self.txtPrice = nil;
	self.txtQuantity = nil;
	self.txtSetupFee = nil;
	[transactionItem release];
	[transaction release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (void) relabel {
	if( txtQuantity ) {
		[self relabelWithDiscount:txtDiscount.text quantity:txtQuantity.text price:txtPrice.text setupFee:@"0"];
	} else {
		[self relabelWithDiscount:txtDiscount.text quantity:@"1" price:txtPrice.text setupFee:txtSetupFee.text];
	}
}

- (void) relabelWithQuantity:(NSString*)quantityText {
	[self relabelWithDiscount:txtDiscount.text quantity:quantityText price:txtPrice.text setupFee:@"0"];
}

- (void) relabelWithDiscount:(NSString*)discountText {
	if( txtQuantity ) {
		[self relabelWithDiscount:discountText quantity:txtQuantity.text price:txtPrice.text setupFee:@"0"];
	} else {
		[self relabelWithDiscount:discountText quantity:@"1" price:txtPrice.text setupFee:txtSetupFee.text];
	}
}

- (void) relabelWithPrice:(NSString*)priceText {
	if( txtQuantity ) {
		[self relabelWithDiscount:txtDiscount.text quantity:txtQuantity.text price:priceText setupFee:@"0"];
	} else {
		[self relabelWithDiscount:txtDiscount.text quantity:@"1" price:priceText setupFee:txtSetupFee.text];
	}
}

- (void) relabelWithSetupFee:(NSString*)setupText {
	[self relabelWithDiscount:txtDiscount.text quantity:@"1" price:txtPrice.text setupFee:setupText];
}

- (void) relabelWithDiscount:(NSString*)discountText quantity:(NSString*)quantityText price:(NSString*)priceText setupFee:(NSString*)setupText {
	
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
	
	if( setupText ) {
		NSNumber *setup = nil;
		if( [setupText hasPrefix:@" "] ) {
			setup = [formatter numberFromString:[setupText substringFromIndex:1]];
		} else {
			setup = [formatter numberFromString:setupText];
		}
		total += [setup doubleValue];
	}
	
	double disc = total;
	NSNumber *discNum = nil;
	if( [discountText hasPrefix:@" "] ) {
		discNum = [formatter numberFromString:[discountText substringFromIndex:1]];
	} else {
		discNum = [formatter numberFromString:discountText];
	}
	if( transactionItem.isPercentDiscount ) {
		disc = total * ( [discNum doubleValue]/100 );
	} else {
		disc = [discNum doubleValue];
	}
	
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	lbDiscount.text = [formatter stringFromNumber:[NSNumber numberWithDouble:disc]];
	[lbDiscount setNeedsDisplay];
	
	lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithFloat:total-disc]];
	[lbTotal setNeedsDisplay];
	
	[formatter release];
}

- (void) done {
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
	
	if( disc && [disc doubleValue] >= 0.0 ) {
		if( price && [price doubleValue] >= 0.0 ) {
			if( transactionItem.itemType == PSATransactionItemProduct ) {
				if( txtQuantity && [txtQuantity.text doubleValue] >= 1 ) {
					if( transactionItem.productAdjustment ) {
						transactionItem.productAdjustment.quantity = [txtQuantity.text intValue];
					}
				} else {
					allOK = NO;
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Quantity" message:@"Quantity must be 1 or greater!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];	
					[alert release];
				}
			}
		} else {
			allOK = NO;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Price" message:@"Price must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];	
			[alert release];
		}
		
	} else {
		allOK = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Discount" message:@"Discount must not be less than 0!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
		
	if( allOK ) {
		transactionItem.discountAmount = disc;
		transactionItem.itemPrice = price;
		transactionItem.setupFee = setup;
		
		if( transactionItem.itemType == PSATransactionItemProduct ) {
			if( ![transaction.products containsObject:transactionItem] ) {
				[transaction.products addObject:transactionItem];
			}
		} else if( transactionItem.itemType == PSATransactionItemService ) {
			if( ![transaction.services containsObject:transactionItem] ) {
				[transaction.services addObject:transactionItem];
			}
		}
		
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}

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
	} else if( textField == txtSetupFee ) {
		[self relabelWithSetupFee:[txtSetupFee.text stringByReplacingCharactersInRange:range withString:string]];
	}
	return YES;
}

- (IBAction) valueChanged:(id)sender {
	if( sender == segPercent ) {
		if( segPercent.selectedSegmentIndex == 0 ) {
			transactionItem.isPercentDiscount = YES;
		} else {
			transactionItem.isPercentDiscount = NO;
		}
	} else if( sender == segTax ) {
		if( segTax.selectedSegmentIndex == 0 ) {
			transactionItem.taxed = YES;
		} else {
			transactionItem.taxed = NO;
		}
	}
	[self relabel];
}



@end
