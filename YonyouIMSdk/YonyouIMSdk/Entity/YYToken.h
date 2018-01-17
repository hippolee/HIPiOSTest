//
//  YYToken.h
//  YonyouIMSdk
//
//  Created by litfb on 15/3/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYToken : NSObject

@property NSString *tokenStr;

+ (instancetype) tokenWithExpiration:(NSString *) tokenStr expiration:(NSString *) expirationStr;

- (NSTimeInterval) expirationTimeInterval;

@end
