//
//  SingleLineCell3.m
//  YonyouIM
//
//  Created by yanghaoc on 16/1/12.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import "SingleLineCell3.h"

@implementation SingleLineCell3

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.iconImage.image = nil;
    self.moreLabel.text = nil;
}

- (void)setName:(NSString *)name {
    self.moreLabel.text = name;
}

@end
