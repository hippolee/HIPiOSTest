//
//  YYIMError.m
//  YonyouIM
//
//  Created by litfb on 14/12/25.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "YYIMError.h"

@implementation YYIMError

+ (YYIMError *)errorWithCode:(NSInteger)errCode
              errorMessage:(NSString *)errorMsg {
    YYIMError *err = [[YYIMError alloc] init];
    [err setErrorCode:errCode];
    [err setErrorMsg:errorMsg];
    return err;
}

+ (YYIMError *)errorWithNSError:(NSError *)error {
    YYIMError *err = [[YYIMError alloc] init];
    if (error) {
        [err setSrcError:error];
        [err setErrorCode:error.code];
        [err setErrorMsg:error.localizedDescription];
    }
    return err;
}

@end
