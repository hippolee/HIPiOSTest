//
//  ChatSingleMixedTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatSingleMixedTableViewCell.h"
#import "YYIMUIDefs.h"
#import "YYMessage+YYIMCatagory.h"
#import "UIImageView+WebCache.h"
#import "UIResponder+YYIMCategory.h"

@interface ChatSingleMixedTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *contentImage;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (retain, nonatomic) NSLayoutConstraint *titleConstraint;

@property (retain, nonatomic) NSLayoutConstraint *detailConstraint;

@end

@implementation ChatSingleMixedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.contentImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.contentImage setClipsToBounds:YES];
    
    [self.titleLabel setFont:[UIFont systemFontOfSize:kChatMixedTitleFontSize]];
    [self.detailLabel setFont:[UIFont systemFontOfSize:kChatMixedDetailFontSize]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.contentImage.image = nil;
    self.detailLabel.text = nil;
    if (_titleConstraint) {
        [self.titleLabel removeConstraint:_titleConstraint];
        _titleConstraint = nil;
    }
    if (_detailConstraint) {
        [self.detailLabel removeConstraint:_detailConstraint];
        _detailConstraint = nil;
    }
}

- (void)setActiveMessage:(YYMessage *)message {
    [super setActiveMessage:message];
    
    YYMessageContent *content = [message getMessageContent];
    YYPubAccountContent *paContent = [content paContent];
    
    [self.contentImage sd_setImageWithURL:[NSURL URLWithString:[paContent getCoverPhoto]] placeholderImage:[UIImage imageNamed:@"icon_image"]];
    
    // title
    if ([paContent title]) {
        self.titleLabel.text = [paContent title];
        [self.titleLabel addConstraint:[self titleConstraint:[ChatSingleMixedTableViewCell titleHeight:paContent]]];
    }
    
    // detail
    if ([paContent digest]) {
        self.detailLabel.text = [paContent digest];
        [self.detailLabel addConstraint:[self detailConstraint:[ChatSingleMixedTableViewCell detailHeight:paContent]]];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messagePressed:)];
    [self.contentView addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark tap

- (void)messagePressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:tapGestureRecognizer}];
}

#pragma mark -

+ (CGFloat)heightForCellWithData:(YYMessage *)message {
    CGFloat height = [message getContentHeight];
    if (height > 0) {
        return height;
    }
    
    YYMessageContent *content = [message getMessageContent];
    YYPubAccountContent *paContent = [content paContent];
    
    height = [self baseHeight];
    // title
    height += [ChatSingleMixedTableViewCell titleHeight:paContent];
    // image
    CGFloat imageHeight = [self baseWidth] / 16 * 9;
    height += imageHeight;
    // detail
    height += [ChatSingleMixedTableViewCell detailHeight:paContent];
    
    [message setContentHeight:height];
    return height;
}

- (NSLayoutConstraint *)titleConstraint:(CGFloat)titleHeight {
    _titleConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:titleHeight];
    _titleConstraint.priority = UILayoutPriorityDefaultHigh;
    return _titleConstraint;
}

- (NSLayoutConstraint *)detailConstraint:(CGFloat)detailHeight {
    _detailConstraint = [NSLayoutConstraint constraintWithItem:self.detailLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:detailHeight];
    _detailConstraint.priority = UILayoutPriorityDefaultHigh;
    return _detailConstraint;
}

+ (CGFloat)baseHeight {
    return 40 + 10 + 10 + 10 + 10 + 40 + 18;
}

@end
