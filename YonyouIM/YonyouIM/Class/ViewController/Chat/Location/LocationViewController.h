//
//  LocationViewController.h
//  YonyouIM
//
//  Created by litfb on 15/3/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol YYIMLocationDelegate;

@interface LocationViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<YYIMLocationDelegate> delegate;

@end

@protocol YYIMLocationDelegate <NSObject>

@required

- (void)doSendLocation:(NSString *)imagePath address:(NSString *) address longitude:(CGFloat) longitude latitude:(CGFloat) latitude;

@end