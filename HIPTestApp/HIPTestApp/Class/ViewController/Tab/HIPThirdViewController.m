//
//  HIPThirdViewController.m
//  HIPTestApp
//
//  Created by litfb on 2017/4/15.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import "HIPThirdViewController.h"

@interface HIPThirdViewController ()

@end

@implementation HIPThirdViewController

- (void)viewDidLoad {
    NSLog(@"--Third--viewDidLoad--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    NSLog(@"--Third--viewDidLoad--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"--Third--viewWillAppear--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewWillAppear:animated];
    NSLog(@"--Third--viewWillAppear--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"--Third--viewDidAppear--Start:%f", [[NSDate date] timeIntervalSince1970] * 1000);
    [super viewDidAppear:animated];
    NSLog(@"--Third--viewDidAppear--End:%f", [[NSDate date] timeIntervalSince1970] * 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
