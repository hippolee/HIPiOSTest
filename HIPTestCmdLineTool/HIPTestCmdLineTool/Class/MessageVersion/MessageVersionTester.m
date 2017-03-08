//
//  MessageVersionTester.m
//  litfb_test_cmdtool
//
//  Created by 李腾飞 on 2017/2/10.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "MessageVersionTester.h"
#import "MessageVersionUtility.h"

@implementation MessageVersionTester

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)test1 {
    NSMutableArray *versions = [NSMutableArray array];
    [versions addObject:[NSNumber numberWithInteger:1]];
    [versions addObject:[NSNumber numberWithInteger:2]];
    [versions addObject:[NSNumber numberWithInteger:3]];
    [versions addObject:[NSNumber numberWithInteger:4]];
    [versions addObject:[NSNumber numberWithInteger:5]];
    [versions addObject:[NSNumber numberWithInteger:6]];
    [versions addObject:[NSNumber numberWithInteger:8]];
    [versions addObject:[NSNumber numberWithInteger:9]];
    [versions addObject:[NSNumber numberWithInteger:10]];
    [versions addObject:[NSNumber numberWithInteger:7]];
    [versions addObject:[NSNumber numberWithInteger:12]];
    [versions addObject:[NSNumber numberWithInteger:11]];
    [versions addObject:[NSNumber numberWithInteger:13]];
    [versions addObject:[NSNumber numberWithInteger:14]];
    [versions addObject:[NSNumber numberWithInteger:15]];
    [versions addObject:[NSNumber numberWithInteger:16]];
    [versions addObject:[NSNumber numberWithInteger:17]];
    [versions addObject:[NSNumber numberWithInteger:18]];
    [versions addObject:[NSNumber numberWithInteger:19]];
    
    NSMutableArray *versions1 = [NSMutableArray array];
    [versions addObject:[NSNumber numberWithInteger:31]];
    [versions addObject:[NSNumber numberWithInteger:32]];
    
    NSMutableArray *versions2 = [NSMutableArray array];
    [versions2 addObject:[NSNumber numberWithInteger:33]];
    [versions2 addObject:[NSNumber numberWithInteger:34]];
    [versions2 addObject:[NSNumber numberWithInteger:35]];
    [versions2 addObject:[NSNumber numberWithInteger:37]];
    [versions2 addObject:[NSNumber numberWithInteger:38]];
    [versions2 addObject:[NSNumber numberWithInteger:39]];
    [versions2 addObject:[NSNumber numberWithInteger:36]];
    [versions2 addObject:[NSNumber numberWithInteger:40]];
    [versions2 addObject:[NSNumber numberWithInteger:41]];
    [versions2 addObject:[NSNumber numberWithInteger:42]];
    [versions2 addObject:[NSNumber numberWithInteger:43]];
    [versions2 addObject:[NSNumber numberWithInteger:44]];
    [versions2 addObject:[NSNumber numberWithInteger:45]];
    [versions2 addObject:[NSNumber numberWithInteger:47]];
    [versions2 addObject:[NSNumber numberWithInteger:46]];
    [versions2 addObject:[NSNumber numberWithInteger:48]];
    
    MessageVersionUtility *msgVerUtil = [MessageVersionUtility sharedInstance];
    NSLog(@"--------began");
    [msgVerUtil setMessageVersionNumber:0];
    NSLog(@"--------");
    for (NSNumber *verNum in versions) {
        [msgVerUtil handleMessageVersion:[verNum integerValue]];
    }
    NSLog(@"--------");
    for (NSNumber *verNum in versions1) {
        [msgVerUtil handleMessageVersion:[verNum integerValue]];
    }
    NSLog(@"--------");
    [msgVerUtil setMessageVersionNumber:30];
    [msgVerUtil attemptIncreaseMessageVersion];
    NSLog(@"--------");
    for (NSNumber *verNum in versions2) {
        [msgVerUtil handleMessageVersion:[verNum integerValue]];
    }
    NSLog(@"--------end");
}

- (void)test2 {
    NSLog(@"--------began");
    int count = 54;
    NSMutableArray *datas = [NSMutableArray array];
    for (int i = 1; i <= count; i++) {
        [datas addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int n = count - 1; n >= 1; n--) {
        int m = rand() % (count - n);
        NSNumber *verNum = [datas objectAtIndex:m];
        [datas removeObjectAtIndex:m];
        [datas addObject:verNum];
    }
    NSLog(@"datas:%@", datas);
    
    NSArray *data0 = [datas subarrayWithRange:NSMakeRange(0, count / 3)];
    NSArray *data1 = [datas subarrayWithRange:NSMakeRange(count / 3, count / 3)];
    NSArray *data2 = [datas subarrayWithRange:NSMakeRange(count * 2 / 3, count / 3)];
    
    NSLog(@"data0:%@", data0);
    NSLog(@"data1:%@", data1);
    NSLog(@"data2:%@", data2);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSNumber *verNum in data0) {
            [[MessageVersionUtility sharedInstance] handleMessageVersion:[verNum integerValue]];
            [NSThread sleepForTimeInterval:1.0];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSNumber *verNum in data1) {
            [[MessageVersionUtility sharedInstance] handleMessageVersion:[verNum integerValue]];
            [NSThread sleepForTimeInterval:1.0];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSNumber *verNum in data2) {
            [[MessageVersionUtility sharedInstance] handleMessageVersion:[verNum integerValue]];
            [NSThread sleepForTimeInterval:1.0];
        }
    });
    
    [NSThread sleepForTimeInterval:20.0];
    NSLog(@"--------end");
}

@end
