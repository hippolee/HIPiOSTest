//
//  HIPUtility.m
//  litfb_test
//
//  Created by litfb on 15/12/30.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "HIPUtility.h"
#import "HIPColorHelper.h"

@implementation HIPUtility

+ (void)initNavigationBarStyle {
    [[UINavigationBar appearance] setBarTintColor:HIP_THEME_ORANGE];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    if (HIP_iOS8_ORLater) {
        [[UINavigationBar appearance] setTranslucent:NO];
        
    }
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

+ (void)genThemeNavController:(UINavigationController *)navController {
    if (!HIP_iOS8_ORLater) {
        [navController.navigationBar setBarTintColor:HIP_THEME_ORANGE];
        [navController.navigationBar setTranslucent:NO];
    }
}

+ (void)setExtraCellLineHidden:(UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+ (void)setBackButtonText:(NSString *)text forController:(UIViewController *)viewController {
    [viewController.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:nil action:nil]];
}

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag {
    // item
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
    // tag
    [item setTag:tag];
    // title offset
    [item setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    return item;
}

+ (void)pushFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC animated:(BOOL)animated {
    [fromVC setHidesBottomBarWhenPushed:YES];
    [fromVC.navigationController pushViewController:toVC animated:YES];
}

@end
