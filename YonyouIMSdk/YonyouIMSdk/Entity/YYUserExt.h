//
//  YYUserExt.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYObjExtProtocol.h"

@interface YYUserExt : NSObject<YYObjExtProtocol>

/**
 *  用户ID
 */
@property NSString *userId;

/**
 *  是否免打扰
 */
@property BOOL noDisturb;

/**
 *  是否置顶
 */
@property BOOL stickTop;

/**
 *  默认值
 *
 *  @return
 */
+ (instancetype)defaultUserExt:(NSString *)userId;

@end
