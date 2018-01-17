//
//  YYPubAccountExt.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYObjExtProtocol.h"

@interface YYPubAccountExt : NSObject<YYObjExtProtocol>

@property NSString *accountId;

@property BOOL noDisturb;

@property BOOL stickTop;

+ (instancetype)defaultPubAccountExt:(NSString *)accountId;

@end
