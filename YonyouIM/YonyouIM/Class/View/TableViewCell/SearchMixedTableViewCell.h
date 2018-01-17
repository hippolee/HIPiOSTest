//
//  SearchMixedTableViewCell.h
//  YonyouIM
//
//  Created by yanghaoc on 16/1/11.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"
#import "YYIMUIDefs.h"

@interface SearchMixedTableViewCell : UITableViewCell<UITableViewDataSource, UITableViewDelegate>

- (void)setActiveType:(YMSearchType)type array:(NSArray *)array limit:(NSInteger)limit searchKey:(NSString *)searchKey;

+ (NSInteger)getHeightOfCell:(NSArray *)array limit:(NSInteger)limit;

@end
