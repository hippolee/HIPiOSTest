//
//  YYIMRosterCollectProvider.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseDataManager.h"
#import "YYIMRosterProtocol.h"

@interface YYIMRosterCollectProvider : YYIMBaseDataManager<YYIMRosterProtocol>

+ (instancetype)sharedInstance;

@end
