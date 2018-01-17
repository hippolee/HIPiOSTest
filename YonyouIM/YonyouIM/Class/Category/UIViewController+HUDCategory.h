//
//  UIViewController+HUDCategory.h
//  YonyouIM
//
//  Created by litfb on 14/12/29.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <UIKit/UIViewController.h>

@interface UIViewController (HUDCategory)

- (void)showHudInView:(UIView *)view hint:(NSString *)hint;

- (void)hideHud;

- (void)showHint:(NSString *)hint;

- (void)showHint:(NSString *)hint view:(UIView *)view;

- (void)showHudVoice:(UIView *)view volume:(NSInteger)volume;

- (void)hudVoiceRefresh:(float)volume;

- (void)hudVoiceCountDown:(int)countDown;

- (void)hudTextRefresh:(NSString *)text;

- (void)showThemeHudInView:(UIView *)view;

@end
