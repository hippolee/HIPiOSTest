//
//  InviteViewController.h
//  YonyouIM
//
//  Created by litfb on 15/4/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseRosterViewController.h"
#import "YMGlobalInviteDelegate.h"

@interface InviteViewController : BaseRosterViewController<UITableViewDataSource, UITableViewDelegate>

@property NSString *actionName;

// delegate
@property (nonatomic, weak) id<YMGlobalInviteDelegate> inviteDelegate;

@end
