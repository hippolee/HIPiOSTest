#import <Foundation/Foundation.h>

#import "JUMPJID.h"
#import "JUMPPacket.h"
#import "JUMPModule.h"

#define _JUMP_PING_H

@class JUMPOPTracker;

@interface JUMPPing : JUMPModule {
	JUMPOPTracker *pingTracker;
}

/**
 * Send pings to the server
 * The disco module may be used to detect if the target supports ping.
**/
- (void)sendPingToServer;
- (void)sendPingToServerWithTimeout:(NSTimeInterval)timeout;

@end

@protocol JUMPPingDelegate
@optional

- (void)jumpPing:(JUMPPing *)sender didReceivePongWithRTT:(NSTimeInterval)rtt;
- (void)jumpPing:(JUMPPing *)sender didNotReceivePongDueToTimeout:(NSTimeInterval)timeout;

// Note: If the jump stream is disconnected, no delegate methods will be called, and outstanding pings are forgotten.

@end
