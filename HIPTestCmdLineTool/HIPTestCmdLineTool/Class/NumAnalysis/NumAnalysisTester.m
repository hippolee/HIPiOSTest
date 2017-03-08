//
//  NumAnalysisTester.m
//  litfb_test_cmdtool
//
//  Created by 李腾飞 on 2017/3/7.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "NumAnalysisTester.h"
#import "NumAnalysisUtility.h"

@implementation NumAnalysisTester

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)testNumRegex {
    [[NumAnalysisUtility sharedInstance] test1];
}

@end
