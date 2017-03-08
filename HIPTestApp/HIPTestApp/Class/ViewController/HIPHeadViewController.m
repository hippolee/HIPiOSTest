//
//  HIPHeadViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/18.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPHeadViewController.h"
#import "HIPUtility.h"
#import "UIImageView+HIPCategory.h"
#import "UIImageView+WebCache.h"
#import "HIPNormalTableViewCell.h"

@interface HIPHeadViewController ()

@end

@implementation HIPHeadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = @"头像测试";
    // 去掉多余分隔线
    [HIPUtility setExtraCellLineHidden:self.tableView];
    // 注册CellNib
    [self.tableView registerNib:[UINib nibWithNibName:@"HIPNormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"HIPNormalTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1500;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HIPNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HIPNormalTableViewCell"];
    
    [cell.nameTextView setText:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    if (indexPath.row == 0) {
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:@"http://tx.haiqq.com/uploads/allimg/150329/161H63D1-3.jpg"]];
    } else {
        [cell.iconImageView setImageWithKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row] headCount:indexPath.row];
    }
    return cell;
}

@end
