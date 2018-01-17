//
//  BaseRosterViewController.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "BaseRosterViewController.h"
#import "NormalTableViewCell.h"
#import "YYIMUIDefs.h"
#import "YYIMUtility.h"
#import "YYIMColorHelper.h"
#import "TableBackgroundView.h"
#import "AddRosterViewController.h"

@interface BaseRosterViewController ()

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@end

@implementation BaseRosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 索引样式
    if (YYIM_iOS7) {
        [self.rosterTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    }
    [self.rosterTableView setSectionIndexColor:UIColorFromRGB(0xb6b6b6)];
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.rosterTableView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTap:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer setCancelsTouchesInView:YES];
    [self.rosterTableView addGestureRecognizer:tapGestureRecognizer];
    self.tapGestureRecognizer = tapGestureRecognizer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 加载数据
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark uitableview

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self tableTap:nil];
}

#pragma mark searchbar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.keyword = searchText;
    [self filterRosters];
}

#pragma mark yyimchat delegate

- (void)didRosterChange {
    [self loadData];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.searchBar isFirstResponder]) {
        return YES;
    }
    return NO;
}

#pragma mark util

- (void)addRosterAction:(id)sender {
    AddRosterViewController *addRosterViewController = [[AddRosterViewController alloc] initWithNibName:@"AddRosterViewController" bundle:nil];
    [self.navigationController pushViewController:addRosterViewController animated:YES];
}

- (void)tableTap:(id)sender {
    [self.searchBar resignFirstResponder];
}

- (void)loadData {
    self.rosterArray = [[YYIMChat sharedInstance].chatManager getAllRosterWithAsk];
    [self filterRosters];
    
    if (self.rosterArray.count > 0) {
        if (self.emptyBgView) {
            [self.emptyBgView removeFromSuperview];
        }
    } else {
        if (!self.emptyBgView) {
            TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"还没有好友哦" type:kYYIMTableBackgroundTypeNormal];
            [self.view insertSubview:emptyBgView aboveSubview:self.rosterTableView];
            
            [emptyBgView addBtnTarget:self action:@selector(addRosterAction:) forControlEvents:UIControlEventTouchUpInside];
            self.emptyBgView = emptyBgView;
            [self.emptyBgView addGestureRecognizer:self.tapGestureRecognizer];
        }
    }
}

- (void)filterRosters {
    if ([YYIMUtility isEmptyString:self.keyword]) {
        [self generateDataDic:self.rosterArray];
    } else {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"rosterAlias CONTAINS[cd] %@ OR rosterAliasPinyin CONTAINS[cd] %@ OR firstLetters CONTAINS[cd] %@", self.keyword, self.keyword, self.keyword];
        NSArray *array = [self.rosterArray filteredArrayUsingPredicate:pre];
        [self generateDataDic:array];
    }
}

- (void)generateDataDic:(NSArray *)rosterArray {
    NSMutableArray *letterArray = [NSMutableArray array];
    [letterArray addObject:UITableViewIndexSearch];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    for (YYRoster *roster in rosterArray) {
        if (![letterArray containsObject:[roster getFirstLetter]]) {
            [letterArray addObject:[roster getFirstLetter]];
        }
        NSMutableArray *array = [dataDic objectForKey:[roster getFirstLetter]];
        if (!array) {
            array = [NSMutableArray array];
            [dataDic setObject:array forKey:[roster firstLetter]];
        }
        [array addObject:roster];
    }
    self.letterArray = letterArray;
    self.dataDic = dataDic;
    [self.rosterTableView reloadData];
}

- (YYRoster *)getDataWithIndexPath:(NSIndexPath *) indexPath {
    NSArray *array = [self.dataDic objectForKey:[self.letterArray objectAtIndex:indexPath.section]];
    YYRoster *roster = [array objectAtIndex:indexPath.row];
    return roster;
}

@end
