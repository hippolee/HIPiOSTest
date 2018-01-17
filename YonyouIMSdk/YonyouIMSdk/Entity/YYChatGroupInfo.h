//
//  YYChatGroupInfo.h
//  YonyouIMSdk
//
//  Created by litfb on 16/3/16.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYChatGroup.h"
#import "YYChatGroupMember.h"

@interface YYChatGroupInfo : NSObject

@property BOOL isJoindGroup;

@property BOOL isValidGroup;

@property (retain, nonatomic) YYChatGroup *group;

@property (retain, nonatomic) NSArray *memberArray;

@property NSInteger maxMemberCount;

@end
