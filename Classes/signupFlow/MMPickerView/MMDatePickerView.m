//
//  MMPickerView.m
//  MMPickerView
//
//  Created by Madjid Mahdjoubi on 6/5/13.
//  Copyright (c) 2013 GG. All rights reserved.
//

#import "MMDatePickerView.h"
#import "MMPickerView.h" // for constants.


@interface MMDatePickerView()

@property (nonatomic, strong) UILabel *pickerViewLabel;
@property (nonatomic, strong) UIView *pickerViewLabelView;
@property (nonatomic, strong) UIView *pickerContainerView;
@property (nonatomic, strong) UIView *pickerViewContainerView;
@property (nonatomic, strong) UIView *pickerTopBarView;
@property (nonatomic, strong) UIImageView *pickerTopBarImageView;
@property (nonatomic, strong) UIToolbar *pickerViewToolBar;
@property (nonatomic, strong) UIBarButtonItem *pickerViewBarButtonItem;
@property (nonatomic, strong) UIButton *pickerDoneButton;
@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) UIColor *pickerViewTextColor;
@property (nonatomic, strong) UIFont *pickerViewFont;
@property (nonatomic, assign) CGFloat yValueFromTop;
@property (nonatomic, assign) NSInteger pickerViewTextAlignment;
@property (nonatomic, assign) BOOL pickerViewShowsSelectionIndicator;
@property (copy) void (^onDismissCompletion)(NSString *);
@property (copy) NSString *(^objectToStringConverter)(id object);

@end


@implementation MMDatePickerView

#pragma mark - Singleton

+ (MMDatePickerView*)sharedView {
    static dispatch_once_t once;
    static MMDatePickerView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] init]; });
    return sharedView;
}

#pragma mark - Show Methods

+(void)showPickerViewInView: (UIView *)view
                   withDate: (NSDate *)date
                withMinDate:(NSDate *)dateMin
                withMaxDate:(NSDate *)dateMax
                withOptions:(NSDictionary *)options
                 completion: (void(^)(NSString *selectedString))completion
{
    [[self sharedView] initializePickerViewInView:view
                                         withDate: (NSDate *)date
                                      withMinDate:(NSDate *)dateMin
                                      withMaxDate:(NSDate *)dateMax
                                      withOptions:options];
    
    [[self sharedView] setPickerHidden:NO callBack:nil];
    [self sharedView].onDismissCompletion = completion;
    [view addSubview:[self sharedView]];
}

#pragma mark - Dismiss Methods

+(void)dismissWithCompletion:(void (^)(NSString *))completion{
    [[self sharedView] setPickerHidden:YES callBack:completion];
}

-(void)dismiss{
    [MMDatePickerView dismissWithCompletion:self.onDismissCompletion];
}

+(void)removePickerView{
    [[self sharedView] removeFromSuperview];
}

#pragma mark - Show/hide PickerView methods

-(void)setPickerHidden: (BOOL)hidden
              callBack: (void(^)(NSString *))callBack; {
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         if (hidden) {
                             [_pickerViewContainerView setAlpha:0.0];
                             [_pickerContainerView setTransform:CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(_pickerContainerView.frame))];
                         } else {
                             [_pickerViewContainerView setAlpha:1.0];
                             [_pickerContainerView setTransform:CGAffineTransformIdentity];
                         }
                     } completion:^(BOOL completed) {
                         if(completed && hidden){
                             [MMDatePickerView removePickerView];
                             callBack([self selectedObject]);
                         }
                     }];
    
}

#pragma mark - Initialize PickerView

-(void)initializePickerViewInView: (UIView *)view
                         withDate: (NSDate *)date
                      withMinDate:(NSDate *)dateMin
                      withMaxDate:(NSDate *)dateMax
                      withOptions:options {
    
    _minDate = dateMin;
    _maxDate = dateMax;
    _selectedDate = date;

    
    NSNumber *textAlignment = [[NSNumber alloc] init];
    textAlignment = options[MMtextAlignment];
    //Default value is NSTextAlignmentCenter
    _pickerViewTextAlignment = 1;
    
    if (textAlignment != nil) {
        _pickerViewTextAlignment = [options[MMtextAlignment] integerValue];
    }
    
    UIColor *pickerViewBackgroundColor = [[UIColor alloc] initWithCGColor:[options[MMbackgroundColor] CGColor]];
    UIColor *pickerViewTextColor = [[UIColor alloc] initWithCGColor:[options[MMtextColor] CGColor]];
    UIColor *toolbarBackgroundColor = [[UIColor alloc] initWithCGColor:[options[MMtoolbarColor] CGColor]];
    UIColor *buttonTextColor = [[UIColor alloc] initWithCGColor:[options[MMbuttonColor] CGColor]];
    UIFont *pickerViewFont = [[UIFont alloc] init];
    pickerViewFont = options[MMfont];
    _yValueFromTop = [options[MMvalueY] floatValue];
    
    [self setFrame: view.bounds];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImage * toolbarImage = options[MMtoolbarBackgroundImage];
    
    //Whole screen with PickerView and a dimmed background
    _pickerViewContainerView = [[UIView alloc] initWithFrame:view.bounds];
    [_pickerViewContainerView setBackgroundColor: [UIColor colorWithRed:0.412 green:0.412 blue:0.412 alpha:0.7]];
    [self addSubview:_pickerViewContainerView];
    
    //PickerView Container with top bar
    _pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, _pickerViewContainerView.bounds.size.height - 260.0, 320.0, 260.0)];
    
    //Default Color Values (if colors == nil)
    
    //PickerViewBackgroundColor - White
    if (pickerViewBackgroundColor==nil) {
        pickerViewBackgroundColor = [UIColor whiteColor];
    }
    
    //PickerViewTextColor - Black
    if (pickerViewTextColor==nil) {
        pickerViewTextColor = [UIColor blackColor];
    }
    _pickerViewTextColor = pickerViewTextColor;
    
    //ToolbarBackgroundColor - Black
    if (toolbarBackgroundColor==nil) {
        toolbarBackgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:0.8];
    }
    
    //ButtonTextColor - Blue
    if (buttonTextColor==nil) {
        buttonTextColor = [UIColor colorWithRed:0.000 green:0.486 blue:0.976 alpha:1];
    }
    
    if (pickerViewFont==nil) {
        _pickerViewFont = [UIFont systemFontOfSize:22];
    }
    _pickerViewFont = pickerViewFont;
    
    /*
     //ToolbackBackgroundImage - Clear Color
     if (toolbarBackgroundImage!=nil) {
     //Top bar imageView
     _pickerTopBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _pickerContainerView.frame.size.width, 44.0)];
     //[_pickerContainerView addSubview:_pickerTopBarImageView];
     _pickerTopBarImageView.image = toolbarBackgroundImage;
     [_pickerViewToolBar setHidden:YES];
     
     }
     */
    
    _pickerContainerView.backgroundColor = pickerViewBackgroundColor;
    [_pickerViewContainerView addSubview:_pickerContainerView];
    
    
    //Content of pickerContainerView
    
    //Top bar view
    _pickerTopBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _pickerContainerView.frame.size.width, 44.0)];
    [_pickerContainerView addSubview:_pickerTopBarView];
    [_pickerTopBarView setBackgroundColor:[UIColor whiteColor]];
    
    
    _pickerViewToolBar = [[UIToolbar alloc] initWithFrame:_pickerTopBarView.frame];
    [_pickerContainerView addSubview:_pickerViewToolBar];
    
    CGFloat iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    //NSLog(@"%f",iOSVersion);
    
    if (iOSVersion < 7.0) {
        _pickerViewToolBar.tintColor = toolbarBackgroundColor;
        //[_pickerViewToolBar setBackgroundColor:toolbarBackgroundColor];
    }else{
        [_pickerViewToolBar setBackgroundColor:toolbarBackgroundColor];
        
        //_pickerViewToolBar.tintColor = toolbarBackgroundColor;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        _pickerViewToolBar.barTintColor = toolbarBackgroundColor;
#endif
    }
    
    if (toolbarImage!=nil) {
        [_pickerViewToolBar setBackgroundImage:toolbarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    _pickerViewBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    _pickerViewToolBar.items = @[flexibleSpace, _pickerViewBarButtonItem];
    [_pickerViewBarButtonItem setTintColor:buttonTextColor];
    
    //[_pickerViewBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Helvetica-Neue" size:23.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
    
    /*
     _pickerDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(_pickerContainerView.frame.size.width - 80.0, 10.0, 60.0, 24.0)];
     [_pickerDoneButton setTitle:@"Done" forState:UIControlStateNormal];
     [_pickerContainerView addSubview:_pickerDoneButton];
     [_pickerDoneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
     */
    
    //Add pickerView
    _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 216.0)];
    _pickerView.minimumDate = _minDate;
    _pickerView.maximumDate = _maxDate;
    _pickerView.date = _selectedDate;
    _pickerView.datePickerMode = UIDatePickerModeDate;

    [_pickerContainerView addSubview:_pickerView];
    
    //[self.pickerViewContainerView setAlpha:0.0];
    [_pickerContainerView setTransform:CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(_pickerContainerView.frame))];

}


#pragma mark - UIPickerViewDelegate

- (id)selectedObject {
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString * dateString = [dateFormat stringFromDate:_pickerView.date];
    
    return dateString;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    UIView *customPickerView = view;
    
    UILabel *pickerViewLabel;
    
    if (customPickerView==nil) {
        
        CGRect frame = CGRectMake(0.0, 0.0, 292.0, 44.0);
        customPickerView = [[UIView alloc] initWithFrame: frame];
        
        //   UIImageView *patternImageView = [[UIImageView alloc] initWithFrame:frame];
        //   patternImageView.image = [[UIImage imageNamed:@"texture"] resizableImageWithCapInsets:UIEdgeInsetsZero];
        //    [customPickerView addSubview:patternImageView];
        
        if (_yValueFromTop == 0.0f) {
            _yValueFromTop = 3.0;
        }
        
        CGRect labelFrame = CGRectMake(0.0, _yValueFromTop, 292.0, 35); // 35 or 44
        pickerViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [pickerViewLabel setTag:1];
        [pickerViewLabel setTextAlignment: _pickerViewTextAlignment];
        [pickerViewLabel setBackgroundColor:[UIColor clearColor]];
        [pickerViewLabel setTextColor:_pickerViewTextColor];
        [pickerViewLabel setFont:_pickerViewFont];
        [customPickerView addSubview:pickerViewLabel];
    } else{
        
        for (UIView *view in customPickerView.subviews) {
            if (view.tag == 1) {
                pickerViewLabel = (UILabel *)view;
                break;
            }
        }
    }
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString * dateString = [dateFormat stringFromDate:_pickerView.date];
    
    pickerViewLabel.text = dateString;
    
    return customPickerView;
    
}


@end
