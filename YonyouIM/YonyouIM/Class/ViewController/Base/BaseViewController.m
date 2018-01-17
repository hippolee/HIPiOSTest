//
//  BaseViewController.m
//  YonyouIM
//
//  Created by litfb on 15/6/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "BaseViewController.h"
#import "YYIMUtility.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 清除返回按钮文字
    [YYIMUtility clearBackButtonText:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // ios7+适配
    [YYIMUtility adapterIOS7ViewController:self];
}

@end
