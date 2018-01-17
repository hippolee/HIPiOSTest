//
//  YYIMBaseViewController.m
//  YonyouIM
//
//  Created by litfb on 15/6/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMBaseViewController.h"
#import "YYIMUtility.h"

@interface YYIMBaseViewController ()

@property BOOL viewIsAppear;

@end

@implementation YYIMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldKeepDelegate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.viewIsAppear = YES;
    [super viewWillAppear:animated];
    // 注册委托
    [[YYIMChat sharedInstance].chatManager addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (![self shouldKeepDelegate]) {
        // 移除委托
        [[YYIMChat sharedInstance].chatManager removeDelegate:self];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    }
    
    self.viewIsAppear = NO;
}

- (void)applicationWillEnterForeground:(id)sender {
    if ([self viewIsAppear]) {
        // 注册委托
        [[YYIMChat sharedInstance].chatManager addDelegate:self];
        
        [self viewWillAppear:NO];
    }
}

- (void)applicationDidEnterBackground:(id)sender {
    // 移除委托
    
    if (![self shouldKeepDelegate]) {
        [[YYIMChat sharedInstance].chatManager removeDelegate:self];
    }
}

@end
