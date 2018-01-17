//
//  YYIMMessageVersionHelper.h
//  YonyouIMSdk
//
//  Created by litfb on 16/3/9.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYIMMessageVersionHelper : NSObject

/**
 *  sharedInstance
 *
 *  @return
 */
+ (instancetype)sharedInstance;

/**
 *  尝试更新本地消息版本号
 */
- (void)attemptIncreaseMessageVersion;

/**
 *  处理新到达消息版本号
 *
 *  @param version 版本号
 */
- (void)handleMessageVersion:(NSInteger)version;

@end
