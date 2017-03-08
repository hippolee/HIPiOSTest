//
//  UrlAnalysisUtility.m
//  litfb_test_cmdtool
//
//  Created by 李腾飞 on 2017/2/10.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "UrlAnalysisUtility.h"

#define URL_REGEX @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"

@implementation UrlAnalysisUtility

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (BOOL)isValidUrl:(NSString *)url {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", URL_REGEX];
    
    return [predicate evaluateWithObject:url];
}

@end
