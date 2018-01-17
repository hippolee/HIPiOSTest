//
//  YYIMNetMeetingManagerViewController.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"

@interface YYIMNetMeetingManagerViewController : YYIMBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *channelId;

@end
