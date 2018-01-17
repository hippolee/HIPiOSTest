//
//  MenuView.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "MenuView.h"
#import "MenuViewCell.h"
#import "MenuBgView.h"
#import "UIColor+YYIMTheme.h"

@interface MenuView ()

@property (retain, nonatomic) id<MenuViewDelegate> menuDelegate;

@end

@implementation MenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:self options:nil];
    [self.contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.contentView];
    
//    UIImage *image = [[UIImage imageNamed:@"bg_menu"] stretchableImageWithLeftCapWidth:5 topCapHeight:15];
//    [self.bgView setImage:image];
    MenuBgView *backgroundView = [[MenuBgView alloc] initWithFrame:self.contentView.frame];
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    self.backgroundView = backgroundView;
    [self.contentView insertSubview:self.backgroundView atIndex:0];
    
    self.backgroundColor = [UIColor clearColor];
    // 注册Cell nib
    UINib *cellNib=[UINib nibWithNibName:@"MenuViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"MenuViewCell"];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.menuDelegate menuDataDicArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 取cell
    static NSString *CellIndentifier = @"MenuViewCell";
    MenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    
    // 取数据
    NSDictionary *dic = [[self.menuDelegate menuDataDicArray] objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell setMenuIconImage:[dic objectForKey:@"icon"]];
    [cell setMenuLabelName:[dic objectForKey:@"name"]];
    
    [cell setSeparatorHidden:YES];
//    if (indexPath.row == [[self.menuDelegate menuDataDicArray] count] - 1) {
//        
//    } else {
//        [cell setSeparatorHidden:NO];
//    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.menuDelegate didSelectMenuAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self setHidden:YES];
}

- (void)reloadData {
    [self.tableView reloadData];
}

@end
