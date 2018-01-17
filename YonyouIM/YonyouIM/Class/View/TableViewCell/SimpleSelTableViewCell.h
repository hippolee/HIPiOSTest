//
//  SimpleSelTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleSelTableViewCell.h"

@interface SimpleSelTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *checkboxImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;

- (void)reuse;

- (void)setName:(NSString *)name;

- (void)setDetail:(NSString *)detail;

@end
