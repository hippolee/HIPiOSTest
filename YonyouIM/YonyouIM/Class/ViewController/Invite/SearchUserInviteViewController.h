//
//  SearchUserInviteViewController.h
//  YonyouIM
//
//  Created by yanghao on 15/11/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMGlobalInviteDelegate.h"
#import "YYIMBaseViewController.h"

@interface SearchUserInviteViewController : YYIMBaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property NSString *actionName;

// delegate
@property (nonatomic, weak) id<YMGlobalInviteDelegate> inviteDelegate;

@end
