//
//  YYIMFirstLetterHelper.h
//  YonyouIM
//
//  Created by litfb on 14/12/30.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYIMFirstLetterHelper : NSObject

// 获取汉字首字母，如果参数既不是汉字也不是英文字母，则返回 @“#”
+ (NSString *)firstLetter:(NSString *)chineseString;

// 获取汉字首字母，如果参数不是汉字/英文字母/数字，则返回 @“#”
+ (NSString *)firstLetterIncludeNumber:(NSString *)chineseString;

// 返回参数中所有汉字的首字母，遇到其他字符，则用 # 替换
+ (NSString *)firstLetters:(NSString *)chineseString;

@end