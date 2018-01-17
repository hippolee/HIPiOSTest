//
//  YYIMStringUtility.h
//  YonyouIM
//
//  Created by litfb on 14/12/31.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYIMStringUtility : NSObject

/**
 *  字符串判空
 *
 *  @param str 字符串
 *
 *  @return 是否nil或@""
 */
+ (BOOL)isEmpty:(NSString *)str;

/**
 *  根据文件ID获得文件下载URL
 *
 *  @param res 文件ID
 *
 *  @return 文件下载URL
 */
+ (NSString *)genFullPathRes:(NSString *)res;

/**
 *  根据图片ID获得图片缩略图URL
 *
 *  @param res 图片ID
 *
 *  @return 图片缩略图URL
 */
+ (NSString *)genFullPathResThumb:(NSString *)res;

/**
 *  返回非空字符串
 *
 *  @param str 字符串
 *
 *  @return 如果字符串为空返回@""
 */
+ (NSObject *)notNilString:(NSString *)str;

/**
 *  判断字符串是否中文
 *
 *  @param str 字符串
 *
 *  @return 字符串是否中文
 */
+ (BOOL)isChinese:(NSString *)str;

/**
 *  MD5加密字符串
 *
 *  @param str 字符串
 *
 *  @return 字符串MD5密文
 */
+ (NSString *)md5Encode:(NSString *)str;

/**
 *  SHA1加密字符串
 *
 *  @param str 字符串
 *
 *  @return 字符串SHA1密文
 */
+ (NSString *)sha1Encode:(NSString *)str;

/**
 *  Base64加密字符串
 *
 *  @param str 字符串
 *
 *  @return 字符串Base64密文
 */
+ (NSData *)base64Decode:(NSString *)str;

+ (NSString *)encodeToEscapeString:(NSString *)input;

+ (NSString *)decodeFromEscapeString:(NSString *)input;

+ (NSString *)decodeFromUnicode:(NSString *)input;

/**
 *  JSONString解析JSONObject
 *
 *  @param jsonString JSONString
 *  @param error      error
 *
 *  @return JSONObject
 */
+ (id)decodeJsonString:(NSString *)jsonString error:(NSError **)error;

/**
 *  JSONObject生成JSONString
 *
 *  @param jsonObject JSONObject
 *  @param error      error
 *
 *  @return JSONString
 */
+ (NSString *)encodeJsonObject:(id)jsonObject error:(NSError **)error;

/**
 *  判断字符串是否全是数字
 *
 *  @param str 字符串
 *
 *  @return BOOL
 */
+ (BOOL)isNumberString:(NSString *)str;

@end
