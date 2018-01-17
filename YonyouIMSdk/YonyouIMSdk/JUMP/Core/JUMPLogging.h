/**
 * In order to provide fast and flexible logging, this project uses Cocoa Lumberjack.
 *
 * The GitHub project page has a wealth of documentation if you have any questions.
 * https://github.com/robbiehanson/CocoaLumberjack
 *
 * Here's what you need to know concerning how logging is setup for JUMPFramework:
 *
 * There are 4 log levels:
 * - Error
 * - Warning
 * - Info
 * - Verbose
 *
 * In addition to this, there is a Trace flag that can be enabled.
 * When tracing is enabled, it spits out the methods that are being called.
 *
 * Please note that tracing is separate from the log levels.
 * For example, one could set the log level to warning, and enable tracing.
 *
 * All logging is asynchronous, except errors.
 * To use logging within your own custom files, follow the steps below.
 *
 * Step 1:
 * Import this header in your implementation file:
 *
 * #import "JUMPLogging.h"
 *
 * Step 2:
 * Define your logging level in your implementation file:
 *
 * // Log levels: off, error, warn, info, verbose
 * static const int jumpLogLevel = JUMP_LOG_LEVEL_VERBOSE;
 *
 * If you wish to enable tracing, you could do something like this:
 *
 * // Log levels: off, error, warn, info, verbose
 * static const int jumpLogLevel = JUMP_LOG_LEVEL_INFO | JUMP_LOG_FLAG_TRACE;
 *
 * Step 3:
 * Replace your NSLog statements with JUMPLog statements according to the severity of the message.
 *
 * NSLog(@"Fatal error, no dohickey found!"); -> JUMPLogError(@"Fatal error, no dohickey found!");
 *
 * JUMPLog has the same syntax as NSLog.
 * This means you can pass it multiple variables just like NSLog.
 *
 * You may optionally choose to define different log levels for debug and release builds.
 * You can do so like this:
 *
 * // Log levels: off, error, warn, info, verbose
 * #if DEBUG
 *   static const int jumpLogLevel = JUMP_LOG_LEVEL_VERBOSE;
 * #else
 *   static const int jumpLogLevel = JUMP_LOG_LEVEL_WARN;
 * #endif
 *
 * Xcode projects created with Xcode 4 automatically define DEBUG via the project's preprocessor macros.
 * If you created your project with a previous version of Xcode, you may need to add the DEBUG macro manually.
 **/

#import "YMDDLog.h"

// Global flag to enable/disable logging throughout the entire jump framework.

#ifndef JUMP_LOGGING_ENABLED
#define JUMP_LOGGING_ENABLED 1
#endif

// Define logging context for every log message coming from the JUMP framework.
// The logging context can be extracted from the DDLogMessage from within the logging framework.
// This gives loggers, formatters, and filters the ability to optionally process them differently.

#define JUMP_LOG_CONTEXT 5222

// Configure log levels.

#define JUMP_LOG_FLAG_ERROR   (1 << 0) // 0...00001
#define JUMP_LOG_FLAG_WARN    (1 << 1) // 0...00010
#define JUMP_LOG_FLAG_INFO    (1 << 2) // 0...00100
#define JUMP_LOG_FLAG_VERBOSE (1 << 3) // 0...01000

#define JUMP_LOG_LEVEL_OFF     0                                              // 0...00000
#define JUMP_LOG_LEVEL_ERROR   (JUMP_LOG_LEVEL_OFF   | JUMP_LOG_FLAG_ERROR)   // 0...00001
#define JUMP_LOG_LEVEL_WARN    (JUMP_LOG_LEVEL_ERROR | JUMP_LOG_FLAG_WARN)    // 0...00011
#define JUMP_LOG_LEVEL_INFO    (JUMP_LOG_LEVEL_WARN  | JUMP_LOG_FLAG_INFO)    // 0...00111
#define JUMP_LOG_LEVEL_VERBOSE (JUMP_LOG_LEVEL_INFO  | JUMP_LOG_FLAG_VERBOSE) // 0...01111

// Setup fine grained logging.
// The first 4 bits are being used by the standard log levels (0 - 3)
//
// We're going to add tracing, but NOT as a log level.
// Tracing can be turned on and off independently of log level.

#define JUMP_LOG_FLAG_TRACE     (1 << 4) // 0...10000

// Setup the usual boolean macros.

#define JUMP_LOG_ERROR   (jumpLogLevel & JUMP_LOG_FLAG_ERROR)
#define JUMP_LOG_WARN    (jumpLogLevel & JUMP_LOG_FLAG_WARN)
#define JUMP_LOG_INFO    (jumpLogLevel & JUMP_LOG_FLAG_INFO)
#define JUMP_LOG_VERBOSE (jumpLogLevel & JUMP_LOG_FLAG_VERBOSE)
#define JUMP_LOG_TRACE   (jumpLogLevel & JUMP_LOG_FLAG_TRACE)

// Configure asynchronous logging.
// We follow the default configuration,
// but we reserve a special macro to easily disable asynchronous logging for debugging purposes.

#if DEBUG
#define JUMP_LOG_ASYNC_ENABLED  NO
#else
#define JUMP_LOG_ASYNC_ENABLED  YES
#endif

#define JUMP_LOG_ASYNC_ERROR     ( NO && JUMP_LOG_ASYNC_ENABLED)
#define JUMP_LOG_ASYNC_WARN      (YES && JUMP_LOG_ASYNC_ENABLED)
#define JUMP_LOG_ASYNC_INFO      (YES && JUMP_LOG_ASYNC_ENABLED)
#define JUMP_LOG_ASYNC_VERBOSE   (YES && JUMP_LOG_ASYNC_ENABLED)
#define JUMP_LOG_ASYNC_TRACE     (YES && JUMP_LOG_ASYNC_ENABLED)

// Define logging primitives.
// These are primarily wrappers around the macros defined in Lumberjack's DDLog.h header file.

#define JUMP_LOG_OBJC_MAYBE(async, lvl, flg, ctx, frmt, ...) \
do{ if(JUMP_LOGGING_ENABLED) LOG_MAYBE(async, lvl, flg, ctx, sel_getName(_cmd), frmt, ##__VA_ARGS__); } while(0)

#define JUMP_LOG_C_MAYBE(async, lvl, flg, ctx, frmt, ...) \
do{ if(JUMP_LOGGING_ENABLED) LOG_MAYBE(async, lvl, flg, ctx, __FUNCTION__, frmt, ##__VA_ARGS__); } while(0)


#define JUMPLogError(frmt, ...)    JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_ERROR,   jumpLogLevel, JUMP_LOG_FLAG_ERROR,  \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogWarn(frmt, ...)     JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_WARN,    jumpLogLevel, JUMP_LOG_FLAG_WARN,   \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogInfo(frmt, ...)     JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_INFO,    jumpLogLevel, JUMP_LOG_FLAG_INFO,    \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogVerbose(frmt, ...)  JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_VERBOSE, jumpLogLevel, JUMP_LOG_FLAG_VERBOSE, \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogTrace()             JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_TRACE,   jumpLogLevel, JUMP_LOG_FLAG_TRACE, \
JUMP_LOG_CONTEXT, @"%@: %@", THIS_FILE, THIS_METHOD)

#define JUMPLogTrace2(frmt, ...)   JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_TRACE,   jumpLogLevel, JUMP_LOG_FLAG_TRACE, \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)


#define JUMPLogCError(frmt, ...)      JUMP_LOG_C_MAYBE(JUMP_LOG_ASYNC_ERROR,   jumpLogLevel, JUMP_LOG_FLAG_ERROR,   \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogCWarn(frmt, ...)       JUMP_LOG_C_MAYBE(JUMP_LOG_ASYNC_WARN,    jumpLogLevel, JUMP_LOG_FLAG_WARN,    \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogCInfo(frmt, ...)       JUMP_LOG_C_MAYBE(JUMP_LOG_ASYNC_INFO,    jumpLogLevel, JUMP_LOG_FLAG_INFO,    \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogCVerbose(frmt, ...)    JUMP_LOG_C_MAYBE(JUMP_LOG_ASYNC_VERBOSE, jumpLogLevel, JUMP_LOG_FLAG_VERBOSE, \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#define JUMPLogCTrace()               JUMP_LOG_C_MAYBE(JUMP_LOG_ASYNC_TRACE,   jumpLogLevel, JUMP_LOG_FLAG_TRACE, \
JUMP_LOG_CONTEXT, @"%@: %s", THIS_FILE, __FUNCTION__)

#define JUMPLogCTrace2(frmt, ...)     JUMP_LOG_C_MAYBE(JUMP_LOG_ASYNC_TRACE,   jumpLogLevel, JUMP_LOG_FLAG_TRACE, \
JUMP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

// Setup logging for JUMPStream

#define JUMP_LOG_FLAG_SEND      (1 << 5)
#define JUMP_LOG_FLAG_RECV_PRE  (1 << 6) // Prints data before it goes to the parser
#define JUMP_LOG_FLAG_RECV_POST (1 << 7) // Prints data as it comes out of the parser

#define JUMP_LOG_FLAG_SEND_RECV (JUMP_LOG_FLAG_SEND | JUMP_LOG_FLAG_RECV_POST)

#define JUMP_LOG_SEND      (jumpLogLevel & JUMP_LOG_FLAG_SEND)
#define JUMP_LOG_RECV_PRE  (jumpLogLevel & JUMP_LOG_FLAG_RECV_PRE)
#define JUMP_LOG_RECV_POST (jumpLogLevel & JUMP_LOG_FLAG_RECV_POST)

#define JUMP_LOG_ASYNC_SEND      (YES && JUMP_LOG_ASYNC_ENABLED)
#define JUMP_LOG_ASYNC_RECV_PRE  (YES && JUMP_LOG_ASYNC_ENABLED)
#define JUMP_LOG_ASYNC_RECV_POST (YES && JUMP_LOG_ASYNC_ENABLED)

#define JUMPLogSend(format, ...)     JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_SEND, jumpLogLevel, \
JUMP_LOG_FLAG_SEND, JUMP_LOG_CONTEXT, format, ##__VA_ARGS__)

#define JUMPLogRecvPre(format, ...)  JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_RECV_PRE, jumpLogLevel, \
JUMP_LOG_FLAG_RECV_PRE, JUMP_LOG_CONTEXT, format, ##__VA_ARGS__)

#define JUMPLogRecvPost(format, ...) JUMP_LOG_OBJC_MAYBE(JUMP_LOG_ASYNC_RECV_POST, jumpLogLevel, \
JUMP_LOG_FLAG_RECV_POST, JUMP_LOG_CONTEXT, format, ##__VA_ARGS__)
