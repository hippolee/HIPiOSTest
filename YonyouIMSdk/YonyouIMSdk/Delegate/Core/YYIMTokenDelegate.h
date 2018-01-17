//
//  YYIMTokenDelegate.h
//  YonyouIM
//
//  Created by litfb on 15/1/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYToken.h"

@protocol YYIMTokenDelegate <NSObject>

@optional

- (void)getAppTokenWithComplete:(void (^)(BOOL result, id resultObject))complete;

@required

- (YYToken *) getAppToken;

@end
