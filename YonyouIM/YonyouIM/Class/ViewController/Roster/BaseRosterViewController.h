//
//  BaseRosterViewController.h
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"

@interface BaseRosterViewController : YYIMBaseViewController<UIGestureRecognizerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *rosterTableView;

@property (retain, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (retain, nonatomic) NSArray *rosterArray;

@property (retain, nonatomic) NSArray *letterArray;

@property (retain, nonatomic) NSDictionary *dataDic;

@property (retain, nonatomic) NSString *keyword;

- (void)loadData;

- (void)filterRosters;

- (YYRoster *)getDataWithIndexPath:(NSIndexPath *)indexPath;

@end
