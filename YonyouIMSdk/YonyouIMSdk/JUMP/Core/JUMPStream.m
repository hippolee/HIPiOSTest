//
//  JUMPStream.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <objc/runtime.h>
#import <libkern/OSAtomic.h>
#import <CFNetwork/CFNetwork.h>

#import "JUMPStream.h"
#import "JUMPLogging.h"
#import "JUMPInternal.h"
#import "JUMPParser.h"
#import "JUMPIDTracker.h"
#import "JUMPSRVResolver.h"
#import "JUMPPlainAuthentication.h"
#import "JUMPAnonymousAuthentication.h"
#import "JUMPIQ.h"
#import "JUMPMessage.h"
#import "JUMPPresence.h"
#import "JUMPError.h"
#import "YYIMLogger.h"
#import <Security/SecureTransport.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int jumpLogLevel = JUMP_LOG_LEVEL_INFO | JUMP_LOG_FLAG_SEND_RECV; // | JUMP_LOG_FLAG_TRACE;
#else
static const int jumpLogLevel = JUMP_LOG_LEVEL_WARN;
#endif

/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

// Define the timeouts (in seconds) for retreiving various parts of the XML stream
#define TIMEOUT_JUMP_WRITE         -1
#define TIMEOUT_JUMP_READ_STREAM   -1

// Define the tags we'll use to differentiate what it is we're currently reading or writing
#define TAG_JUMP_READ_HEADER        100
#define TAG_JUMP_READ_BODY          101
#define TAG_JUMP_READ_RUBBISH       109
#define TAG_JUMP_WRITE_START        200
#define TAG_JUMP_WRITE_STOP         201
#define TAG_JUMP_WRITE_STREAM       202
#define TAG_JUMP_WRITE_RECEIPT      203

// Define the timeouts (in seconds) for SRV
#define TIMEOUT_SRV_RESOLUTION 30.0

NSString *const JUMPStreamErrorDomain = @"JUMPStreamErrorDomain";
NSString *const JUMPStreamDidChangeMyJIDNotification = @"JUMPStreamDidChangeMyJID";

NSInteger const JUMPStreamPacketHeaderLength = 13;
const NSTimeInterval JUMPStreamTimeoutNone = -1;

enum JUMPStreamFlags {
    kP2PInitiator                 = 1 << 0,  // If set, we are the P2P initializer
    kIsSecure                     = 1 << 1,  // If set, connection has been secured via SSL/TLS
    kIsAuthenticated              = 1 << 2,  // If set, authentication has succeeded
    kDidStartNegotiation          = 1 << 3,  // If set, negotiation has started at least once
};

enum JUMPStreamConfig {
    kP2PMode                      = 1 << 0,  // If set, the JUMPStream was initialized in P2P mode
    kResetByteCountPerConnection  = 1 << 1,  // If set, byte count should be reset per connection
    kEnableBackgroundingOnSocket  = 1 << 2,  // If set, the VoIP flag should be set on the socket
};

#pragma mark -

@interface JUMPStream () {
    
    dispatch_queue_t jumpQueue;
    void *jumpQueueTag;
    
    dispatch_queue_t willSendIqQueue;
    dispatch_queue_t willSendMessageQueue;
    dispatch_queue_t willSendPresenceQueue;
    
    dispatch_queue_t willReceiveStanzaQueue;
    
    dispatch_queue_t didReceiveIqQueue;
    
    dispatch_source_t connectTimer;
    
    YMGCDMulticastDelegate <JUMPStreamDelegate> *multicastDelegate;
    
    JUMPStreamState state;
    
    YMGCDAsyncSocket *asyncSocket;
    
    uint64_t numberOfBytesSent;
    uint64_t numberOfBytesReceived;
    
    JUMPHeader *header;
    JUMPParser *parser;
    NSError *parserError;
    NSError *otherError;
    
    //    Byte flags;
    BOOL isSecure;
    BOOL isAuthenticated;
    
    Byte config;
    
    NSString *hostName;
    UInt16 hostPort;
    
    JUMPStreamStartTLSPolicy startTLSPolicy;
    id <JUMPSASLAuthentication> auth;
    id <JUMPCustomBinding> customBinding;
    NSDate *authenticationDate;
    
    JUMPJID *myJID_setByClient;
    JUMPJID *myJID_setByServer;
    JUMPJID *remoteJID;
    
    JUMPPresence *myPresence;
    
    NSTimeInterval keepAliveInterval;
    dispatch_source_t keepAliveTimer;
    NSTimeInterval lastSendReceiveTime;
    NSData *keepAliveData;
    
    NSMutableArray *registeredModules;
    NSMutableDictionary *autoDelegateDict;
    
    JUMPSRVResolver *srvResolver;
    NSArray *srvResults;
    NSUInteger srvResultsIndex;
    
    JUMPIDTracker *idTracker;
    
    NSMutableArray *receipts;
    
    id userTag;
}
@end

@interface JUMPPacketReceipt (PrivateAPI)

- (void)signalSuccess;
- (void)signalFailure;

@end

#pragma mark -

@implementation JUMPStream

@synthesize tag = userTag;
@synthesize jumpQueue;
@synthesize jumpQueueTag;

/**
 * Shared initialization between the various init methods.
 **/
- (void)commonInit {
    jumpQueueTag = &jumpQueueTag;
    jumpQueue = dispatch_queue_create("jump", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(jumpQueue, jumpQueueTag, jumpQueueTag, NULL);
    
    willSendIqQueue = dispatch_queue_create("jump.willSendIq", DISPATCH_QUEUE_SERIAL);
    willSendMessageQueue = dispatch_queue_create("jump.willSendMessage", DISPATCH_QUEUE_SERIAL);
    willSendPresenceQueue = dispatch_queue_create("jump.willSendPresence", DISPATCH_QUEUE_SERIAL);
    
    didReceiveIqQueue = dispatch_queue_create("jump.didReceiveIq", DISPATCH_QUEUE_SERIAL);
    
    multicastDelegate = (YMGCDMulticastDelegate <JUMPStreamDelegate> *)[[YMGCDMulticastDelegate alloc] init];
    
    [self innerSetState:STATE_JUMP_DISCONNECTED];
    
    //    flags = 0;
    isSecure = NO;
    isAuthenticated = NO;
    config = 0;
    
    numberOfBytesSent = 0;
    numberOfBytesReceived = 0;
    
    parser = [[JUMPParser alloc] initWithDelegate:self delegateQueue:jumpQueue];
    
    hostPort = 5222;
    keepAliveInterval = JUMP_DEFAULT_KEEPALIVE_INTERVAL;
    keepAliveData = [@" " dataUsingEncoding:NSUTF8StringEncoding];
    
    registeredModules = [NSMutableArray array];
    autoDelegateDict = [[NSMutableDictionary alloc] init];
    
    idTracker = [[JUMPIDTracker alloc] initWithStream:self dispatchQueue:jumpQueue];
    
    receipts = [NSMutableArray array];
}

/**
 * Standard JUMP initialization.
 * The stream is a standard client to server connection.
 **/
- (id)init {
    if ((self = [super init])) {
        // Common initialization
        [self commonInit];
        // Initialize socket
        asyncSocket = [[YMGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:jumpQueue];
        [asyncSocket setIPv4PreferredOverIPv6:NO];
    }
    return self;
}

/**
 * Standard deallocation method.
 * Every object variable declared in the header file should be released here.
 **/
- (void)dealloc {
    [asyncSocket setDelegate:nil delegateQueue:NULL];
    [asyncSocket disconnect];
    
    [parser setDelegate:nil delegateQueue:NULL];
    
    if (keepAliveTimer) {
        dispatch_source_cancel(keepAliveTimer);
    }
    
    [idTracker removeAllIDs];
    
    for (JUMPPacketReceipt *receipt in receipts) {
        [receipt signalFailure];
    }
}

#pragma mark Properties

- (JUMPStreamState)state {
    __block JUMPStreamState result = STATE_JUMP_DISCONNECTED;
    
    dispatch_block_t block = ^{
        result = state;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (NSString *)hostName {
    if (dispatch_get_specific(jumpQueueTag)) {
        return hostName;
    } else {
        __block NSString *result;
        
        dispatch_sync(jumpQueue, ^{
            result = hostName;
        });
        
        return result;
    }
}

- (void)setHostName:(NSString *)newHostName {
    if (dispatch_get_specific(jumpQueueTag)) {
        if (hostName != newHostName) {
            hostName = [newHostName copy];
        }
    } else {
        NSString *newHostNameCopy = [newHostName copy];
        
        dispatch_async(jumpQueue, ^{
            hostName = newHostNameCopy;
        });
    }
}

- (UInt16)hostPort {
    if (dispatch_get_specific(jumpQueueTag)) {
        return hostPort;
    } else {
        __block UInt16 result;
        
        dispatch_sync(jumpQueue, ^{
            result = hostPort;
        });
        
        return result;
    }
}

- (void)setHostPort:(UInt16)newHostPort {
    dispatch_block_t block = ^{
        hostPort = newHostPort;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (JUMPStreamStartTLSPolicy)startTLSPolicy {
    __block JUMPStreamStartTLSPolicy result;
    
    dispatch_block_t block = ^{
        result = startTLSPolicy;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)setStartTLSPolicy:(JUMPStreamStartTLSPolicy)flag {
    dispatch_block_t block = ^{
        startTLSPolicy = flag;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (JUMPJID *)myJID {
    __block JUMPJID *result = nil;
    
    dispatch_block_t block = ^{
        
        if (myJID_setByServer) {
            result = myJID_setByServer;
        } else {
            result = myJID_setByClient;
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)setMyJID_setByClient:(JUMPJID *)newMyJID {
    // JUMPJID is an immutable class (copy == retain)
    dispatch_block_t block = ^{
        
        if (![myJID_setByClient isEqualToJID:newMyJID]) {
            myJID_setByClient = newMyJID;
            
            if (myJID_setByServer == nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:JUMPStreamDidChangeMyJIDNotification object:self];
                [multicastDelegate jumpStreamDidChangeMyJID:self];
            }
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (void)setMyJID_setByServer:(JUMPJID *)newMyJID {
    // JUMPJID is an immutable class (copy == retain)
    
    dispatch_block_t block = ^{
        
        if (![myJID_setByServer isEqualToJID:newMyJID]) {
            JUMPJID *oldMyJID;
            if (myJID_setByServer) {
                oldMyJID = myJID_setByServer;
            } else {
                oldMyJID = myJID_setByClient;
            }
            
            myJID_setByServer = newMyJID;
            
            if (![oldMyJID isEqualToJID:newMyJID]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:JUMPStreamDidChangeMyJIDNotification object:self];
                [multicastDelegate jumpStreamDidChangeMyJID:self];
            }
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (void)setMyJID:(JUMPJID *)newMyJID {
    [self setMyJID_setByClient:newMyJID];
}

- (JUMPJID *)remoteJID {
    if (dispatch_get_specific(jumpQueueTag)) {
        return remoteJID;
    } else {
        __block JUMPJID *result;
        
        dispatch_sync(jumpQueue, ^{
            result = remoteJID;
        });
        
        return result;
    }
}

- (JUMPPresence *)myPresence {
    if (dispatch_get_specific(jumpQueueTag)) {
        return myPresence;
    } else {
        __block JUMPPresence *result;
        
        dispatch_sync(jumpQueue, ^{
            result = myPresence;
        });
        
        return result;
    }
}

- (NSTimeInterval)keepAliveInterval {
    __block NSTimeInterval result = 0.0;
    
    dispatch_block_t block = ^{
        result = keepAliveInterval;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)setKeepAliveInterval:(NSTimeInterval)interval {
    dispatch_block_t block = ^{
        
        if (keepAliveInterval != interval) {
            if (interval <= 0.0) {
                keepAliveInterval = interval;
            } else {
                keepAliveInterval = MAX(interval, JUMP_MIN_KEEPALIVE_INTERVAL);
            }
            [self setupKeepAliveTimer];
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (char)keepAliveWhitespaceCharacter {
    __block char keepAliveChar = ' ';
    
    dispatch_block_t block = ^{
        
        NSString *keepAliveString = [[NSString alloc] initWithData:keepAliveData encoding:NSUTF8StringEncoding];
        if ([keepAliveString length] > 0) {
            keepAliveChar = (char)[keepAliveString characterAtIndex:0];
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return keepAliveChar;
}

- (void)setKeepAliveWhitespaceCharacter:(char)keepAliveChar {
    dispatch_block_t block = ^{
        
        if (keepAliveChar == ' ' || keepAliveChar == '\n' || keepAliveChar == '\t') {
            keepAliveData = [[NSString stringWithFormat:@"%c", keepAliveChar] dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            JUMPLogWarn(@"Invalid whitespace character! Must be: space, newline, or tab");
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (uint64_t)numberOfBytesSent {
    __block uint64_t result = 0;
    
    dispatch_block_t block = ^{
        result = numberOfBytesSent;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (uint64_t)numberOfBytesReceived {
    __block uint64_t result = 0;
    
    dispatch_block_t block = ^{
        result = numberOfBytesReceived;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)getNumberOfBytesSent:(uint64_t *)bytesSentPtr numberOfBytesReceived:(uint64_t *)bytesReceivedPtr {
    __block uint64_t bytesSent = 0;
    __block uint64_t bytesReceived = 0;
    
    dispatch_block_t block = ^{
        bytesSent = numberOfBytesSent;
        bytesReceived = numberOfBytesReceived;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    
    if (bytesSentPtr) {
        *bytesSentPtr = bytesSent;
    }
    if (bytesReceivedPtr) {
        *bytesReceivedPtr = bytesReceived;
    }
}

- (BOOL)resetByteCountPerConnection {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (config & kResetByteCountPerConnection) ? YES : NO;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)setResetByteCountPerConnection:(BOOL)flag {
    dispatch_block_t block = ^{
        if (flag) {
            config |= kResetByteCountPerConnection;
        } else {
            config &= ~kResetByteCountPerConnection;
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (BOOL)enableBackgroundingOnSocket {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (config & kEnableBackgroundingOnSocket) ? YES : NO;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)setEnableBackgroundingOnSocket:(BOOL)flag {
    dispatch_block_t block = ^{
        if (flag)
            config |= kEnableBackgroundingOnSocket;
        else
            config &= ~kEnableBackgroundingOnSocket;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

#pragma mark Configuration

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Asynchronous operation (if outside jumpQueue)
    
    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Synchronous operation
    
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
}

- (void)removeDelegate:(id)delegate {
    // Synchronous operation
    
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate];
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
}

#pragma mark Connection State

/**
 * Returns YES if the connection is closed, and thus no stream is open.
 * If the stream is neither disconnected, nor connected, then a connection is currently being established.
 **/
- (BOOL)isDisconnected {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (state == STATE_JUMP_DISCONNECTED);
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

/**
 * Returns YES is the connection is currently connecting
 **/
- (BOOL)isConnecting {
    JUMPLogTrace();
    
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        result = (state == STATE_JUMP_CONNECTING);
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

/**
 * Returns YES if the connection is open, and the stream has been properly established.
 * If the stream is neither disconnected, nor connected, then a connection is currently being established.
 **/
- (BOOL)isConnected {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (state == STATE_JUMP_CONNECTED);
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (BOOL)isConnectedNoAuth {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (state == STATE_JUMP_CONNECTED_NOAUTH);
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)innerSetState:(JUMPStreamState)newState {
    state = newState;
}

#pragma mark Connect Timeout

/**
 * Start Connect Timeout
 **/
- (void)startConnectTimeout:(NSTimeInterval)timeout {
    JUMPLogTrace();
    
    if (timeout >= 0.0 && !connectTimer) {
        connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, jumpQueue);
        
        dispatch_source_set_event_handler(connectTimer, ^{ @autoreleasepool {
            [self doConnectTimeout];
        }});
        
        dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, (timeout * NSEC_PER_SEC));
        dispatch_source_set_timer(connectTimer, tt, DISPATCH_TIME_FOREVER, 0);
        
        dispatch_resume(connectTimer);
    }
}

/**
 * End Connect Timeout
 **/
- (void)endConnectTimeout {
    [self endConnectTimeoutWithError:nil];
}

- (void)endConnectTimeoutWithError:(NSError *)error {
    JUMPLogTrace();
    
    if (connectTimer) {
        if (error) {
            [multicastDelegate jumpStreamDidNotConnect:self error:error];
        }
        dispatch_source_cancel(connectTimer);
        connectTimer = NULL;
    }
}

/**
 * Connect has timed out, so inform the delegates and close the connection
 **/
- (void)doConnectTimeout {
    JUMPLogTrace();
    
    [self endConnectTimeout];
    
    if (state != STATE_JUMP_DISCONNECTED) {
        [multicastDelegate jumpStreamConnectDidTimeout:self];
        
        if (state == STATE_JUMP_RESOLVING_SRV) {
            [srvResolver stop];
            srvResolver = nil;
            
            [self innerSetState:STATE_JUMP_DISCONNECTED];
        } else {
            [asyncSocket disconnect];
            
            // Everthing will be handled in socketDidDisconnect:withError:
        }
    }
}

#pragma mark C2S Connection

- (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    JUMPLogTrace();
    
    BOOL result = [asyncSocket connectToHost:host onPort:port error:errPtr];
    
    if (result && [self resetByteCountPerConnection]) {
        numberOfBytesSent = 0;
        numberOfBytesReceived = 0;
    }
    
    if (result) {
        [self startConnectTimeout:timeout];
    }
    return result;
}

- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr {
    JUMPLogTrace();
    
    __block BOOL result = NO;
    __block NSError *err = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state != STATE_JUMP_DISCONNECTED) {
            NSString *errMsg = @"Attempting to connect while already connected or connecting.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:info];
            
            result = NO;
            return_from_block;
        }
        
        if (myJID_setByClient == nil) {
            // Note: If you wish to use anonymous authentication, you should still set myJID prior to calling connect.
            // You can simply set it to something like "anonymous@<domain>", where "<domain>" is the proper domain.
            // After the authentication process, you can query the myJID property to see what your assigned JID is.
            //
            // Setting myJID allows the framework to follow the jump protocol properly,
            // and it allows the framework to connect to servers without a DNS entry.
            //
            // For example, one may setup a private jump server for internal testing on their local network.
            // The jump domain of the server may be something like "testing.mycompany.com",
            // but since the server is internal, an IP (192.168.1.22) is used as the hostname to connect.
            //
            // Proper connection requires a TCP connection to the IP (192.168.1.22),
            // but the jump handshake requires the jump domain (testing.mycompany.com).
            
            NSString *errMsg = @"You must set myJID before calling connect.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidProperty userInfo:info];
            
            result = NO;
            return_from_block;
        }
        
        // Notify delegates
        [multicastDelegate jumpStreamWillConnect:self];
        
        if ([hostName length] == 0) {
            // Resolve the hostName via myJID SRV resolution
            
            [self innerSetState:STATE_JUMP_RESOLVING_SRV];
            
            srvResolver = [[JUMPSRVResolver alloc] initWithdDelegate:self delegateQueue:jumpQueue resolverQueue:NULL];
            
            srvResults = nil;
            srvResultsIndex = 0;
            
            NSString *srvName = [JUMPSRVResolver srvNameFromJUMPDomain:[myJID_setByClient domain]];
            
            [srvResolver startWithSRVName:srvName timeout:TIMEOUT_SRV_RESOLUTION];
            
            result = YES;
        } else {
            // Open TCP connection to the configured hostName.
            
            [self innerSetState:STATE_JUMP_CONNECTING];
            
            NSError *connectErr = nil;
            result = [self connectToHost:hostName onPort:hostPort withTimeout:JUMPStreamTimeoutNone error:&connectErr];
            
            if (!result) {
                err = connectErr;
                [self innerSetState:STATE_JUMP_DISCONNECTED];
            }
        }
        
        if(result) {
            [self startConnectTimeout:timeout];
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    
    if (errPtr) {
        *errPtr = err;
    }
    return result;
}

//- (BOOL)oldSchoolSecureConnectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr
//{
//	JUMPLogTrace();
//
//	__block BOOL result = NO;
//	__block NSError *err = nil;
//
//	dispatch_block_t block = ^{ @autoreleasepool {
//
//		// Go through the regular connect routine
//		NSError *connectErr = nil;
//		result = [self connectWithTimeout:timeout error:&connectErr];
//
//		if (result)
//		{
//			// Mark the secure flag.
//			// We will check the flag in socket:didConnectToHost:port:
//
//			[self setIsSecure:YES];
//		}
//		else
//		{
//			err = connectErr;
//		}
//	}};
//
//	if (dispatch_get_specific(jumpQueueTag))
//		block();
//	else
//		dispatch_sync(jumpQueue, block);
//
//	if (errPtr)
//		*errPtr = err;
//
//	return result;
//}

#pragma mark Disconnect

/**
 * Closes the connection to the remote host.
 **/
- (void)disconnect {
    JUMPLogTrace();
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state != STATE_JUMP_DISCONNECTED) {
            [multicastDelegate jumpStreamWasToldToDisconnect:self];
            
            if (state == STATE_JUMP_RESOLVING_SRV) {
                [srvResolver stop];
                srvResolver = nil;
                
                [self innerSetState:STATE_JUMP_DISCONNECTED];
                
                [multicastDelegate jumpStreamDidDisconnect:self withError:nil];
            } else {
                [asyncSocket disconnect];
                
                // Everthing will be handled in socketDidDisconnect:withError:
            }
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
}

- (void)disconnectAfterSending {
    JUMPLogTrace();
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state != STATE_JUMP_DISCONNECTED) {
            [multicastDelegate jumpStreamWasToldToDisconnect:self];
            
            if (state == STATE_JUMP_RESOLVING_SRV) {
                [srvResolver stop];
                srvResolver = nil;
                
                [self innerSetState:STATE_JUMP_DISCONNECTED];
                
                [multicastDelegate jumpStreamDidDisconnect:self withError:nil];
            } else {
                JUMPPacket *packet = [[JUMPPacket alloc] initWithOpData:JUMP_OPDATA(JUMPStreamEndPacketOpCode)];
                
                NSData *outgoingData = [packet packetData];
                JUMPLogSend(@"SEND: %@", outgoingData);
                numberOfBytesSent += [outgoingData length];
                
                [asyncSocket writeData:outgoingData withTimeout:TIMEOUT_JUMP_WRITE tag:TAG_JUMP_WRITE_STOP];
                [asyncSocket disconnectAfterWriting];
                
                // Everthing will be handled in socketDidDisconnect:withError:
            }
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

#pragma mark Security

/**
 * Returns YES if SSL/TLS has been used to secure the connection.
 **/
- (BOOL)isSecure {
    if (dispatch_get_specific(jumpQueueTag)) {
        return isSecure;
    } else {
        __block BOOL result;
        
        dispatch_sync(jumpQueue, ^{
            result = isSecure;
        });
        
        return result;
    }
}

- (void)setIsSecure:(BOOL)flag {
    dispatch_block_t block = ^{
        isSecure = flag;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

//- (BOOL)supportsStartTLS {
//	__block BOOL result = NO;
//
//	dispatch_block_t block = ^{ @autoreleasepool {
//
//		// The root element can be properly queried for authentication mechanisms anytime after the
//		// stream:features are received, and TLS has been setup (if required)
//		if (state >= STATE_JUMP_POST_NEGOTIATION)
//		{
//			NSXMLElement *features = [rootElement elementForName:@"stream:features"];
//			NSXMLElement *starttls = [features elementForName:@"starttls" xmlns:@"urn:ietf:params:xml:ns:jump-tls"];
//
//			result = (starttls != nil);
//		}
//	}};
//
//	if (dispatch_get_specific(jumpQueueTag))
//		block();
//	else
//		dispatch_sync(jumpQueue, block);
//
//	return result;
//}
//
//- (void)sendStartTLSRequest
//{
//	NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
//
//	JUMPLogTrace();
//
//	NSString *starttls = @"<starttls xmlns='urn:ietf:params:xml:ns:jump-tls'/>";
//
//	NSData *outgoingData = [starttls dataUsingEncoding:NSUTF8StringEncoding];
//
//	JUMPLogSend(@"SEND: %@", starttls);
//	numberOfBytesSent += [outgoingData length];
//
//	[asyncSocket writeData:outgoingData
//			   withTimeout:TIMEOUT_JUMP_WRITE
//					   tag:TAG_JUMP_WRITE_STREAM];
//}
//
//- (BOOL)secureConnection:(NSError **)errPtr {
//	JUMPLogTrace();
//
//	__block BOOL result = YES;
//	__block NSError *err = nil;
//
//	dispatch_block_t block = ^{ @autoreleasepool {
//
//		if (state != STATE_JUMP_CONNECTED) {
//			NSString *errMsg = @"Please wait until the stream is connected.";
//			NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//
//			err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:info];
//
//			result = NO;
//			return_from_block;
//		}
//
//		if ([self isSecure]) {
//			NSString *errMsg = @"The connection is already secure.";
//			NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//
//			err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:info];
//
//			result = NO;
//			return_from_block;
//		}
//
////		if (![self supportsStartTLS])
////		{
////			NSString *errMsg = @"The server does not support startTLS.";
////			NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
////
////			err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamUnsupportedAction userInfo:info];
////
////			result = NO;
////			return_from_block;
////		}
//
//		// Update state
//		state = STATE_JUMP_STARTTLS_1;
//
//		// Send the startTLS XML request
//		[self sendStartTLSRequest];
//
//		// We do not mark the stream as secure yet.
//		// We're waiting to receive the <proceed/> response from the
//		// server before we actually start the TLS handshake.
//
//	}};
//
//	if (dispatch_get_specific(jumpQueueTag))
//		block();
//	else
//		dispatch_sync(jumpQueue, block);
//
//	if (errPtr)
//		*errPtr = err;
//
//	return result;
//}

#pragma mark Authentication

- (NSArray *)supportedAuthenticationMechanisms {
    __block NSMutableArray *result = [NSMutableArray array];
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        [result addObject:@"plain"];
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

/**
 * This method checks the stream features of the connected server to determine
 * if the given authentication mechanism is supported.
 *
 * If we are not connected to a server, this method simply returns NO.
 **/
- (BOOL)supportsAuthenticationMechanism:(NSString *)mechanismType {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if ([@"PLAIN" isEqualToString:mechanismType]) {
            result = YES;
        }
        
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (BOOL)authenticate:(id <JUMPSASLAuthentication>)inAuth error:(NSError **)errPtr {
    JUMPLogTrace();
    
    __block BOOL result = NO;
    __block NSError *err = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state != STATE_JUMP_CONNECTED_NOAUTH && state != STATE_JUMP_CONNECTED) {
            NSString *errMsg = @"Please wait until the stream is connected.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:info];
            
            result = NO;
            return_from_block;
        }
        
        if (myJID_setByClient == nil) {
            NSString *errMsg = @"You must set myJID before calling authenticate:error:.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidProperty userInfo:info];
            
            result = NO;
            return_from_block;
        }
        
        // Change state.
        // We do this now because when we invoke the start method below,
        // it may in turn invoke our sendAuthPacket method, which expects us to be in STATE_JUMP_AUTH.
        [self innerSetState:STATE_JUMP_AUTH];
        
        if ([inAuth start:&err]) {
            auth = inAuth;
            result = YES;
        } else {
            // Unable to start authentication for some reason.
            // Revert back to connected state.
            [self innerSetState:STATE_JUMP_CONNECTED_NOAUTH];
            
            // Notify delegate
            [multicastDelegate jumpStream:self didNotAuthenticate:nil error:err];
            
            auth = nil;
            
            [self disconnect];
            
            result = NO;
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    
    if (errPtr) {
        *errPtr = err;
    }
    return result;
}

/**
 * This method applies to standard password authentication schemes only.
 * This is NOT the primary authentication method.
 *
 * @see authenticate:error:
 *
 * This method exists for backwards compatibility, and may disappear in future versions.
 **/
- (BOOL)authenticateWithPassword:(NSString *)inPassword error:(NSError **)errPtr {
    JUMPLogTrace();
    
    // The given password parameter could be mutable
    NSString *password = [inPassword copy];
    
    
    __block BOOL result = YES;
    __block NSError *err = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state != STATE_JUMP_CONNECTED_NOAUTH && state != STATE_JUMP_CONNECTED) {
            NSString *errMsg = @"Please wait until the stream is connected.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:info];
            
            result = NO;
            return_from_block;
        }
        
        if (myJID_setByClient == nil) {
            NSString *errMsg = @"You must set myJID before calling authenticate:error:.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidProperty userInfo:info];
            
            result = NO;
            return_from_block;
        }
        
        if (parser == nil) {
            JUMPLogVerbose(@"%@: Initializing parser...", THIS_FILE);
            
            // Need to create the parser.
            parser = [[JUMPParser alloc] initWithDelegate:self delegateQueue:jumpQueue];
        }
        
        // Choose the best authentication method.
        //
        // P.S. - This method is deprecated.
        
        id <JUMPSASLAuthentication> someAuth = nil;
        
        if ([self supportsPlainAuthentication]) {
            someAuth = [[JUMPPlainAuthentication alloc] initWithStream:self password:password];
            result = [self authenticate:someAuth error:&err];
        } else if ([self supportsAnonymousAuthentication]) {
            someAuth = [[JUMPAnonymousAuthentication alloc] initWithStream:self];
            result = [self authenticate:someAuth error:&err];
        } else {
            NSString *errMsg = @"No suitable authentication method found";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamUnsupportedAction userInfo:info];
            result = NO;
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    
    if (errPtr) {
        *errPtr = err;
    }
    return result;
}

- (BOOL)isAuthenticating {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        result = (state == STATE_JUMP_AUTH);
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (BOOL)isAuthenticated {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = isAuthenticated;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

- (void)setIsAuthenticated:(BOOL)flag {
    dispatch_block_t block = ^{
        isAuthenticated = flag;
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (NSDate *)authenticationDate {
    __block NSDate *result = nil;
    
    dispatch_block_t block = ^{
        if(isAuthenticated) {
            result =  authenticationDate;
        }
    };
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
    return result;
}

//#pragma mark Compression
//
//- (NSArray *)supportedCompressionMethods {
//	__block NSMutableArray *result = [[NSMutableArray alloc] init];
//
//	dispatch_block_t block = ^{ @autoreleasepool {
//
//		// The root element can be properly queried for compression methods anytime after the
//		// stream:features are received, and TLS has been setup (if required).
//
//		if (state >= STATE_JUMP_POST_NEGOTIATION)
//		{
//			NSXMLElement *features = [rootElement elementForName:@"stream:features"];
//			NSXMLElement *compression = [features elementForName:@"compression" xmlns:@"http://jabber.org/features/compress"];
//
//			NSArray *methods = [compression elementsForName:@"method"];
//
//			for (NSXMLElement *method in methods)
//			{
//				[result addObject:[method stringValue]];
//			}
//		}
//	}};
//
//	if (dispatch_get_specific(jumpQueueTag))
//		block();
//	else
//		dispatch_sync(jumpQueue, block);
//
//	return result;
//}
//
///**
// * This method checks the stream features of the connected server to determine
// * if the given compression method is supported.
// *
// * If we are not connected to a server, this method simply returns NO.
//**/
//- (BOOL)supportsCompressionMethod:(NSString *)compressionMethod {
//	__block BOOL result = NO;
//
//	dispatch_block_t block = ^{ @autoreleasepool {
//
//		// The root element can be properly queried for compression methods anytime after the
//		// stream:features are received, and TLS has been setup (if required).
//
//		if (state >= STATE_JUMP_POST_NEGOTIATION)
//		{
//			NSXMLElement *features = [rootElement elementForName:@"stream:features"];
//			NSXMLElement *compression = [features elementForName:@"compression" xmlns:@"http://jabber.org/features/compress"];
//
//			NSArray *methods = [compression elementsForName:@"method"];
//
//			for (NSXMLElement *method in methods)
//			{
//				if ([[method stringValue] isEqualToString:compressionMethod])
//				{
//					result = YES;
//					break;
//				}
//			}
//		}
//	}};
//
//	if (dispatch_get_specific(jumpQueueTag))
//		block();
//	else
//		dispatch_sync(jumpQueue, block);
//
//	return result;
//}

#pragma mark Sending

- (void)sendIQ:(JUMPIQ *)iq withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    // We're getting ready to send an IQ.
    // Notify delegates to allow them to optionally alter/filter the outgoing IQ.
    
    SEL selector = @selector(jumpStream:willSendIQ:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        [self continueSendIQ:iq withTag:tag];
    } else {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the packet in a thread-safe manner.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        dispatch_async(willSendIqQueue, ^{ @autoreleasepool {
            
            // Allow delegates to modify and/or filter outgoing packet
            
            __block JUMPIQ *modifiedIQ = iq;
            
            id del;
            dispatch_queue_t dq;
            
            while (modifiedIQ && [delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
#if DEBUG
                {
                    char methodReturnType[32];
                    
                    Method method = class_getInstanceMethod([del class], selector);
                    method_getReturnType(method, methodReturnType, sizeof(methodReturnType));
                    
                    if (strcmp(methodReturnType, @encode(JUMPIQ*)) != 0)
                    {
                        NSAssert(NO, @"Method jumpStream:willSendIQ: is no longer void (see JUMPStream.h). "
                                 @"Culprit = %@", NSStringFromClass([del class]));
                    }
                }
#endif
                
                dispatch_sync(dq, ^{ @autoreleasepool {
                    
                    modifiedIQ = [del jumpStream:self willSendIQ:modifiedIQ];
                    
                }});
            }
            
            if (modifiedIQ) {
                dispatch_async(jumpQueue, ^{ @autoreleasepool {
                    
                    if (state == STATE_JUMP_CONNECTED) {
                        [self continueSendIQ:modifiedIQ withTag:tag];
                    } else {
                        [self failToSendIQ:modifiedIQ];
                    }
                }});
            }
        }});
    }
}

- (void)sendMessage:(JUMPMessage *)message withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    // We're getting ready to send a message.
    // Notify delegates to allow them to optionally alter/filter the outgoing message.
    
    SEL selector = @selector(jumpStream:willSendMessage:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        [self continueSendMessage:message withTag:tag];
    } else {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the packet in a thread-safe manner.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        dispatch_async(willSendMessageQueue, ^{ @autoreleasepool {
            
            // Allow delegates to modify outgoing packet
            
            __block JUMPMessage *modifiedMessage = message;
            
            id del;
            dispatch_queue_t dq;
            
            while (modifiedMessage && [delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
#if DEBUG
                {
                    char methodReturnType[32];
                    
                    Method method = class_getInstanceMethod([del class], selector);
                    method_getReturnType(method, methodReturnType, sizeof(methodReturnType));
                    
                    if (strcmp(methodReturnType, @encode(JUMPMessage*)) != 0)
                    {
                        NSAssert(NO, @"Method jumpStream:willSendMessage: is no longer void (see JUMPStream.h). "
                                 @"Culprit = %@", NSStringFromClass([del class]));
                    }
                }
#endif
                
                dispatch_sync(dq, ^{ @autoreleasepool {
                    
                    modifiedMessage = [del jumpStream:self willSendMessage:modifiedMessage];
                    
                }});
            }
            
            if (modifiedMessage) {
                dispatch_async(jumpQueue, ^{ @autoreleasepool {
                    
                    if (state == STATE_JUMP_CONNECTED) {
                        [self continueSendMessage:modifiedMessage withTag:tag];
                    } else {
                        [self failToSendMessage:modifiedMessage];
                    }
                }});
            }
        }});
    }
}

- (void)sendPresence:(JUMPPresence *)presence withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    // We're getting ready to send a presence packet.
    // Notify delegates to allow them to optionally alter/filter the outgoing presence.
    
    SEL selector = @selector(jumpStream:willSendPresence:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        [self continueSendPresence:presence withTag:tag];
    } else {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the packet in a thread-safe manner.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        dispatch_async(willSendPresenceQueue, ^{ @autoreleasepool {
            
            // Allow delegates to modify outgoing packet
            
            __block JUMPPresence *modifiedPresence = presence;
            
            id del;
            dispatch_queue_t dq;
            
            while (modifiedPresence && [delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
#if DEBUG
                {
                    char methodReturnType[32];
                    
                    Method method = class_getInstanceMethod([del class], selector);
                    method_getReturnType(method, methodReturnType, sizeof(methodReturnType));
                    
                    if (strcmp(methodReturnType, @encode(JUMPPresence*)) != 0)
                    {
                        NSAssert(NO, @"Method jumpStream:willSendPresence: is no longer void (see JUMPStream.h). "
                                 @"Culprit = %@", NSStringFromClass([del class]));
                    }
                }
#endif
                
                dispatch_sync(dq, ^{ @autoreleasepool {
                    
                    modifiedPresence = [del jumpStream:self willSendPresence:modifiedPresence];
                    
                }});
            }
            
            if (modifiedPresence) {
                dispatch_async(jumpQueue, ^{ @autoreleasepool {
                    
                    if (state == STATE_JUMP_CONNECTED) {
                        [self continueSendPresence:modifiedPresence withTag:tag];
                    } else {
                        [self failToSendPresence:modifiedPresence];
                    }
                }});
            }
        }});
    }
}

- (void)continueSendIQ:(JUMPIQ *)iq withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    NSData *outgoingData = [iq gzipPacketData];
    
    JUMPLogSend(@"SEND:%@", [iq jsonString]);
    YYIMLogDebug(@"IQ SEND:%@-%@", [iq headerData], [iq jsonString]);
    YYIMLogDebug(@"SEND PACKET GZIP DATA:%@|%ld", outgoingData, (unsigned long)[outgoingData length]);
    //    YYIMLogDebug(@"SEND PACKET DATA:%@|%ld", [iq packetData], [[iq packetData] length]);
    numberOfBytesSent += [outgoingData length];
    
    [asyncSocket writeData:outgoingData withTimeout:TIMEOUT_JUMP_WRITE tag:tag];
    
    [multicastDelegate jumpStream:self didSendIQ:iq];
}

- (void)continueSendMessage:(JUMPMessage *)message withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    NSData *outgoingData = [message gzipPacketData];
    
    JUMPLogSend(@"SEND:%@", [message jsonString]);
    YYIMLogDebug(@"MESSAGE SEND:%@-%@", [message headerData], [message jsonString]);
    YYIMLogDebug(@"SEND PACKET GZIP DATA:%@|%ld", outgoingData, (unsigned long)[outgoingData length]);
    //    YYIMLogDebug(@"SEND PACKET DATA:%@|%ld", [message packetData], [[message packetData] length]);
    
    numberOfBytesSent += [outgoingData length];
    
    [asyncSocket writeData:outgoingData withTimeout:TIMEOUT_JUMP_WRITE tag:tag];
    
    [multicastDelegate jumpStream:self didSendMessage:message];
}

- (void)continueSendPresence:(JUMPPresence *)presence withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    NSData *outgoingData = [presence gzipPacketData];
    
    JUMPLogSend(@"SEND:%@", [presence jsonString]);
    YYIMLogDebug(@"PRESENCE SEND:%@-%@", [presence headerData], [presence jsonString]);
    YYIMLogDebug(@"SEND PACKET GZIP DATA:%@|%ld", outgoingData, (unsigned long)[outgoingData length]);
    //    YYIMLogDebug(@"SEND PACKET DATA:%@|%ld", [presence packetData], [[presence packetData] length]);
    numberOfBytesSent += [outgoingData length];
    
    [asyncSocket writeData:outgoingData withTimeout:TIMEOUT_JUMP_WRITE tag:tag];
    
    // Update myPresence if this is a normal presence packet.
    // In other words, ignore presence subscription stuff, MUC room stuff, etc.
    //
    // We use the built-in [presence type] which guarantees lowercase strings,
    // and will return @"available" if there was no set type (as available is implicit).
    
    NSString *type = [presence type];
    if ([type isEqualToString:@"available"] || [type isEqualToString:@"unavailable"]) {
        if ([presence toStr] == nil && myPresence != presence) {
            myPresence = presence;
        }
    }
    
    [multicastDelegate jumpStream:self didSendPresence:presence];
}

- (void)continueSendPacket:(JUMPPacket *)packet withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    NSData *outgoingData = [packet gzipPacketData];
    
    JUMPLogSend(@"SEND:%@", [packet jsonString]);
    YYIMLogDebug(@"PACKET SEND:%@-%@", [packet headerData], [packet jsonString]);
    YYIMLogDebug(@"SEND PACKET GZIP DATA:%@|%ld", outgoingData, (unsigned long)[outgoingData length]);
    //    YYIMLogDebug(@"SEND PACKET DATA:%@|%ld", [packet packetData], [[packet packetData] length]);
    numberOfBytesSent += [outgoingData length];
    
    [asyncSocket writeData:outgoingData withTimeout:TIMEOUT_JUMP_WRITE tag:tag];
}

/**
 * Private method.
 * Presencts a common method for the various public sendPacket methods.
 **/
- (void)sendPacket:(JUMPPacket *)packet withTag:(long)tag {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    if ([packet isKindOfClass:[JUMPIQ class]]) {
        [self sendIQ:(JUMPIQ *)packet withTag:tag];
    } else if ([packet isKindOfClass:[JUMPMessage class]]) {
        [self sendMessage:(JUMPMessage *)packet withTag:tag];
    } else if ([packet isKindOfClass:[JUMPPresence class]]) {
        [self sendPresence:(JUMPPresence *)packet withTag:tag];
    } else if ([packet isPingPacket]) {
        [self continueSendPacket:packet withTag:tag];
    }
}

/**
 * This methods handles sending an XML stanza.
 * If the JUMPStream is not connected, this method does nothing.
 **/
- (void)sendPacket:(JUMPPacket *)packet {
    if (packet == nil) return;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state == STATE_JUMP_CONNECTED) {
            [self sendPacket:packet withTag:TAG_JUMP_WRITE_STREAM];
        } else {
            [self failToSendPacket:packet];
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

/**
 * This method handles sending an XML stanza.
 * If the JUMPStream is not connected, this method does nothing.
 *
 * After the packet has been successfully sent,
 * the jumpStream:didSendPacketWithTag: delegate method is called.
 **/
- (void)sendPacket:(JUMPPacket *)packet andGetReceipt:(JUMPPacketReceipt **)receiptPtr {
    if (packet == nil) return;
    
    if (receiptPtr == nil) {
        [self sendPacket:packet];
    } else {
        __block JUMPPacketReceipt *receipt = nil;
        
        dispatch_block_t block = ^{ @autoreleasepool {
            
            if (state == STATE_JUMP_CONNECTED) {
                receipt = [[JUMPPacketReceipt alloc] init];
                [receipts addObject:receipt];
                
                [self sendPacket:packet withTag:TAG_JUMP_WRITE_RECEIPT];
            } else {
                [self failToSendPacket:packet];
            }
        }};
        
        if (dispatch_get_specific(jumpQueueTag)) {
            block();
        } else {
            dispatch_sync(jumpQueue, block);
        }
        
        *receiptPtr = receipt;
    }
}

- (void)failToSendPacket:(JUMPPacket *)packet {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    if ([packet isKindOfClass:[JUMPIQ class]]) {
        [self failToSendIQ:(JUMPIQ *)packet];
    } else if ([packet isKindOfClass:[JUMPMessage class]]) {
        [self failToSendMessage:(JUMPMessage *)packet];
    } else if ([packet isKindOfClass:[JUMPPresence class]]) {
        [self failToSendPresence:(JUMPPresence *)packet];
    } else {
        
    }
}

- (void)failToSendIQ:(JUMPIQ *)iq {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    NSError *error = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:nil];
    
    [multicastDelegate jumpStream:self didFailToSendIQ:iq error:error];
}

- (void)failToSendMessage:(JUMPMessage *)message {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    NSError *error = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:nil];
    
    [multicastDelegate jumpStream:self didFailToSendMessage:message error:error];
}

- (void)failToSendPresence:(JUMPPresence *)presence {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    NSError *error = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamInvalidState userInfo:nil];
    
    [multicastDelegate jumpStream:self didFailToSendPresence:presence error:error];
}

/**
 * Retrieves the current presence and resends it in once atomic operation.
 * Useful for various components that need to update injected information in the presence stanza.
 **/
- (void)resendMyPresence {
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (myPresence && [[myPresence type] isEqualToString:@"available"]) {
            [self sendPacket:myPresence];
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

/**
 * This method is for use by jump authentication mechanism classes.
 * They should send packets using this method instead of the public sendPacket methods,
 * as those methods don't send the packets while authentication is in progress.
 *
 * @see JUMPSASLAuthentication
 **/
- (void)sendAuthPacket:(JUMPPacket *)packet {
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state == STATE_JUMP_AUTH) {
            NSData *outgoingData = [packet packetData];
            
            YYIMLogInfo(@"AUTH SEND: %@", [packet jsonString]);
            numberOfBytesSent += [outgoingData length];
            
            [asyncSocket writeData:outgoingData withTimeout:TIMEOUT_JUMP_WRITE tag:TAG_JUMP_WRITE_STREAM];
        } else {
            JUMPLogWarn(@"Unable to send packet while not in STATE_JUMP_AUTH: %@", [packet jsonString]);
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (void)receiveIQ:(JUMPIQ *)iq {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    // We're getting ready to receive an IQ.
    // Notify delegates to allow them to optionally alter/filter the incoming IQ packet.
    
    SEL selector = @selector(jumpStream:willReceiveIQ:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        if (willReceiveStanzaQueue) {
            // But still go through the stanzaQueue in order to guarantee in-order-delivery of all received stanzas.
            
            dispatch_async(willReceiveStanzaQueue, ^{
                dispatch_async(jumpQueue, ^{ @autoreleasepool {
                    if (state == STATE_JUMP_CONNECTED) {
                        [self continueReceiveIQ:iq];
                    }
                }});
            });
        } else {
            [self continueReceiveIQ:iq];
        }
    } else {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the packet in a thread-safe manner.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        if (willReceiveStanzaQueue == NULL) {
            willReceiveStanzaQueue = dispatch_queue_create("jump.willReceiveStanza", DISPATCH_QUEUE_SERIAL);
        }
        
        dispatch_async(willReceiveStanzaQueue, ^{ @autoreleasepool {
            
            // Allow delegates to modify and/or filter incoming packet
            
            __block JUMPIQ *modifiedIQ = iq;
            
            id del;
            dispatch_queue_t dq;
            
            while (modifiedIQ && [delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
                dispatch_sync(dq, ^{ @autoreleasepool {
                    
                    modifiedIQ = [del jumpStream:self willReceiveIQ:modifiedIQ];
                    
                }});
            }
            
            dispatch_async(jumpQueue, ^{ @autoreleasepool {
                
                if (state == STATE_JUMP_CONNECTED) {
                    if (modifiedIQ) {
                        [self continueReceiveIQ:modifiedIQ];
                    } else {
                        [multicastDelegate jumpStreamDidFilterStanza:self];
                    }
                }
            }});
        }});
    }
}

- (void)receiveMessage:(JUMPMessage *)message {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    // We're getting ready to receive a message.
    // Notify delegates to allow them to optionally alter/filter the incoming message.
    
    SEL selector = @selector(jumpStream:willReceiveMessage:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        if (willReceiveStanzaQueue) {
            // But still go through the stanzaQueue in order to guarantee in-order-delivery of all received stanzas.
            
            dispatch_async(willReceiveStanzaQueue, ^{
                dispatch_async(jumpQueue, ^{ @autoreleasepool {
                    
                    if (state == STATE_JUMP_CONNECTED) {
                        [self continueReceiveMessage:message];
                    }
                }});
            });
        } else {
            [self continueReceiveMessage:message];
        }
    } else {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the packet in a thread-safe manner.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        if (willReceiveStanzaQueue == NULL) {
            willReceiveStanzaQueue = dispatch_queue_create("jump.willReceiveStanza", DISPATCH_QUEUE_SERIAL);
        }
        
        dispatch_async(willReceiveStanzaQueue, ^{ @autoreleasepool {
            
            // Allow delegates to modify incoming packet
            
            __block JUMPMessage *modifiedMessage = message;
            
            id del;
            dispatch_queue_t dq;
            
            while (modifiedMessage && [delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
                dispatch_sync(dq, ^{ @autoreleasepool {
                    
                    modifiedMessage = [del jumpStream:self willReceiveMessage:modifiedMessage];
                    
                }});
            }
            
            dispatch_async(jumpQueue, ^{ @autoreleasepool {
                
                if (state == STATE_JUMP_CONNECTED) {
                    if (modifiedMessage) {
                        [self continueReceiveMessage:modifiedMessage];
                    } else {
                        [multicastDelegate jumpStreamDidFilterStanza:self];
                    }
                }
            }});
        }});
    }
}

- (void)receivePresence:(JUMPPresence *)presence {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    NSAssert(state == STATE_JUMP_CONNECTED, @"Invoked with incorrect state");
    
    // We're getting ready to receive a presence packet.
    // Notify delegates to allow them to optionally alter/filter the incoming presence.
    
    SEL selector = @selector(jumpStream:willReceivePresence:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        if (willReceiveStanzaQueue) {
            // But still go through the stanzaQueue in order to guarantee in-order-delivery of all received stanzas.
            
            dispatch_async(willReceiveStanzaQueue, ^{
                dispatch_async(jumpQueue, ^{ @autoreleasepool {
                    
                    if (state == STATE_JUMP_CONNECTED) {
                        [self continueReceivePresence:presence];
                    }
                }});
            });
        } else {
            [self continueReceivePresence:presence];
        }
    } else {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the packet in a thread-safe manner.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        if (willReceiveStanzaQueue == NULL) {
            willReceiveStanzaQueue = dispatch_queue_create("jump.willReceiveStanza", DISPATCH_QUEUE_SERIAL);
        }
        
        dispatch_async(willReceiveStanzaQueue, ^{ @autoreleasepool {
            
            // Allow delegates to modify outgoing packet
            
            __block JUMPPresence *modifiedPresence = presence;
            
            id del;
            dispatch_queue_t dq;
            
            while (modifiedPresence && [delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
                dispatch_sync(dq, ^{ @autoreleasepool {
                    
                    modifiedPresence = [del jumpStream:self willReceivePresence:modifiedPresence];
                    
                }});
            }
            
            dispatch_async(jumpQueue, ^{ @autoreleasepool {
                
                if (state == STATE_JUMP_CONNECTED) {
                    if (modifiedPresence) {
                        [self continueReceivePresence:presence];
                    } else {
                        [multicastDelegate jumpStreamDidFilterStanza:self];
                    }
                }
            }});
        }});
    }
}

- (void)continueReceiveIQ:(JUMPIQ *)iq {
    if ([iq requiresResponse]) {
        // As per the JUMP specificiation, if the IQ requires a response,
        // and we don't have any delegates or modules that can properly respond to the IQ,
        // we MUST send back and error IQ.
        //
        // So we notifiy all interested delegates and modules about the received IQ,
        // keeping track of whether or not any of them have handled it.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        id del;
        dispatch_queue_t dq;
        
        SEL selector = @selector(jumpStream:didReceiveIQ:);
        
        dispatch_semaphore_t delSemaphore = dispatch_semaphore_create(0);
        dispatch_group_t delGroup = dispatch_group_create();
        
        while ([delegateEnumerator getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
            dispatch_group_async(delGroup, dq, ^{ @autoreleasepool {
                
                if ([del jumpStream:self didReceiveIQ:iq]) {
                    dispatch_semaphore_signal(delSemaphore);
                }
                
            }});
        }
        
        dispatch_async(didReceiveIqQueue, ^{ @autoreleasepool {
            
            dispatch_group_wait(delGroup, DISPATCH_TIME_FOREVER);
            
            // Did any of the delegates handle the IQ? (handle == will response)
            
            BOOL handled = (dispatch_semaphore_wait(delSemaphore, DISPATCH_TIME_NOW) == 0);
            
            // An entity that receives an IQ request of type "get" or "set" MUST reply
            // with an IQ response of type "result" or "error".
            //
            // The response MUST preserve the 'id' attribute of the request.
            
            if (!handled) {
                // Return error message:
                //
                // <iq to="jid" type="error" id="id">
                //   <query xmlns="ns"/>
                //   <error type="cancel" code="501">
                //     <feature-not-implemented xmlns="urn:ietf:params:xml:ns:jump-stanzas"/>
                //   </error>
                // </iq>
                
                //                NSXMLPacket *reason = [NSXMLPacket packetWithName:@"feature-not-implemented"
                //                                                               xmlns:@"urn:ietf:params:xml:ns:jump-stanzas"];
                //
                //                NSXMLPacket *error = [NSXMLPacket packetWithName:@"error"];
                //                [error addAttributeWithName:@"type" stringValue:@"cancel"];
                //                [error addAttributeWithName:@"code" stringValue:@"501"];
                //                [error addChild:reason];
                //
                //                JUMPIQ *iqResponse = [JUMPIQ iqWithType:@"error"
                //                                                     to:[iq from]
                //                                              packetID:[iq packetID]
                //                                                  child:error];
                //
                //                NSXMLPacket *iqChild = [iq childPacket];
                //                if (iqChild) {
                //                    NSXMLNode *iqChildCopy = [iqChild copy];
                //                    [iqResponse insertChild:iqChildCopy atIndex:0];
                //                }
                //
                //                // Purposefully go through the sendPacket: method
                //                // so that it gets dispatched onto the jumpQueue,
                //                // and so that modules may get notified of the outgoing error message.
                //
                //                [self sendPacket:iqResponse];
            }
            
        }});
    } else {
        // The IQ doesn't require a response.
        // So we can just fire the delegate method and ignore the responses.
        
        [multicastDelegate jumpStream:self didReceiveIQ:iq];
    }
}

- (void)continueReceiveMessage:(JUMPMessage *)message {
    [multicastDelegate jumpStream:self didReceiveMessage:message];
}

- (void)continueReceivePresence:(JUMPPresence *)presence {
    [multicastDelegate jumpStream:self didReceivePresence:presence];
}

/**
 * This method allows you to inject an packet into the stream as if it was received on the socket.
 * This is an advanced technique, but makes for some interesting possibilities.
 **/
- (void)injectPacket:(JUMPPacket *)packet {
    if (packet == nil) {
        return;
    }
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (state != STATE_JUMP_CONNECTED) {
            return_from_block;
        }
        
        YYIMLogDebug(@"INJECT PACKET:%@-%@", [packet headerData], [packet jsonString]);
        
        if ([packet isIqPacket]) {
            [self receiveIQ:[JUMPIQ iqFromPacket:packet]];
        } else if ([packet isMessagePacket]) {
            [self receiveMessage:[JUMPMessage messageFromPacket:packet]];
        } else if ([packet isPresencePacket]) {
            [self receivePresence:[JUMPPresence presenceFromPacket:packet]];
        } else if ([packet isPingPacket]) {
            [multicastDelegate jumpStream:self didReceivePing:packet];
        } else {
            [multicastDelegate jumpStream:self didReceiveError:[JUMPError errorFromPacket:packet]];
        }
    }};
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

/**
 * This method handles starting TLS negotiation on the socket, using the proper settings.
 **/
- (void)startTLS {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    JUMPLogTrace();
    
    // Update state (part 2 - prompting delegates)
    [self innerSetState:STATE_JUMP_TLS];
    
    // Create a mutable dictionary for security settings
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:5];
    
    SEL selector = @selector(jumpStream:willSecureWithSettings:);
    
    if (![multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        // None of the delegates implement the method.
        // Use a shortcut.
        
        [self continueStartTLS:settings];
    } else {
        // Query all interested delegates.
        // This must be done serially to maintain thread safety.
        
        YMGCDMulticastDelegateEnumerator *delegateEnumerator = [multicastDelegate delegateEnumerator];
        
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{ @autoreleasepool {
            
            // Prompt the delegate(s) to populate the security settings
            
            id delegate;
            dispatch_queue_t delegateQueue;
            
            while ([delegateEnumerator getNextDelegate:&delegate delegateQueue:&delegateQueue forSelector:selector]) {
                dispatch_sync(delegateQueue, ^{ @autoreleasepool {
                    
                    [delegate jumpStream:self willSecureWithSettings:settings];
                    
                }});
            }
            
            dispatch_async(jumpQueue, ^{ @autoreleasepool {
                
                [self continueStartTLS:settings];
                
            }});
            
        }});
    }
}

- (void)continueStartTLS:(NSMutableDictionary *)settings {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    JUMPLogTrace2(@"%@: %@ %@", THIS_FILE, THIS_METHOD, settings);
    
    if (state == STATE_JUMP_TLS) {
        // If the delegates didn't respond
        if ([settings count] == 0) {
            // Use the default settings, and set the peer name
            
            NSString *expectedCertName = hostName;
            if (expectedCertName == nil) {
                expectedCertName = [myJID_setByClient domain];
            }
            
            if ([expectedCertName length] > 0) {
                [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
            }
        }
        
        [asyncSocket startTLS:settings];
        
        // Continue reading for XML packets
        [asyncSocket readDataToLength:JUMPStreamPacketHeaderLength withTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_HEADER];
        
        // we're connected at this point.
        [self innerSetState:STATE_JUMP_CONNECTED_NOAUTH];
        
        if (![self isAuthenticated]) {
            [self setupKeepAliveTimer];
            
            [multicastDelegate jumpStreamDidConnect:self];
        }
        
        // Note: We don't need to wait for asyncSocket to complete TLS negotiation.
        // We can just continue reading/writing to the socket, and it will handle queueing everything for us!
        //
        //		if ([self didStartNegotiation])
        //		{
        //			// Now we start our negotiation over again...
        //			[self sendOpeningNegotiation];
        //
        //			// We paused reading from the socket.
        //			// We're ready to continue now.
        //			[asyncSocket readDataWithTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_STREAM];
        //		}
        //		else
        //		{
        //			// First time starting negotiation
        //			[self startNegotiation];
        //		}
    }
}
/**
 * After the authenticate:error: or authenticateWithPassword:error: methods are invoked, some kind of
 * authentication message is sent to the server.
 * This method forwards the response to the authentication module, and handles the resulting authentication state.
 **/
- (void)handleAuth:(JUMPPacket *)authResponse {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    JUMPLogTrace();
    
    JUMPHandleAuthResponse result = [auth handleAuth:authResponse];
    
    if (result == JUMP_AUTH_SUCCESS) {
        // We are successfully authenticated (via sasl:digest-md5)
        [self setIsAuthenticated:YES];
        
        // Revert back to connected state (from authenticating state)
        [self innerSetState:STATE_JUMP_CONNECTED];
        
        [multicastDelegate jumpStreamDidAuthenticate:self];
        
        // Done with auth
        auth = nil;
    } else if (result == JUMP_AUTH_FAIL) {
        // Revert back to connected state (from authenticating state)
        [self innerSetState:STATE_JUMP_CONNECTED_NOAUTH];
        
        // Notify delegate
        [multicastDelegate jumpStream:self didNotAuthenticate:authResponse error:nil];
        
        // Done with auth
        auth = nil;
        
        [self disconnect];
    } else if (result == JUMP_AUTH_CONTINUE) {
        // Authentication continues.
        // State doesn't change.
    } else {
        JUMPLogError(@"Authentication class (%@) returned invalid response code (%i)",
                     NSStringFromClass([auth class]), (int)result);
        
        NSAssert(NO, @"Authentication class (%@) returned invalid response code (%i)",
                 NSStringFromClass([auth class]), (int)result);
    }
}

#pragma mark JUMPSRVResolver Delegate

- (void)tryNextSrvResult {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    JUMPLogTrace();
    
    NSError *connectError = nil;
    BOOL success = NO;
    
    while (srvResultsIndex < [srvResults count]) {
        JUMPSRVRecord *srvRecord = [srvResults objectAtIndex:srvResultsIndex];
        NSString *srvHost = srvRecord.target;
        UInt16 srvPort    = srvRecord.port;
        
        success = [self connectToHost:srvHost onPort:srvPort withTimeout:JUMPStreamTimeoutNone error:&connectError];
        
        if (success) {
            break;
        } else {
            srvResultsIndex++;
        }
    }
    
    if (!success) {
        // SRV resolution of the JID domain failed.
        // As per the RFC:
        //
        // "If the SRV lookup fails, the fallback is a normal IPv4/IPv6 address record resolution
        // to determine the IP address, using the "jump-client" port 5222, registered with the IANA."
        //
        // In other words, just try connecting to the domain specified in the JID.
        
        success = [self connectToHost:[myJID_setByClient domain] onPort:5222 withTimeout:JUMPStreamTimeoutNone error:&connectError];
    }
    
    if (!success) {
        [self endConnectTimeout];
        
        [self innerSetState:STATE_JUMP_DISCONNECTED];
        
        [multicastDelegate jumpStreamDidDisconnect:self withError:connectError];
    }
}

- (void)jumpSRVResolver:(JUMPSRVResolver *)sender didResolveRecords:(NSArray *)records {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    if (sender != srvResolver) return;
    
    JUMPLogTrace();
    
    srvResults = [records copy];
    srvResultsIndex = 0;
    
    [self innerSetState:STATE_JUMP_CONNECTING];
    
    [self tryNextSrvResult];
}

- (void)jumpSRVResolver:(JUMPSRVResolver *)sender didNotResolveDueToError:(NSError *)error {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    if (sender != srvResolver) return;
    
    JUMPLogTrace();
    
    [self innerSetState:STATE_JUMP_CONNECTING];
    
    [self tryNextSrvResult];
}

#pragma mark AsyncSocket Delegate

/**
 * Called when a socket connects and is ready for reading and writing. "host" will be an IP address, not a DNS name.
 **/
- (void)socket:(YMGCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    // This method is invoked on the jumpQueue.
    //
    // The TCP connection is now established.
    
    JUMPLogTrace();
    
    [self endConnectTimeout];
    
    if (self.enableBackgroundingOnSocket) {
        __block BOOL result;
        
        [asyncSocket performBlock:^{
            result = [asyncSocket enableBackgroundingOnSocket];
        }];
        
        if (result) {
            JUMPLogVerbose(@"%@: Enabled backgrounding on socket", THIS_FILE);
        } else {
            JUMPLogError(@"%@: Error enabling backgrounding on socket!", THIS_FILE);
        }
    }
    
    [multicastDelegate jumpStream:self socketDidConnect:sock];
    
    srvResolver = nil;
    srvResults = nil;
    
    if ([self isSecure]) {
        // The connection must be secured immediately (just like with HTTPS)
        [self startTLS];
    } else {
        // Continue reading for XML packets
        [asyncSocket readDataToLength:JUMPStreamPacketHeaderLength withTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_HEADER];
        
        // we're connected at this point.
        [self innerSetState:STATE_JUMP_CONNECTED_NOAUTH];
        
        if (![self isAuthenticated]) {
            [self setupKeepAliveTimer];
            
            [multicastDelegate jumpStreamDidConnect:self];
        }
    }
}

- (void)socket:(YMGCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    JUMPLogTrace();
    
    SEL selector = @selector(jumpStream:didReceiveTrust:completionHandler:);
    
    if ([multicastDelegate hasDelegateThatRespondsToSelector:selector]) {
        [multicastDelegate jumpStream:self didReceiveTrust:trust completionHandler:completionHandler];
    } else {
        JUMPLogWarn(@"%@: Stream secured with (GCDAsyncSocketManuallyEvaluateTrust == YES),"
                    @" but there are no delegates that implement jumpStream:didReceiveTrust:completionHandler:."
                    @" This is likely a mistake.", THIS_FILE);
        
        // The delegate method should likely have code similar to this,
        // but will presumably perform some extra security code stuff.
        // For example, allowing a specific self-signed certificate that is known to the app.
        
        dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(bgQueue, ^{
            
            SecTrustResultType result = kSecTrustResultDeny;
            OSStatus status = SecTrustEvaluate(trust, &result);
            
            if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
                completionHandler(YES);
            } else {
                completionHandler(NO);
            }
        });
    }
}

- (void)socketDidSecure:(YMGCDAsyncSocket *)sock {
    // This method is invoked on the jumpQueue.
    
    JUMPLogTrace();
    
    [multicastDelegate jumpStreamDidSecure:self];
}

/**
 * Called when a socket has completed reading the requested data. Not called if there is an error.
 **/
- (void)socket:(YMGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // This method is invoked on the jumpQueue.
    
    JUMPLogTrace();
    
    lastSendReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    numberOfBytesReceived += [data length];
    
    JUMPLogRecvPre(@"RECV: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    YYIMLogDebug(@"SOCKET RECV:%ld: %@|%ld",tag , data, (unsigned long)[data length]);
    
    // Continue reading for XML packets
    switch (tag) {
            // 1.已读取报文头，计算长度后继续读取报文体
        case TAG_JUMP_READ_HEADER: {
            header = [JUMPHeader headerWithData:data];
            if (![header checkHeader]) {
                YYIMLogError(@"RUBBISH_HEADER:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                [asyncSocket readDataWithTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_RUBBISH];
            } else {
                int headerLength = [header getPacketLength];
                if (headerLength > 0) {
                    [asyncSocket readDataToLength:headerLength withTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_BODY];
                } else {
                    [parser parseData:nil header:header];
                }
            }
        }
            break;
        case TAG_JUMP_READ_BODY:// 2.已读出报文体，转发报文体，然后继续读取报文头
            // Asynchronously parse the xml data
            [parser parseData:data header:header];
            break;
        case TAG_JUMP_READ_RUBBISH:
            YYIMLogError(@"RUBBISH:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [asyncSocket readDataToLength:JUMPStreamPacketHeaderLength withTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_HEADER];
            break;
        default:
            break;
    }
}

/**
 * Called after data with the given tag has been successfully sent.
 **/
- (void)socket:(YMGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    // This method is invoked on the jumpQueue.
    
    JUMPLogTrace();
    
    lastSendReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    
    if (tag == TAG_JUMP_WRITE_RECEIPT) {
        if ([receipts count] == 0) {
            JUMPLogWarn(@"%@: Found TAG_JUMP_WRITE_RECEIPT with no pending receipts!", THIS_FILE);
            return;
        }
        
        JUMPPacketReceipt *receipt = [receipts objectAtIndex:0];
        [receipt signalSuccess];
        [receipts removeObjectAtIndex:0];
    } else if (tag == TAG_JUMP_WRITE_STOP) {
        [multicastDelegate jumpStreamDidSendClosingStreamStanza:self];
    }
}

/**
 * Called when a socket disconnects with or without error.
 **/
- (void)socketDidDisconnect:(YMGCDAsyncSocket *)sock withError:(NSError *)err {
    // This method is invoked on the jumpQueue.
    
    JUMPLogTrace();
    
    [self endConnectTimeoutWithError:err];
    
    if (srvResults && (++srvResultsIndex < [srvResults count])) {
        [self tryNextSrvResult];
    } else {
        // Update state
        [self innerSetState:STATE_JUMP_DISCONNECTED];
        
        // Release the parser (to free underlying resources)
        [parser setDelegate:nil delegateQueue:NULL];
        parser = nil;
        
        // Clear any saved authentication information
        auth = nil;
        
        authenticationDate = nil;
        
        // Clear stored packets
        myJID_setByServer = nil;
        myPresence = nil;
        
        // Stop the keep alive timer
        if (keepAliveTimer) {
            dispatch_source_cancel(keepAliveTimer);
            keepAliveTimer = NULL;
        }
        
        // Clear srv results
        srvResolver = nil;
        srvResults = nil;
        
        // Stop tracking IDs
        [idTracker removeAllIDs];
        
        // Clear any pending receipts
        for (JUMPPacketReceipt *receipt in receipts) {
            [receipt signalFailure];
        }
        [receipts removeAllObjects];
        
        // Clear flags
        isAuthenticated = NO;
        
        // Notify delegate
        
        if (parserError || otherError) {
            NSError *error = parserError ? : otherError;
            
            [multicastDelegate jumpStreamDidDisconnect:self withError:error];
            
            parserError = nil;
            otherError = nil;
        } else {
            [multicastDelegate jumpStreamDidDisconnect:self withError:err];
        }
    }
}

#pragma mark JUMPParser Delegate

- (void)jumpParser:(JUMPParser *)sender didReadPacket:(JUMPPacket *)packet {
    // This method is invoked on the jumpQueue.
    
    if (sender != parser) return;
    
    JUMPLogTrace();
    //    YYIMLogDebug(@"DID READ PACKET:%@-%@|%ld", [packet headerData], [packet jsonString], [[packet packetData] length]);
    YYIMLogDebug(@"DID READ PACKET:%@-%@", [packet headerData], [packet jsonString]);
    
    if (state == STATE_JUMP_AUTH) {
        // Some response to the authentication process
        [self handleAuth:packet];
    } else {
        if ([packet isIqPacket]) {
            [self receiveIQ:[JUMPIQ iqFromPacket:packet]];
        } else if ([packet isMessagePacket]) {
            [self receiveMessage:[JUMPMessage messageFromPacket:packet]];
        } else if ([packet isPresencePacket]) {
            [self receivePresence:[JUMPPresence presenceFromPacket:packet]];
        } else if ([packet isPingPacket]) {
            [multicastDelegate jumpStream:self didReceivePing:packet];
        } else {
            [multicastDelegate jumpStream:self didReceiveError:[JUMPError errorFromPacket:packet]];
        }
    }
}

- (void)jumpParserDidParseData:(JUMPParser *)sender {
    // This method is invoked on the jumpQueue.
    
    if (sender != parser) return;
    
    JUMPLogTrace();
    
    // Continue reading for XML packets
    [asyncSocket readDataToLength:JUMPStreamPacketHeaderLength withTimeout:TIMEOUT_JUMP_READ_STREAM tag:TAG_JUMP_READ_HEADER];
}

- (void)jumpParserDidEnd:(JUMPParser *)sender {
    // This method is invoked on the jumpQueue.
    
    if (sender != parser) return;
    
    JUMPLogTrace();
    
    [asyncSocket disconnect];
}

- (void)jumpParser:(JUMPParser *)sender didFail:(NSError *)error {
    // This method is invoked on the jumpQueue.
    
    if (sender != parser) return;
    
    JUMPLogTrace();
    
    parserError = error;
    YYIMLogError(@"PARSE PACKET FAIL:%@|%@", [error localizedDescription], [error userInfo]);
    [asyncSocket disconnect];
}

#pragma mark Keep Alive

- (void)setupKeepAliveTimer {
    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    
    JUMPLogTrace();
    
    if (keepAliveTimer) {
        dispatch_source_cancel(keepAliveTimer);
        keepAliveTimer = NULL;
    }
    
    if (state == STATE_JUMP_CONNECTED) {
        if (keepAliveInterval > 0) {
            keepAliveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, jumpQueue);
            
            dispatch_source_set_event_handler(keepAliveTimer, ^{ @autoreleasepool {
                [self keepAlive];
            }});
            
            // Everytime we send or receive data, we update our lastSendReceiveTime.
            // We set our timer to fire several times per keepAliveInterval.
            // This allows us to maintain a single timer,
            // and an acceptable timer resolution (assuming larger keepAliveIntervals).
            
            uint64_t interval = ((keepAliveInterval / 4.0) * NSEC_PER_SEC);
            
            dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, interval);
            
            dispatch_source_set_timer(keepAliveTimer, tt, interval, 1.0);
            dispatch_resume(keepAliveTimer);
        }
    }
}

- (void)keepAlive {
    //    NSAssert(dispatch_get_specific(jumpQueueTag), @"Invoked on incorrect queue");
    //
    //    if (state == STATE_JUMP_CONNECTED) {
    //        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    //        NSTimeInterval elapsed = (now - lastSendReceiveTime);
    //
    //        if (elapsed < 0 || elapsed >= keepAliveInterval) {
    //            numberOfBytesSent += [keepAliveData length];
    //
    //            [asyncSocket writeData:keepAliveData withTimeout:TIMEOUT_JUMP_WRITE tag:TAG_JUMP_WRITE_STREAM];
    //
    //            // Force update the lastSendReceiveTime here just to be safe.
    //            //
    //            // In case the TCP socket comes to a crawl with a giant packet in the queue,
    //            // which would prevent the socket:didWriteDataWithTag: method from being called for some time.
    //
    //            lastSendReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    //        }
    //    }
}

#pragma mark Module Plug-In System

- (void)registerModule:(JUMPModule *)module {
    if (module == nil) return;
    
    // Asynchronous operation
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        // Register module
        
        [registeredModules addObject:module];
        
        // Add auto delegates (if there are any)
        
        NSString *className = NSStringFromClass([module class]);
        YMGCDMulticastDelegate *autoDelegates = [autoDelegateDict objectForKey:className];
        
        YMGCDMulticastDelegateEnumerator *autoDelegatesEnumerator = [autoDelegates delegateEnumerator];
        id delegate;
        dispatch_queue_t delegateQueue;
        
        while ([autoDelegatesEnumerator getNextDelegate:&delegate delegateQueue:&delegateQueue]) {
            [module addDelegate:delegate delegateQueue:delegateQueue];
        }
        
        // Notify our own delegate(s)
        
        [multicastDelegate jumpStream:self didRegisterModule:module];
        
    }};
    
    // Asynchronous operation
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (void)unregisterModule:(JUMPModule *)module {
    if (module == nil) return;
    
    // Synchronous operation
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        // Notify our own delegate(s)
        
        [multicastDelegate jumpStream:self willUnregisterModule:module];
        
        // Remove auto delegates (if there are any)
        
        NSString *className = NSStringFromClass([module class]);
        YMGCDMulticastDelegate *autoDelegates = [autoDelegateDict objectForKey:className];
        
        YMGCDMulticastDelegateEnumerator *autoDelegatesEnumerator = [autoDelegates delegateEnumerator];
        id delegate;
        dispatch_queue_t delegateQueue;
        
        while ([autoDelegatesEnumerator getNextDelegate:&delegate delegateQueue:&delegateQueue]) {
            // The module itself has dispatch_sync'd in order to invoke its deactivate method,
            // which has in turn invoked this method. If we call back into the module,
            // and have it dispatch_sync again, we're going to get a deadlock.
            // So we must remove the delegate(s) asynchronously.
            
            [module removeDelegate:delegate delegateQueue:delegateQueue synchronously:NO];
        }
        
        // Unregister modules
        
        [registeredModules removeObject:module];
        
    }};
    
    // Synchronous operation
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
}

- (void)autoAddDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue toModulesOfClass:(Class)aClass {
    if (delegate == nil) return;
    if (aClass == nil) return;
    
    // Asynchronous operation
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSString *className = NSStringFromClass(aClass);
        
        // Add the delegate to all currently registered modules of the given class.
        
        for (JUMPModule *module in registeredModules) {
            if ([module isKindOfClass:aClass]) {
                [module addDelegate:delegate delegateQueue:delegateQueue];
            }
        }
        
        // Add the delegate to list of auto delegates for the given class.
        // It will be added as a delegate to future registered modules of the given class.
        
        id delegates = [autoDelegateDict objectForKey:className];
        if (delegates == nil) {
            delegates = [[YMGCDMulticastDelegate alloc] init];
            
            [autoDelegateDict setObject:delegates forKey:className];
        }
        
        [delegates addDelegate:delegate delegateQueue:delegateQueue];
        
    }};
    
    // Asynchronous operation
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_async(jumpQueue, block);
    }
}

- (void)removeAutoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue fromModulesOfClass:(Class)aClass {
    if (delegate == nil) return;
    // delegateQueue may be NULL
    // aClass may be NULL
    
    // Synchronous operation
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (aClass == NULL) {
            // Remove the delegate from all currently registered modules of ANY class.
            
            for (JUMPModule *module in registeredModules) {
                [module removeDelegate:delegate delegateQueue:delegateQueue];
            }
            
            // Remove the delegate from list of auto delegates for all classes,
            // so that it will not be auto added as a delegate to future registered modules.
            
            for (YMGCDMulticastDelegate *delegates in [autoDelegateDict objectEnumerator]) {
                [delegates removeDelegate:delegate delegateQueue:delegateQueue];
            }
        } else {
            NSString *className = NSStringFromClass(aClass);
            
            // Remove the delegate from all currently registered modules of the given class.
            
            for (JUMPModule *module in registeredModules) {
                if ([module isKindOfClass:aClass]) {
                    [module removeDelegate:delegate delegateQueue:delegateQueue];
                }
            }
            
            // Remove the delegate from list of auto delegates for the given class,
            // so that it will not be added as a delegate to future registered modules of the given class.
            
            YMGCDMulticastDelegate *delegates = [autoDelegateDict objectForKey:className];
            [delegates removeDelegate:delegate delegateQueue:delegateQueue];
            
            if ([delegates count] == 0) {
                [autoDelegateDict removeObjectForKey:className];
            }
        }
        
    }};
    
    // Synchronous operation
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
}

- (void)enumerateModulesWithBlock:(void (^)(JUMPModule *module, NSUInteger idx, BOOL *stop))enumBlock {
    if (enumBlock == NULL) return;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSUInteger i = 0;
        BOOL stop = NO;
        
        for (JUMPModule *module in registeredModules) {
            enumBlock(module, i, &stop);
            
            if (stop) {
                break;
            } else {
                i++;
            }
        }
    }};
    
    // Synchronous operation
    
    if (dispatch_get_specific(jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(jumpQueue, block);
    }
}

- (void)enumerateModulesOfClass:(Class)aClass withBlock:(void (^)(JUMPModule *module, NSUInteger idx, BOOL *stop))block {
    [self enumerateModulesWithBlock:^(JUMPModule *module, NSUInteger idx, BOOL *stop) {
        if([module isKindOfClass:aClass]) {
            block(module,idx,stop);
        }
    }];
}

#pragma mark Utilities

+ (NSString *)generateUUID {
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    return result;
}

- (NSString *)generateUUID {
    return [[self class] generateUUID];
}

+ (NSString *)generateJUMPID {
    return [[self generateUUID] lowercaseString];
}

- (NSString *)generateJUMPID {
    return [[self class] generateJUMPID];
}

@end

#pragma mark -

@implementation JUMPPacketReceipt

static const uint32_t receipt_unknown = 0 << 0;
static const uint32_t receipt_failure = 1 << 0;
static const uint32_t receipt_success = 1 << 1;


- (id)init {
    if ((self = [super init])) {
        atomicFlags = receipt_unknown;
        semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)signalSuccess {
    uint32_t mask = receipt_success;
    OSAtomicOr32Barrier(mask, &atomicFlags);
    
    dispatch_semaphore_signal(semaphore);
}

- (void)signalFailure {
    uint32_t mask = receipt_failure;
    OSAtomicOr32Barrier(mask, &atomicFlags);
    
    dispatch_semaphore_signal(semaphore);
}

- (BOOL)wait:(NSTimeInterval)timeout_seconds {
    uint32_t mask = 0;
    uint32_t flags = OSAtomicOr32Barrier(mask, &atomicFlags);
    
    if (flags != receipt_unknown) {
        return (flags == receipt_success);
    }
    
    dispatch_time_t timeout_nanos;
    
    if (isless(timeout_seconds, 0.0)) {
        timeout_nanos = DISPATCH_TIME_FOREVER;
    } else {
        timeout_nanos = dispatch_time(DISPATCH_TIME_NOW, (timeout_seconds * NSEC_PER_SEC));
    }
    
    // dispatch_semaphore_wait
    //
    // Decrement the counting semaphore. If the resulting value is less than zero,
    // this function waits in FIFO order for a signal to occur before returning.
    //
    // Returns zero on success, or non-zero if the timeout occurred.
    //
    // Note: If the timeout occurs, the semaphore value is incremented (without signaling).
    
    long result = dispatch_semaphore_wait(semaphore, timeout_nanos);
    
    if (result == 0) {
        flags = OSAtomicOr32Barrier(mask, &atomicFlags);
        
        return (flags == receipt_success);
    } else {
        // Timed out waiting...
        return NO;
    }
}

@end
