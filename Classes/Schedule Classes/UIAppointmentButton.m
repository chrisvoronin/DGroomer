//
//  UIAppointmentButton.m
//  myBusiness
//
//  Created by David J. Maier on 11/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "Client.h"
#import "Project.h"
#import "Service.h"
#import "UIAppointmentButton.h"


@implementation UIAppointmentButton

@synthesize appointment, delegate, column, isWeekAppointment, pixelsPerMinute, positionFixed, totalColumns;

#define SHADOW_OFFSET 4
#define MINIMUM_HEIGHT 30

- (id)initWithFrame:(CGRect)frame {
	CGRect myFrame = CGRectMake( frame.origin.x, frame.origin.y, frame.size.width, frame.size.height+SHADOW_OFFSET );
    if (self = [super initWithFrame:myFrame]) {
        // Initialization code
		column = -1;
		isWeekAppointment = NO;
		positionFixed = NO;
		totalColumns = -1;
    }
    return self;
}


- (void)dealloc {
	[appointment release];
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
	// Draw for the full size of our frame
	CGRect rectAll = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
	[self drawRoundedRectWithTextInContext:theContext frame:rectAll];
}

/*
 *	Only draws a rounded rectangle, with gradient and outline
 */
- (void) drawRoundedRectInContext:(CGContextRef)context frame:(CGRect)theFrame {
	// Save state
	CGContextSaveGState( context );
	// Draw a rounded rect with 1px black border
	CGContextSetRGBStrokeColor( context, 0.0, 0.0, 0.0, .3 );
	if( appointment.type == iBizAppointmentTypeSingleService ) {
		CGContextSetFillColorWithColor( context, [[((Service*)appointment.object).color colorWithAlphaComponent:.7] CGColor] );
	} else if( appointment.type == iBizAppointmentTypeProject ) {
		CGContextSetFillColorWithColor( context, [[UIColor colorWithRed:.596 green:.678 blue:.843 alpha:.7] CGColor] );
	} else {
		CGContextSetFillColorWithColor( context, [[UIColor colorWithRed:.165 green:.733 blue:.945 alpha:.7] CGColor] );
	}
	// Shadowize
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a positive offset
		CGContextSetShadow( context, CGSizeMake(0, 2), 2 );
	} else {
		// 3.1 wants a -2 offset
		CGContextSetShadow( context, CGSizeMake(0, -2), 2 );
	}
	// This creates a rounded rectangle by making a bunch of arcs
	// I have removed the descriptive comments found in the QuartzDemo project
	CGRect rrect;
	if( isWeekAppointment ) {
		rrect = CGRectMake( 1, theFrame.origin.y, theFrame.size.width-1, theFrame.size.height-SHADOW_OFFSET );
	} else {
		rrect = CGRectMake( 3, theFrame.origin.y, theFrame.size.width-6, theFrame.size.height-SHADOW_OFFSET );
	}
	CGFloat radius = 7.0;
	// Get the min, max, and midpoints
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	// Move around the shape
	CGContextMoveToPoint( context, minx, midy );
	CGContextAddArcToPoint( context, minx, miny, midx, miny, radius );
	CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius );
	CGContextAddArcToPoint( context, maxx, maxy, midx, maxy, radius );
	CGContextAddArcToPoint( context, minx, maxy, minx, midy, radius );
	// Close the path
	CGContextClosePath( context );
	// Draw 
	CGContextDrawPath( context, kCGPathFillStroke );
	// Restore all context we just set
	CGContextRestoreGState( context );
	CGContextSaveGState( context );
	// Recreate the top 15 pixels (gradient) of our rounded rect
	CGContextMoveToPoint( context, minx, 15 );
	CGContextAddArcToPoint( context, minx, miny, midx, miny, radius );
	CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius );
	CGContextAddLineToPoint( context, maxx, 15 );
	CGContextClosePath( context );
	// Clipping mask
	CGContextClip( context );
	// Draw a gradient from the top (white, half alpha) down to background color (white, no alpha)
	CGGradientRef myGradient; 
	CGColorSpaceRef myColorspace; 
	size_t num_locations = 2; 
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 1.0, 1.0, 1.0, .5,	1.0, 1.0, 1.0, 0.0 }; 
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents( myColorspace, components, locations, num_locations ); 
	CGContextDrawLinearGradient( context, myGradient, CGPointMake(midx,0), CGPointMake(midx,15), 0);
	CGGradientRelease(myGradient);
	// Restore state
	CGContextRestoreGState( context );
	// Draw overlay if highlighted == YES
	if( self.highlighted ) {
		CGContextSaveGState( context );
		CGContextSetRGBFillColor( context, 0.0, 0.0, 0.0, .3 );
		CGContextMoveToPoint( context, minx, midy );
		CGContextAddArcToPoint( context, minx, miny, midx, miny, radius );
		CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius );
		CGContextAddArcToPoint( context, maxx, maxy, midx, maxy, radius );
		CGContextAddArcToPoint( context, minx, maxy, minx, midy, radius );
		CGContextClosePath( context );
		CGContextDrawPath( context, kCGPathFill );
	}
}

/*
 *	Draws a rounded rect of size frame, with the appointment text inserted at the top
 */
- (void) drawRoundedRectWithTextInContext:(CGContextRef)context frame:(CGRect)theFrame {
	[self drawRoundedRectInContext:context frame:theFrame];
	// Save state
	CGContextSaveGState( context );
	// Setup some text
	NSString *label = nil;
	UIFont *font = nil;
	CGRect textFrame;
	if( isWeekAppointment ) {
		font = [UIFont boldSystemFontOfSize:10];
		textFrame = CGRectMake( 5, 3, theFrame.size.width-10, theFrame.size.height-6 );
		if( appointment.type == iBizAppointmentTypeSingleService ) {
			label = [[NSString alloc] initWithFormat:@"%@%@", (appointment.notes) ? @"*" : @"", ((Service*)appointment.object).serviceName];
		} else if( appointment.type == iBizAppointmentTypeProject ) {
			label = [[NSString alloc] initWithFormat:@"%@%@", (appointment.notes) ? @"*" : @"", ((Project*)appointment.object).name];
		} else {
			label = [[NSString alloc] initWithFormat:@"%@", (appointment.notes) ? appointment.notes : @"Block"];
		}
	} else {
		font = [UIFont boldSystemFontOfSize:14];
		textFrame = CGRectMake( 10, 3, theFrame.size.width-15, theFrame.size.height-6 );
		if( appointment.type == iBizAppointmentTypeSingleService ) {
			label = [[NSString alloc] initWithFormat:@"%@%@ - %@", (appointment.notes) ? @"*" : @"", ((Service*)appointment.object).serviceName, (appointment.client) ? [appointment.client getClientName] : @"No Client"];
		} else if( appointment.type == iBizAppointmentTypeProject ) {
			label = [[NSString alloc] initWithFormat:@"%@%@ - %@", (appointment.notes) ? @"*" : @"", ((Project*)appointment.object).name, (appointment.client) ? [appointment.client getClientName] : @"No Client"];
		} else {
			label = [[NSString alloc] initWithFormat:@"%@", (appointment.notes) ? appointment.notes : @"Block"];
		}
	}
	// Draw the text
	CGContextSetRGBFillColor( context, 1.0, 1.0, 1.0, 1.0 );
	// Shadow up 1 pixel (looks like a beveled inset)
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
		// 3.2+ wants a negative offset
		CGContextSetShadow( context, CGSizeMake(0, -1), 0 );
	} else {
		// 3.1 wants a positive offset
		CGContextSetShadow( context, CGSizeMake(0, 1), 0 );
	}
	// 10 pixels indented, 3 from the top
	[label drawInRect:textFrame withFont:font lineBreakMode:UILineBreakModeTailTruncation];
	[label release];
	// Done, restore the previous graphics state
	CGContextRestoreGState( context );
}


#pragma mark -
#pragma mark UIControl Methods
#pragma mark -

- (BOOL) touchInGapWithEvent:(UIEvent*)theEvent {
	return NO;
}

/*
 *	Passes along the touches unless they occur in a gap area.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	touchTimer = [[NSTimer timerWithTimeInterval:.75 target:self selector:@selector(touchIsLong:) userInfo:touches repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:touchTimer forMode:NSDefaultRunLoopMode];
	
	//[super touchesBegan:touches withEvent:event];
	self.highlighted = YES;
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

/*
 *	Sets the highlighted property back to NO
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if( ![touchTimer isValid] ) {
		// Held for menu
	} else {
		[self sendAction:@selector(goToAppointment:forEvent:) to:self.delegate forEvent:event];
	}
	
	[touchTimer invalidate];
	[touchTimer release];
	touchTimer = nil;
	
	self.highlighted = NO;
	//[super touchesEnded:touches withEvent:event];
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchTimer invalidate];
	[touchTimer release];
	touchTimer = nil;
	[[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}
				  
- (void) touchIsLong:(NSTimer*)theTimer {
	// Show Menu
	if( [self becomeFirstResponder] ) {
		CGRect frame;
		if( [theTimer isValid] ) {
			CGPoint tap = [((UITouch*)[(NSSet*)[theTimer userInfo] anyObject]) locationInView:self];
			frame = CGRectMake( tap.x, tap.y-20, 0, 0);
		} else {
			frame = CGRectMake( 0, 0, 0, 0);
		}
		[self setNeedsDisplayInRect:frame];
		
		UIMenuController *theMenu = [UIMenuController sharedMenuController];
		[theMenu setTargetRect:frame inView:self];
		[theMenu setMenuVisible:YES animated:YES];
	}
}

#pragma mark -
#pragma mark Menu commands and validation
#pragma mark -

- (BOOL) canBecomeFirstResponder {
	return YES;
}

/*
 The view implements this method to conditionally enable or disable commands of the editing menu. 
 The canPerformAction:withSender method is declared by UIResponder.
 */

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(cut:) || action == @selector(copy:)) {
		return YES;
	}
    return NO;
}

/*
 These methods are declared by the UIResponderStandardEditActions informal protocol.
 */
- (void) copy:(id)sender {
	[self.delegate copy:self];
}


- (void) cut:(id)sender {
	[self.delegate cut:self];
}


#pragma mark -
#pragma mark Custom Methods
#pragma mark -
- (BOOL) overlapsWithFrame:(CGRect)theFrame {
	BOOL overlap = NO;
	// Make our frame without the shadow accounted for
	CGRect myFrame = CGRectMake( self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-SHADOW_OFFSET);
	
	//DebugLog( @"%@ %@", NSStringFromCGRect(btnAppointment.frame), NSStringFromCGRect(myFrame));

	if( CGRectIntersectsRect( myFrame, theFrame ) ) {
		overlap = YES;
	}
	
	return overlap;
}


@end
