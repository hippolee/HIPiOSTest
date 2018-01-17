//
//  YYIMChatDefs.h
//  YonyouIMSdk
//
//  Created by litfb on 15/9/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#ifndef YonyouIMSdk_YYIMChatDefs_h
#define YonyouIMSdk_YYIMChatDefs_h

typedef NS_ENUM(NSInteger, YYIMClientType) {
    kYYIMClientTypeAndroid,
    kYYIMClientTypeIOS,
    kYYIMClientTypeWeb,
    kYYIMClientTypePC,
    kYYIMClientTypeUnknown
};

typedef NS_ENUM(NSInteger, YYIMFileSet) {
    kYYIMFileSetPublic,
    kYYIMFileSetGroup,
    kYYIMFileSetPerson
};

typedef NS_ENUM(NSInteger, YYIMRosterState) {
    // 离线
    kYYIMRosterStateOffline,
    // 在线
    kYYIMRosterStateChat,
    // 隐身
    kYYIMRosterStateUnavaliable,
    // 离开
    kYYIMRosterStateAway,
    // 忙碌
    kYYIMRosterStateDnd
};

#define YM_CLIENT_IOS               @"ios"
#define YM_CLIENT_ANDROID           @"android"
#define YM_CLIENT_WEBIM             @"web"
#define YM_CLIENT_DESKTOP           @"pc"

#define YM_ORG_ROOT_ID              @"1"

#define YM_FILE_ROOT_ID             @"root"

#endif
