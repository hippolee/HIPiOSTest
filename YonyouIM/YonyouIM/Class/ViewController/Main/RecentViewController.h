//
//  RecentViewController.h
//  YonyouIM
//
//  Created by litfb on 14/12/18.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseMainTabViewController.h"
#import "YYIMChatHeader.h"
#import "YYIMUIDefs.h"

@interface RecentViewController : BaseMainTabViewController<UITableViewDataSource, UITableViewDelegate>

- (void)responseCellClick:(YMSearchType)searchType index:(NSInteger)index;

@end
