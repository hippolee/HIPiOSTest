//
//  YYIMAttachManager.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDataManager.h"
#import "YYIMAttachProtocol.h"

@interface YYIMAttachManager : YYIMBaseDataManager<YYIMAttachProtocol>

+ (instancetype)sharedInstance;

@end
