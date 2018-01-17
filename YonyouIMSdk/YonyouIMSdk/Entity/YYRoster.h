//
//  YYRoster.h
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "YYUser.h"

#define YYIM_ROSTER_SUBSCRIPTION_BOTH       @"both"
#define YYIM_ROSTER_SUBSCRIPTION_NONE       @"none"
#define YYIM_ROSTER_SUBSCRIPTION_FAVORITE   @"favorite"

#define YYIM_ROSTER_ASK_NONE            0
#define YYIM_ROSTER_ASK_SUB             1

#define YYIM_ROSTER_RECV_NONE           0
#define YYIM_ROSTER_RECV_SUB            1

@interface YYRoster : NSObject

@property (nonatomic) NSString *rosterId;
@property (nonatomic) NSString *rosterAlias;
@property (nonatomic) NSString *rosterPhoto;
@property (nonatomic) NSArray *groups;
@property (nonatomic) NSString *subscription;
@property (nonatomic) NSInteger ask;
@property (nonatomic) NSInteger recv;

//好友的tag
@property (nonatomic, strong) NSArray *rosterTag;

@property (nonatomic, readonly) NSString *rosterAliasPinyin;
@property (nonatomic, readonly) NSString *firstLetters;

/** 在线状态 */
@property NSInteger androidState;
@property NSInteger iosState;
@property NSInteger webimState;
@property NSInteger desktopState;

@property NSString *firstLetter;

@property (retain, nonatomic) YYUser *user;

- (NSString *)getRosterPhoto;

- (NSString *)getFirstLetter;

- (BOOL)isOnline;

- (BOOL)hasTag:(NSString *)tag;

- (NSString *)groupStr;

- (void)setGroupsWithStr:(NSString *)groupStr;

@end
