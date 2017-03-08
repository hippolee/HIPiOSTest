//
//  MessageVersionUtility.h
//  litfb_test_cmdtool
//
//  Created by litfb on 16/3/10.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageVersionUtility : NSObject

+ (instancetype)sharedInstance;

- (void)attemptIncreaseMessageVersion;

- (void)handleMessageVersion:(NSInteger)version;

- (void)setMessageVersionNumber:(NSInteger)version;

- (NSInteger)getMessageVersionNumber;

@end
