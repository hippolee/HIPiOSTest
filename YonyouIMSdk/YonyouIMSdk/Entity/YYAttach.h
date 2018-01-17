//
//  YYAttach.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YYIMAttachDownloadState) {
    kYYIMAttachDownloadNo,
    kYYIMAttachDownloadIng,
    kYYIMAttachDownloadFaild,
    kYYIMAttachDownloadSuccess
};

typedef NS_ENUM(NSInteger, YYIMAttachUploadState) {
    kYYIMAttachUploadNo,
    kYYIMAttachUploadIng,
    kYYIMAttachUploadFaild,
    kYYIMAttachUploadSuccess
};

@interface YYAttach : NSObject

@property NSString *attachId;

@property NSString *uploadKey;

@property NSString *attachMD5;

@property YYIMAttachUploadState uploadState;

@property YYIMAttachDownloadState downloadState;

@property NSString *attachPath;

@property NSString *attachExt;

@property long long attachSize;

@end
