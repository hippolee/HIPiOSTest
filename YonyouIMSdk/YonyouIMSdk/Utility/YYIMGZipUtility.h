//
//  YYIMGZipUtility.h
//  YonyouIM
//
//  Created by litfb on 16/1/26.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYIMGZipUtility : NSObject

/**
 *  压缩数据
 *
 *  @param data
 *
 *  @return NSData
 */
+ (NSData *)gzipData:(NSData*)data;

/**
 *  解压缩数据
 *
 *  @param data
 *
 *  @return NSData
 */
+ (NSData *)unGzipData:(NSData*)data;

@end
