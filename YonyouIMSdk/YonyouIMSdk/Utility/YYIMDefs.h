//
//  YYIMDefs.h
//  YonyouIM
//
//  Created by litfb on 14/12/30.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#ifndef YonyouIM_YYIMDefs_h
#define YonyouIM_YYIMDefs_h

#import "YYIMError.h"
#import "YYAttach.h"

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

typedef NS_ENUM(NSInteger, YYIMConnectState) {
    kYYIMConnectStateDisconnect,
    kYYIMConnectStateConnecting,
    kYYIMConnectStateConnected
};

typedef NS_ENUM(NSInteger, YYIMImageType) {
    kYYIMImageTypeNormal,
    kYYIMImageTypeOriginal,
    kYYIMImageTypeThumb
};

//上传时候标示是什么类型
typedef NS_ENUM(NSInteger, YYIMUploadMediaType) {
    kYYIMUploadMediaTypeImage,      //上传的是图片类型
    kYYIMUploadMediaTypeFile,       //上传的是文件类型
    kYYIMUploadMediaTypeDoc,        //上传的是文档类型
    kYYIMUploadMediaTypeMicroVideo  //上传的是短视频类型
};

// 消息的文件类型
typedef NS_ENUM(NSInteger, YYIMMessageFileType) {
    kYYIMMessageFileTypeDefault,    //普通文件
    kYYIMMessageFileTypeImage,      //图片
    kYYIMMessageFileTypeMicroVideo  //小视频
};

typedef void(^YYIMAttachDownloadCompleteBlock)(BOOL result,  NSString *filePath, YYIMError *error);

typedef void(^YYIMAttachUploadCompleteBlock)(BOOL result, YYAttach *attach, YYIMError *error);

typedef void(^YYIMAttachDownloadProgressBlock)(float progress, long long totalSize, long long readedSize);

#define YM_CLIENT_IOS               @"ios"
#define YM_CLIENT_ANDROID           @"android"
#define YM_CLIENT_WEBIM             @"web"
#define YM_CLIENT_DESKTOP           @"pc"

#define YM_CLIENT_CURRENT_VERSION   @"v2.6"

#define YM_NETCONFERENCE_PUBACCOUNT     @"netconference"

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

#define YM_ANONYMOUS_RESOURCE       @"ANONYMOUS"

#define YM_ADMIN_USER               @"admin"

#define YM_ORG_ROOT_ID              @"1"

#define YM_FILE_ROOT_ID             @"root"

#endif
