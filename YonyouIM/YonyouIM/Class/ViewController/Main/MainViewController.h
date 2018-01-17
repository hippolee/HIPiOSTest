//
//  MainViewController.h
//  YonyouIM
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RecentViewController.h"
#import "RecentRosterViewController.h"
#import "MeViewController.h"

@interface MainViewController : UITabBarController

@property (retain, nonatomic) RecentViewController *recentViewController;

@property (retain, nonatomic) RecentRosterViewController *recentRosterViewController;

@property (retain, nonatomic) MeViewController *meViewController;

@end
