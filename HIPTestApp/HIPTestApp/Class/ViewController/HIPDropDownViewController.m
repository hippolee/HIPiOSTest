//
//  HIPDropDownViewController.m
//  litfb_test
//
//  Created by yanghaoc on 15/12/31.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "HIPDropDownViewController.h"
#import "HIPUtility.h"
#import "HIPRefreshView.h"
#import "HIPTestViewController.h"

@interface HIPDropDownViewController ()

@property (retain, nonatomic) NSMutableArray *dataArray;

@end

@implementation HIPDropDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"下拉加载"];
    // 去掉多余分隔线
    [HIPUtility setExtraCellLineHidden:self.tableView];
    // 集成下拉加载更多
    [self setupDropDownMore];
    // 初始化数据
    [self initData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark setup

- (void)setupDropDownMore {
    HIPRefreshView *headerView = [[HIPRefreshView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 40)];
    [headerView setHidden:YES];
    [self.tableView setTableHeaderView:headerView];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HIPTestViewController *testViewController = [[HIPTestViewController alloc] init];
    [HIPUtility pushFromViewController:self toViewController:testViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果tableView还没有数据，就直接返回
    if (self.dataArray.count < 20 || ![self.tableView.tableHeaderView isHidden]) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) { // 最后一个cell完全进入视野范围内
        // 显示header
        self.tableView.tableHeaderView.hidden = NO;
        
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
    array = [NSMutableArray arrayWithArray:[[array reverseObjectEnumerator] allObjects]];
    self.dataArray = array;
}

- (void)loadMoreData {
    NSString *dataId = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    NSMutableArray *array = [NSMutableArray array];
    long index = [self.dataArray count];
    for (long i = index; i < index + 20; i++) {
        [array addObject:[NSString stringWithFormat:@"data:%@:%ld", dataId, i]];
    }
    array = [NSMutableArray arrayWithArray:[[array reverseObjectEnumerator] allObjects]];
    [self.dataArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
    
    CGFloat offsetOfButtom = self.tableView.contentSize.height - self.tableView.contentOffset.y;
    // 刷新表格
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0.0f, self.tableView.contentSize.height - offsetOfButtom);
    // 结束刷新(隐藏header)
    [self.tableView.tableHeaderView setHidden:YES];
}

@end
