//
//  YYNetMeetingInfo.m
//  YonyouIMSdk
//
//  Created by litfb on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYNetMeetingInfo.h"
#import "YYIMChat.h"

@implementation YYNetMeetingInfo

- (YYUser *)moderatorUser {
    if (!_moderatorUser) {
        _moderatorUser = [[YYIMChat sharedInstance].chatManager getUserWithId:self.moderator];
    }
    return _moderatorUser;
}

- (NSString *)moderatorName {
    return [[self moderatorUser] userName];
}

- (BOOL)isReservationNotice {
    switch (self.state) {
        case kYYIMNetMeetingStateIng:
        case kYYIMNetMeetingStateEnd:
            return NO;
        default:
            return YES;
    }
}

@end
