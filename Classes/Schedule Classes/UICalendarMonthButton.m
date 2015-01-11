//
//  UICalendarMonthButton.m
//  myBusiness
//
//  Created by David J. Maier on 11/27/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "UICalendarMonthButton.h"


@implementation UICalendarMonthButton

@synthesize appointmentsInAfternoon, appointmentsInMorning, dayNumber, rowNumber;


- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void) dealloc {
	[dayNumber release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIView Drawing Methods
#pragma mark -
/*
 *	Draws the components to the screen.
 *	Creates a shadowed rounded rectangle with service color, white gradient for lighting effect at the top
 *	and the text to display for the appointment.
 */
- (void)drawRect:(CGRect)rect {
	// Get context
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	if( self.selected ) {
		[self drawSelectedInContext:theContext frame:rect];
		if( dayNumber ) {
			[self drawSelectedTextInContext:theContext frame:rect];
		}
		[self drawAppointmentNotifiersSelectedInContext:theContext frame:rect];
	} else {
		[self drawNormalInContext:theContext frame:rect];
		if( dayNumber ) {
			if( self.highlighted ) {
				[self drawHighlightedTextInContext:theContext frame:rect];
			} else {
				[self drawNormalTextInContext:theContext frame:rect];
			}
		}
		[self drawAppointmentNotifiersInContext:theContext frame:rect];
	}
}

- (void) drawAppointmentNotifiersInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );
	CGContextSetRGBFillColor( context, .22, .271, .333, 1.0 );
	// Shadow down 1 pixel
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a positive offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, 1), 0, [[UIColor whiteColor] CGColor] );
	} else {
		// 3.1 wants a -2 offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, -1), 0, [[UIColor whiteColor] CGColor] );
	}
	// Draw circles
	if( appointmentsInMorning ) {
		CGContextAddEllipseInRect( context, CGRectMake( 15, 35, 4, 4) );
		CGContextDrawPath( context, kCGPathFill );
	}
	if( appointmentsInAfternoon ) {
		//CGContextSetRGBFillColor( context, 0, 0, 0, 1.0 );
		CGContextAddEllipseInRect( context, CGRectMake( 28, 35, 4, 4) );
		CGContextDrawPath( context, kCGPathFill );
	}
	// Restore state
	CGContextRestoreGState( context );
}

- (void) drawAppointmentNotifiersSelectedInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );
	CGContextSetRGBFillColor( context, 1, 1, 1, 1.0 );
	// Shadow up 1 pixel (looks like a beveled inset)
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a positive offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, -1), 0, [[UIColor blackColor] CGColor] );
	} else {
		// 3.1 wants a -2 offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, 1), 0, [[UIColor blackColor] CGColor] );
	}
	// Draw circles
	if( appointmentsInMorning ) {
		CGContextAddEllipseInRect( context, CGRectMake( 15, 35, 4, 4) );
		CGContextDrawPath( context, kCGPathFill );
	}
	if( appointmentsInAfternoon ) {
		//CGContextSetRGBFillColor( context, 0, 0, 0, 1.0 );
		CGContextAddEllipseInRect( context, CGRectMake( 28, 35, 4, 4) );
		CGContextDrawPath( context, kCGPathFill );
	}
	// Restore state
	CGContextRestoreGState( context );
}

/*
 *	Only draws a rounded rectangle, with gradient and outline
 */
- (void) drawHighlightedTextInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );	
	// Draw the text
	CGContextSetRGBFillColor( context, .569, .596, .635, 1.0 );
	// Shadow down 1 pixel
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a positive offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, 1), 0, [[UIColor whiteColor] CGColor] );
	} else {
		// 3.1 wants a -2 offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, -1), 0, [[UIColor whiteColor] CGColor] );
	}
	// 10 pixels indented, 3 from the top
	CGRect textFrame = CGRectMake( 0, 6, theFrame.size.width-1, theFrame.size.height-15 );
	[dayNumber drawInRect:textFrame withFont:[UIFont boldSystemFontOfSize:24] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	// Restore state
	CGContextRestoreGState( context );
}

/*
 *	Only draws a rounded rectangle, with gradient and outline
 */
- (void) drawNormalInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );

	// Background (grayish) based on row
	switch ( rowNumber ) {
		case 0:
			CGContextSetRGBFillColor( context, .88, .88, .89, 1.0 );
			break;
		case 1:
			CGContextSetRGBFillColor( context, .86, .86, .87, 1.0 );
			break;
		case 2:
			CGContextSetRGBFillColor( context, .84, .84, .86, 1.0 );
			break;
		case 3:
			CGContextSetRGBFillColor( context, .827, .82, .84, 1.0 );
			break;
		case 4:
			CGContextSetRGBFillColor( context, .81, .81, .827, 1.0 );
			break;
		case 5:
			CGContextSetRGBFillColor( context, .79, .79, .81, 1.0 );
			break;
	}
	
	CGContextAddRect( context, theFrame );
	CGContextDrawPath( context, kCGPathFill );
	
	// Stroke color (whitish) based on row
	switch ( rowNumber ) {
		case 0:
			CGContextSetRGBFillColor( context, .952, .952, .956, 1.0 );
			break;
		case 1:
			CGContextSetRGBFillColor( context, .945, .945, .95, 1.0 );
			break;
		case 2:
			CGContextSetRGBFillColor( context, .94, .94, .945, 1.0 );
			break;
		case 3:
			CGContextSetRGBFillColor( context, .93, .93, .94, 1.0 );
			break;
		case 4:
			CGContextSetRGBFillColor( context, .93, .92, .93, 1.0 );
			break;
		case 5:
			CGContextSetRGBFillColor( context, .92, .92, .93, 1.0 );
			break;
	}
	
	CGRect top = CGRectMake( 1, 0, theFrame.size.width-2, 1);
	CGRect right = CGRectMake( theFrame.size.width-2, 0, 1, theFrame.size.height-1);
	CGContextAddRect( context, top );
	CGContextDrawPath( context, kCGPathFill );
	CGContextAddRect( context, right );
	CGContextDrawPath( context, kCGPathFill );
	
	CGContextSetRGBFillColor( context, .627, .643, .678, 1.0 );
	CGRect left = CGRectMake( 0, 0, 1, theFrame.size.height );
	CGRect bottom = CGRectMake( 0, theFrame.size.height-1, theFrame.size.width, 1 );
	CGContextAddRect( context, left );
	CGContextDrawPath( context, kCGPathFill );
	CGContextAddRect( context, bottom );
	CGContextDrawPath( context, kCGPathFill );
	
	// Restore state
	CGContextRestoreGState( context );
}

/*
 *	Only draws a rounded rectangle, with gradient and outline
 */
- (void) drawNormalTextInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );	
	// Draw the text
	CGContextSetRGBFillColor( context, .22, .271, .333, 1.0 );
	// Shadow down 1 pixel
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a positive offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, 1), 0, [[UIColor whiteColor] CGColor] );
	} else {
		// 3.1 wants a -2 offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, -1), 0, [[UIColor whiteColor] CGColor] );
	}
	// 10 pixels indented, 3 from the top
	CGRect textFrame = CGRectMake( 0, 6, theFrame.size.width-1, theFrame.size.height-15 );
	[dayNumber drawInRect:textFrame withFont:[UIFont boldSystemFontOfSize:24] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	// Restore state
	CGContextRestoreGState( context );
}

/*
 *	Only draws a rounded rectangle, with gradient and outline
 */
- (void) drawSelectedInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );
	//
	CGFloat width = (theFrame.size.width-1)/2;
	CGFloat height = theFrame.size.height/2;
	// The blue bottom half
	CGContextSetRGBFillColor( context, 0, .447, .886, 1.0 );
	CGRect realSize = CGRectMake( 0, width-1, theFrame.size.width-1, height );
	CGContextAddRect( context, realSize );
	CGContextDrawPath( context, kCGPathFill );
	// Draw a blue gradient for the top half
	CGGradientRef myGradient; 
	CGColorSpaceRef myColorspace; 
	size_t num_locations = 2; 
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { .47, .706, .941, 1.0,	 .16, .537, .906, 1.0 }; 
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents( myColorspace, components, locations, num_locations ); 
	CGContextDrawLinearGradient( context, myGradient, CGPointMake(width,0), CGPointMake(width,height), 0);
	CGGradientRelease(myGradient);
	// Black lines around
	CGContextSetRGBFillColor( context, 0, 0, 0, 1.0 );
	CGRect top = CGRectMake( 1, 0, theFrame.size.width-2, 1);
	CGRect right = CGRectMake( theFrame.size.width-2, 0, 1, theFrame.size.height-1);
	CGContextAddRect( context, top );
	CGContextDrawPath( context, kCGPathFill );
	CGContextAddRect( context, right );
	CGContextDrawPath( context, kCGPathFill );
	//
	CGRect left = CGRectMake( 0, 0, 1, theFrame.size.height );
	CGRect bottom = CGRectMake( 0, theFrame.size.height-1, theFrame.size.width, 1 );
	CGContextAddRect( context, left );
	CGContextDrawPath( context, kCGPathFill );
	CGContextAddRect( context, bottom );
	CGContextDrawPath( context, kCGPathFill );
	// Restore state
	CGContextRestoreGState( context );
}

/*
 *	Only draws a rounded rectangle, with gradient and outline
 */
- (void) drawSelectedTextInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );
	// Draw the text
	CGContextSetRGBFillColor( context, 1.0, 1.0, 1.0, 1.0 );
	// Drop Shadow down 1 pixel (looks like a beveled inset)
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a positive offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, 1), 0, [[UIColor blackColor] CGColor] );
	} else {
		// 3.1 wants a -2 offset
		CGContextSetShadowWithColor( context, CGSizeMake(0, -1), 0, [[UIColor blackColor] CGColor] );
	}
	// 10 pixels indented, 3 from the top
	CGRect textFrame = CGRectMake( 0, 6, theFrame.size.width-1, theFrame.size.height-15 );
	[dayNumber drawInRect:textFrame withFont:[UIFont boldSystemFontOfSize:24] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	// Restore state
	CGContextRestoreGState( context );
}

@end
