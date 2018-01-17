//
//  YYIMUtility.h
//  YonyouIM
//
//  Created by litfb on 15/1/8.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

@interface YYIMUtility : NSObject

/**
 *  获得大于当前时间的最近的半点
 *
 *  @return 时间
 */
+ (NSTimeInterval)getHalfTimeOfNow;

/**
 *  时间字符串
 *
 *  @param timeInMillis 时间戳
 *
 *  @return 时间字符串
 */
+ (NSString *)genTimeString:(NSTimeInterval)timeInMillis;

/**
 *  时间字符串
 *
 *  @param date 时间对象
 *
 *  @return 时间字符串
 */
+ (NSString *)genTimeStringWithDate:(NSDate *)date;

/**
 *  根据format格式化时间字符串
 *
 *  @param timeInMillis 时间戳
 *  @param dateFormat   时间格式
 *
 *  @return 时间字符串
 */
+ (NSString *)genTimeString:(NSTimeInterval)timeInMillis dateFormat:(NSString *)dateFormat;

/**
 *  根据format格式化时间字符串
 *
 *  @param date       时间对象
 *  @param dateFormat 时间格式
 *
 *  @return 时间字符串
 */
+ (NSString *)genTimeStringWithDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

/**
 *  生成群组名称
 *
 *  @param user        创建人
 *  @param inviteArray 邀请用户列表
 *
 *  @return 群组名称
 */
+ (NSString *)genGroupName:(YYUser *)user invites:(NSArray *)inviteArray;

/**
 *  设置UITableView的多余行间隔线隐藏
 *
 *  @param tableView
 */
+ (void)setExtraCellLineHidden:(UITableView *)tableView;

/**
 *  字符串判空
 *
 *  @param str 字符串
 *
 *  @return 字符串是否nil或者@""
 */
+ (BOOL)isEmptyString:(NSString *)str;

+ (NSString *)trimString:(NSString *)str;

+ (void)initNavigationBarStyle;

/**
 *  UINavigationController
 *
 *  @param rootViewController
 *
 *  @return UINavigationController
 */
+ (UINavigationController *)themeNavController:(UIViewController *)rootViewController;

+ (void)genThemeNavController:(UINavigationController *)navController;

+ (UIViewController *)getCurrentVC;

/**
 *  文件图标
 *
 *  @param ext 文件扩展名
 *
 *  @return 文件图标
 */
+ (NSString *)fileIconWithExt:(NSString *)ext;

/**
 *  文件大小字符串
 *
 *  @param size 文件size
 *
 *  @return 文件大小
 */
+ (NSString *)fileSize:(long long)size;

/**
 *  UIViewController适配
 *
 *  @param viewController
 */
+ (void)adapterIOS7ViewController:(UIViewController *)viewController;

/**
 *  设置返回按钮显示
 *
 *  @param viewController
 */
+ (void)clearBackButtonText:(UIViewController *)viewController;

/**
 *  找到view所在的cell
 *
 *  @param view
 *
 *  @return cell
 */
+ (UITableViewCell *)superCellForView:(UIView *)view;

/**
 *  找到view所在的cell
 *
 *  @param view
 *
 *  @return cell
 */
+ (UICollectionViewCell *)superCollectionCellForView:(UIView *)view;

/**
 *  UITabBarItem
 *
 *  @param title         标题
 *  @param image         图标
 *  @param selectedImage 选中图标
 *  @param tag           tag
 *
 *  @return UITabBarItem
 */
+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger) tag;

/**
 *  UITabBarItem
 *
 *  @param title 标题
 *  @param tag   tag
 *
 *  @return UITabBarItem
 */
+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title tag:(NSInteger) tag;

/**
 *  颜色生成Image
 *
 *  @param color 颜色
 *
 *  @return UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  图片缓存key
 *
 *  @param url 图片url
 *
 *  @return 图片key
 */
+ (NSString *)cacheKeyForYMImageUrl:(NSURL *)url;

/**
 *  从url获取参数值
 *
 *  @param url   url
 *  @param param 参数名
 *
 *  @return 参数值
 */
+ (NSString *)getParamValueFromUrl:(NSString *)url forParam:(NSString *)param;

/**
 *  图片尺寸
 *
 *  @param size 原尺寸
 *  @param side 最大边长
 *
 *  @return size
 */
+ (CGSize)sizeOfImageThumbSize:(CGSize)size withMaxSide:(CGFloat)side;

/**
 *  字符串关键字高亮
 *
 *  @param string  字符串
 *  @param keyword 关键字
 *  @param color   高亮颜色
 *
 *  @return 关键字高亮字符串
 */
+ (NSMutableAttributedString *)attributeStringWithString:(NSString *)string keyword:(NSString *)keyword hilightColor:(UIColor *)color;

/**
 *  获得消息描述
 *
 *  @param message 消息
 *
 *  @return 消息描述
 */
+ (NSString *)getSimpleMessage:(YYMessage *)message;

/**
 *  判断字符串是Integer
 *
 *  @param str 字符串
 *
 *  @return 字符串是否Integer
 */
+ (BOOL)isIntegerString:(NSString *)str;

/**
 *  MD5加密字符串
 *
 *  @param str 字符串
 *
 *  @return 字符串MD5密文
 */
+ (NSString *)md5Encode:(NSString *)str;

+ (NSString *)encodeToEscapeString:(NSString *)input;

+ (NSString *)decodeFromEscapeString:(NSString *)input;

/**
 *  push到下一个Controller然后关闭自己
 *
 *  @param fromVC
 *  @param toVC
 */
+ (void)pushFromController:(UIViewController *)fromVC toController:(UIViewController *)toVC;

+ (NSString *)genTimingStringWithTime:(NSInteger)time;

/**
 *  根据类名查找subview
 *
 *  @param className subview类名
 *  @param view      view
 *
 *  @return subview
 */
+ (UIView *)findSubviewWithClassName:(NSString *)className inView:(UIView *)view;

/**
 *  处理SearchBar背景色
 *
 *  @param searchBar
 *  @param color
 */
+ (void)searchBar:(UISearchBar *)searchBar setBackgroundColor:(UIColor *)color;

/**
 *  根据关键字进行文本高亮处理
 *
 *  @param content 文本内容
 *  @param keyword 高亮关键字
 *  @param font    默认字体
 *  @param color   默认颜色
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)getHighlightContent:(NSString *)content keyword:(NSString *)keyword defaultFont:(UIFont *)font textColor:(UIColor *)color;

@end
