#import "JUMPPing.h"
#import "JUMPOPTracker.h"
#import "JUMPFramework.h"

#define DEFAULT_TIMEOUT 30.0 // seconds

#pragma mark -

@interface JUMPPingInfo : JUMPBasicOPTrackingInfo {
    NSDate *timeSent;
}

@property (nonatomic, readonly) NSDate *timeSent;

- (NSTimeInterval)rtt;

@end

#pragma mark -

@interface JUMPPing ()<JUMPStreamDelegate>

@end

#pragma mark -

@implementation JUMPPing

- (id)init {
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue {
    if ((self = [super initWithDispatchQueue:queue])) {

    }
    return self;
}

- (BOOL)activate:(JUMPStream *)aXmppStream {
    if ([super activate:aXmppStream]) {
        pingTracker = [[JUMPOPTracker alloc] initWithDispatchQueue:moduleQueue];
        return YES;
    }
    return NO;
}

- (void)deactivate {
    
    dispatch_block_t block = ^{ @autoreleasepool {
        [pingTracker removeAllOPDatas];
        pingTracker = nil;
    }};
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    [super deactivate];
}

- (void)sendPingToServer {
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    return [self sendPingToServerWithTimeout:DEFAULT_TIMEOUT];
}

- (void)sendPingToServerWithTimeout:(NSTimeInterval)timeout {
    // Send ping packet
    // opcode:0x0002
    
    JUMPPacket *ping = [[JUMPPacket alloc] initWithOpData:JUMP_OPDATA(JUMPPingPacketOpCode)];
    
    JUMPPingInfo *pingInfo = [[JUMPPingInfo alloc] initWithTarget:self
                                                         selector:@selector(handlePong:withInfo:)
                                                          timeout:timeout];
    
    [pingTracker addOPData:[ping opData] trackingInfo:pingInfo];
    
    [jumpStream sendPacket:ping];
}

- (void)handlePong:(JUMPPacket *)pong withInfo:(JUMPPingInfo *)pingInfo {
    if (pong) {
        [multicastDelegate jumpPing:self didReceivePongWithRTT:[pingInfo rtt]];
    } else {
        // Timeout
        [multicastDelegate jumpPing:self didNotReceivePongDueToTimeout:[pingInfo timeout]];
    }
}

- (void)jumpStream:(JUMPStream *)sender didReceivePing:(JUMPPacket *)ping {
    [pingTracker invokeForOPData:[ping opData] withObject:ping];
}

- (void)jumpStreamDidDisconnect:(JUMPStream *)sender withError:(NSError *)error {
    [pingTracker removeAllOPDatas];
}

@end

#pragma mark -

@implementation JUMPPingInfo

@synthesize timeSent;

- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector timeout:(NSTimeInterval)aTimeout {
    if ((self = [super initWithTarget:aTarget selector:aSelector timeout:aTimeout])) {
        timeSent = [[NSDate alloc] init];
    }
    return self;
}

- (NSTimeInterval)rtt {
    return [timeSent timeIntervalSinceNow] * -1.0;
}


@end
