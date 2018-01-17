//
//  JUMPError.h
//  YonyouIMSdk
//
//  Created by litfb on 15/6/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPPacket.h"

@interface JUMPError : JUMPPacket

/**
 * Converts an JUMPPacket to an JUMPError element in place (no memory allocations or copying)
 **/
+ (JUMPError *)errorFromPacket:(JUMPPacket *)packet;

- (NSInteger)code;

- (NSString *)message;

@end
