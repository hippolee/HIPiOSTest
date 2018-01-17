//
//  PanTableViewCell1.m
//  YonyouIM
//
//  Created by litfb on 15/7/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PanTableViewCell1.h"
#import "YYIMColorHelper.h"

@implementation PanTableViewCell1

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    self.iconImage.image = nil;
    self.nameLabel.text = nil;
    self.propLabel.text = nil;
}

- (void)setIconImageName:(NSString *)imageName {
    [self.iconImage setImage:[UIImage imageNamed:imageName]];
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setProp:(NSString *)prop {
    self.propLabel.text = prop;
}

@end
