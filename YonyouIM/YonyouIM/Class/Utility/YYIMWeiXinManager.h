//
//  YYIMWeiXinManager.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YYIMWeiXinManager : NSObject

/**
 *  向微信发送消息
 *
 *  @param scene 类型（WXSceneSession = 0,聊天界面；WXSceneTimeline = 1,朋友圈；WXSceneFavorite = 2, 收藏
 *  @param message
 */
+ (void)sendWinXinText:(NSString *)message scene:(int)scene;

+ (void)sendWinXinURL:(NSString *)url sence:(int)scene title:(NSString *) title message:(NSString *)message image:(UIImage *)image;

@end
