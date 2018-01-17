//
//  SingleLineSelCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "SingleLineSelCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"

@interface SingleLineSelCell ()

@property (nonatomic) BOOL enableSelect;

@end

@implementation SingleLineSelCell

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

- (void)reuse {
    [super reuse];
    self.selectEnable = YES;
    [self.checkboxImage setImage:[UIImage imageNamed:@"icon_checkbox"]];
    [self.checkboxImage setHighlightedImage:[UIImage imageNamed:@"icon_checkbox_hl"]];
    [self setSelected:NO animated:NO];
}

@end
