//
//  YYIMTeleconferenceManager.h
//  YonyouIMSdk
//
//  Created by litfb on 15/6/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDataManager.h"
#import "YYIMTeleconferenceProtocol.h"

@interface YYIMTeleconferenceManager : YYIMBaseDataManager<YYIMTeleconferenceProtocol>

+ (instancetype)sharedInstance;

@end
