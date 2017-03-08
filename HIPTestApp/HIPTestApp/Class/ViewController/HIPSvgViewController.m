//
//  HIPSvgViewController.m
//  litfb_test
//
//  Created by litfb on 16/3/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSvgViewController.h"
#import "HIPUtility.h"
#import "HIPRefreshView.h"
#import "HIPDBHelper.h"
#import "HIPSvgDetailController.h"
#import "HIPNavigationBar.h"

#define HIP_PAGE_SIZE 20

@interface HIPSvgViewController ()

@property (retain, nonatomic) NSMutableArray *dataArray;

@property BOOL loadMore;

@end

@implementation HIPSvgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"SVG"];
    // 新增
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_add"] style:UIBarButtonItemStylePlain target:self action:@selector(addAction:)]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableViewIdentifier = @"HIPSvgViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    HIPSvgInfo *svgInfo = [self.dataArray objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[svgInfo svgName]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HIPSvgDetailController *svgDetailController = [[HIPSvgDetailController alloc] init];
    [svgDetailController setSvgArray:self.dataArray];
    [svgDetailController setIndex:indexPath.row];
    
    UINavigationController *svgDetailNavController = [[UINavigationController alloc] initWithNavigationBarClass:[HIPNavigationBar class] toolbarClass:nil];
    [svgDetailNavController addChildViewController:svgDetailController];
    
    [self.navigationController presentViewController:svgDetailNavController animated:YES completion:^{
        
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    HIPSvgInfo *svgInfo = [self.dataArray objectAtIndex:indexPath.row];
    [[HIPDBHelper sharedInstance] deleteSvgWithId:[svgInfo svgId]];
    [self.dataArray removeObject:svgInfo];
    [tableView reloadData];
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
        if (!self.loadMore) {
            return;
        }
        // 显示footer
        self.tableView.tableFooterView.hidden = NO;
        // 加载更多数据
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.0f];
    }
}

#pragma mark loadData

- (void)initData {
    self.dataArray = [NSMutableArray array];
    NSArray *array = [[HIPDBHelper sharedInstance] getSvgWithLimit:HIP_PAGE_SIZE offset:0];
    if ([array count]) {
        self.loadMore = YES;
        [self.dataArray addObjectsFromArray:array];
    } else {
        self.loadMore = NO;
    }
}

- (void)loadMoreData {
    NSArray *array = [[HIPDBHelper sharedInstance] getSvgWithLimit:HIP_PAGE_SIZE offset:[self.dataArray count]];
    if ([array count]) {
        [self.dataArray addObjectsFromArray:array];
    } else {
        self.loadMore = NO;
    }
    
    // 刷新表格
    [self.tableView reloadData];
    // 结束刷新(隐藏footer)
    [self.tableView.tableFooterView setHidden:YES];
}

- (void)addAction:(id)sender {
    HIPSvgInfo *svgInfo = [[HIPDBHelper sharedInstance] addSvg];
    [self.dataArray insertObject:svgInfo atIndex:0];
    [self.tableView reloadData];
}

@end
