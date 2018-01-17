//
//  YYIMMessageVersionHelper.m
//  YonyouIMSdk
//
//  Created by litfb on 16/3/9.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMMessageVersionHelper.h"
#import "YYIMConfig.h"
#import "YYIMLogger.h"

@interface YYIMMessageVersionHelper ()

@property NSMutableArray<NSNumber *> *versionArray;

@end

@implementation YYIMMessageVersionHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    if (self = [super init]) {
        self.versionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)attemptIncreaseMessageVersion {
    @synchronized(self) {
        NSInteger currVersion = [[YYIMConfig sharedInstance] getMessageVersionNumber];
        //        YYIMLogDebug(@"attemptIncreaseMessageVersion currentVersion %ld", (long)currVersion);
        
        NSInteger version = currVersion;
        if ([self.versionArray count] <= 0) {
            //            YYIMLogDebug(@"empty versionArray");
            return;
        }
        
        int index = -1;
        //        YYIMLogDebug(@"--for begin");
        for (int i = 0; i < [self.versionArray count]; i++) {
            NSInteger v = [[self.versionArray objectAtIndex:i] integerValue];
            //            YYIMLogDebug(@"--v %ld", (long)v);
            NSInteger nextVersion = version + 1;
            if (nextVersion == v) {
                version = nextVersion;
                index = i;
            }
            if (nextVersion < v) {
                //                YYIMLogDebug(@"--break ");
                break;
            }
        }
        //        YYIMLogDebug(@"--for end");
        if (version > currVersion) {
            //            YYIMLogDebug(@"change current version %ld", (long)version);
            [[YYIMConfig sharedInstance] setMessageVersionNumber:version];
        }
        
        if (index >= 0) {
            self.versionArray = [NSMutableArray arrayWithArray:[self.versionArray subarrayWithRange:NSMakeRange(index + 1, [self.versionArray count] - index - 1)]];
            //            YYIMLogDebug(@"new versions %@", self.versionArray);
        }
    }
}

- (void)handleMessageVersion:(NSInteger)version {
    @synchronized(self) {
        //        YYIMLogDebug(@"handleMessageVersion version %ld", (long)version);
        
        [self.versionArray addObject:[NSNumber numberWithInteger:version]];
        self.versionArray = [NSMutableArray arrayWithArray:[self.versionArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *verNum1, NSNumber *verNum2) {
            return [verNum1 compare:verNum2];
        }]];
        
        //        YYIMLogDebug(@"version array count %lu", (unsigned long)[self.versionArray count]);
        //        YYIMLogDebug(@"current versions %@", self.versionArray);
        
        [self attemptIncreaseMessageVersion];
    }
}

@end
