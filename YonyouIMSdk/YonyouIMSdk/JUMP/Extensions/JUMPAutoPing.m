#import "JUMPAutoPing.h"
#import "JUMPPing.h"
#import "JUMPLogging.h"
#import "JUMPStream.h"

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int jumpLogLevel = JUMP_LOG_LEVEL_WARN;
#else
static const int jumpLogLevel = JUMP_LOG_LEVEL_WARN;
#endif

@interface JUMPAutoPing ()
- (void)updatePingIntervalTimer;
- (void)startPingIntervalTimer;
- (void)stopPingIntervalTimer;
@end

#pragma mark -

@implementation JUMPAutoPing

- (id)init {
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue {
    if ((self = [super initWithDispatchQueue:queue])) {
        pingInterval = 60;
        pingTimeout = 10;
        
        lastReceiveTime = 0;
        
        jumpPing = [[JUMPPing alloc] initWithDispatchQueue:queue];
        
        [jumpPing addDelegate:self delegateQueue:moduleQueue];
    }
    return self;
}

- (BOOL)activate:(JUMPStream *)aXmppStream {
    if ([super activate:aXmppStream]) {
        [jumpPing activate:aXmppStream];
        
        return YES;
    }
    return NO;
}

- (void)deactivate {
    dispatch_block_t block = ^{ @autoreleasepool {
        
        [self stopPingIntervalTimer];
        
        lastReceiveTime = 0;
        awaitingPingResponse = NO;
        
        [jumpPing deactivate];
        [super deactivate];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
}

- (void)dealloc {
    [self stopPingIntervalTimer];
    
    [jumpPing removeDelegate:self];
}

#pragma mark Properties

- (NSTimeInterval)pingInterval {
    if (dispatch_get_specific(moduleQueueTag)) {
        return pingInterval;
    } else {
        __block NSTimeInterval result;
        
        dispatch_sync(moduleQueue, ^{
            result = pingInterval;
        });
        return result;
    }
}

- (void)setPingInterval:(NSTimeInterval)interval {
    dispatch_block_t block = ^{
        
        if (pingInterval != interval) {
            pingInterval = interval;
            
            // Update the pingTimer.
            //
            // Depending on new value and current state of the pingTimer,
            // this may mean starting, stoping, or simply updating the timer.
            
            if (pingInterval > 0) {
                // Remember: Only start the pinger after the jump stream is up and authenticated
                if ([jumpStream isAuthenticated])
                    [self startPingIntervalTimer];
            } else {
                [self stopPingIntervalTimer];
            }
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_async(moduleQueue, block);
    }
}

- (NSTimeInterval)pingTimeout {
    if (dispatch_get_specific(moduleQueueTag)) {
        return pingTimeout;
    } else {
        __block NSTimeInterval result;
        
        dispatch_sync(moduleQueue, ^{
            result = pingTimeout;
        });
        return result;
    }
}

- (void)setPingTimeout:(NSTimeInterval)timeout {
    dispatch_block_t block = ^{
        
        if (pingTimeout != timeout) {
            pingTimeout = timeout;
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_async(moduleQueue, block);
    }
}

- (NSTimeInterval)lastReceiveTime {
    if (dispatch_get_specific(moduleQueueTag)) {
        return lastReceiveTime;
    } else {
        __block NSTimeInterval result;
        
        dispatch_sync(moduleQueue, ^{
            result = lastReceiveTime;
        });
        return result;
    }
}

#pragma mark Ping Interval

- (void)handlePingIntervalTimerFire {
    if (awaitingPingResponse) return;
    
    BOOL sendPing = NO;
    
    if (lastReceiveTime == 0) {
        sendPing = YES;
    } else {
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval elapsed = (now - lastReceiveTime);
        
        JUMPLogTrace2(@"%@: %@ - elapsed(%f)", [self class], THIS_METHOD, elapsed);
        
        sendPing = ((elapsed < 0) || (elapsed >= pingInterval));
    }
    
    if (sendPing) {
        awaitingPingResponse = YES;
        
        [jumpPing sendPingToServerWithTimeout:pingTimeout];
        
        [multicastDelegate jumpAutoPingDidSendPing:self];
    }
}

- (void)updatePingIntervalTimer {
    JUMPLogTrace();
    
    NSAssert(pingIntervalTimer != NULL, @"Broken logic (1)");
    NSAssert(pingInterval > 0, @"Broken logic (2)");
    
    // The timer fires every (pingInterval / 4) seconds.
    // Upon firing it checks when data was last received from the target,
    // and sends a ping if the elapsed time has exceeded the pingInterval.
    // Thus the effective resolution of the timer is based on the configured pingInterval.
    
    uint64_t interval = ((pingInterval / 4.0) * NSEC_PER_SEC);
    
    // The timer's first fire should occur 'interval' after lastReceiveTime.
    // If there is no lastReceiveTime, then the timer's first fire should occur 'interval' after now.
    
    NSTimeInterval diff;
    if (lastReceiveTime == 0) {
        diff = 0.0;
    } else {
        diff = lastReceiveTime - [NSDate timeIntervalSinceReferenceDate];
    }
    
    dispatch_time_t bt = dispatch_time(DISPATCH_TIME_NOW, (diff * NSEC_PER_SEC));
    dispatch_time_t tt = dispatch_time(bt, interval);
    
    dispatch_source_set_timer(pingIntervalTimer, tt, interval, 0);
}

- (void)startPingIntervalTimer {
    JUMPLogTrace();
    
    if (pingInterval <= 0) {
        // Pinger is disabled
        return;
    }
    
    BOOL newTimer = NO;
    
    if (pingIntervalTimer == NULL) {
        newTimer = YES;
        pingIntervalTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, moduleQueue);
        
        dispatch_source_set_event_handler(pingIntervalTimer, ^{ @autoreleasepool {
            
            [self handlePingIntervalTimerFire];
            
        }});
    }
    
    [self updatePingIntervalTimer];
    
    if (newTimer) {
        dispatch_resume(pingIntervalTimer);
    }
}

- (void)stopPingIntervalTimer {
    JUMPLogTrace();
    
    if (pingIntervalTimer) {
        pingIntervalTimer = NULL;
    }
}

#pragma mark JUMPPing Delegate

- (void)jumpPing:(JUMPPing *)sender didReceivePongWithRTT:(NSTimeInterval)rtt {
    JUMPLogTrace();
    
    awaitingPingResponse = NO;
    [multicastDelegate jumpAutoPingDidReceivePong:self];
}

- (void)jumpPing:(JUMPPing *)sender didNotReceivePongDueToTimeout:(NSTimeInterval)timeout {
    JUMPLogTrace();
    
    awaitingPingResponse = NO;
    [multicastDelegate jumpAutoPingDidTimeout:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark JUMPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)jumpStreamDidAuthenticate:(JUMPStream *)sender
{
    lastReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    awaitingPingResponse = NO;
    
    [self startPingIntervalTimer];
}

- (void)jumpStream:(JUMPStream *)sender didReceivePing:(JUMPPacket *)ping {
    lastReceiveTime = [NSDate timeIntervalSinceReferenceDate];
}

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    lastReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    return NO;
}

- (void)jumpStream:(JUMPStream *)sender didReceiveMessage:(JUMPMessage *)message {
    lastReceiveTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)jumpStream:(JUMPStream *)sender didReceivePresence:(JUMPPresence *)presence {
    lastReceiveTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)jumpStreamDidDisconnect:(JUMPStream *)sender withError:(NSError *)error {
    [self stopPingIntervalTimer];
    
    lastReceiveTime = 0;
    awaitingPingResponse = NO;
}

@end
