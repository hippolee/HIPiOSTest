//
//  JUMPStream.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPSASLAuthentication.h"
#import "JUMPCustomBinding.h"
#import "YMGCDAsyncSocket.h"
#import "YMGCDMulticastDelegate.h"

@class JUMPJID;
@class JUMPIQ;
@class JUMPMessage;
@class JUMPPresence;
@class JUMPModule;
@class JUMPPacket;
@class JUMPError;
@class JUMPPacketReceipt;
@protocol JUMPStreamDelegate;

#define JUMP_MIN_KEEPALIVE_INTERVAL      15.0 // 15 Seconds
#define JUMP_DEFAULT_KEEPALIVE_INTERVAL 120.0 //  2 Minutes

extern NSString *const JUMPStreamErrorDomain;

typedef NS_ENUM(NSUInteger, JUMPStreamErrorCode) {
    JUMPStreamInvalidType,       // Attempting to access P2P methods in a non-P2P stream, or vice-versa
    JUMPStreamInvalidState,      // Invalid state for requested action, such as connect when already connected
    JUMPStreamInvalidProperty,   // Missing a required property, such as myJID
    JUMPStreamInvalidParameter,  // Invalid parameter, such as a nil JID
    JUMPStreamUnsupportedAction, // The server doesn't support the requested action
};

typedef NS_ENUM(NSUInteger, JUMPStreamStartTLSPolicy) {
    JUMPStreamStartTLSPolicyAllowed,   // TLS will be used if the server requires it
    JUMPStreamStartTLSPolicyPreferred, // TLS will be used if the server offers it
    JUMPStreamStartTLSPolicyRequired   // TLS will be used if the server offers it, else the stream won't connect
};

extern const NSTimeInterval JUMPStreamTimeoutNone;

@interface JUMPStream : NSObject<YMGCDAsyncSocketDelegate>

/**
 * Standard JUMP initialization.
 * The stream is a standard client to server connection.
 **/
- (id)init;

/**
 * JUMPStream uses a multicast delegate.
 * This allows one to add multiple delegates to a single JUMPStream instance,
 * which makes it easier to separate various components and extensions.
 *
 * For example, if you were implementing two different custom extensions on top of JUMP,
 * you could put them in separate classes, and simply add each as a delegate.
 **/
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;

#pragma mark Properties

/**
 * The server's hostname that should be used to make the TCP connection.
 * This may be a domain name (e.g. "deusty.com") or an IP address (e.g. "70.85.193.226").
 *
 * Note that this may be different from the virtual jump hostname.
 * Just as HTTP servers can support mulitple virtual hosts from a single server, so too can jump servers.
 * A prime example is google via google apps.
 *
 * For example, say you own the domain "mydomain.com".
 * If you go to mydomain.com in a web browser,
 * you are directed to your apache server running on your webserver somewhere in the cloud.
 * But you use google apps for your email and jump needs.
 * So if somebody sends you an email, it actually goes to google's servers, where you later access it from.
 * Similarly, you connect to google's servers to sign into jump.
 *
 * In the example above, your hostname is "talk.google.com" and your JID is "me@mydomain.com".
 *
 * This hostName property is optional.
 * If you do not set the hostName, then the framework will follow the jump specification using jid's domain.
 * That is, it first do an SRV lookup (as specified in the jump RFC).
 * If that fails, it will fall back to simply attempting to connect to the jid's domain.
 **/
@property (readwrite, copy) NSString *hostName;

/**
 * The port the jump server is running on.
 * If you do not explicitly set the port, the default port will be used.
 * If you set the port to zero, the default port will be used.
 *
 * The default port is 5222.
 **/
@property (readwrite, assign) UInt16 hostPort;

/**
 * The stream's policy on when to Start TLS.
 *
 * The default is JUMPStreamStartTLSPolicyAllowed.
 *
 * @see JUMPStreamStartTLSPolicy
**/
@property (readwrite, assign) JUMPStreamStartTLSPolicy startTLSPolicy;

/**
 * The JID of the user.
 *
 * This value is required, and is used in many parts of the underlying implementation.
 * When connecting, the domain of the JID is used to properly specify the correct jump virtual host.
 * It is used during registration to supply the username of the user to create an account for.
 * It is used during authentication to supply the username of the user to authenticate with.
 * And the resource may be used post-authentication during the required jump resource binding step.
 *
 * A proper JID is of the form user@domain/resource.
 * For example: robbiehanson@deusty.com/work
 *
 * The resource is optional, in the sense that if one is not supplied,
 * one will be automatically generated for you (either by us or by the server).
 *
 * Please note:
 * Resource collisions are handled in different ways depending on server configuration.
 *
 * For example:
 * You are signed in with user1@domain.com/home on your desktop.
 * Then you attempt to sign in with user1@domain.com/home on your laptop.
 *
 * The server could possibly:
 * - Reject the resource request for the laptop.
 * - Accept the resource request for the laptop, and immediately disconnect the desktop.
 * - Automatically assign the laptop another resource without a conflict.
 *
 * For this reason, you may wish to check the myJID variable after the stream has been connected,
 * just in case the resource was changed by the server.
 **/
@property (readwrite, copy) JUMPJID *myJID;

/**
 * Many routers will teardown a socket mapping if there is no activity on the socket.
 * For this reason, the jump stream supports sending keep-alive data.
 * This is simply whitespace, which is ignored by the jump protocol.
 *
 * Keep-alive data is only sent in the absence of any other data being sent/received.
 *
 * The default value is defined in DEFAULT_KEEPALIVE_INTERVAL.
 * The minimum value is defined in MIN_KEEPALIVE_INTERVAL.
 *
 * To disable keep-alive, set the interval to zero (or any non-positive number).
 *
 * The keep-alive timer (if enabled) fires every (keepAliveInterval / 4) seconds.
 * Upon firing it checks when data was last sent/received,
 * and sends keep-alive data if the elapsed time has exceeded the keepAliveInterval.
 * Thus the effective resolution of the keepalive timer is based on the interval.
 *
 * @see keepAliveWhitespaceCharacter
 **/
@property (readwrite, assign) NSTimeInterval keepAliveInterval;

/**
 * The keep-alive mechanism sends whitespace which is ignored by the jump protocol.
 * The default whitespace character is a space (' ').
 *
 * This can be changed, for whatever reason, to another whitespace character.
 * Valid whitespace characters are space(' '), tab('\t') and newline('\n').
 *
 * If you attempt to set the character to any non-whitespace character, the attempt is ignored.
 *
 * @see keepAliveInterval
 **/
@property (readwrite, assign) char keepAliveWhitespaceCharacter;

/**
 * Represents the last sent presence packet concerning the presence of myJID on the server.
 * In other words, it represents the presence as others see us.
 *
 * This excludes presence packets sent concerning subscriptions, MUC rooms, etc.
 *
 * @see resendMyPresence
 **/
@property (strong, readonly) JUMPPresence *myPresence;

/**
 * Returns the total number of bytes bytes sent/received by the jump stream.
 *
 * By default this is the byte count since the jump stream object has been created.
 * If the stream has connected/disconnected/reconnected multiple times,
 * the count will be the summation of all connections.
 *
 * The functionality may optionaly be changed to count only the current socket connection.
 * @see resetByteCountPerConnection
 **/
@property (readonly) uint64_t numberOfBytesSent;
@property (readonly) uint64_t numberOfBytesReceived;

/**
 * Same as the individual properties,
 * but provides a way to fetch them in one atomic operation.
 **/
- (void)getNumberOfBytesSent:(uint64_t *)bytesSentPtr numberOfBytesReceived:(uint64_t *)bytesReceivedPtr;

/**
 * Affects the funtionality of the byte counter.
 *
 * The default value is NO.
 *
 * If set to YES, the byte count will be reset just prior to a new connection (in the connect methods).
 **/
@property (readwrite, assign) BOOL resetByteCountPerConnection;

/**
 * The tag property allows you to associate user defined information with the stream.
 * Tag values are not used internally, and should not be used by jump modules.
 **/
@property (readwrite, strong) id tag;

/**
 * If set, the kCFStreamNetworkServiceTypeVoIP flags will be set on the underlying CFRead/Write streams.
 *
 * The default value is NO.
 **/
@property (readwrite, assign) BOOL enableBackgroundingOnSocket;

#pragma mark State

/**
 * Returns YES if the connection is closed, and thus no stream is open.
 * If the stream is neither disconnected, nor connected, then a connection is currently being established.
 **/
- (BOOL)isDisconnected;

/**
 * Returns YES is the connection is currently connecting
 **/
- (BOOL)isConnecting;

/**
 * Returns YES if the connection is open, and the stream has been properly established.
 * If the stream is neither disconnected, nor connected, then a connection is currently being established.
 *
 * If this method returns YES, then it is ready for you to start sending and receiving packets.
 **/
- (BOOL)isConnected;

- (BOOL)isConnectedNoAuth;

#pragma mark Connect & Disconnect

/**
 * Connects to the configured hostName on the configured hostPort.
 * The timeout is optional. To not time out use JUMPStreamTimeoutNone.
 * If the hostName or myJID are not set, this method will return NO and set the error parameter.
 **/
- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;

///**
// * THIS IS DEPRECATED BY THE XMPP SPECIFICATION.
// * 
// * The xmpp specification outlines the proper use of SSL/TLS by negotiating
// * the startTLS upgrade within the stream negotiation.
// * This method exists for those ancient servers that still require the connection to be secured prematurely.
// * The timeout is optional. To not time out use XMPPStreamTimeoutNone.
// *
// * Note: Such servers generally use port 5223 for this, which you will need to set.
//**/
//- (BOOL)oldSchoolSecureConnectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;
/**
 * Disconnects from the remote host by closing the underlying TCP socket connection.
 * The terminating </stream:stream> packet is not sent to the server.
 *
 * This method is synchronous.
 * Meaning that the disconnect will happen immediately, even if there are pending packets yet to be sent.
 *
 * The jumpStreamDidDisconnect:withError: delegate method will immediately be dispatched onto the delegate queue.
 **/
- (void)disconnect;

/**
 * Disconnects from the remote host by sending the terminating </stream:stream> packet,
 * and then closing the underlying TCP socket connection.
 *
 * This method is asynchronous.
 * The disconnect will happen after all pending packets have been sent.
 * Attempting to send packets after this method has been called will not work (the packets won't get sent).
 **/
- (void)disconnectAfterSending;

#pragma mark Security

/**
 * Returns YES if SSL/TLS was used to establish a connection to the server.
 * 
 * Some servers may require an "upgrade to TLS" in order to start communication,
 * so even if the connection was not explicitly secured, an ugrade to TLS may have occured.
 * 
 * See also the xmppStream:willSecureWithSettings: delegate method.
**/
- (BOOL)isSecure;

- (void)setIsSecure:(BOOL)flag;

///**
// * Returns whether or not the server supports securing the connection via SSL/TLS.
// * 
// * Some servers will actually require a secure connection,
// * in which case the stream will attempt to secure the connection during the opening process.
// * 
// * If the connection has already been secured, this method may return NO.
//**/
//- (BOOL)supportsStartTLS;

/**
 * Attempts to secure the connection via SSL/TLS.
 * 
 * This method is asynchronous.
 * The SSL/TLS handshake will occur in the background, and
 * the xmppStreamDidSecure: delegate method will be called after the TLS process has completed.
 * 
 * This method returns immediately.
 * If the secure process was started, it will return YES.
 * If there was an issue while starting the security process,
 * this method will return NO and set the error parameter.
 * 
 * The errPtr parameter is optional - you may pass nil.
 * 
 * You may wish to configure the security settings via the xmppStream:willSecureWithSettings: delegate method.
 * 
 * If the SSL/TLS handshake fails, the connection will be closed.
 * The reason for the error will be reported via the xmppStreamDidDisconnect:withError: delegate method.
 * The error parameter will be an NSError object, and may have an error domain of kCFStreamErrorDomainSSL.
 * The corresponding error code is documented in Apple's Security framework, in SecureTransport.h
**/
//- (BOOL)secureConnection:(NSError **)errPtr;

#pragma mark Authentication

/**
 * Returns the server's list of supported authentication mechanisms.
 * Each item in the array will be of type NSString.
 *
 * For example, if the server supplied this stanza within it's reported stream:features:
 *
 * <mechanisms xmlns="urn:ietf:params:xml:ns:jump-sasl">
 *     <mechanism>DIGEST-MD5</mechanism>
 *     <mechanism>PLAIN</mechanism>
 * </mechanisms>
 *
 * Then this method would return [@"DIGEST-MD5", @"PLAIN"].
 **/
- (NSArray *)supportedAuthenticationMechanisms;

/**
 * Returns whether or not the given authentication mechanism name was specified in the
 * server's list of supported authentication mechanisms.
 *
 * Note: The authentication classes often provide a category on JUMPStream, adding useful methods.
 *
 * @see JUMPPlainAuthentication - supportsPlainAuthentication
 * @see JUMPDigestMD5Authentication - supportsDigestMD5Authentication
 * @see JUMPXFacebookPlatformAuthentication - supportsXFacebookPlatformAuthentication
 * @see JUMPDeprecatedPlainAuthentication - supportsDeprecatedPlainAuthentication
 * @see JUMPDeprecatedDigestAuthentication - supportsDeprecatedDigestAuthentication
 **/
- (BOOL)supportsAuthenticationMechanism:(NSString *)mechanism;

/**
 * This is the root authentication method.
 * All other authentication methods go through this one.
 *
 * This method attempts to start the authentication process given the auth instance.
 * That is, this method will invoke start: on the given auth instance.
 * If it returns YES, then the stream will enter into authentication mode.
 * It will then continually invoke the handleAuth: method on the given instance until authentication is complete.
 *
 * This method is asynchronous.
 *
 * If there is something immediately wrong, such as the stream is not connected,
 * the method will return NO and set the error.
 * Otherwise the delegate callbacks are used to communicate auth success or failure.
 *
 * @see jumpStreamDidAuthenticate:
 * @see jumpStream:didNotAuthenticate:
 *
 * @see authenticateWithPassword:error:
 *
 * Note: The security process is abstracted in order to provide flexibility,
 *       and allow developers to easily implement their own custom authentication protocols.
 *       The authentication classes often provide a category on JUMPStream, adding useful methods.
 *
 * @see JUMPXFacebookPlatformAuthentication - authenticateWithFacebookAccessToken:error:
 **/
- (BOOL)authenticate:(id <JUMPSASLAuthentication>)auth error:(NSError **)errPtr;

/**
 * This method applies to standard password authentication schemes only.
 * This is NOT the primary authentication method.
 *
 * @see authenticate:error:
 *
 * This method exists for backwards compatibility, and may disappear in future versions.
 **/
- (BOOL)authenticateWithPassword:(NSString *)password error:(NSError **)errPtr;

/**
 * Returns whether or not the jump stream is currently authenticating with the JUMP Server.
 **/
- (BOOL)isAuthenticating;

/**
 * Returns whether or not the jump stream has successfully authenticated with the server.
 **/
- (BOOL)isAuthenticated;

/**
 * Returns the date when the jump stream successfully authenticated with the server.
 **/
- (NSDate *)authenticationDate;

//#pragma mark Compression
//
///**
// * Returns the server's list of supported compression methods in accordance to XEP-0138: Stream Compression
// * Each item in the array will be of type NSString.
// *
// * Then this method would return [@"zlib", @"lzw"].
// **/
//- (NSArray *)supportedCompressionMethods;
//
///**
// * Returns whether or not the given compression method name was specified in the
// * server's list of supported compression methods.
// *
// * Note: The JUMPStream doesn't currently support any compression methods 
//**/
//- (BOOL)supportsCompressionMethod:(NSString *)compressionMethod;

#pragma mark Sending

/**
 * Sends the given JUMP packet.
 * If the stream is not yet connected, this method does nothing.
 **/
- (void)sendPacket:(JUMPPacket *)packet;

/**
 * Just like the sendPacket: method above,
 * but allows you to receive a receipt that can later be used to verify the packet has been sent.
 *
 * If you later want to check to see if the packet has been sent:
 *
 * if ([receipt wait:0]) {
 *   // Packet has been sent
 * }
 *
 * If you later want to wait until the packet has been sent:
 *
 * if ([receipt wait:-1]) {
 *   // Packet was sent
 * } else {
 *   // Packet failed to send due to disconnection
 * }
 *
 * It is important to understand what it means when [receipt wait:timeout] returns YES.
 * It does NOT mean the server has received the packet.
 * It only means the data has been queued for sending in the underlying OS socket buffer.
 *
 * So at this point the OS will do everything in its capacity to send the data to the server,
 * which generally means the server will eventually receive the data.
 * Unless, of course, something horrible happens such as a network failure,
 * or a system crash, or the server crashes, etc.
 *
 * Even if you close the jump stream after this point, the OS will still do everything it can to send the data.
 **/
- (void)sendPacket:(JUMPPacket *)packet andGetReceipt:(JUMPPacketReceipt **)receiptPtr;

/**
 * Fetches and resends the myPresence packet (if available) in a single atomic operation.
 *
 * There are various jump extensions that hook into the jump stream and append information to outgoing presence stanzas.
 * For example, the JUMPCapabilities module automatically appends capabilities information (as a hash).
 * When these modules need to update/change their appended information,
 * they should use this method to do so.
 *
 * The alternative is to fetch the myPresence packet, and resend it manually using the sendPacket method.
 * However, that is 2 seperate operations, and the user, may send a different presence packet inbetween.
 * Using this method guarantees everything is done as an atomic operation.
 **/
- (void)resendMyPresence;

- (void)injectPacket:(JUMPPacket *)packet;

#pragma mark Module Plug-In System

/**
 * The JUMPModule class automatically invokes these methods when it is activated/deactivated.
 *
 * The registerModule method registers the module with the jumpStream.
 * If there are any other modules that have requested to be automatically added as delegates to modules of this type,
 * then those modules are automatically added as delegates during the asynchronous execution of this method.
 *
 * The registerModule method is asynchronous.
 *
 * The unregisterModule method unregisters the module with the jumpStream,
 * and automatically removes it as a delegate of any other module.
 *
 * The unregisterModule method is fully synchronous.
 * That is, after this method returns, the module will not be scheduled in any more delegate calls from other modules.
 * However, if the module was already scheduled in an existing asynchronous delegate call from another module,
 * the scheduled delegate invocation remains queued and will fire in the near future.
 * Since the delegate invocation is already queued,
 * the module's retainCount has been incremented,
 * and the module will not be deallocated until after the delegate invocation has fired.
 **/
- (void)registerModule:(JUMPModule *)module;
- (void)unregisterModule:(JUMPModule *)module;

/**
 * Automatically registers the given delegate with all current and future registered modules of the given class.
 *
 * That is, the given delegate will be added to the delegate list ([module addDelegate:delegate delegateQueue:dq]) to
 * all current and future registered modules that respond YES to [module isKindOfClass:aClass].
 *
 * This method is used by modules to automatically integrate with other modules.
 * For example, a module may auto-add itself as a delegate to JUMPCapabilities
 * so that it can broadcast its implemented features.
 *
 * This may also be useful to clients, for example, to add a delegate to instances of something like JUMPChatRoom,
 * where there may be multiple instances of the module that get created during the course of an jump session.
 *
 * If you auto register on multiple queues, you can remove all registrations with a single
 * call to removeAutoDelegate::: by passing NULL as the 'dq' parameter.
 *
 * If you auto register for multiple classes, you can remove all registrations with a single
 * call to removeAutoDelegate::: by passing nil as the 'aClass' parameter.
 **/
- (void)autoAddDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue toModulesOfClass:(Class)aClass;
- (void)removeAutoDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue fromModulesOfClass:(Class)aClass;

/**
 * Allows for enumeration of the currently registered modules.
 *
 * This may be useful if the stream needs to be queried for modules of a particular type.
 **/
- (void)enumerateModulesWithBlock:(void (^)(JUMPModule *module, NSUInteger idx, BOOL *stop))block;

/**
 * Allows for enumeration of the currently registered modules that are a kind of Class.
 * idx is in relation to all modules not just those of the given class.
 **/
- (void)enumerateModulesOfClass:(Class)aClass withBlock:(void (^)(JUMPModule *module, NSUInteger idx, BOOL *stop))block;

#pragma mark Utilities

/**
 * Generates and returns a new autoreleased UUID.
 * UUIDs (Universally Unique Identifiers) may also be known as GUIDs (Globally Unique Identifiers).
 *
 * The UUID is generated using the CFUUID library, which generates a unique 128 bit value.
 * The uuid is then translated into a string using the standard format for UUIDs:
 * "68753A44-4D6F-1226-9C60-0050E4C00067"
 *
 * This method is most commonly used to generate a unique id value for an jump packet.
 **/
+ (NSString *)generateUUID;
- (NSString *)generateUUID;

+ (NSString *)generateJUMPID;
- (NSString *)generateJUMPID;

@end

#pragma mark -

@interface JUMPPacketReceipt : NSObject {
    uint32_t atomicFlags;
    dispatch_semaphore_t semaphore;
}

/**
 * Packet receipts allow you to check to see if the packet has been sent.
 * The timeout parameter allows you to do any of the following:
 *
 * - Do an instantaneous check (pass timeout == 0)
 * - Wait until the packet has been sent (pass timeout < 0)
 * - Wait up to a certain amount of time (pass timeout > 0)
 *
 * It is important to understand what it means when [receipt wait:timeout] returns YES.
 * It does NOT mean the server has received the packet.
 * It only means the data has been queued for sending in the underlying OS socket buffer.
 *
 * So at this point the OS will do everything in its capacity to send the data to the server,
 * which generally means the server will eventually receive the data.
 * Unless, of course, something horrible happens such as a network failure,
 * or a system crash, or the server crashes, etc.
 *
 * Even if you close the jump stream after this point, the OS will still do everything it can to send the data.
 **/
- (BOOL)wait:(NSTimeInterval)timeout;

@end

#pragma mark -

@protocol JUMPStreamDelegate
@optional

/**
 * This method is called before the stream begins the connection process.
 *
 * If developing an iOS app that runs in the background, this may be a good place to indicate
 * that this is a task that needs to continue running in the background.
 **/
- (void)jumpStreamWillConnect:(JUMPStream *)sender;

/**
 * This method is called after the tcp socket has connected to the remote host.
 * It may be used as a hook for various things, such as updating the UI or extracting the server's IP address.
 *
 * If developing an iOS app that runs in the background,
 * please use JUMPStream's enableBackgroundingOnSocket property as opposed to doing it directly on the socket here.
 **/
- (void)jumpStream:(JUMPStream *)sender socketDidConnect:(YMGCDAsyncSocket *)socket;

/**
 * This method is called immediately prior to the stream being secured via TLS/SSL.
 * Note that this delegate may be called even if you do not explicitly invoke the startTLS method.
 * Servers have the option of requiring connections to be secured during the opening process.
 * If this is the case, the JUMPStream will automatically attempt to properly secure the connection.
 *
 * The dictionary of settings is what will be passed to the startTLS method of the underlying GCDAsyncSocket.
 * The GCDAsyncSocket header file contains a discussion of the available key/value pairs,
 * as well as the security consequences of various options.
 * It is recommended reading if you are planning on implementing this method.
 *
 * The dictionary of settings that are initially passed will be an empty dictionary.
 * If you choose not to implement this method, or simply do not edit the dictionary,
 * then the default settings will be used.
 * That is, the kCFStreamSSLPeerName will be set to the configured host name,
 * and the default security validation checks will be performed.
 *
 * This means that authentication will fail if the name on the X509 certificate of
 * the server does not match the value of the hostname for the jump stream.
 * It will also fail if the certificate is self-signed, or if it is expired, etc.
 *
 * These settings are most likely the right fit for most production environments,
 * but may need to be tweaked for development or testing,
 * where the development server may be using a self-signed certificate.
 *
 * Note: If your development server is using a self-signed certificate,
 * you likely need to add GCDAsyncSocketManuallyEvaluateTrust=YES to the settings.
 * Then implement the jumpStream:didReceiveTrust:completionHandler: delegate method to perform custom validation.
 **/
- (void)jumpStream:(JUMPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings;

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements jumpStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)jumpStream:(JUMPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler;

/**
 * This method is called after the stream has been secured via SSL/TLS.
 * This method may be called if the server required a secure connection during the opening process,
 * or if the secureConnection: method was manually invoked.
**/
- (void)jumpStreamDidSecure:(JUMPStream *)sender;

/**
 * This method is called after the XML stream has been fully opened.
 * More precisely, this method is called after an opening <xml/> and <stream:stream/> tag have been sent and received,
 * and after the stream features have been received, and any required features have been fullfilled.
 * At this point it's safe to begin communication with the server.
 **/
- (void)jumpStreamDidConnect:(JUMPStream *)sender;
- (void)jumpStreamDidNotConnect:(JUMPStream *)sender error:(NSError *)error;

/**
 * This method is called after authentication has successfully finished.
 * If authentication fails for some reason, the jumpStream:didNotAuthenticate: method will be called instead.
 **/
- (void)jumpStreamDidAuthenticate:(JUMPStream *)sender;

/**
 * This method is called if authentication fails.
 **/
- (void)jumpStream:(JUMPStream *)sender didNotAuthenticate:(JUMPPacket *)packet error:(NSError *)error;

/**
 * These methods are called before their respective XML packets are broadcast as received to the rest of the stack.
 * These methods can be used to modify packets on the fly.
 * (E.g. perform custom decryption so the rest of the stack sees readable text.)
 *
 * You may also filter incoming packets by returning nil.
 *
 * When implementing these methods to modify the packet, you do not need to copy the given packet.
 * You can simply edit the given packet, and return it.
 * The reason these methods return an packet, instead of void, is to allow filtering.
 *
 * Concerning thread-safety, delegates implementing the method are invoked one-at-a-time to
 * allow thread-safe modification of the given packets.
 *
 * You should NOT implement these methods unless you have good reason to do so.
 * For general processing and notification of received packets, please use jumpStream:didReceiveX: methods.
 *
 * @see jumpStream:didReceiveIQ:
 * @see jumpStream:didReceiveMessage:
 * @see jumpStream:didReceivePresence:
 **/
- (JUMPIQ *)jumpStream:(JUMPStream *)sender willReceiveIQ:(JUMPIQ *)iq;
- (JUMPMessage *)jumpStream:(JUMPStream *)sender willReceiveMessage:(JUMPMessage *)message;
- (JUMPPresence *)jumpStream:(JUMPStream *)sender willReceivePresence:(JUMPPresence *)presence;

/**
 * This method is called if any of the jumpStream:willReceiveX: methods filter the incoming stanza.
 *
 * It may be useful for some extensions to know that something was received,
 * even if it was filtered for some reason.
 **/
- (void)jumpStreamDidFilterStanza:(JUMPStream *)sender;

/**
 * These methods are called after their respective XML packets are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then jump stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given packets.
 * As documented in NSXML / KissXML, packets are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an packet for any reason,
 * you should copy the packet first, and then modify and use the copy.
 **/
- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq;
- (void)jumpStream:(JUMPStream *)sender didReceiveMessage:(JUMPMessage *)message;
- (void)jumpStream:(JUMPStream *)sender didReceivePresence:(JUMPPresence *)presence;
- (void)jumpStream:(JUMPStream *)sender didReceivePing:(JUMPPacket *)ping;

/**
 * This method is called if an JUMP error is received.
 * In other words, a <stream:error/>.
 *
 * However, this method may also be called for any unrecognized xml stanzas.
 *
 * Note that standard errors (<iq type='error'/> for example) are delivered normally,
 * via the other didReceive...: methods.
 **/
- (void)jumpStream:(JUMPStream *)sender didReceiveError:(JUMPError *)error;

/**
 * These methods are called before their respective XML packets are sent over the stream.
 * These methods can be used to modify outgoing packets on the fly.
 * (E.g. add standard information for custom protocols.)
 *
 * You may also filter outgoing packets by returning nil.
 *
 * When implementing these methods to modify the packet, you do not need to copy the given packet.
 * You can simply edit the given packet, and return it.
 * The reason these methods return an packet, instead of void, is to allow filtering.
 *
 * Concerning thread-safety, delegates implementing the method are invoked one-at-a-time to
 * allow thread-safe modification of the given packets.
 *
 * You should NOT implement these methods unless you have good reason to do so.
 * For general processing and notification of sent packets, please use jumpStream:didSendX: methods.
 *
 * @see jumpStream:didSendIQ:
 * @see jumpStream:didSendMessage:
 * @see jumpStream:didSendPresence:
 **/
- (JUMPIQ *)jumpStream:(JUMPStream *)sender willSendIQ:(JUMPIQ *)iq;
- (JUMPMessage *)jumpStream:(JUMPStream *)sender willSendMessage:(JUMPMessage *)message;
- (JUMPPresence *)jumpStream:(JUMPStream *)sender willSendPresence:(JUMPPresence *)presence;

/**
 * These methods are called after their respective XML packets are sent over the stream.
 * These methods may be used to listen for certain events (such as an unavailable presence having been sent),
 * or for general logging purposes. (E.g. a central history logging mechanism).
 **/
- (void)jumpStream:(JUMPStream *)sender didSendIQ:(JUMPIQ *)iq;
- (void)jumpStream:(JUMPStream *)sender didSendMessage:(JUMPMessage *)message;
- (void)jumpStream:(JUMPStream *)sender didSendPresence:(JUMPPresence *)presence;

/**
 * These methods are called after failing to send the respective XML packets over the stream.
 * This occurs when the stream gets disconnected before the packet can get sent out.
 **/
- (void)jumpStream:(JUMPStream *)sender didFailToSendIQ:(JUMPIQ *)iq error:(NSError *)error;
- (void)jumpStream:(JUMPStream *)sender didFailToSendMessage:(JUMPMessage *)message error:(NSError *)error;
- (void)jumpStream:(JUMPStream *)sender didFailToSendPresence:(JUMPPresence *)presence error:(NSError *)error;

/**
 * This method is called if the JUMP Stream's jid changes.
 **/
- (void)jumpStreamDidChangeMyJID:(JUMPStream *)jumpStream;

/**
 * This method is called if the disconnect method is called.
 * It may be used to determine if a disconnection was purposeful, or due to an error.
 *
 * Note: A disconnect may be either "clean" or "dirty".
 * A "clean" disconnect is when the stream sends the closing </stream:stream> stanza before disconnecting.
 * A "dirty" disconnect is when the stream simply closes its TCP socket.
 * In most cases it makes no difference how the disconnect occurs,
 * but there are a few contexts in which the difference has various protocol implications.
 *
 * @see jumpStreamDidSendClosingStreamStanza
 **/
- (void)jumpStreamWasToldToDisconnect:(JUMPStream *)sender;

/**
 * This method is called after the stream has sent the closing </stream:stream> stanza.
 * This signifies a "clean" disconnect.
 *
 * Note: A disconnect may be either "clean" or "dirty".
 * A "clean" disconnect is when the stream sends the closing </stream:stream> stanza before disconnecting.
 * A "dirty" disconnect is when the stream simply closes its TCP socket.
 * In most cases it makes no difference how the disconnect occurs,
 * but there are a few contexts in which the difference has various protocol implications.
 **/
- (void)jumpStreamDidSendClosingStreamStanza:(JUMPStream *)sender;

/**
 * This methods is called if the JUMP stream's connect times out.
 **/
- (void)jumpStreamConnectDidTimeout:(JUMPStream *)sender;

/**
 * This method is called after the stream is closed.
 *
 * The given error parameter will be non-nil if the error was due to something outside the general jump realm.
 * Some examples:
 * - The TCP socket was unexpectedly disconnected.
 * - The SRV resolution of the domain failed.
 * - Error parsing xml sent from server.
 *
 * @see jumpStreamConnectDidTimeout:
 **/
- (void)jumpStreamDidDisconnect:(JUMPStream *)sender withError:(NSError *)error;

/**
 * These methods are called as jump modules are registered and unregistered with the stream.
 * This generally corresponds to jump modules being initailzed and deallocated.
 *
 * The methods may be useful, for example, if a more precise auto delegation mechanism is needed
 * than what is available with the autoAddDelegate:toModulesOfClass: method.
 **/
- (void)jumpStream:(JUMPStream *)sender didRegisterModule:(id)module;
- (void)jumpStream:(JUMPStream *)sender willUnregisterModule:(id)module;

@end