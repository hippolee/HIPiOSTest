//
//  HIPDropRefreshViewController.m
//  litfb_test
//
//  Created by litfb on 15/12/30.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "HIPDropRefreshViewController.h"
#import "HIPUtility.h"

@interface HIPDropRefreshViewController ()

@property (weak, nonatomic) UIRefreshControl *control;

@property (retain, nonatomic) NSMutableArray *dataArray;

@end

@implementation HIPDropRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"下拉刷新"];
    // 去掉多余分隔线
    [HIPUtility setExtraCellLineHidden:self.tableView];
    // 设置下拉刷新
    [self setupPullDownRefresh];
    // 初始化数据
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark refresh

- (void)setupPullDownRefresh {
    // 添加刷新控件
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
    self.control = control;
}

- (void)refreshStateChange:(id)sender {
    [self performSelector:@selector(didLoadData:) withObject:nil afterDelay:0.5f];
}

- (void)didLoadData:(id)sender {
    // 重新初始化数据
    [self initData];
    // 刷新表格
    [self.tableView reloadData];
    // 结束刷新
    [self.control endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableViewIdentifier = @"PullRefreshTableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    
    [[cell textLabel] setText:[self.dataArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark private

- (void)initData {
    NSString *dataId = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"data:%@:%d", dataId, i]];
    }
    self.dataArray = array;
}

@end
