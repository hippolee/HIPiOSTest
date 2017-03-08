//
//  MessageVersionUtility.m
//  litfb_test_cmdtool
//
//  Created by litfb on 16/3/10.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "MessageVersionUtility.h"

@interface MessageVersionUtility ()

@property NSMutableArray<NSNumber *> *versionArray;

@property NSInteger currVersion;

@end

@implementation MessageVersionUtility

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
        [self setCurrVersion:0];
    }
    return self;
}

- (void)attemptIncreaseMessageVersion {
    @synchronized(self) {
        NSLog(@"attemptIncreaseMessageVersion currentVersion %ld", (long)self.currVersion);
        
        NSInteger version = [self getMessageVersionNumber];
        if ([self.versionArray count] <= 0) {
            NSLog(@"empty versionArray");
            return;
        }
        
        int index = -1;
        NSLog(@"--for begin");
        for (int i = 0; i < [self.versionArray count]; i++) {
            NSInteger v = [[self.versionArray objectAtIndex:i] integerValue];
            NSLog(@"--v %ld", (long)v);
            NSInteger nextVersion = version + 1;
            if (nextVersion == v) {
                version = nextVersion;
                index = i;
            }
            if (nextVersion < v) {
                NSLog(@"--break ");
                break;
            }
        }
        NSLog(@"--for end");
        [self setMessageVersionNumber:version];
        
        if (index >= 0) {
            self.versionArray = [NSMutableArray arrayWithArray:[self.versionArray subarrayWithRange:NSMakeRange(index + 1, [self.versionArray count] - index - 1)]];
            NSLog(@"new versions %@", self.versionArray);
        }
    }
}

- (void)handleMessageVersion:(NSInteger)version {
    @synchronized(self) {
        NSLog(@"handleMessageVersion version %ld", (long)version);
        
        [self.versionArray addObject:[NSNumber numberWithInteger:version]];
        self.versionArray = [NSMutableArray arrayWithArray:[self.versionArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *verNum1, NSNumber *verNum2) {
            return [verNum1 compare:verNum2];
        }]];
        
        NSLog(@"version array count %lu", (unsigned long)[self.versionArray count]);
        NSLog(@"current versions %@", self.versionArray);
        
        [self attemptIncreaseMessageVersion];
    }
}

- (void)setMessageVersionNumber:(NSInteger)version {
    NSLog(@"change current version %ld", (long)version);
    self.currVersion = version;
}

- (NSInteger)getMessageVersionNumber {
    return self.currVersion;
}

@end
