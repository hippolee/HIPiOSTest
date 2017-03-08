//
//  HIPUtility.h
//  litfb_test
//
//  Created by litfb on 15/12/30.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HIP_iOS9_ORLater ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define HIP_iOS8_ORLater ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define HIP_iOS7_ORLater ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface HIPUtility : NSObject

/**
 *  初始化NavigationBar的样式
 */
+ (void)initNavigationBarStyle;

+ (void)genThemeNavController:(UINavigationController *)navController;

/**
 *  设置UITableView的多余SeparatorLine隐藏
 *
 *  @param tableView UITableView
 */
+ (void)setExtraCellLineHidden:(UITableView *)tableView;

/**
 *  设置返回按钮的文字
 *
 *  @param text           text
 *  @param viewController viewController
 */
+ (void)setBackButtonText:(NSString *)text forController:(UIViewController *)viewController;

/**
 *  UITabBarItem统一样式生成
 *
 *  @param title         title
 *  @param image         image
 *  @param selectedImage selectedImage
 *  @param tag           tag
 *
 *  @return UITabBarItem
 */
+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag;

/**
 *  pushViewController
 *  处理了HidesBottomBarWhenPushed
 *
 *  @param fromVC   fromVC
 *  @param toVC     toVC
 *  @param animated animated
 */
+ (void)pushFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC animated:(BOOL)animated;

@end
