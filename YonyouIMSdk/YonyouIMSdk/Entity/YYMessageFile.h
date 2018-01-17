//
//  YYMessageFile.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/6/12.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YYIMFileOwnerType) {
    YYIMFileOwnerTypePersonal,     //个人
    YYIMFileOwnerTypeChatGroup     //群组
};

@interface YYMessageFile : NSObject
// 文件的附件id
@property NSString *attachId;
// 文件上传者
@property NSString *creator;
// 文件名称
@property NSString *fileName;
// 文件大小
@property long long fileSize;
// 文件上传时间
@property NSTimeInterval date;
// 文件所属类型
@property YYIMFileOwnerType ownerType;
// 文件关系者（发送者和接收者）
@property NSString *ownerId;
// 文件类型（普通文件还是图片或者其他类型）
@property NSString *fileType;
// 文件的详细类型（office、压缩文件、图片类型等等）
@property NSString *detailFileType;
// 文件后缀名
@property NSString *suffix;
// 文件阅览url
@property NSURL *filePreviewURL;
// 缩略图url
@property NSURL *thumbImageURL;
// 图片url
@property NSURL *imageURL;

@end
