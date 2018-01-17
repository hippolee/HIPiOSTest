//
//  OrgCollectionViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "OrgCollectionViewCell.h"
#import "YYIMColorHelper.h"

@implementation OrgCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    self.nameLabel.textColor= UIColorFromRGB(0x007ce6);
    self.arrowImage.hidden = NO;
}

- (void)setIsCurrentOrg:(BOOL)isCurrentOrg {
    _isCurrentOrg = isCurrentOrg;
    if (isCurrentOrg) {
        self.nameLabel.textColor = UIColorFromRGB(0xa3a3a3);
        self.arrowImage.hidden = YES;
    } else {
        self.nameLabel.textColor= UIColorFromRGB(0x007ce6);
        self.arrowImage.hidden = NO;
    }
}

@end
