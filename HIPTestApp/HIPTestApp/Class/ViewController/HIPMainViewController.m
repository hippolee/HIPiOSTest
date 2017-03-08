//
//  HIPMainViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPMainViewController.h"
#import "HIPTableViewController.h"
#import "HIPTestViewController.h"
#import "HIPUtility.h"
#import "HIPColorHelper.h"
#import "HIPImageUtility.h"

@interface HIPMainViewController ()

@property (retain, nonatomic) UINavigationController *tableNavController;

@property (retain, nonatomic) UINavigationController *testNavControler;

@end

@implementation HIPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initView
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    [self addChildViewController:self.tableNavController];
    [self addChildViewController:self.testNavControler];
    [self.tabBar setTintColor:HIP_THEME_ORANGE];
    [self.tabBar setShadowImage:[HIPImageUtility imageWithColor:[UIColor clearColor]]];
}

#pragma mark controllers

- (UINavigationController *)tableNavController {
    if (!_tableNavController) {
        // HIPTableViewController
        HIPTableViewController *tabelViewController = [[HIPTableViewController alloc] initWithNibName:nil bundle:nil];
        // UINavigationController
        UINavigationController *tableNavController = [[UINavigationController alloc] initWithRootViewController:tabelViewController];
        [HIPUtility genThemeNavController:tableNavController];
        // UITabBarItem
        UITabBarItem *item = [HIPUtility tabBarItemWithTitle:@"解决方案" image:[UIImage imageNamed:@"icon_diploma"] selectedImage:[UIImage imageNamed:@"icon_diploma"] tag:1];
        [tableNavController setTabBarItem:item];
        
        _tableNavController = tableNavController;
    }
    return _tableNavController;
}

- (UINavigationController *)testNavControler {
    if (!_testNavControler) {
        // HIPTestViewController
        HIPTestViewController *testViewController = [[HIPTestViewController alloc] initWithNibName:nil bundle:nil];
        // UINavigationController
        UINavigationController *testNavController = [[UINavigationController alloc] initWithRootViewController:testViewController];
        [HIPUtility genThemeNavController:testNavController];
        // UITabBarItem
        UITabBarItem *item = [HIPUtility tabBarItemWithTitle:@"测试方案" image:[UIImage imageNamed:@"icon_idea"] selectedImage:[UIImage imageNamed:@"icon_idea"] tag:2];
        [testNavController setTabBarItem:item];
        
        _testNavControler = testNavController;
    }
    return _testNavControler;
}

@end