//
//  YYIMLogger.m
//  YonyouIMSdk
//
//  Created by litfb on 15/7/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMLogger.h"
#import "YMDDLog.h"
#import "YMDDTTYLogger.h"
#import "YMDDFileLogger.h"

@implementation YYIMLogger

static int kYMLogLevel;

+ (void)initLogger {
    [YMDDLog addLogger:[YMDDTTYLogger sharedInstance]];
    
    YMDDFileLogger *fileLogger = [[YMDDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [YMDDLog addLogger:fileLogger];
}

+ (int)logLevel {
    return kYMLogLevel;
}

+ (void)setLogLevel:(int)logLevel {
    kYMLogLevel = logLevel;
}

+ (void)log:(BOOL)synchronous level:(int)level flag:(int)flag context:(int)context file:(const char *)file function:(const char *)function line:(int)line tag:(id)tag format:(NSString *)format, ... {
    va_list args;
    if (format) {
        va_start(args, format);
        [YMDDLog log:synchronous level:level flag:flag context:context file:file function:function line:line tag:tag format:format args:args];
        va_end(args);
    }
}

@end
