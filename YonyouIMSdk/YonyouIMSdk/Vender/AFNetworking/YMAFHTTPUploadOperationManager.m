//
//  YMAFHTTPUploadOperationManager.m
//  YonyouIMSdk
//
//  Created by litfb on 15/8/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMAFHTTPUploadOperationManager.h"

@implementation YMAFHTTPUploadOperationManager

+ (instancetype)sharedManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        [self.operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

@end
