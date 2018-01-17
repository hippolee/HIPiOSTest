//
//  YYIMTokenProtocol.h
//  YonyouIMSdk
//
//  Created by litfb on 15/3/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYToken.h"

@protocol YYIMTokenProtocol <NSObject>

@optional

- (YYToken *)getAppToken;

@required

- (void)getAppTokenWithComplete:(void (^)(BOOL result, id resultObject))complete;

- (void)registerTokenDelegate:(id<YYIMTokenDelegate>) delegate;

@end
