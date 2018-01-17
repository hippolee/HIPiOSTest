//
//  YMTableMenu.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YMTableMenu.h"
#import "YYIMUtility.h"

@interface YMTableMenu()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *menuItemArray;

@end


@implementation YMTableMenu

+ (YMTableMenu *)initYMTableMenu {
    NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"YMTableMenu" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)setMenuItems:(NSArray *)itemArray {
    self.menuItemArray = itemArray;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *cellIndentifier = @"YMTableMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    cell.textLabel.text = [self.menuItemArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMTableMenu:atIndex:)]) {
        [self.delegate didClickMTableMenu:self atIndex:indexPath.row];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self setHidden:YES];
}

@end
