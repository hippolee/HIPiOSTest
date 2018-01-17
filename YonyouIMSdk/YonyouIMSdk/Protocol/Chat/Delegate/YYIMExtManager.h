//
//  YYIMExtManager.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/10.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDataManager.h"
#import "YYIMExtProtocol.h"

@interface YYIMExtManager : YYIMBaseDataManager<YYIMExtProtocol>

+ (instancetype)sharedInstance;

@end
