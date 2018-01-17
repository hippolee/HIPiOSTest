//
//  ChatBatchMixedSubCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatBatchMixedSubCell.h"
#import "UIImageView+WebCache.h"

@interface ChatBatchMixedSubCell ()

@property (retain, nonatomic) YYPubAccountContent *paContent;

@end

@implementation ChatBatchMixedSubCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.coverImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.coverImage setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    self.coverImage.image = nil;
    self.titleLabel.text = nil;
    self.sepView.hidden = YES;
}

- (void)setActivePaContent:(YYPubAccountContent *)paContent {
    self.paContent = paContent;
    [self.coverImage sd_setImageWithURL:[NSURL URLWithString:[paContent getCoverPhoto]] placeholderImage:[UIImage imageNamed:@"icon_image"]];
    [self.titleLabel setText:[paContent title]];
}

@end
