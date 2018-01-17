//
//  MenuView.h
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate;

@interface MenuView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *contentView;

@property (nonatomic, retain) IBOutlet UIImageView *bgView;

@property (nonatomic, retain) UIView *backgroundView;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)setMenuDelegate:(id<MenuViewDelegate>) delegate;

- (void)reloadData;

@end

@protocol MenuViewDelegate <NSObject>

@required

- (NSArray *) menuDataDicArray;

- (void) didSelectMenuAtIndex:(NSUInteger) index;

@end
