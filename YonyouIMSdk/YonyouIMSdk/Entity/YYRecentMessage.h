//
//  YYRecentMessage.h
//  YonyouIM
//
//  Created by litfb on 15/1/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYMessage.h"
#import "YYObjExtProtocol.h"

@interface YYRecentMessage : YYMessage

@property NSInteger newMessageCount;

@property NSInteger atCount;

@property id<YYObjExtProtocol> chatExt;

@end
