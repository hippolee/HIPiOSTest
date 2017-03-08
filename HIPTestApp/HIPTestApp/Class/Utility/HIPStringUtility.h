//
//  HIPStringUtility.h
//  litfb_test
//
//  Created by litfb on 16/1/18.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HIPStringUtility : NSObject

/**
 *  字符串判空
 *
 *  @param str 字符串
 *
 *  @return 是否为空
 */
+ (BOOL)isEmpty:(NSString *)str;

/**
 *  字符串trim
 *
 *  @param str 字符串
 *
 *  @return NSString
 */
+ (NSString *)trimString:(NSString *)str;

/**
 *  获取汉字首字母，如果参数既不是汉字/英文字母，则返回 @“#”
 *
 *  @param str 字符串
 *
 *  @return 首字母
 */
+ (NSString *)firstLetter:(NSString *)str;

/**
 *  获取汉字首字母，如果参数不是汉字/英文字母/数字，则返回 @“#”
 *
 *  @param str 字符串
 *
 *  @return 首字母
 */
+ (NSString *)firstLetterIncludeNumber:(NSString *)str;

/**
 *  返回参数中所有汉字的首字母，遇到其他字符，则用@“#”替换
 *
 *  @param str 字符串
 *
 *  @return 首字母
 */
+ (NSString *)firstLetters:(NSString *)str;

/**
 *  16进制字符串转Data
 *
 *  @param str 字符串
 *
 *  @return NSData
 */
+ (NSData *)convertHexStrToData:(NSString *)str;

/**
 *  Data转16进制字符串
 *
 *  @param data 数据
 *
 *  @return NSString
 */
+ (NSString *)convertDataToHexStr:(NSData *)data;

+ (NSString *)getValueFromUrl:(NSURL *)url forParam:(NSString *)param;

+ (NSString *)encodeToEscapeString:(NSString *)str;
+ (NSString *)decodeFromEscapeString:(NSString *)str;

@end
