//
//  HIPColorViewController.m
//  litfb_test
//
//  Created by litfb on 16/2/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPColorViewController.h"
#import "HIPUtility.h"
#import "HIPColorHelper.h"

@interface HIPColorViewController ()

@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation HIPColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"颜色"];
    // 去掉多余分隔线
    [HIPUtility setExtraCellLineHidden:self.tableView];
    // 不能选择
    [self.tableView setAllowsSelection:NO];
    // 初始化数据
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    NSNumber *number = [self.dataArray objectAtIndex:indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%lX", (long)[number integerValue]];
    NSString *colorStr;
    switch (str.length) {
        case 1:
            colorStr = [NSString stringWithFormat:@"0x00000%@", str];
            break;
        case 2:
            colorStr = [NSString stringWithFormat:@"0x0000%@", str];
            break;
        case 4:
            colorStr = [NSString stringWithFormat:@"0x00%@", str];
            break;
        default:
            colorStr = [NSString stringWithFormat:@"0x%@", str];
            break;
    }
    [[cell textLabel] setText:colorStr];
    [[cell textLabel] setTextColor:UIColorFromRGB(0xffffff - [number integerValue])];
    [cell setBackgroundColor:UIColorFromRGB([number integerValue])];
    return cell;
}

#pragma mark private

- (void)initData {
    NSMutableArray *numArray = [NSMutableArray array];
//    [numArray addObject:[NSNumber numberWithInt:0x000000]];
    [numArray addObject:[NSNumber numberWithInt:0x333333]];
//    [numArray addObject:[NSNumber numberWithInt:0x666666]];
    [numArray addObject:[NSNumber numberWithInt:0x999999]];
//    [numArray addObject:[NSNumber numberWithInt:0xcccccc]];
    [numArray addObject:[NSNumber numberWithInt:0xffffff]];
    
    long size = [numArray count];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            for (int k = 0; k < size; k++) {
                int r = [[numArray objectAtIndex:i] integerValue] & 0xff0000;
                int g = [[numArray objectAtIndex:j] integerValue] & 0x00ff00;
                int b = [[numArray objectAtIndex:k] integerValue] & 0x0000ff;
                [array addObject:[NSNumber numberWithInt:(r + g + b)]];
            }
        }
    }
    self.dataArray = array;
}

@end
