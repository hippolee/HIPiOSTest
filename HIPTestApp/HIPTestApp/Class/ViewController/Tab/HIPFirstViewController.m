//
//  HIPFirstViewController.m
//  HIPTestApp
//
//  Created by litfb on 2017/4/15.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import "HIPFirstViewController.h"

@interface HIPFirstViewController ()

@end

@implementation HIPFirstViewController

- (void)viewDidLoad {
    NSLog(@"--First--viewDidLoad--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor redColor]];
    NSLog(@"--First--viewDidLoad--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"--First--viewWillAppear--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewWillAppear:animated];
    NSLog(@"--First--viewWillAppear--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"--First--viewDidAppear--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewDidAppear:animated];
    NSLog(@"--First--viewDidAppear--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
