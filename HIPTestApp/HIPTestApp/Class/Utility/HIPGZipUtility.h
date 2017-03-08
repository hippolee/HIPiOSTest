//
//  HIPGZipUtility.h
//  litfb_test
//
//  Created by litfb on 16/1/26.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HIPGZipUtility : NSObject

/**
 *  压缩数据
 *
 *  @param data NSData
 *
 *  @return NSData
 */
+ (NSData *)gzipData:(NSData*)data;

/**
 *  解压缩数据
 *
 *  @param data NSData
 *
 *  @return NSData
 */
+ (NSData *)unGzipData:(NSData*)data;

@end
