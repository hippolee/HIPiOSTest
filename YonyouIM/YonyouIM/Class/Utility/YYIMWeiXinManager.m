//
//  YYIMWeiXinManager.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMWeiXinManager.h"
#import "WXApi.h"
#import "WXApiObject.h"

@implementation YYIMWeiXinManager

+ (void)sendWinXinText:(NSString *)message scene:(int)scene {
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = message;
    req.bText = YES;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

+ (void)sendWinXinURL:(NSString *)url sence:(int)scene title:(NSString *) title message:(NSString *)message image:(UIImage *)image {
    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = title;
    msg.description = message;
    [msg setThumbImage:image];
    
    WXWebpageObject *object = [WXWebpageObject object];
    object.webpageUrl = url;
    
    msg.mediaObject = object;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

@end
