//
//  YYPubAccountMenu.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/6/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYPubAccountMenuItem;

typedef NS_ENUM(NSInteger, YYPubAccountMenuItemType) {
    kYYPubAccountMenuItemTypeCommand,  //公共号指令
    kYYPubAccountMenuItemTypeURL       //群公共号链接
};

@interface YYPubAccountMenu : NSObject
//公共号id
@property NSString *accountId;
//json形式的数据格式
@property NSString *menuJson;
//上一次数据库更新的时间
@property NSTimeInterval lastUpdate;
//服务器数据更新时间
@property NSTimeInterval ts;
//公共号菜单集合
@property (strong, nonatomic) NSArray *menuItemArray;

@end

@interface YYPubAccountMenuItem : NSObject

@property NSString *itemName;

@property (strong, nonatomic) NSArray *itemArray;

@property YYPubAccountMenuItemType itemType;

@property NSString *itemKey;

@property NSString *itemUrl;

@end

