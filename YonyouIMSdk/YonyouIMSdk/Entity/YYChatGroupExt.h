//
//  YYChatGroupExt.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYObjExtProtocol.h"

@interface YYChatGroupExt : NSObject<YYObjExtProtocol>

@property NSString *groupId;

@property BOOL noDisturb;

@property BOOL stickTop;

@property BOOL showName;

+ (instancetype)defaultChatGroupExt:(NSString *)groupId;

@end
