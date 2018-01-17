//
//  YYIMBaseDelegate.m
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "YYIMBaseDataManager.h"
#import "JUMPFramework.h"
#import "YMGCDMulticastDelegate.h"
#import "YYIMChatDelegate.h"

@interface YYIMBaseDataManager ()<JUMPStreamDelegate> {
    
    dispatch_queue_t moduleQueue;
    void *moduleQueueTag;
    
}

@property (retain, atomic) JUMPStream *jumpStream;

@property (retain, atomic) JUMPIDTracker *responseTracker;

@property (retain, atomic) YMGCDMulticastDelegate<YYIMChatDelegate> *multicastDelegate;

@end

@implementation YYIMBaseDataManager

- (instancetype)init {
    if (self = [super init]) {
        moduleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        moduleQueueTag = &moduleQueueTag;
        dispatch_queue_set_specific(moduleQueue, moduleQueueTag, moduleQueueTag, NULL);
    }
    return self;
}

- (BOOL)activateWithJUMPStream:(JUMPStream *)aJumpStream delegate:(YMGCDMulticastDelegate<YYIMChatDelegate> *)aDelegate {
    __block BOOL result = YES;
    
    dispatch_block_t block = ^{
        if (self.jumpStream != nil) {
            result = NO;
        } else {
            self.jumpStream = aJumpStream;
            [self.jumpStream addDelegate:self delegateQueue:moduleQueue];
            self.multicastDelegate = aDelegate;
            self.responseTracker = [[JUMPIDTracker alloc] initWithDispatchQueue:moduleQueue];
            [self didActivate];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    return result;
}

- (void)didActivate {
    // Override me to do custom work after the module is activated
}

- (NSString *)moduleName {
    return NSStringFromClass([self class]);
}

- (dispatch_queue_t)moduleQueue {
    return moduleQueue;
}

- (JUMPStream *)activeStream {
    if (dispatch_get_specific(moduleQueueTag)) {
        return self.jumpStream;
    } else {
        __block JUMPStream *result;
        
        dispatch_sync(moduleQueue, ^{
            result = self.jumpStream;
        });
        
        return result;
    }
}

- (YMGCDMulticastDelegate<YYIMChatDelegate> *)activeDelegate {
    if (dispatch_get_specific(moduleQueueTag)) {
        return self.multicastDelegate;
    } else {
        __block YMGCDMulticastDelegate<YYIMChatDelegate> *result;
        
        dispatch_sync(moduleQueue, ^{
            result = self.multicastDelegate;
        });
        
        return result;
    }
}

- (JUMPIDTracker *)tracker {
    if (dispatch_get_specific(moduleQueueTag)) {
        return self.responseTracker;
    } else {
        __block JUMPIDTracker *result;
        
        dispatch_sync(moduleQueue, ^{
            result = self.responseTracker;
        });
        
        return result;
    }
}

#pragma mark delegate

- (void)addDelegate:(id<YYIMChatDelegate>)delegate {
    dispatch_block_t block = ^{
        [self.multicastDelegate removeDelegate:delegate];
        [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_async(moduleQueue, block);
    }
}

- (void)removeDelegate:(id<YYIMChatDelegate>)delegate {
    dispatch_block_t block = ^{
        [self.multicastDelegate removeDelegate:delegate];
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_async(moduleQueue, block);
    }
}

#pragma mark jumpstream delegate

- (void)jumpStreamDidDisconnect:(JUMPStream *)sender withError:(NSError *)error {
    [self.responseTracker removeAllIDs];
}

#pragma mark sound vibrate

- (void)playSoundAndVibrate {
    [self playSound];
    [self playVibrate];
}

// 响铃
- (void)playSound {
    NSURL *url = [[NSBundle mainBundle] URLForResource: @"sms-received1" withExtension: @"wav"];
    
    if (url) {
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

// 震动
- (void)playVibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
