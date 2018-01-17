//
//  YYIMConnectManager.m
//  YonyouIMSdk
//
//  Created by litfb on 15/3/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMConnectManager.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "JUMPFramework.h"
#import "YYIMChat.h"
#import "YYIMConfig.h"
#import "YYIMStringUtility.h"
#import "YYIMDefs.h"
#import "JUMPAutoPing.h"
#import "JUMPReconnect.h"
#import "YYIMLogger.h"
#import "YMAFNetworking.h"

@interface YYIMConnectManager ()<JUMPStreamDelegate, JUMPReconnectDelegate, JUMPAutoPingDelegate>

@property (retain, nonatomic) JUMPAutoPing *autoPing;
@property (retain, nonatomic) JUMPReconnect *reconnect;
@property (retain, nonatomic) NSThread *reconnectThread;
@property (assign, nonatomic) BOOL isStopped;

@property (assign, nonatomic) NSTimeInterval keepAliveInterval;
@property dispatch_source_t keepAliveTimer;

@end

@implementation YYIMConnectManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)didActivate {
    [self setKeepAliveInterval:15];
    
    JUMPAutoPing *autoPing = [[JUMPAutoPing alloc] init];
    [autoPing activate:[self activeStream]];
    [autoPing addDelegate:self delegateQueue:[self moduleQueue]];
    [self setAutoPing:autoPing];
    
    JUMPReconnect *reconnect = [[JUMPReconnect alloc] init];
    [reconnect activate:[self activeStream]];
    [reconnect addDelegate:self delegateQueue:[self moduleQueue]];
    [reconnect setAutoReconnect:YES];
    [self setReconnect:reconnect];
    
    [self setIsStopped:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkDidChange:) name:YMAFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)stopReconnect {
    [self setIsStopped:YES];
}

- (void)setKeepAliveInterval:(NSTimeInterval)keepAliveInterval {
    if (_keepAliveInterval != keepAliveInterval) {
        if (keepAliveInterval <= 0.0) {
            _keepAliveInterval = keepAliveInterval;
        } else {
            _keepAliveInterval = MAX(keepAliveInterval, JUMP_MIN_KEEPALIVE_INTERVAL);
        }
        [self setupKeepAliveTimer];
    }
}

- (void)setupKeepAliveTimer {
    if (self.keepAliveTimer) {
        dispatch_source_cancel(self.keepAliveTimer);
        self.keepAliveTimer = NULL;
    }
    
    if (self.keepAliveInterval > 0) {
        self.keepAliveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [self moduleQueue]);
        
        dispatch_source_set_event_handler(self.keepAliveTimer, ^{ @autoreleasepool {
            [self keepAlive];
        }});
        
        // Everytime we send or receive data, we update our lastSendReceiveTime.
        // We set our timer to fire several times per keepAliveInterval.
        // This allows us to maintain a single timer,
        // and an acceptable timer resolution (assuming larger keepAliveIntervals).
        
        uint64_t interval = (self.keepAliveInterval * NSEC_PER_SEC);
        
        dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, interval);
        
        dispatch_source_set_timer(self.keepAliveTimer, tt, interval, 1.0);
        dispatch_resume(self.keepAliveTimer);
    }
}

- (void)keepAlive {
    if (![self isStopped]) {
        [[YYIMChat sharedInstance].chatManager doAutoLogin];
    }
}

#pragma mark jump delegate

- (void)jumpStreamWillConnect:(JUMPStream *)sender {
    if ([self isStopped]) {
        [self setIsStopped:NO];
    }
}

- (void)jumpStreamDidAuthenticate:(JUMPStream *)sender {

}

- (void)jumpStreamDidDisconnect:(JUMPStream *)sender withError:(NSError *)error {
    YYIMLogError(@"jumpstream did disconnect!error:%@", [error description]);
}

- (void)jumpStreamWasToldToDisconnect:(JUMPStream *)sender {
    YYIMLogError(@"jumpstream was told to disconnect!");
    if (![self isStopped]) {
        [self setIsStopped:YES];
    }
}

- (void)jumpStream:(JUMPStream *)sender didReceiveError:(JUMPError *)error {
    if ([error isStreamError] && [error code] == 409) {
        [[self activeDelegate] didLoginConflictOccurred];
        [[YYIMChat sharedInstance].chatManager logoff];
        [self setIsStopped:YES];
        YYIMLogDebug(@"conflict! connect manager stopped!");
    }
}

#pragma mark autoping delegate

- (void)jumpAutoPingDidTimeout:(JUMPAutoPing *)sender {
    YYIMLogError(@"ping timeout");
    if (![self isStopped]) {
        [[YYIMChat sharedInstance].chatManager doAutoLogin];
    }
}

#pragma mark reconnect delegate

- (void)jumpReconnect:(JUMPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags {
    YYIMLogError(@"didDetectAccidentalDisconnect");
}

- (BOOL)jumpReconnect:(JUMPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags {
    YYIMLogInfo(@"shouldAttemptAutoReconnect");
    return YES;
}

#pragma mark private func

- (void)networkDidChange:(id)sender {
    if (![self isStopped]) {
        [[YYIMChat sharedInstance].chatManager doAutoLogin];
    }
}

- (void)dealloc {
    if (self.keepAliveTimer) {
        dispatch_source_cancel(self.keepAliveTimer);
    }
}

@end
