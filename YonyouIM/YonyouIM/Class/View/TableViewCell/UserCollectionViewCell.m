//
//  UserCollectionViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/3/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UserCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+YYIMCategory.h"

@implementation UserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *delLayer = [self.delView layer];
    [delLayer setMasksToBounds:YES];
    [delLayer setCornerRadius:8];
    
    [self reuse];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.iconImage.image = nil;
    self.nameLabel.text = nil;
    self.roundCorner = 0.0f;
    
    CALayer *layer = [self.iconImage layer];
    [layer setMasksToBounds:NO];
    [layer setCornerRadius:0];
    
    [self.delView setHidden:YES];
}

- (void)setRoundCorner:(CGFloat)roundCorner {
    CALayer *layer = [self.iconImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:roundCorner];
}

- (void) setHeadImageWithUrl:(NSString *) headUrl {
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:[UIImage imageNamed:@"icon_head"] options:0];
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void) setHeadIcon:(NSString *)iconName {
    [self.iconImage setImage:[UIImage imageNamed:iconName]];
}

- (void) setName:(NSString *) name {
    self.nameLabel.text = name;
}

@end
