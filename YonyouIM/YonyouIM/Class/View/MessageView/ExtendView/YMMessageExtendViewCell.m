//
//  YMMessageExtendViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMMessageExtendViewCell.h"
#import "UIButton+YYIMCatagory.h"
#import "YYIMColorHelper.h"

@implementation YMMessageExtendViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CALayer *layer = [self.iconImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:2.0f];
    [layer setBorderWidth:0.5f];
    [layer setBorderColor:UIColorFromRGB(0x9c9c9c).CGColor];
    
    [self.iconImage setBackgroundColor:[UIColor clearColor]];
}

- (void)prepareForReuse {
    self.iconImage.image = nil;
    self.nameLabel.text = nil;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self.iconImage setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        [self.iconImage setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setIconWithImageName:(NSString *)imageName {
    [self.iconImage setImage:[UIImage imageNamed:imageName]];
}

- (void)setName:(NSString *)name {
    [self.nameLabel setText:name];
}

@end
