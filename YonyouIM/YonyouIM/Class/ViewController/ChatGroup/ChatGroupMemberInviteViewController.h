//
//  ChatGroupMemberInviteViewController.h
//  YonyouIM
//
//  Created by yanghao on 15/11/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GlobalInviteViewController.h"
#import "YMGlobalInviteDelegate.h"

/**
 *  用于邀请群组中的成员的页面
 */
@interface ChatGroupMemberInviteViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property NSString *groupId;

@property NSString *actionName;

// delegate
@property (nonatomic, weak) id<YMGlobalInviteDelegate> inviteDelegate;

@end
