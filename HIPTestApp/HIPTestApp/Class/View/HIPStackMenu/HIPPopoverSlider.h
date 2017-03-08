//
//  HIPPopoverSlider.h
//  litfb_test
//
//  Created by litfb on 16/5/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPSliderPopover.h"

@interface HIPPopoverSlider : UISlider

@property (strong, nonatomic) HIPSliderPopover *popover;

@property (nonatomic) CGFloat thumbSize;

- (void)showPopover;

- (void)showPopoverAnimated:(BOOL)animated;

- (void)hidePopover;

- (void)hidePopoverAnimated:(BOOL)animated;

@end
