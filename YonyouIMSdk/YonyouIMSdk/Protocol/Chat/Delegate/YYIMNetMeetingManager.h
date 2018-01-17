//
//  YYIMNetMeetingManager.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/15.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDataManager.h"
#import "YYIMNetMeetingProtocol.h"

@interface YYIMNetMeetingManager : YYIMBaseDataManager<YYIMNetMeetingProtocol>

+ (instancetype)sharedInstance;

@end
