//
//  HIPColorPowerSlider.m
//  litfb_test
//
//  Created by litfb on 16/5/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPColorPowerSlider.h"
#import "HIPPopoverSlider.h"
#import "HIPImageUtility.h"

@interface HIPColorPowerSlider ()

@property (weak, nonatomic) HIPPopoverSlider *slider;

@end

@implementation HIPColorPowerSlider

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:[self sliderBackgroundView]];
        
        HIPPopoverSlider *slider = [[HIPPopoverSlider alloc] initWithFrame:CGRectMake(6, 10, CGRectGetWidth(frame) - 12, CGRectGetHeight(frame) - 20)];
        [slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
        _slider = slider;
        
        [self setColor:color];
    }
    return self;
}

#pragma mark Slider Methods

- (void)setMinimumValue:(NSUInteger)minimumValue {
    _minimumValue = minimumValue;
    [_slider setMinimumValue:minimumValue];
}

- (void)setMaximumValue:(NSUInteger)maximumValue {
    _maximumValue = maximumValue;
    [_slider setMaximumValue:maximumValue];
}

- (void)setValue:(NSUInteger)value {
    if (value > _maximumValue) {
        value = _maximumValue;
    }
    if (value < _minimumValue) {
        value = _minimumValue;
    }
    _value = value;
    [_slider setValue:_value];
    [[_slider popover] setText:[NSString stringWithFormat:@"%lu", (unsigned long)_value]];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [_slider setThumbImage:[HIPImageUtility convertViewToImage:[self sliderThumbView]] forState:UIControlStateNormal];
}

#pragma mark Action

- (void)valueChange:(UISlider *)slider {
    float fvalue = [slider value];
    NSUInteger ivalue = roundf(fvalue);
    if (ivalue != self.value) {
        _value = ivalue;
        [[_slider popover] setText:[NSString stringWithFormat:@"%lu", (unsigned long)_value]];
        
        [slider setValue:_value animated:YES];
        
        if (_delegate && [_delegate respondsToSelector:@selector(colorPowerSlider:powerDidChange:)]) {
            [_delegate colorPowerSlider:self powerDidChange:_value];
        }
    }
}

#pragma mark Private

- (UIView *)sliderThumbView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30.0f, 30.0f)];
    [view setBackgroundColor:[UIColor blackColor]];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:14.5f];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 22, 22)];
    [view1 setBackgroundColor:_color];
    
    CALayer *layer1 = [view1 layer];
    [layer1 setMasksToBounds:YES];
    [layer1 setCornerRadius:10.5f];
    [view addSubview:view1];
    return view;
}

- (UIView *)sliderBackgroundView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:(CGRectGetHeight(self.frame) - 1) / 2];
    [layer setBorderColor:[UIColor grayColor].CGColor];
    [layer setBorderWidth:1.0f];
    return view;
}

@end
