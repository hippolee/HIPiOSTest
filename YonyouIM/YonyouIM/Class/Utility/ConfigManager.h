//
//  ConfigManager.h
//  YonyouIM
//
//  Created by litfb on 16/4/13.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

+ (instancetype)sharedManager;

- (void)sdkConfig;

- (void)alphaSettings;

- (void)graySettings;

- (void)betaSettings;

#pragma settings
// IM Server
- (NSString *)getSettingIMServer;

- (void)setSettingIMServer:(NSString *)imServer;

// IM Server端口
- (NSInteger)getSettingIMServerPort;

- (void)setSettingIMServerPort:(NSInteger)serverPort;

// IM Server SSL端口
- (NSInteger)getSettingIMServerSSLPort;

- (void)setSettingIMServerSSLPort:(NSInteger)serverPort;

// Enable ssl
- (BOOL)isSettingIMServerEnableSSL;

- (void)setSettingIMServerEnableSSL:(BOOL)enable;

// IM RestServer
- (NSString *)getSettingIMRestServer;

- (void)setSettingIMRestServer:(NSString *)server;

// IM RestServer https
- (BOOL)isSettingIMRestServerHTTPS;

- (void)setSettingIMRestServerHTTPS:(BOOL)isHTTPS;

// 资源上传Server
- (NSString *)getSettingResourceUploadServer;

- (void)setSettingResourceUploadServer:(NSString *)uploadServer;

// 资源下载Server
- (NSString *)getSettingResourceDownloadServer;

- (void)setSettingResourceDownloadServer:(NSString *)downloadServer;

// 好友模式是否为收藏
- (BOOL)isSettingRosterCollect;

- (void)setSettingRosterCollect:(BOOL)isCollect;

@end
