//
//  HIPPullUpViewController.m
//  litfb_test
//
//  Created by yanghaoc on 15/12/31.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "HIPPullUpViewController.h"
#import "HIPUtility.h"
#import "HIPRefreshView.h"

@interface HIPPullUpViewController ()

@property (retain, nonatomic) NSMutableArray *dataArray;

@end

@implementation HIPPullUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"上拉加载"];
    // 去掉多余分隔线
    [HIPUtility setExtraCellLineHidden:self.tableView];
    // 集成上拉加载更多
    [self setupPullUpLoadMore];
    // 初始化数据
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark setup

- (void)setupPullUpLoadMore {
    HIPRefreshView *footerView = [[HIPRefreshView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 40)];
    [footerView setHidden:YES];
    [self.tableView setTableFooterView:footerView];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果tableView还没有数据，就直接返回
    if (self.dataArray.count < 20 || ![self.tableView.tableFooterView isHidden]) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    // 当最后一个cell完全显示在眼前时，contentOffset的y值
    CGFloat judgeOffsetY = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height - self.tableView.tableFooterView.frame.size.height;
    if (offsetY >= judgeOffsetY) { // 最后一个cell完全进入视野范围内
        // 显示footer
        self.tableView.tableFooterView.hidden = NO;
        
        // 加载更多数据
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.0f];
    }
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

- (void)loadMoreData {
    NSString *dataId = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    NSMutableArray *array = [NSMutableArray array];
    long index = [self.dataArray count];
    for (long i = index; i < index + 20; i++) {
        [array addObject:[NSString stringWithFormat:@"data:%@:%ld", dataId, i]];
    }
    [self.dataArray addObjectsFromArray:array];
    
    // 刷新表格
    [self.tableView reloadData];
    // 结束刷新(隐藏footer)
    [self.tableView.tableFooterView setHidden:YES];
}

@end
