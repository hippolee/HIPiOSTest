//
//  YYSettings.h
//  YonyouIMSdk
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYSettings : NSObject

// 新消息提示
@property BOOL newMsgRemind;
// 声音
@property BOOL playSound;
// 振动
@property BOOL playVibrate;
// 显示消息详情
@property BOOL showDetail;

/**
 *  默认设置
 *  新消息提示：  TRUE
 *  声音：       TRUE
 *  震动：       TRUE
 *  显示消息详情：TRUE
 *
 *  @return 默认设置
 */
+ (instancetype)defaultSettings;

@end
