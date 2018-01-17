//
//  YYIMPubAccountManager.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDataManager.h"
#import "YYIMPubAccountProtocol.h"

@interface YYIMPubAccountManager : YYIMBaseDataManager<YYIMPubAccountProtocol>

+ (instancetype)sharedInstance;

@end
