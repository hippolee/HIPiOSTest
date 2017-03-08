//
//  HIPPopoverSlider.m
//  litfb_test
//
//  Created by litfb on 16/5/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPPopoverSlider.h"

@implementation HIPPopoverSlider

#pragma mark -
#pragma mark UISlider methods

- (HIPSliderPopover *)popover {
    if (!_popover) {
        HIPSliderPopover *popover = [[HIPSliderPopover alloc] initWithFrame:CGRectMake(0, 0, 40, 32)];
        [popover setAlpha:0.0f];
        [self.superview addSubview:popover];
        _popover = popover;
        
        [self addTarget:self action:@selector(updatePopoverFrame) forControlEvents:UIControlEventValueChanged];
        [self updatePopoverFrame];
    }
    return _popover;
}

- (CGFloat)thumbSize {
    if (_thumbSize <= 0) {
        _thumbSize = 30.0f;
    }
    return _thumbSize;
}

- (void)setValue:(float)value {
    [super setValue:value];
    [self updatePopoverFrame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updatePopoverFrame];
    [self showPopoverAnimated:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hidePopoverAnimated:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hidePopoverAnimated:YES];
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark -
#pragma mark - Popover Methods

- (void)updatePopoverFrame {
    CGFloat totalNum = self.maximumValue - self.minimumValue;
    CGFloat leftNum = self.value - self.minimumValue;
    CGFloat leftPercent = leftNum / totalNum;
    
    CGFloat totalWidth = CGRectGetWidth(self.frame);
    CGFloat sliderX = CGRectGetMinX(self.frame);
    CGFloat sliderY = CGRectGetMinY(self.frame);
    
    CGFloat popoverWidth = CGRectGetWidth(self.popover.frame);
    CGFloat popoverHeight = CGRectGetHeight(self.popover.frame);
    
    CGRect popoverRect = self.popover.frame;
    popoverRect.origin.x = self.thumbSize / 2 + sliderX + (totalWidth - self.thumbSize) * leftPercent - popoverWidth / 2;
    popoverRect.origin.y = sliderY - popoverHeight - 6;
    
    [self.popover setFrame:popoverRect];
}

- (void)showPopover {
    [self showPopoverAnimated:NO];
}

- (void)showPopoverAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 1.0;
        }];
    } else {
        self.popover.alpha = 1.0;
    }
}

- (void)hidePopover {
    [self hidePopoverAnimated:NO];
}

- (void)hidePopoverAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 0;
        }];
    } else {
        self.popover.alpha = 0;
    }
}

@end
