//
//  YMPubAccountMenuCustomView.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YMPubAccountMenuCustomView.h"
#import "YYIMColorHelper.h"

@interface YMPubAccountMenuCustomView ()

@property (strong, nonatomic) NSMutableArray *categoryButtonArray;
@property (strong, nonatomic) YYPubAccountMenu *accountMenu;

//当前选中的index
@property NSInteger selectPubAccountMenuIndex;
@property NSInteger lastPubAccountMenuIndex;

@end

@implementation YMPubAccountMenuCustomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.categoryButtonArray = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

- (void)updateContent:(YYPubAccountMenu *)accountMenu {
    self.accountMenu = accountMenu;
    
    if (self.categoryButtonArray.count > 0) {
        for (UIButton *btn in self.categoryButtonArray) {
            [btn removeFromSuperview];
        }
        
        [self.categoryButtonArray removeAllObjects];
    }
    
    //生成按钮组
    [self genButtonArray];
}

- (void)genButtonArray {
    CGFloat buttonWith = CGRectGetWidth(self.frame) / self.accountMenu.menuItemArray.count;
    CGFloat buttonHeight = CGRectGetHeight(self.frame);
    
    for (int i = 0; i < self.accountMenu.menuItemArray.count; i++) {
        YYPubAccountMenuItem *menuItem = [self.accountMenu.menuItemArray objectAtIndex:i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * buttonWith, 0, buttonWith, buttonHeight)];
        [button setTitle:menuItem.itemName forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x2f2f2f) forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [button.layer setMasksToBounds:YES];
        button.layer.borderColor = [UIColorFromRGB(0xd8d8d8) CGColor];
        button.layer.borderWidth = 0.5f;
        
        if (menuItem.itemArray && menuItem.itemArray.count > 0) {
            [button setImage:[UIImage imageNamed:@"menu_corner"] forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(button.frame) - 14,CGRectGetWidth(button.frame) - 14,2,2);
        }
        
        [self addSubview:button];
    }
}

- (void)clickMenu:(UIButton *)sender {
    self.lastPubAccountMenuIndex = self.selectPubAccountMenuIndex;
    self.selectPubAccountMenuIndex = sender.tag;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPubAccountMenuCustomViewClick:index:)]) {
        [self.delegate didPubAccountMenuCustomViewClick:self index:sender.tag];
    }
}

- (NSInteger)getCurrentIndex {
    return self.selectPubAccountMenuIndex;
}

- (NSInteger)getLastIndex {
    return self.lastPubAccountMenuIndex;
}

@end
