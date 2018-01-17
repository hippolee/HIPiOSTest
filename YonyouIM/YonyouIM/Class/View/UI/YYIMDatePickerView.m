//
//  YYIMDatePickerView.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMDatePickerView.h"
#import "YYIMColorHelper.h"

@interface  YYIMDatePickerView()

@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation YYIMDatePickerView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initView];
    }
    return self;
}

- (void)initView {
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat buttonWidth = (width - 16 - 16)/2;
    
    UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [backGroundView setBackgroundColor:[UIColor blackColor]];
    [backGroundView setAlpha:0.6f];
    [self addSubview:backGroundView];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(8, height - 50, buttonWidth, 40)];
    [cancelButton setBackgroundColor:[UIColor whiteColor ]];
    [cancelButton setTitleColor:UIColorFromRGB(0x67c5f8) forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelSelectDate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(8 + buttonWidth + 16, height - 50, buttonWidth, 40)];
    [confirmButton setBackgroundColor:[UIColor whiteColor ]];
    [confirmButton setTitleColor:UIColorFromRGB(0x67c5f8) forState:UIControlStateNormal];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmSelectDate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmButton];
    
    CALayer *cancelButtonLayer = [cancelButton layer];
    [cancelButtonLayer setMasksToBounds:YES];
    [cancelButtonLayer setCornerRadius:5];
    CALayer *confirmButtonLayer = [confirmButton layer];
    [confirmButtonLayer setMasksToBounds:YES];
    [confirmButtonLayer setCornerRadius:5];
    
    UIView *datePickerView = [[UIView alloc] initWithFrame:CGRectMake(8, height - 50 - 10 - 216, width - 16, 216)];
    [datePickerView setBackgroundColor:[UIColor whiteColor]];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.frame = CGRectMake(0, 0, datePickerView.frame.size.width, 216);
    
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePickerView addSubview:self.datePicker];
    
    [self addSubview:datePickerView];
}

- (void)setDatePickerDate:(NSDate *)date {
    self.datePicker.date = date;
}

- (void)setDatePickerMinuteInterval:(NSInteger)interval {
    self.datePicker.minuteInterval = interval;
}

- (void)cancelSelectDate {
    [self.delegate didDatePickerViewCancel:self];
}

- (void)confirmSelectDate {
    [self.delegate didDatePickerViewSelect:self date:self.datePicker.date dateSelect:self.dateSelect];
}

@end
