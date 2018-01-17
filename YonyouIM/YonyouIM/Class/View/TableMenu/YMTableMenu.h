//
//  YMTableMenu.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMTableMenuDelegate;

@interface YMTableMenu : UIView<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<YMTableMenuDelegate> delegate;

+ (YMTableMenu *)initYMTableMenu;

- (void)setMenuItems:(NSArray *)itemArray;

@end

@protocol YMTableMenuDelegate <NSObject>

- (void)didClickMTableMenu:(YMTableMenu*)menu atIndex:(NSInteger)index;

@end
