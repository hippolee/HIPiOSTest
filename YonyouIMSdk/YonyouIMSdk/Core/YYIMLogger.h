//
//  YYIMLogger.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YYIM_LOG_LEVEL_DEF [YYIMLogger logLevel]

/**
 * This is the single macro that all other macros below compile into.
 * This big multiline macro makes all the other macros easier to read.
 **/

#define YYIM_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
[YYIMLogger log:isAsynchronous                                             \
level:lvl                                                        \
flag:flg                                                        \
context:ctx                                                        \
file:__FILE__                                                   \
function:fnct                                                       \
line:__LINE__                                                   \
tag:atag                                                       \
format:(frmt), ##__VA_ARGS__]

/**
 * Define the Objective-C and C versions of the macro.
 * These automatically inject the proper function name for either an objective-c method or c function.
 *
 * We also define shorthand versions for asynchronous and synchronous logging.
 **/

#define YYIM_LOG_OBJC_MACRO(async, lvl, flg, ctx, frmt, ...) \
YYIM_LOG_MACRO(async, lvl, flg, ctx, nil, sel_getName(_cmd), frmt, ##__VA_ARGS__)

#define YYIM_LOG_C_MACRO(async, lvl, flg, ctx, frmt, ...) \
YYIM_LOG_MACRO(async, lvl, flg, ctx, nil, __FUNCTION__, frmt, ##__VA_ARGS__)

#define  YYIM_SYNC_LOG_OBJC_MACRO(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_OBJC_MACRO( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

#define YYIM_ASYNC_LOG_OBJC_MACRO(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_OBJC_MACRO(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

#define  YYIM_SYNC_LOG_C_MACRO(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_C_MACRO( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

#define YYIM_ASYNC_LOG_C_MACRO(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_C_MACRO(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

/**
 * Define version of the macro that only execute if the logLevel is above the threshold.
 * The compiled versions essentially look like this:
 *
 * if (logFlagForThisLogMsg & ddLogLevel) { execute log message }
 *
 * When LOG_LEVEL_DEF is defined as ddLogLevel.
 *
 * As shown further below, Lumberjack actually uses a bitmask as opposed to primitive log levels.
 * This allows for a great amount of flexibility and some pretty advanced fine grained logging techniques.
 *
 * Note that when compiler optimizations are enabled (as they are for your release builds),
 * the log messages above your logging threshold will automatically be compiled out.
 *
 * (If the compiler sees ddLogLevel declared as a constant, the compiler simply checks to see if the 'if' statement
 *  would execute, and if not it strips it from the binary.)
 *
 * We also define shorthand versions for asynchronous and synchronous logging.
 **/

#define YYIM_LOG_MAYBE(async, lvl, flg, ctx, fnct, frmt, ...) \
do { if(lvl & flg) YYIM_LOG_MACRO(async, lvl, flg, ctx, nil, fnct, frmt, ##__VA_ARGS__); } while(0)

#define YYIM_LOG_OBJC_MAYBE(async, lvl, flg, ctx, frmt, ...) \
YYIM_LOG_MAYBE(async, lvl, flg, ctx, sel_getName(_cmd), frmt, ##__VA_ARGS__)

#define YYIM_LOG_C_MAYBE(async, lvl, flg, ctx, frmt, ...) \
YYIM_LOG_MAYBE(async, lvl, flg, ctx, __FUNCTION__, frmt, ##__VA_ARGS__)

#define  YYIM_SYNC_LOG_OBJC_MAYBE(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_OBJC_MAYBE( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

#define YYIM_ASYNC_LOG_OBJC_MAYBE(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_OBJC_MAYBE(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

#define  YYIM_SYNC_LOG_C_MAYBE(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_C_MAYBE( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

#define YYIM_ASYNC_LOG_C_MAYBE(lvl, flg, ctx, frmt, ...) \
YYIM_LOG_C_MAYBE(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

/**
 * Define versions of the macros that also accept tags.
 *
 * The DDLogMessage object includes a 'tag' ivar that may be used for a variety of purposes.
 * It may be used to pass custom information to loggers or formatters.
 * Or it may be used by 3rd party extensions to the framework.
 *
 * Thes macros just make it a little easier to extend logging functionality.
 **/

#define YYIM_LOG_OBJC_TAG_MACRO(async, lvl, flg, ctx, tag, frmt, ...) \
YYIM_LOG_MACRO(async, lvl, flg, ctx, tag, sel_getName(_cmd), frmt, ##__VA_ARGS__)

#define YYIM_LOG_C_TAG_MACRO(async, lvl, flg, ctx, tag, frmt, ...) \
YYIM_LOG_MACRO(async, lvl, flg, ctx, tag, __FUNCTION__, frmt, ##__VA_ARGS__)

#define YYIM_LOG_TAG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
do { if(lvl & flg) YYIM_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define YYIM_LOG_OBJC_TAG_MAYBE(async, lvl, flg, ctx, tag, frmt, ...) \
YYIM_LOG_TAG_MAYBE(async, lvl, flg, ctx, tag, sel_getName(_cmd), frmt, ##__VA_ARGS__)

#define YYIM_LOG_C_TAG_MAYBE(async, lvl, flg, ctx, tag, frmt, ...) \
YYIM_LOG_TAG_MAYBE(async, lvl, flg, ctx, tag, __FUNCTION__, frmt, ##__VA_ARGS__)

/**
 * Define the standard options.
 *
 * We default to only 4 levels because it makes it easier for beginners
 * to make the transition to a logging framework.
 *
 * More advanced users may choose to completely customize the levels (and level names) to suite their needs.
 * For more information on this see the "Custom Log Levels" page:
 * https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/CustomLogLevels
 *
 * Advanced users may also notice that we're using a bitmask.
 * This is to allow for custom fine grained logging:
 * https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/FineGrainedLogging
 *
 * -- Flags --
 *
 * Typically you will use the LOG_LEVELS (see below), but the flags may be used directly in certain situations.
 * For example, say you have a lot of warning log messages, and you wanted to disable them.
 * However, you still needed to see your error and info log messages.
 * You could accomplish that with the following:
 *
 * static const int ddLogLevel = LOG_FLAG_ERROR | LOG_FLAG_INFO;
 *
 * When LOG_LEVEL_DEF is defined as ddLogLevel.
 *
 * Flags may also be consulted when writing custom log formatters,
 * as the DDLogMessage class captures the individual flag that caused the log message to fire.
 *
 * -- Levels --
 *
 * Log levels are simply the proper bitmask of the flags.
 *
 * -- Booleans --
 *
 * The booleans may be used when your logging code involves more than one line.
 * For example:
 *
 * if (LOG_VERBOSE) {
 *     for (id sprocket in sprockets)
 *         DDLogVerbose(@"sprocket: %@", [sprocket description])
 * }
 *
 * -- Async --
 *
 * Defines the default asynchronous options.
 * The default philosophy for asynchronous logging is very simple:
 *
 * Log messages with errors should be executed synchronously.
 *     After all, an error just occurred. The application could be unstable.
 *
 * All other log messages, such as debug output, are executed asynchronously.
 *     After all, if it wasn't an error, then it was just informational output,
 *     or something the application was easily able to recover from.
 *
 * -- Changes --
 *
 * You are strongly discouraged from modifying this file.
 * If you do, you make it more difficult on yourself to merge future bug fixes and improvements from the project.
 * Instead, create your own MyLogging.h or ApplicationNameLogging.h or CompanyLogging.h
 *
 * For an example of customizing your logging experience, see the "Custom Log Levels" page:
 * https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/CustomLogLevels
 **/

#define YYIM_LOG_FLAG_ERROR    (1 << 0)  // 0...00001
#define YYIM_LOG_FLAG_WARN     (1 << 1)  // 0...00010
#define YYIM_LOG_FLAG_INFO     (1 << 2)  // 0...00100
#define YYIM_LOG_FLAG_DEBUG    (1 << 3)  // 0...01000
#define YYIM_LOG_FLAG_VERBOSE  (1 << 4)  // 0...10000

#define YYIM_LOG_LEVEL_OFF        0
#define YYIM_LOG_LEVEL_ERROR      (YYIM_LOG_LEVEL_OFF | YYIM_LOG_FLAG_ERROR)               // 0...00001
#define YYIM_LOG_LEVEL_WARN       (YYIM_LOG_LEVEL_OFF | YYIM_LOG_FLAG_ERROR | YYIM_LOG_FLAG_WARN)               // 0...00011
#define YYIM_LOG_LEVEL_INFO       (YYIM_LOG_LEVEL_OFF | YYIM_LOG_FLAG_ERROR | YYIM_LOG_FLAG_WARN | YYIM_LOG_FLAG_INFO)                // 0...00111
#define YYIM_LOG_LEVEL_DEBUG      (YYIM_LOG_LEVEL_OFF | YYIM_LOG_FLAG_ERROR | YYIM_LOG_FLAG_WARN | YYIM_LOG_FLAG_INFO | YYIM_LOG_FLAG_DEBUG)               // 0...01111
#define YYIM_LOG_LEVEL_VERBOSE    (YYIM_LOG_LEVEL_OFF | YYIM_LOG_FLAG_ERROR | YYIM_LOG_FLAG_WARN | YYIM_LOG_FLAG_INFO | YYIM_LOG_FLAG_DEBUG | YYIM_LOG_FLAG_VERBOSE)            // 0...11111

#define YYIM_LOG_ERROR           (YYIM_LOG_LEVEL_DEF & YYIM_LOG_FLAG_ERROR)
#define YYIM_LOG_WARN            (YYIM_LOG_LEVEL_DEF & YYIM_LOG_FLAG_WARN)
#define YYIM_LOG_INFO            (YYIM_LOG_LEVEL_DEF & YYIM_LOG_FLAG_INFO)
#define YYIM_LOG_DEBUG           (YYIM_LOG_LEVEL_DEF & YYIM_LOG_FLAG_DEBUG)
#define YYIM_LOG_VERBOSE         (YYIM_LOG_LEVEL_DEF & YYIM_LOG_FLAG_VERBOSE)

#define YYIM_LOG_ASYNC_ENABLED YES

#define YYIM_LOG_ASYNC_ERROR    ( NO && YYIM_LOG_ASYNC_ENABLED)
#define YYIM_LOG_ASYNC_WARN     (YES && YYIM_LOG_ASYNC_ENABLED)
#define YYIM_LOG_ASYNC_INFO     (YES && YYIM_LOG_ASYNC_ENABLED)
#define YYIM_LOG_ASYNC_DEBUG    (YES && YYIM_LOG_ASYNC_ENABLED)
#define YYIM_LOG_ASYNC_VERBOSE  (YES && YYIM_LOG_ASYNC_ENABLED)

#define YYIMLogError(frmt, ...)   YYIM_LOG_OBJC_MAYBE(YYIM_LOG_ASYNC_ERROR,   YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define YYIMLogWarn(frmt, ...)    YYIM_LOG_OBJC_MAYBE(YYIM_LOG_ASYNC_WARN,    YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define YYIMLogInfo(frmt, ...)    YYIM_LOG_OBJC_MAYBE(YYIM_LOG_ASYNC_INFO,    YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define YYIMLogDebug(frmt, ...)   YYIM_LOG_OBJC_MAYBE(YYIM_LOG_ASYNC_DEBUG,   YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define YYIMLogVerbose(frmt, ...) YYIM_LOG_OBJC_MAYBE(YYIM_LOG_ASYNC_VERBOSE, YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

#define YYIMLogCError(frmt, ...)   YYIM_LOG_C_MAYBE(YYIM_LOG_ASYNC_ERROR,   YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define YYIMLogCWarn(frmt, ...)    YYIM_LOG_C_MAYBE(YYIM_LOG_ASYNC_WARN,    YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define YYIMLogCInfo(frmt, ...)    YYIM_LOG_C_MAYBE(YYIM_LOG_ASYNC_INFO,    YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define YYIMLogCDebug(frmt, ...)   YYIM_LOG_C_MAYBE(YYIM_LOG_ASYNC_DEBUG,   YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define YYIMLogCVerbose(frmt, ...) YYIM_LOG_C_MAYBE(YYIM_LOG_ASYNC_VERBOSE, YYIM_LOG_LEVEL_DEF, YYIM_LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

@interface YYIMLogger : NSObject

+ (void)initLogger;

+ (int)logLevel;

+ (void)setLogLevel:(int)logLevel;

/**
 * Logging Primitive.
 *
 * This method is used by the macros above.
 * It is suggested you stick with the macros as they're easier to use.
 **/

+ (void)log:(BOOL)synchronous
      level:(int)level
       flag:(int)flag
    context:(int)context
       file:(const char *)file
   function:(const char *)function
       line:(int)line
        tag:(id)tag
     format:(NSString *)format, ... __attribute__ ((format (__NSString__, 9, 10)));

@end
