//
//  UIViewController+HUDCategory.m
//  YonyouIM
//
//  Created by litfb on 14/12/29.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "UIViewController+HUDCategory.h"
#import "MBProgressHUD.h"
#import "UIImage+GIF.h"
#import <objc/runtime.h>

static const void *objHUDKey = &objHUDKey;

@implementation UIViewController (HUDCategory)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, objHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, objHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.labelText = hint;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)hideHud {
    [[self HUD] hide:YES];
}

- (void)showHint:(NSString *)hint {
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint view:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)showHudVoice:(UIView *)view volume:(NSInteger)volume {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    [imageView setImage:[UIImage imageNamed:@"icon_record1"]];
    hud.customView = imageView;
    
    hud.mode = MBProgressHUDModeCustomView;
    
    hud.labelText = @"手指上滑 取消发送";
    hud.minSize = CGSizeMake(156.0f, 156.0f);
    
    [view addSubview:hud];
    [hud show:YES];
    [self setHUD:hud];
}

- (void)hudVoiceRefresh:(float)volume {
    MBProgressHUD *hud = [self HUD];
    if (!hud) {
        [self showHudVoice:self.view volume:volume];
    }
    
    //-160表示完全安静，0表示最大输入值
    NSInteger imageIndex = 0;
    
    if (volume < -60) {
        imageIndex = 1;
    } else if (volume >= -60 && volume < -50) {
        imageIndex = 2;
    } else if (volume >= -50 && volume < -40) {
        imageIndex = 3;
    } else if (volume >= -40 && volume < -30) {
        imageIndex = 4;
    } else if (volume >= -30 && volume < -20) {
        imageIndex = 5;
    } else if (volume >= -20 && volume < -10) {
        imageIndex = 6;
    } else if (volume >= -10) {
        imageIndex = 7;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_record%ld", (long)imageIndex]]];
    hud.customView = imageView;
}

- (void)hudVoiceCountDown:(int)countDown {
    MBProgressHUD *hud = [self HUD];
    if (!hud) {
        return;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    [label setText:[NSString stringWithFormat:@"%d", countDown]];
    [label setFont:[UIFont systemFontOfSize:80]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    hud.customView = label;
    
    hud.labelText = @"";
}

- (void)hudTextRefresh:(NSString *)text {
    MBProgressHUD *hud = [self HUD];
    if (!hud) {
        return;
    }
    hud.labelText = text;
}

- (void)showThemeHudInView:(UIView *)view {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    // customView
    UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [gifView setImage:[UIImage sd_animatedGIFNamed:@"yyim_hud"]];
    HUD.customView = gifView;
    HUD.color = [UIColor clearColor];
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    // show
    [HUD show:YES];
    [self setHUD:HUD];
}

@end
