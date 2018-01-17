//
//  MemberSelViewController.h
//  YonyouIM
//
//  Created by litfb on 15/6/10.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "YYIMChatHeader.h"

@protocol YMMemberSelDelegate;

@interface MemberSelViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSString *identifiy;

@property (retain, nonatomic) NSString *groupId;

@property (weak, nonatomic) id<YMMemberSelDelegate> delegate;

@end

@protocol YMMemberSelDelegate <NSObject>

@optional

- (BOOL)allowMultipleMemberSelect:(MemberSelViewController *)controller;

- (void)memberSelController:(MemberSelViewController *)controller identifiy:(NSString *)identifiy didSelMembers:(NSArray *)memberArray;

- (void)memberSelController:(MemberSelViewController *)controller identifiy:(NSString *)identifiy didSelMember:(YYChatGroupMember *)member;

@end