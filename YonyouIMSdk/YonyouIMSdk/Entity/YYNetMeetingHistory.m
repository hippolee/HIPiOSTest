//
//  YYNetMeetingRecord.m
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/4/26.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYNetMeetingHistory.h"
#import "YYIMChat.h"

@implementation YYNetMeetingHistory

- (YYUser *)moderatorUser {
    if (!_moderatorUser) {
        _moderatorUser = [[YYIMChat sharedInstance].chatManager getUserWithId:self.moderator];
    }
    return _moderatorUser;
}

- (NSString *)moderatorName {
    return [[self moderatorUser] userName];
}

@end
