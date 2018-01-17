//
//  AccountInfoViewController.h
//  YonyouIM
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"

@interface AccountInfoViewController : YYIMBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property NSString *accountId;

@end
