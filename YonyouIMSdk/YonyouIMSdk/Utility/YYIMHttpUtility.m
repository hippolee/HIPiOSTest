//
//  YYIMHttpUtility.m
//  YonyouIM
//
//  Created by litfb on 15/2/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMHttpUtility.h"
#import "YYIMConfig.h"
#import "YYIMStringUtility.h"
#import "YMAFNetworking.h"
#import "YYIMJUMPHelper.h"
#import "YYIMError.h"
#import "YYIMLogger.h"
#import "YYIMResourceUtility.h"

@implementation YYIMHttpUtility

+ (void)uploadResourceWithSourcePath:(NSString *)sourcePath fileName:(NSString *)fileName fileSize:(long long)fileSize receiver:(NSString *)receiver mediaType:(YYIMUploadMediaType)mediaType isOriginal:(BOOL)isOriginal completion:(void (^)(NSInteger resultCode, YYIMError *error, id responseObject))completion {
    if ([YYIMStringUtility isEmpty:sourcePath]) {
        completion(-1, nil, nil);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result) {
            NSMutableString *fullUrlString = [NSMutableString stringWithString:[[YYIMConfig sharedInstance] getResourceUploadServlet]];
            // token
            [fullUrlString appendFormat:@"?token=%@", [token tokenStr]];
            // 文件名
            [fullUrlString appendFormat:@"&name=%@", fileName];
            // 文件大小
            [fullUrlString appendFormat:@"&size=%@", [NSString stringWithFormat:@"%lld", fileSize]];
            // 文件发送者
            [fullUrlString appendFormat:@"&creator=%@", [[YYIMConfig sharedInstance] getFullUser]];
            // 文件接收者
            if ([YYIMStringUtility isEmpty:receiver]) {
                [fullUrlString appendFormat:@"&receiver=%@", [[YYIMConfig sharedInstance] getJid]];
            } else {
                [fullUrlString appendFormat:@"&receiver=%@", receiver];
            }
            
            switch (mediaType) {
                case kYYIMUploadMediaTypeImage:
                    // 上传图片
                    [fullUrlString appendFormat:@"&mediaType=%@", @"1"];
                    break;
                case kYYIMUploadMediaTypeFile:
                    // 上传文件
                    [fullUrlString appendFormat:@"&mediaType=%@", @"2"];
                    break;
                case kYYIMUploadMediaTypeDoc:
                    // 上传文档
                    [fullUrlString appendFormat:@"&mediaType=%@", @"3"];
                    break;
                case kYYIMUploadMediaTypeMicroVideo:
                    // 上传小视频
                    [fullUrlString appendFormat:@"&mediaType=%@", @"4"];
                    break;
                default:
                    break;
            }
            
            // 是否断点上传
            [fullUrlString appendString:@"&breakpoint=0"];
            // 已上传的文件字节数
            [fullUrlString appendString:@"&uploaded=0"];
            // 客户端上传图片是否压缩
            [fullUrlString appendFormat:@"&original=%@", (isOriginal ? @"1" : @"0")];
            
            YMAFHTTPUploadOperationManager *manager = [YMAFHTTPUploadOperationManager sharedManager];
            [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            [manager.securityPolicy setAllowInvalidCertificates:YES];
            [manager.securityPolicy setValidatesDomainName:NO];
            [manager.requestSerializer setTimeoutInterval:300];
            YYIMLogDebug(@"uploadResourceWithSourcePath:%@", fullUrlString);
            
            [manager POST:fullUrlString parameters:nil constructingBodyWithBlock:^(id<YMAFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:sourcePath] name:@"file" error:nil];
            } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                completion(200, nil, responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                YYIMLogError(@"upload failure%@", [error localizedDescription]);
                NSHTTPURLResponse *response = [error.userInfo objectForKey:YMAFNetworkingOperationFailingURLResponseErrorKey];
                completion([response statusCode], [YYIMError errorWithNSError:error], [error localizedDescription]);
            }];
        } else {
            YYIMLogError(@"getTokenFaild");
            completion(-2, tokenError, nil);
        }
    }];
}

+ (void)downloadResourceWithAttachId:(NSString *)attachId targetPath:(NSString *)targetPath imageType:(YYIMImageType)imageType thumbnail:(BOOL)thumbnail fileSize:(long long)fileSize progress:(YYIMAttachDownloadProgressBlock)progress completion:(void (^)(NSInteger, YYIMError *, id))completion {
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result) {
            long long downloadedFileSize = -1;
            
            if (fileSize > 0) {
                // 文件管理器
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:targetPath]) {
                    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:targetPath error:nil];
                    downloadedFileSize = [fileAttributes fileSize];
                    if (downloadedFileSize >= fileSize) {
                        completion(200, nil, nil);
                        return;
                    }
                }
            }
            
            NSURL *url;
            if ([attachId hasPrefix:@"http"]) {
                url = [NSURL URLWithString:attachId];
            } else {
                NSMutableString *fullUrlString = [NSMutableString stringWithString:[[YYIMConfig sharedInstance] getResourceDownloadServlet]];
                [fullUrlString appendString:[NSString stringWithFormat:@"?token=%@&attachId=%@&downloader=%@", [token tokenStr], attachId, [[YYIMConfig sharedInstance] getFullUser]]];
                
                switch (imageType) {
                    case kYYIMImageTypeOriginal:
                    case kYYIMImageTypeThumb:
                        [fullUrlString appendFormat:@"&mediaType=%ld", (long)imageType];
                        break;
                    default:
                        break;
                }
                
                if (thumbnail) {
                    [fullUrlString appendFormat:@"&thumbnail=true"];
                }
                
                YYIMLogDebug(@"downloadResourceWithAttachId:%@", fullUrlString);
                
                url = [NSURL URLWithString:fullUrlString];
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            //默认配置
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            //AFN3.0+基于封住URLSession的句柄
            YMAFURLSessionManager *manager = [[YMAFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            [manager.securityPolicy setAllowInvalidCertificates:YES];
            [manager.securityPolicy setValidatesDomainName:NO];
            
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
                YYIMLogInfo(@"is download：%f", (float)downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
                if (progress) {
                    progress((float)downloadProgress.completedUnitCount/downloadProgress.totalUnitCount, downloadProgress.totalUnitCount, downloadProgress.completedUnitCount);
                }
            } destination:^NSURL *(NSURL *tempPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:targetPath];
            } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    completion(200, nil, responseObject);
                    return;
                }
                
                completion(400, [YYIMError errorWithNSError:error], responseObject);
            }];
            
            [downloadTask resume];
        } else {
            YYIMLogError(@"getTokenFaild");
            completion(-2, tokenError, nil);
        }
    }];
}

+ (void)updateDeviceToken {
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    NSString *cerName = [[YYIMConfig sharedInstance] getApnsCerName];
    NSString *deviceToken = [[YYIMConfig sharedInstance] getDeviceToken];
    if ([YYIMStringUtility isEmpty:cerName] || [YYIMStringUtility isEmpty:deviceToken] || [YYIMStringUtility isEmpty:user]) {
        return;
    }
    NSString *fullUser = [[YYIMConfig sharedInstance] getFullUser];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:cerName forKey:@"certificateName"];
    [params setObject:deviceToken forKey:@"deviceToken"];
    
    YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
    [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSString *urlString = [[YYIMConfig sharedInstance] getDeviceTokenServlet];
    urlString = [urlString stringByAppendingString:fullUser];
    
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        YYIMLogInfo(@"register deviceToken:%@|%@|%@", fullUser, deviceToken, cerName);
    } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        YYIMLogError(@"register deviceToken error:%@", error.localizedDescription);
    }];
}

+ (void)removeDeviceToken {
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        return;
    }
    NSString *fullUser = [[YYIMConfig sharedInstance] getFullUser];
    
    YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
    [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSString *urlString = [[YYIMConfig sharedInstance] getDeviceTokenServlet];
    urlString = [urlString stringByAppendingString:fullUser];
    
    [manager DELETE:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        YYIMLogInfo(@"remove deviceToken success");
    } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        YYIMLogError(@"remove deviceToken error:%@", error.localizedDescription);
    }];
}

@end
