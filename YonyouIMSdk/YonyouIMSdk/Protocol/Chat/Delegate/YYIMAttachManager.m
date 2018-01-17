//
//  YYIMAttachManager.m
//  YonyouIMSdk
//
//  Created by litfb on 15/7/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMAttachManager.h"
#import "JUMPFramework.h"
#import "YYIMStringUtility.h"
#import "YYIMHttpUtility.h"
#import "YYIMResourceUtility.h"
#import "YYIMPanDBHelper.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"

@interface YYIMAttachManager ()

@property (retain, atomic) YMGCDMulticastDelegate<YYIMAttachProgressDelegate> *progressDelegate;

@end

@implementation YYIMAttachManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)didActivate {
    self.progressDelegate = (YMGCDMulticastDelegate<YYIMAttachProgressDelegate> *)[[YMGCDMulticastDelegate alloc] init];
}

- (void)addAttachProgressDelegate:(id<YYIMAttachProgressDelegate>)delegate {
    [self.progressDelegate removeDelegate:delegate];
    [self.progressDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)downloadAttach:(NSString *)attachId targetPath:(NSString *)targetPath imageType:(YYIMImageType)imageType thumbnail:(BOOL)thumbnail fileSize:(long long)fileSize progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete {
    
    NSString *attachKey;
    
    if (thumbnail) {
        //资源微略图
        attachKey = [YYIMResourceUtility getThumbAttachKey:attachId];
    } else {
        attachKey = [YYIMResourceUtility getAttachKey:attachId imageType:imageType];
    }
    
    YYAttach *state = [self getAttachState:attachKey];
    switch ([state downloadState]) {
        case kYYIMAttachDownloadSuccess:
            if (downloadComplete) {
                downloadComplete(YES, [state attachPath], nil);
            }
            return;
        case kYYIMAttachDownloadIng:
            return;
        default:
            break;
    }
    // 保存状态
    [[YYIMPanDBHelper sharedInstance] updateAttachDownloadState:attachKey downloadState:kYYIMAttachDownloadIng path:nil];
    
    // 文件路径
    NSString *fullPath = [YYIMResourceUtility fullPathWithResourceRelaPath:targetPath];
    // 下载资源
    [YYIMHttpUtility downloadResourceWithAttachId:attachId targetPath:fullPath imageType:imageType thumbnail:thumbnail fileSize:fileSize progress:^(float progress, long long totalSize, long long readedSize) {
        if (downloadProgress) {
            downloadProgress(progress, totalSize, readedSize);
        }
        [self.progressDelegate attachDownloadProgress:progress totalSize:totalSize readedSize:readedSize withAttachKey:attachKey];
    } completion:^(NSInteger resultCode, YYIMError *error, id responseObject) {
        BOOL result = NO;
        if (resultCode < 300 && !error) {
            [[YYIMPanDBHelper sharedInstance] updateAttachDownloadState:attachKey downloadState:kYYIMAttachDownloadSuccess path:targetPath];
            result = YES;
        } else {
            [[YYIMPanDBHelper sharedInstance] updateAttachDownloadState:attachKey downloadState:kYYIMAttachDownloadFaild path:nil];
            [error setErrorCode:resultCode];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [error setErrorMsg:[(NSDictionary *)responseObject objectForKey:@"message"]];
            }
        }
        [self.progressDelegate attachDownloadComplete:result withAttachKey:attachKey error:error];
        if (downloadComplete) {
            downloadComplete(result, targetPath, error);
        }
    }];
}

- (void)uploadAttach:(NSString *)relaAttachPath fileName:(NSString *)fileName receiver:(NSString *)receiver mediaType:(YYIMUploadMediaType)mediaType isOriginal:(BOOL)isOriginal complete:(YYIMAttachUploadCompleteBlock)complete {
    // 文件管理器
    NSString *fullPath = [YYIMResourceUtility fullPathWithResourceRelaPath:relaAttachPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    long long fileSize = 0;
    if ([fileManager fileExistsAtPath:fullPath]) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
        fileSize = [fileAttributes fileSize];
    } else {
        YYIMLogError(@"file:%@ not exists!", relaAttachPath);
        if (complete) {
            complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_FILE_NOT_FOUND errorMessage:@"file not found"]);
        }
    }
    if (!fileName) {
        fileName = [fullPath lastPathComponent];
    }
    
    YYAttach *attach = [[YYAttach alloc] init];
    [attach setUploadKey:[NSString stringWithFormat:@"%@%@", [[YYIMConfig sharedInstance] getFullUser], [[NSUUID UUID] UUIDString]]];
    [attach setAttachPath:relaAttachPath];
    [attach setAttachMD5:[YYIMResourceUtility getFileMD5WithPath:fullPath]];
    [attach setAttachSize:fileSize];
    [attach setAttachExt:[relaAttachPath pathExtension]];
    [attach setUploadState:kYYIMAttachUploadNo];
    [[YYIMPanDBHelper sharedInstance] createAttach:attach];
    
    [YYIMHttpUtility uploadResourceWithSourcePath:fullPath fileName:fileName fileSize:fileSize receiver:receiver mediaType:mediaType isOriginal:isOriginal completion:^(NSInteger resultCode, YYIMError *error, id responseObject) {
        if (resultCode == 200) {
            NSString *attachId = [(NSDictionary *)responseObject objectForKey:@"attachId"];
            [attach setAttachId:attachId];
            [[YYIMPanDBHelper sharedInstance] updateAttachUploadState:[attach uploadKey] attachId:attachId uploadState:kYYIMAttachUploadSuccess];
            complete(YES, attach, nil);
        } else {
            [[YYIMPanDBHelper sharedInstance] updateAttachUploadState:[attach uploadKey] attachId:nil uploadState:kYYIMAttachUploadFaild];
            [error setErrorCode:resultCode];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [error setErrorMsg:[(NSDictionary *)responseObject objectForKey:@"message"]];
            }
            complete(NO, nil, error);
        }
    }];
}

- (YYAttach *)getAttachState:(NSString *)attachId {
    return [self getAttachState:attachId imageType:kYYIMImageTypeNormal];
}

- (YYAttach *)getAttachState:(NSString *)attachId imageType:(YYIMImageType)imageType {
    NSString *attachKey = [YYIMResourceUtility getAttachKey:attachId imageType:imageType];
    return [[YYIMPanDBHelper sharedInstance] getAttachWithId:attachKey];
}

@end
