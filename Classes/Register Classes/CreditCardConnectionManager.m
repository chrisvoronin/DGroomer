//
//  CreditCardConnectionManager.m
//  myBusiness
//
//  Created by David J. Maier on 3/15/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "CreditCardResponse.h"
#import "CreditCardPayment.h"
#import "CreditCardSettings.h"
#import "Project.h"
#import "ProjectEstimateInvoiceViewController.h"
#import "PSADataManager.h"
#import "Transaction.h"
#import "TransactionViewController.h"
#import "CreditCardConnectionManager.h"


@implementation CreditCardConnectionManager

@synthesize ccPayment, connData, delegate;

- (id) init {
	ccPayment = nil;
	currentObject = nil;
	previousElement = nil;
	ccSettings = [[PSADataManager sharedInstance] getCreditCardSettings];
	return self;
}

- (void) dealloc {
	//[ccPayment release];
	[currentObject release];
	[previousElement release];
	[ccSettings release];
	[super dealloc];
}

- (void) cancel {
	if( theConnection ) {
		[theConnection cancel];
		[theConnection release];
		theConnection = nil;
		if( connData ) {
			//[connData release];
			connData = nil;
		}
		[ccPayment resetStatus];
		[self.delegate processingDidChangeState];
	}
}

- (void) charge {
	//
	if( ccPayment ) {
		refundFailed = NO;
		// Start connection
		// CP
		NSString *x_cpversion = @"1.0";
		NSString *x_market_type = @"2";
		NSString *x_device_type = @"1";
		// CnP
		NSString *x_version = @"3.1";
		NSString *x_delim_data = @"TRUE";
		NSString *x_delim_char = @"|";
		NSString *x_relay_response = @"FALSE";
		
		//NSString *x_type = @"AUTH_ONLY";
		NSString *x_type = @"AUTH_CAPTURE";
		
		NSString *x_login = ccSettings.apiLogin;
		NSString *x_tran_key = ccSettings.transactionKey;
        
        if(x_login.length < 1 || x_tran_key.length < 1)
        {
            NSString *message = [[NSString alloc] initWithString:@"To process a credit card, please fill out the Credit Card Settings in the Settings option from the main screen."];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
            [message release];
            return;
        }
        
		NSString *x_amount =  [[NSString alloc] initWithFormat:@"%.2f", ([ccPayment.amount doubleValue]+[ccPayment.tip doubleValue])];
		NSString *x_card_num = ccPayment.ccNumber;
		NSString *x_card_code = ccPayment.ccCVV;
		NSString *x_exp_date = [[NSString alloc] initWithFormat:@"%02d-%02d", [ccPayment.ccExpirationMonth integerValue], [ccPayment.ccExpirationYear integerValue]];

		NSString *x_description = [NSString stringWithFormat:@"%@ credit card payment", APPLICATION_NAME];
		
		//NSString *x_currency_code = @"EUR";
		
		// Client info.
		NSString *x_first_name = ccPayment.nameFirst;
		NSString *x_last_name = ccPayment.nameLast;
		NSString *x_phone = ccPayment.clientPhone;
		NSString *x_email = ccPayment.clientEmail;
		NSString *x_address = ccPayment.addressStreet;
		NSString *x_city = ccPayment.addressCity;
		NSString *x_state = ccPayment.addressState;
		NSString *x_zip = ccPayment.addressZip;
		
		// Create the POST data and NSURLConnection, then fire it off to Authorize.Net
		NSURL *url = [[NSURL alloc] initWithString:[ccSettings getGatewayURL]];
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
		[url release];
		[req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
		[req setHTTPMethod:@"POST"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		
		// adding the body
		NSMutableData *postBody = [[NSMutableData alloc] init];
		// Parameter Information
		[postBody appendData:[@"x_login=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_login dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_tran_key=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_tran_key dataUsingEncoding:NSASCIIStringEncoding]];
		
		if( ccSettings.processingType == CreditCardProcessingTypeCardPresent ) {
			[postBody appendData:[@"&x_cpversion=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_cpversion dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_market_type=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_market_type dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_device_type=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_device_type dataUsingEncoding:NSASCIIStringEncoding]];
		} else {
			[postBody appendData:[@"&x_version=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_version dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_relay_response=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_relay_response dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_delim_data=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_delim_data dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_delim_char=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_delim_char dataUsingEncoding:NSASCIIStringEncoding]];
			
			if( x_email && ccSettings.sendEmailFromGateway ) {
				[postBody appendData:[@"&x_email_customer=" dataUsingEncoding:NSASCIIStringEncoding]];
				[postBody appendData:[@"TRUE" dataUsingEncoding:NSASCIIStringEncoding]];
			}
		}
		
		[postBody appendData:[@"&x_amount=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_amount dataUsingEncoding:NSASCIIStringEncoding]];
		[x_amount release];

		/*
		if( x_currency_code ) {
			[postBody appendData:[@"&x_currency_code=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_currency_code dataUsingEncoding:NSASCIIStringEncoding]];
		}
		 */
		
		[postBody appendData:[@"&x_type=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_type dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_card_num=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_card_num dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_card_code=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_card_code dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_exp_date=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_exp_date dataUsingEncoding:NSASCIIStringEncoding]];
		[x_exp_date release];
		
		[postBody appendData:[@"&x_description=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_description dataUsingEncoding:NSASCIIStringEncoding]];
		
		if( x_first_name ) {
			[postBody appendData:[@"&x_first_name=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_first_name dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_last_name ) {
			[postBody appendData:[@"&x_last_name=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_last_name dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_address ) {
			[postBody appendData:[@"&x_address=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_address dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_city ) {
			[postBody appendData:[@"&x_city=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_city dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_state ) {
			[postBody appendData:[@"&x_state=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_state dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_zip ) {
			[postBody appendData:[@"&x_zip=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_zip dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_phone ) {
			[postBody appendData:[@"&x_phone=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_phone dataUsingEncoding:NSASCIIStringEncoding]];
		}
		if( x_email && ccSettings.sendEmailFromGateway ) {
			[postBody appendData:[@"&x_email=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_email dataUsingEncoding:NSASCIIStringEncoding]];
		}
		
		/*if( ccSettings.testMode ) {
		 [postBody appendData:[@"&x_test_request=" dataUsingEncoding:NSASCIIStringEncoding]];
		 [postBody appendData:[@"TRUE" dataUsingEncoding:NSASCIIStringEncoding]];
		 }*/
		
		[req setHTTPBody:postBody];
		[postBody release];
		
		ccPayment.status = CreditCardProcessingConnecting;
		ccPayment.date = [NSDate date];
		[self.delegate processingDidChangeState];
		// Create the connection and get the data
		theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		
		if( theConnection )	{
			connData = [[NSMutableData alloc] initWithLength:0];
		}
	}
}

- (void) refund {

	//
	if( ccPayment ) {
		refundFailed = NO;
		// Start connection
		// CP
		NSString *x_cpversion = @"1.0";
		NSString *x_market_type = @"2";
		NSString *x_device_type = @"1";
		// CnP
		NSString *x_version = @"3.1";
		NSString *x_delim_data = @"TRUE";
		NSString *x_delim_char = @"|";
		NSString *x_relay_response = @"FALSE";
		
		NSString *x_type = @"CREDIT";
		
		NSString *x_login = ccSettings.apiLogin;
		NSString *x_tran_key = ccSettings.transactionKey;
		NSString *x_amount =  [[NSString alloc] initWithFormat:@"%.2f", ([ccPayment.amount doubleValue]+[ccPayment.tip doubleValue])];
		NSString *x_card_num = ccPayment.ccNumber;
		
		NSString *x_ref_trans_id = nil;
		if( ccPayment.response.transID && [ccPayment.response.transID isEqualToString:@"0"] ) {
			x_ref_trans_id = ccPayment.response.refTransID;
		} else {
			x_ref_trans_id = ccPayment.response.transID;
		}

		// Create the POST data and NSURLConnection, then fire it off to Authorize.Net
		NSURL *url = [[NSURL alloc] initWithString:[ccSettings getGatewayURL]];
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
		[url release];
		[req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
		[req setHTTPMethod:@"POST"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

		// adding the body
		NSMutableData *postBody = [[NSMutableData alloc] init];
		// Parameter Information
		[postBody appendData:[@"x_login=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_login dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_tran_key=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_tran_key dataUsingEncoding:NSASCIIStringEncoding]];
		
		if( ccSettings.processingType == CreditCardProcessingTypeCardPresent ) {
			[postBody appendData:[@"&x_cpversion=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_cpversion dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_market_type=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_market_type dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_device_type=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_device_type dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_ref_trans_id=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_ref_trans_id dataUsingEncoding:NSASCIIStringEncoding]];
		} else {
			[postBody appendData:[@"&x_version=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_version dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_relay_response=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_relay_response dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_delim_data=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_delim_data dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_delim_char=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_delim_char dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_trans_id=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_ref_trans_id dataUsingEncoding:NSASCIIStringEncoding]];
		}
		
		[postBody appendData:[@"&x_amount=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_amount dataUsingEncoding:NSASCIIStringEncoding]];
		[x_amount release];
		
		[postBody appendData:[@"&x_type=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_type dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_card_num=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_card_num dataUsingEncoding:NSASCIIStringEncoding]];
		
		[req setHTTPBody:postBody];
		[postBody release];
		
		ccPayment.status = CreditCardProcessingConnecting;
		ccPayment.date = [NSDate date];
		[self.delegate processingDidChangeState];
		// Create the connection and get the data
		theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		
		if( theConnection )	{
			connData = [[NSMutableData alloc] initWithLength:0];
		}
	}
}

- (void) voidTransaction {
	//
	if( ccPayment ) {
		// So the parser knows this is a void not refund
		refundFailed = YES;
		// Start connection
		// CP
		NSString *x_cpversion = @"1.0";
		NSString *x_market_type = @"2";
		NSString *x_device_type = @"1";
		// CnP
		NSString *x_version = @"3.1";
		NSString *x_delim_data = @"TRUE";
		NSString *x_delim_char = @"|";
		NSString *x_relay_response = @"FALSE";
		
		NSString *x_type = @"VOID";
		
		NSString *x_login = ccSettings.apiLogin;
		NSString *x_tran_key = ccSettings.transactionKey;
		NSString *x_ref_trans_id = nil;
		if( ccPayment.response.transID && [ccPayment.response.transID isEqualToString:@"0"] ) {
			x_ref_trans_id = ccPayment.response.refTransID;
		} else {
			x_ref_trans_id = ccPayment.response.transID;
		}
		
		// Create the POST data and NSURLConnection, then fire it off to Authorize.Net
		NSURL *url = [[NSURL alloc] initWithString:[ccSettings getGatewayURL]];
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
		[url release];
		[req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
		[req setHTTPMethod:@"POST"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

		// adding the body
		NSMutableData *postBody = [[NSMutableData alloc] init];
		// Parameter Information
		[postBody appendData:[@"x_login=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_login dataUsingEncoding:NSASCIIStringEncoding]];
		
		[postBody appendData:[@"&x_tran_key=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_tran_key dataUsingEncoding:NSASCIIStringEncoding]];
		
		if( ccSettings.processingType == CreditCardProcessingTypeCardPresent ) {
			[postBody appendData:[@"&x_cpversion=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_cpversion dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_market_type=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_market_type dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_device_type=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_device_type dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_ref_trans_id=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_ref_trans_id dataUsingEncoding:NSASCIIStringEncoding]];
		} else {
			[postBody appendData:[@"&x_version=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_version dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_relay_response=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_relay_response dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_delim_data=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_delim_data dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_delim_char=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_delim_char dataUsingEncoding:NSASCIIStringEncoding]];
			
			[postBody appendData:[@"&x_trans_id=" dataUsingEncoding:NSASCIIStringEncoding]];
			[postBody appendData:[x_ref_trans_id dataUsingEncoding:NSASCIIStringEncoding]];
		}
		
		[postBody appendData:[@"&x_type=" dataUsingEncoding:NSASCIIStringEncoding]];
		[postBody appendData:[x_type dataUsingEncoding:NSASCIIStringEncoding]];
		
		[req setHTTPBody:postBody];
		[postBody release];
		
		ccPayment.status = CreditCardProcessingConnecting;
		ccPayment.date = [NSDate date];
		[self.delegate processingDidChangeState];
		// Create the connection and get the data
		theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		
		if( theConnection )	{
			connData = [[NSMutableData alloc] initWithLength:0];
		}
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
#pragma mark -

- (void) connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	//DebugLog( @"didSendBodyData: written: %d expected: %d", totalBytesWritten, totalBytesExpectedToWrite );
	// Update status when written==expected
	if( totalBytesWritten == totalBytesExpectedToWrite ) {
		ccPayment.status = CreditCardProcessingRequestSent;
		ccPayment.date = [NSDate date];
		[delegate processingDidChangeState];
	}
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	//DebugLog( @"didReceiveResponse" );
	[connData setLength: 0];
	ccPayment.status = CreditCardProcessingResponseReceived;
	ccPayment.date = [NSDate date];
	[delegate processingDidChangeState];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//DebugLog( @"didReceiveData" );
	[connData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//DebugLog( @"didFailWithError: %@", [error localizedDescription] );
	ccPayment.status = CreditCardProcessingError;
	ccPayment.date = [NSDate date];
	[delegate processingDidChangeState];
	// Done... these aren't needed
	[connection release];
	connection = nil;
	[connData release];
	connData = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {

	//NSString *rsltStr =  [[NSString alloc] initWithData:connData encoding:NSUTF8StringEncoding];
	//DebugLog( @"%@ \n\n\n", rsltStr );
	//[rsltStr release];
	
	ccPayment.status = CreditCardProcessingParsingResponse;
	ccPayment.date = [NSDate date];
	[delegate processingDidChangeState];
	
	if( ccSettings.processingType == CreditCardProcessingTypeCardPresent ) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:connData];
		parser.delegate = self;
		[parser parse];
		[parser release];
	} else {
		[self parseResponseDelimited:connData];
	}
	
	// Done... these aren't needed
	[connection release];
	connection = nil;
	[connData release];
	connData = nil;
}

/*
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	DebugLog( @"Received authentication challenge" );
}
 */

#pragma mark -
#pragma mark Delimited Parser
#pragma mark -

- (void) parseResponseDelimited:(NSData*)data {
	NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSArray *array = [dataStr componentsSeparatedByString:@"|"];
	
	// Don't overwrite a previous response. Want to keep the transID, etc.
	if( !ccPayment.response ) {
		CreditCardResponse *resp = [[CreditCardResponse alloc] init];
		ccPayment.response = resp;
		[resp release];
	} else {
		[ccPayment.response.messages removeAllObjects];
		[ccPayment.response.errors removeAllObjects];
	}
	
	NSString *trannyType;
	
	for( int i=1; i <= array.count; i++ ) {
		//
		switch (i) {
			case 1:
				// Response Code
				ccPayment.response.responseCode = [[array objectAtIndex:i-1] integerValue];
				break;
			case 2:
				// Response Subcode
				break;
			case 3:
				// Response Reason Code
				break;
			case 4:
				// Response Reason Text
				// Use the Response Reason Code for the key
				if( ccPayment.response.responseCode == 3 ) {
					// Error
					[ccPayment.response.errors setObject:[array objectAtIndex:i-1] forKey:[array objectAtIndex:i-2]];
				} else {
					[ccPayment.response.messages setObject:[array objectAtIndex:i-1] forKey:[array objectAtIndex:i-2]];
				}
				break;
			case 5:
				// Auth Code
				ccPayment.response.authCode = [array objectAtIndex:i-1];
				break;
			case 6:
				// AVS Result
				ccPayment.response.avsResultCode = [array objectAtIndex:i-1];
				break;
			case 7:
				// Authorize.Net Transaction ID
				if( ![[array objectAtIndex:i-1] isEqualToString:@"0"] ) {
					ccPayment.response.transID = [array objectAtIndex:i-1];
				}
				break;
			case 12:
				trannyType = [[array objectAtIndex:i-1] lowercaseString];
				break;
			case 38:
				// Transaction MD5 Hash
				ccPayment.response.transHash = [array objectAtIndex:i-1];
				break;
			case 39:
				// CCV Response Code
				ccPayment.response.cvvResultCode = [array objectAtIndex:i-1];
				break;
			case 40:
				// CAVV Response Code
				break;
		}

	}
	
	// Done Parsing
	if( ccPayment.response.responseCode == 1 ) {
		if( [trannyType isEqualToString:@"credit"] ) {
			ccPayment.status = CreditCardProcessingRefunded;
		} else if( [trannyType isEqualToString:@"void"] ) {
			ccPayment.status = CreditCardProcessingVoided;
			// So we don't loop voiding
			refundFailed = NO;
		} else {
			ccPayment.status = CreditCardProcessingApproved;
		}
	} else if( ccPayment.response.responseCode == 2 ) {
		ccPayment.status = CreditCardProcessingDeclined;
	} else {
		ccPayment.status = CreditCardProcessingError;
		
		for( NSString *errorCode in [ccPayment.response.errors allKeys] ) {
			if( [errorCode isEqualToString:@"54"] ) {
				// Error 54: The referenced transaction does not meet the criteria for issuing a credit.
				refundFailed = YES;
				break;
			}
		}
	}
	
	if( refundFailed ) {
		[ccPayment voidWithDelegate:self.delegate];
	} else {
		ccPayment.date = [NSDate date];
		// Done...
		[delegate processingDidChangeState];
	}
	
	[dataStr release];
}

#pragma mark -
#pragma mark NSXMLParser Delegate Methods
#pragma mark -

/*
 * Constants for the XML element names that will be considered during the parse. 
 * Declaring these as static constants reduces the number of objects created during the run
 * and is less prone to programmer error.
 */
static NSString *kElement_AuthCode = @"AuthCode";
static NSString *kElement_AVSResultCode = @"AVSResultCode";
static NSString *kElement_Code = @"Code";
static NSString *kElement_CVVResultCode = @"CVVResultCode";
static NSString *kElement_Description = @"Description";
//static NSString *kElement_Error = @"Error";
//static NSString *kElement_Errors = @"Errors";
static NSString *kElement_ErrorCode = @"ErrorCode";
static NSString *kElement_ErrorText = @"ErrorText";
//static NSString *kElement_Message = @"Message";
//static NSString *kElement_Messages = @"Messages";
static NSString *kElement_RefTransID = @"RefTransID";
static NSString *kElement_Response = @"response";
static NSString *kElement_ResponseCode = @"ResponseCode";
static NSString *kElement_TransHash = @"TransHash";
static NSString *kElement_TransID = @"TransID";

/*
 *
 */
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict
{
	//DebugLog( @"didStartElement: %@  qual: %@  attributes: %d", elementName, qName, attributeDict.count );
	if( [elementName isEqualToString:kElement_Response] ) {
		CreditCardResponse *resp = [[CreditCardResponse alloc] init];
		ccPayment.response = resp;
		[resp release];
	}
	
	// Need to retain?
	if( previousElement )	[previousElement release];
	previousElement = [elementName retain];
}

/*
 *
 */
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{	
	//DebugLog( @"String: %@", string );
	// Error Storage
	if( [previousElement isEqualToString:kElement_ErrorCode] ) {
		currentObject = [string retain];
	} 
	else if( [previousElement isEqualToString:kElement_ErrorText] ) {
		[ccPayment.response.errors setObject:string forKey:currentObject];
		[currentObject release];
		currentObject = nil;
	}
	// Message Storage
	else if( [previousElement isEqualToString:kElement_Code] ) {
		currentObject = [string retain];
	}
	else if( [previousElement isEqualToString:kElement_Description] ) {
		[ccPayment.response.messages setObject:string forKey:currentObject];
		[currentObject release];
		currentObject = nil;
	}
	// Response Storage
	else if( [previousElement isEqualToString:kElement_ResponseCode] ) {
		ccPayment.response.responseCode = [string integerValue];
	}
	else if( [previousElement isEqualToString:kElement_AuthCode] ) {
		ccPayment.response.authCode = string;
	}
	else if( [previousElement isEqualToString:kElement_AVSResultCode] ) {
		ccPayment.response.avsResultCode = string;
	}
	else if( [previousElement isEqualToString:kElement_CVVResultCode] ) {
		ccPayment.response.cvvResultCode = string;
	}
	else if( [previousElement isEqualToString:kElement_TransID] ) {
		ccPayment.response.transID = string;
	}
	else if( [previousElement isEqualToString:kElement_RefTransID] ) {
		ccPayment.response.refTransID = string;
	}
	else if( [previousElement isEqualToString:kElement_TransHash] ) {
		ccPayment.response.transHash = string;
	}

}

/*
 *
 */
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//DebugLog( @"didEndElement: %@  qual: %@", elementName, qName );
	if( [elementName isEqualToString:kElement_Response] ) {

		if( ccPayment.response.responseCode == 1 ) {
			if( ccPayment.response.refTransID ) {

				// Refunded or Voided? How to tell?
				if( !refundFailed ) {
					ccPayment.status = CreditCardProcessingRefunded;
				} else {
					ccPayment.status = CreditCardProcessingVoided;
					// So we don't loop voiding
					refundFailed = NO;
				}
				
				
			} else {
				ccPayment.status = CreditCardProcessingApproved;
			}
		} else if( ccPayment.response.responseCode == 2 ) {
			ccPayment.status = CreditCardProcessingDeclined;
		} else {
			ccPayment.status = CreditCardProcessingError;

			for( NSString *errorCode in [ccPayment.response.errors allKeys] ) {
				if( [errorCode isEqualToString:@"54"] ) {
					// Error 54: The referenced transaction does not meet the criteria for issuing a credit.
					// Try a void instead...
					//[parser abortParsing];
					refundFailed = YES;
					break;
				}
			}
		}
		
		if( refundFailed ) {
			[ccPayment voidWithDelegate:self.delegate];
		} else {
			ccPayment.date = [NSDate date];
			// Done...
			[delegate processingDidChangeState];
		}
	}
}

/*
 *
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	//DebugLog( @"parseErrorOccurred: %@. %@. %@.", [parseError localizedDescription], [parseError localizedFailureReason], [parseError localizedRecoveryOptions] );
	ccPayment.status = CreditCardProcessingError;
	ccPayment.date = [NSDate date];
	// Create an error with our own code, and parse error message
	[ccPayment.response.errors setObject:@"Parsing error occurred! Please report this message to our support." forKey:@"999"];
}


@end