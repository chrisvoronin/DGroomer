//
//  CalendarDayBackgroundView.m
//  myBusiness
//
//  Created by David J. Maier on 12/7/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "Settings.h"
#import "CalendarDayBackgroundView.h"


@implementation CalendarDayBackgroundView

@synthesize delegate, is15MinuteIntervals, isDayOff, lastTouch, offsetX, offsetY, workHoursEnd, workHoursBegin;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		offsetX = -1;
		offsetY = -1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	if( offsetX < 0 )	offsetX = 53;
	if( offsetY < 0 )	offsetY = 10;
	// Some drawing properties
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height-(offsetY*2);
	CGFloat pixelsPerHour = height/24;
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	// SOLID LINES
	CGContextSaveGState( context );
	CGContextSetShouldAntialias( context, NO );
	// Setup all the line drawing properties
	CGContextSetRGBFillColor( context, .8, .8, .8, 1.0 );
	CGContextSetRGBStrokeColor( context, .8, .8, .8, 1.0 );
	CGContextSetLineWidth( context, 1.0 );
	// Draw the lines
	for( CGFloat i=offsetY; i <= (self.frame.size.height-offsetY); i=i+pixelsPerHour ){
		CGContextMoveToPoint( context, offsetX, i );
		CGContextAddLineToPoint( context, width, i );
		CGContextStrokePath( context );
	}
	
	// DASHED LINES
	// Setup all the line drawing properties
	CGFloat lengths[2] = { 1.0, 1.0 };
	CGContextSetLineDash( context, 0, lengths, 2 );
	// Draw the lines
	for( CGFloat i=offsetY+pixelsPerHour; i <= (self.frame.size.height-offsetY); i=i+pixelsPerHour ){
		CGContextMoveToPoint( context, offsetX, i-(pixelsPerHour/2) );
		CGContextAddLineToPoint( context, width, i-(pixelsPerHour/2) );
		CGContextStrokePath( context );
	}
	CGContextRestoreGState( context );
	
	// TEXT
	CGContextSaveGState( context );
	// First setup all the text properties
	UIFont *timeFont = [UIFont boldSystemFontOfSize:14];
	UIFont *amPmFont = [UIFont systemFontOfSize:12];
	NSString *stringToWrite = nil;
	NSString *amString = nil;
	NSString *pmString = nil;
	// Decide if it's 24 hour time based on the date formatter format
	BOOL armyTime = YES;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	if( [[formatter dateFormat] hasSuffix:@"a"] ) {
		armyTime = NO;
		amString = [formatter AMSymbol];
		pmString = [formatter PMSymbol];
	}
	[formatter release];
	
	// Loop and draw
	for( int i=0; i <= 24; i++ ) {
		CGRect amPmRect;
		CGRect timeRect;
		int hour;
		if( i == 0 ) {
			if( armyTime ) {
				hour = i;
			} else {
				hour = 12;
			}
			stringToWrite = amString;
		} else if( i > 12 && i < 24 ) {
			if( armyTime ) {
				hour = i;
			} else {
				hour = i-12;
				if( i==24 )	stringToWrite = amString;
				else		stringToWrite = pmString;
			}
		} else if( i == 24 ) {
			if( armyTime ) {
				hour = 0;
			} else {
				hour = 12;
			}
			stringToWrite = amString;
		} else {
			hour = i;
			stringToWrite = amString;
		}
		
		if( i == 12 && !armyTime ) {
			// Noon
			CGContextSetRGBFillColor( context, 0, 0, 0, 1.0 );
			timeRect = CGRectMake( 0, i*pixelsPerHour, 55, 18 );
			// If the language is English, write Noon, otherwise just put a number
			NSArray *langs = [NSLocale preferredLanguages];
			if( langs.count > 0 && [[langs objectAtIndex:0] hasPrefix:@"en"] ) {
				[@"Noon" drawInRect:timeRect withFont:timeFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
			} else {
				[@"12" drawInRect:timeRect withFont:timeFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
			}
		} else {
			// AM/PM
			if( !armyTime ) {
				CGContextSetRGBFillColor( context, .51, .51, .51, 1.0 );
				amPmRect = CGRectMake( 25, i*pixelsPerHour+2, 22, 18);
				[stringToWrite drawInRect:amPmRect withFont:amPmFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
			}
			// Time
			CGContextSetRGBFillColor( context, 0, 0, 0, 1.0 );
			
			if( armyTime ) {
				timeRect = CGRectMake( 0, i*pixelsPerHour, 45, 18);
				stringToWrite = [[NSString alloc] initWithFormat:@"%d:00", hour];
			} else {
				timeRect = CGRectMake( 0, i*pixelsPerHour, 23, 18);
				stringToWrite = [[NSString alloc] initWithFormat:@"%d", hour];
			}
			[stringToWrite drawInRect:timeRect withFont:timeFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
			[stringToWrite release];
			stringToWrite = nil;
		}
		// HALF HOUR STRINGS
		if( is15MinuteIntervals ) {
			CGContextSetRGBFillColor( context, .65, .65, .65, 1.0 );
			timeRect = CGRectMake( 0, i*pixelsPerHour+(pixelsPerHour/2), 45, 18 );
			stringToWrite = [[NSString alloc] initWithFormat:@"%d:30", hour];
			[stringToWrite drawInRect:timeRect withFont:amPmFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
			[stringToWrite release];
			stringToWrite = nil;
		}
	}
	CGContextRestoreGState( context );
	
	// OFF HOURS / DAY OFF
	CGContextSaveGState( context );
	CGContextSetRGBFillColor( context, .65, .65, .65, .3 );
	if( isDayOff ) {
		CGRect theRect = CGRectMake( offsetX+2, offsetY, rect.size.width-offsetX-2, rect.size.height-(offsetY*2) );
		CGContextFillRect( context, theRect );
	} else {
		PSADataManager *manager = [PSADataManager sharedInstance];
		NSDate	*startTime = [manager getTimeForString:workHoursBegin withFormat:[manager getWorkHoursDateFormat]];
		NSDate	*endTime = [manager getTimeForString:workHoursEnd withFormat:[manager getWorkHoursDateFormat]];
		// Draw the top portion
		NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:startTime];
		CGFloat minutes = ([comps hour]*60)+[comps minute];
		CGRect theRect = CGRectMake( offsetX+2, offsetY, rect.size.width-offsetX-2, (minutes/60)*pixelsPerHour );
		CGContextFillRect( context, theRect );
		// Draw the bottom portion
		comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:endTime];
		minutes = ([comps hour]*60)+[comps minute];
		theRect = CGRectMake( offsetX+2, (minutes/60)*pixelsPerHour+offsetY, rect.size.width-offsetX-2, rect.size.height-((minutes/60)*pixelsPerHour)-(offsetY*2) );
		CGContextFillRect( context, theRect );
	}
	CGContextRestoreGState( context );
}

- (void)dealloc {
	[lastTouch release];
	[workHoursBegin release];
	[workHoursEnd release];
    [super dealloc];
}

#pragma mark -
#pragma mark Touch and Pasteboard Methods
#pragma mark -

- (CGPoint) getLastTouchPoint {
	return lastTouchPoint;
}

/*
 *	Passes along the touches unless they occur in a gap area.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {	
	touchTimer = [[NSTimer timerWithTimeInterval:.75 target:self selector:@selector(touchIsLong:) userInfo:touches repeats:NO] retain];
	[[NSRunLoop currentRunLoop] addTimer:touchTimer forMode:NSDefaultRunLoopMode];

	self.lastTouch = event;
	lastTouchPoint = [((UITouch*)[[self.lastTouch allTouches] anyObject]) locationInView:self];
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
			frame = CGRectMake( tap.x, tap.y, 0, 0);
		} else {
			frame = CGRectMake( 0, 0, 0, 0);
		}
		[self setNeedsDisplayInRect:frame];

		UIMenuController *theMenu = [UIMenuController sharedMenuController];
		[theMenu setTargetRect:frame inView:self];
		[theMenu setMenuVisible:YES animated:YES];
	}
}

// Touch handling, tile selection, and menu/pasteboard.
- (BOOL) canBecomeFirstResponder {
	return YES;
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(paste:)) {
		return YES;
	}
    return NO;
}

- (void) paste:(id)sender {
	[self.delegate paste:self];
}


@end
