//
//  HIPColorPowerSlider.h
//  litfb_test
//
//  Created by litfb on 16/5/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HIPColorPowerDelegate;

@interface HIPColorPowerSlider : UIView

@property (weak, nonatomic) id<HIPColorPowerDelegate> delegate;

@property (nonatomic) NSUInteger minimumValue;

@property (nonatomic) NSUInteger maximumValue;

@property (nonatomic) NSUInteger value;

@property (nonatomic) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color;

@end

@protocol HIPColorPowerDelegate <NSObject>

- (void)colorPowerSlider:(HIPColorPowerSlider *)slider powerDidChange:(NSUInteger)power;

@end