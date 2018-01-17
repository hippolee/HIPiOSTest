//
//  YYIMConnectManager.h
//  YonyouIMSdk
//
//  Created by litfb on 15/3/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseDataManager.h"
#import "YYIMConnectProtocol.h"

@interface YYIMConnectManager : YYIMBaseDataManager<YYIMConnectProtocol>

+ (instancetype)sharedInstance;

- (void)stopReconnect;

@end
