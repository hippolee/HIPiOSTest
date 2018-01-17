//
//  YYChatGroupMember.m
//  YonyouIM
//
//  Created by litfb on 15/1/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYChatGroupMember.h"
#import "YYIMStringUtility.h"

@implementation YYChatGroupMember

- (NSString *)memberName {
    if (self.user) {
        if (![YYIMStringUtility isEmpty:[self.user userName]]) {
            return [self.user userName];
        }
    }
    return _memberName;
}

- (NSString *)getMemberPhoto {
    if (self.user) {
        return [self.user getUserPhoto];
    }
    return [YYIMStringUtility genFullPathRes:[self memberPhoto]];
}

@end
