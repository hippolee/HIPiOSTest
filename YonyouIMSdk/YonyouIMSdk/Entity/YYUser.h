//
//  YYUser.h
//  YonyouIM
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYUser : NSObject

@property NSString *userId;
// 昵称
@property NSString *userName;
// 邮箱
@property NSString *userEmail;
// 部门
@property NSString *userOrg;
@property NSString *userUnit;
@property NSString *userOrgId;
// 头像
@property NSString *userPhoto;
// 手机
@property NSString *userMobile;
// 职位
@property NSString *userTitle;
// 性别
@property NSString *userGender;
// 工号
@property NSString *userNumber;
// 电话
@property NSString *userTelephone;
// 办公地点
@property NSString *userLocation;
// 备注
@property NSString *userDesc;

//用户的tag
@property (nonatomic, strong) NSArray *userTag;


@property NSTimeInterval lastUpdate;

- (NSString *)getUserPhoto;

@end
