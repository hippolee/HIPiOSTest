//
//  SimpleSelTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "SimpleSelTableViewCell.h"
#import "YYIMColorHelper.h"

@implementation SimpleSelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = UIColorFromRGBA(0xececec, 0.25f);
    [self setSelectedBackgroundView:view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setName:(NSString *) name {
    self.nameLabel.text = name;
}

- (void) setDetail:(NSString *) detail {
    [self.detailLabel setText:detail];
}

- (void) reuse {
    self.nameLabel.text = nil;
    self.detailLabel.text = nil;
}

@end
