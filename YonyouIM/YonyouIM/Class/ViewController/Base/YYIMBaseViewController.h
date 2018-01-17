//
//  YYIMBaseViewController.h
//  YonyouIM
//
//  Created by litfb on 15/6/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"
#import "BaseViewController.h"

@interface YYIMBaseViewController : BaseViewController<YYIMChatDelegate>

- (BOOL)shouldKeepDelegate;

@end
