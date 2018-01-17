//
//  GlobalInviteViewController.h
//  YonyouIM
//
//  Created by yanghao on 15/11/11.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYChatGroup.h"
#import "YYIMBaseViewController.h"
#import "YMGlobalInviteDelegate.h"

@interface GlobalInviteViewController : YYIMBaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property NSString *groupId;

@property NSString *userId;

@property NSString *channelId;

@property NSArray *disableUserIds;

@property NSString *actionName;

//默认认为已经有的数量
@property NSInteger defaultCount;

// delegate
@property (nonatomic, weak) id<GlobalInviteViewControllerDelegate> delegate;

@end

