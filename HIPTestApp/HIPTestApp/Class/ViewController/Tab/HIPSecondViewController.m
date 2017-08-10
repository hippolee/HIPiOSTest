//
//  HIPSecondViewController.m
//  HIPTestApp
//
//  Created by litfb on 2017/4/15.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import "HIPSecondViewController.h"

@interface HIPSecondViewController ()

@end

@implementation HIPSecondViewController

- (void)viewDidLoad {
    NSLog(@"--Second--viewDidLoad--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor greenColor]];
    NSLog(@"--Second--viewDidLoad--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"--Second--viewWillAppear--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewWillAppear:animated];
    NSLog(@"--Second--viewWillAppear--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"--Second--viewDidAppear--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewDidAppear:animated];
    NSLog(@"--Second--viewDidAppear--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
