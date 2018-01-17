//
//  YYIMLoginManager.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMLoginProtocol.h"
#import "YYIMBaseDataManager.h"

@interface YYIMLoginManager : YYIMBaseDataManager<YYIMLoginProtocol>

+ (instancetype)sharedInstance;

@end
