//
//  UserViewController.h
//  YonyouIM
//
//  Created by litfb on 15/3/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"

@interface UserViewController : YYIMBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property NSString *userId;

@end
