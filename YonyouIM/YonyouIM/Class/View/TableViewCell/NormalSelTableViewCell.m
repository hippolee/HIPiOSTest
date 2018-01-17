//
//  NormalSelTabelViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "NormalSelTableViewCell.h"

@interface NormalSelTableViewCell ()

@property (nonatomic) BOOL enableSelect;

@end

@implementation NormalSelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.enableSelect) {
        [super setSelected:selected animated:animated];
    }
}

- (void)setSelectEnable:(BOOL)enable {
    [self setSelectEnable:enable withDisableImage:[UIImage imageNamed:@"icon_checkbox_ds"]];
}

- (void)setSelectEnable:(BOOL)enable withDisableImage:(UIImage *)image {
    self.enableSelect = enable;
    if (enable) {
        [self.checkboxImage setImage:[UIImage imageNamed:@"icon_checkbox"]];
        [self.checkboxImage setHighlightedImage:[UIImage imageNamed:@"icon_checkbox_hl"]];
    } else {
        [self.checkboxImage setImage:image];
        [self.checkboxImage setHighlightedImage:image];
    }
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    [super reuse];
    self.selectEnable = YES;
    [self setSelected:NO animated:NO];
    [self.checkboxImage setImage:[UIImage imageNamed:@"icon_checkbox"]];
    [self.checkboxImage setHighlightedImage:[UIImage imageNamed:@"icon_checkbox_hl"]];
}

@end
