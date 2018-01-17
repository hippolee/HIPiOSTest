//
//  YYNetMeetingMember.m
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYNetMeetingMember.h"
#import "YYIMStringUtility.h"
#import "YYIMFirstLetterHelper.h"

@implementation YYNetMeetingMember

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
    
    return @"";
}

- (BOOL)isModerator {
    return [self.memberRole isEqualToString:@"moderator"];
}

- (NSString *)getFirstLetter {
    if (!_firstLetter) {
        _firstLetter = [[YYIMFirstLetterHelper firstLetter:[self memberName]] uppercaseString];
    }
    return _firstLetter;
}

@end
