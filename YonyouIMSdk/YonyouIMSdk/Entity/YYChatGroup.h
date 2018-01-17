//
//  YYChatGroup.h
//  YonyouIM
//
//  Created by litfb on 15/1/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  群组
 */
@interface YYChatGroup : NSObject

/**
 *  群组Id
 */
@property NSString *groupId;

/**
 *  群组名称
 */
@property NSString *groupName;

/**
 *  群组标签
 */
@property NSArray *groupTag;

/**
 *  是否保存到通讯录
 */
@property BOOL isCollect;

/**
 *  是否超级群
 */
@property BOOL isSuper;

/**
 *  群成员数量
 */
@property NSInteger memberCount;

/**
 *  是否管理员
 */
@property BOOL isOwner;

/**
 *  群变更时间
 */
@property NSTimeInterval ts;

@end
