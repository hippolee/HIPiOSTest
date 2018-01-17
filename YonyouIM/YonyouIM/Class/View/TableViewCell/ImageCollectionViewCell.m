//
//  ImageCollectionViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/2/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

//- (void)prepareForReuse {
//    self.checkboxButton
//}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.foregroundView setHidden:NO];
    } else {
        [self.foregroundView setHidden:YES];
    }
    [self.checkboxButton setSelected:selected];
}

@end
