//
//  CalendarWeekBackgroundView.m
//  PSA
//
//  Created by David J. Maier on 7/1/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "PSADataManager.h"
#import "Settings.h"
#import "CalendarWeekBackgroundView.h"


@implementation CalendarWeekBackgroundView

@synthesize daysDisplayed, delegate, is15MinuteIntervals, lastTouch, offsetX, offsetY, settings;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		offsetX = -1;
		offsetY = -1;
		settings = nil;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	if( offsetX < 0 )	offsetX = 15;
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
	CGContextSetLineWidth( context, .5 );
	
	// VERTICAL LINES
	for( CGFloat i=offsetX; i <= (self.frame.size.width); i=i+((self.frame.size.width-offsetX)/daysDisplayed) ) {
		CGContextMoveToPoint( context, i, offsetY );
		CGContextAddLineToPoint( context, i, height+offsetY );
		CGContextStrokePath( context );
	}
	
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
	UIFont *halfFont = [UIFont systemFontOfSize:11];
	// Decide if it's 24 hour time based on the date formatter format
	BOOL armyTime = YES;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	if( [[formatter dateFormat] hasSuffix:@"a"] ) {
		armyTime = NO;
	}
	[formatter release];
	//
	NSString *stringToWrite = nil;
	// Loop and draw
	for( int i=0; i <= 24; i++ ) {
		CGRect timeRect;
		int hour;
		if( i == 0 ) {
			CGContextSetRGBFillColor( context, .15, .588, 1.0, 1.0 );
			if( armyTime ) {
				hour = 0;
			} else {
				hour = 12;
			}
		} else if( i > 12 ) {
			CGContextSetRGBFillColor( context, .106, .176, .353, 1.0 );
			if( armyTime ) {
				hour = i;
			} else {
				hour = i-12;
			}
			if( i==24 )	{
				if( armyTime ) {
					hour = 0;
				}
				CGContextSetRGBFillColor( context, .15, .588, 1.0, 1.0 );
			}
		} else {
			CGContextSetRGBFillColor( context, .15, .588, 1.0, 1.0 );
			hour = i;
		}
		
		if( i == 12 ) {
			// Noon
			CGContextSetRGBFillColor( context, .106, .176, .353, 1.0 );
			timeRect = CGRectMake( 0, i*pixelsPerHour+2, 55, 18 );
			[@"12" drawInRect:timeRect withFont:timeFont lineBreakMode:UILineBreakModeClip alignment:NSTextAlignmentLeft];
		} else {
			timeRect = CGRectMake( 0, i*pixelsPerHour+2, 23, 18);
			stringToWrite = [[NSString alloc] initWithFormat:@"%2d", hour];
			[stringToWrite drawInRect:timeRect withFont:timeFont lineBreakMode:UILineBreakModeClip alignment:NSTextAlignmentLeft];
			[stringToWrite release];
			stringToWrite = nil;
		}
		// HALF HOUR STRINGS
		if( is15MinuteIntervals ) {
			CGContextSetRGBFillColor( context, .65, .65, .65, 1.0 );
			timeRect = CGRectMake( 0, i*pixelsPerHour+(pixelsPerHour/2)+2, 45, 18 );
			[@" :30" drawInRect:timeRect withFont:halfFont lineBreakMode:UILineBreakModeClip alignment:NSTextAlignmentLeft];
		}
	}
	CGContextRestoreGState( context );
	
	// OFF HOURS / DAY OFF
	CGContextSaveGState( context );
	CGContextSetRGBFillColor( context, .65, .65, .65, .3 );
	// For each day of the week
	PSADataManager *manager = [PSADataManager sharedInstance];
	NSDate	*startTime = nil;
	NSDate	*endTime = nil;
	for( int i=0; i < daysDisplayed; i++ ) {
		switch (i) {
			case 0:
				if( !settings.isSundayOff ) {
					startTime = [manager getTimeForString:settings.sundayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.sundayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
			case 1:
				if( !settings.isMondayOff ) {
					startTime = [manager getTimeForString:settings.mondayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.mondayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
			case 2:
				if( !settings.isTuesdayOff ) {
					startTime = [manager getTimeForString:settings.tuesdayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.tuesdayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
			case 3:
				if( !settings.isWednesdayOff ) {
					startTime = [manager getTimeForString:settings.wednesdayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.wednesdayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
			case 4:
				if( !settings.isThursdayOff ) {
					startTime = [manager getTimeForString:settings.thursdayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.thursdayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
			case 5:
				if( !settings.isFridayOff ) {
					startTime = [manager getTimeForString:settings.fridayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.fridayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
			case 6:
				if( !settings.isSaturdayOff ) {
					startTime = [manager getTimeForString:settings.saturdayStart withFormat:[manager getWorkHoursDateFormat]];
					endTime = [manager getTimeForString:settings.saturdayFinish withFormat:[manager getWorkHoursDateFormat]];
				}
				break;
		}
		
		// Get the actual weekday for the index...
		NSInteger weekdayIndex = i-[[NSCalendar autoupdatingCurrentCalendar] firstWeekday]+1;
		if( weekdayIndex < 0 ) {
			// Wrap it around by adding 7 (assumed number of days in a week)
			weekdayIndex = weekdayIndex + 7;
		}
		
		CGFloat xStart = ((self.frame.size.width-offsetX)/daysDisplayed)*weekdayIndex+offsetX;
		
		if( !startTime && !endTime ) {
			CGRect theRect = CGRectMake( xStart, offsetY, ((self.frame.size.width-offsetX)/daysDisplayed), rect.size.height-(offsetY*2) );
			CGContextFillRect( context, theRect );
		} else {
			// Draw the top portion
			NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:startTime];
			CGFloat minutes = ([comps hour]*60)+[comps minute];
			CGRect theRect = CGRectMake( xStart, offsetY, ((self.frame.size.width-offsetX)/daysDisplayed), (minutes/60)*pixelsPerHour );
			CGContextFillRect( context, theRect );
			// Draw the bottom portion
			comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:endTime];
			minutes = ([comps hour]*60)+[comps minute];
			theRect = CGRectMake( xStart, (minutes/60)*pixelsPerHour+offsetY, ((self.frame.size.width-offsetX)/daysDisplayed), rect.size.height-((minutes/60)*pixelsPerHour)-(offsetY*2) );
			CGContextFillRect( context, theRect );
		}
		startTime = nil;
		endTime = nil;
	}
	CGContextRestoreGState( context );
}

- (void)dealloc {
	[lastTouch release];
	[settings release];
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(paste:)) {
		return YES;
	}
    return NO;
}

- (void) paste:(id)sender {
	[self.delegate paste:self];
}



@end
