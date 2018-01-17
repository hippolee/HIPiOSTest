//
//  ChatTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "YYIMEmojiHelper.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUtility.h"
#import "YYMessage+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "UIImage+GIF.h"

@interface ChatTableViewCell ()

@property (retain, nonatomic) YYMessage *message;

@property BOOL isAudioPlaying;

@property (retain, nonatomic) NSLayoutConstraint *timeConstraint;

@property (retain, nonatomic) NSLayoutConstraint *nameConstraint;

@property (retain, nonatomic) NSLayoutConstraint *timeLabelConstraint;

@property (retain, nonatomic) NSLayoutConstraint *fileImageConstraint;

@property (retain, nonatomic) NSLayoutConstraint *shareImageConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint2;

@property (retain, nonatomic) NSLayoutConstraint *messageImageConstraint;

- (IBAction)resendAction:(id)sender;

@end

@implementation ChatTableViewCell

+ (CGFloat)heightForCellWithData:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow {
    CGFloat height = [message contentHeight];
    if (isTimeShow) {
        height += 30;
    }
    if (!isBottomShow) {
        height -= 8;
    }
    return height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *layer = [self.headImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:20];
    
    CALayer *timeLayer = [self.timeLabel layer];
    [timeLayer setMasksToBounds:YES];
    [timeLayer setCornerRadius:3];
    
    [self.messageImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.timeLabel setEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
    [self.messageLabel setEmojiDelegate:self];
    
    CALayer *shareImageLayer = [self.shareImage layer];
    [shareImageLayer setMasksToBounds:YES];
    [self.shareImage setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.messageLabel setDisableURL:NO];
    [self.messageLabel setUserInteractionEnabled:YES];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.timeLabel.text = nil;
    self.timeLabel.hidden = YES;
    self.headImage.image = nil;
    self.headImage.hidden = NO;
    self.nameLabel.text = nil;
    self.messageView.showArrow = YES;
    self.messageLabel.text = nil;
    self.messageImage.image = nil;
    self.messageImage.hidden = YES;
    self.audioImage.hidden = YES;
    self.durationLabel.text = nil;
    self.durationLabel.hidden = YES;
    self.stateLabel.text = nil;
    self.stateLabel.textColor = UIColorFromRGB(0xaaaaaa);
    self.unreadImage.image = nil;
    self.unreadImage.hidden = YES;
    self.loadingView.image = nil;
    self.loadingView.hidden = YES;
    self.resendBtn.hidden = YES;
    self.locationLabel.text = nil;
    self.locationLabel.hidden = YES;
    self.fileImage.image = nil;
    self.fileImage.hidden = YES;
    self.fileLabel.text = nil;
    self.fileLabel.hidden = YES;
    self.fileSizeLabel.text = nil;
    self.fileSizeLabel.hidden = YES;
    self.downloadLabel.text = nil;
    self.downloadLabel.hidden = YES;
    self.shareImage.image = nil;
    self.shareImage.hidden = YES;
    self.shareTitleLabel.text = nil;
    self.shareTitleLabel.hidden = YES;
    self.shareDescLabel.text = nil;
    self.shareDescLabel.hidden = YES;
    
    if (_timeConstraint) {
        [self.timeView removeConstraint:_timeConstraint];
    }
    if (_nameConstraint) {
        [self.nameLabel removeConstraint:_nameConstraint];
    }
    if (_timeLabelConstraint) {
        [self.timeLabel removeConstraint:_timeLabelConstraint];
    }
    if (_fileImageConstraint) {
        [self.fileImage removeConstraint:_fileImageConstraint];
    }
    if (_shareImageConstraint) {
        [self.shareImage removeConstraint:_shareImageConstraint];
    }
    if (_bottomConstraint) {
        [self.bottomView removeConstraint:_bottomConstraint];
    }
    if (_bottomConstraint2) {
        [self.bottomView removeConstraint:_bottomConstraint2];
    }
    if (_messageImageConstraint) {
        [self.messageImage removeConstraint:_messageImageConstraint];
        _messageImageConstraint = nil;
    }
}

- (void)setTimeText:(NSString *)time {
    if (time != nil && time.length > 0) {
        self.timeLabel.text = time;
        self.timeLabel.hidden = NO;
        [self.timeView addConstraint:[self timeConstraint]];
        [self.timeLabel addConstraint:[self timeLabelConstraint]];
    }
}

- (void)setHeadImageName:(NSString *)imageName {
    [self.headImage setImage:[UIImage imageNamed:imageName]];
}

- (void) setHeadImageWithUrl:(NSString *) headUrl {
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:[UIImage imageNamed:@"icon_head"] options:0];
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void)setName:(NSString *)name {
    [self.nameLabel setText:name];
    [self.nameLabel addConstraint:[self nameConstraint]];
}

- (void)setActiveMessage:(YYMessage *)message {
    self.message = message;
    
    if (self.headImage) {
        [self.headImage setUserInteractionEnabled:YES];
        UITapGestureRecognizer *headTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headPressed:)];
        [self.headImage addGestureRecognizer:headTapGestureRecognizer];
    }
    
    // resend:direction_send&&state_faild
    if ([message direction] == YM_MESSAGE_DIRECTION_SEND && [message status] == YM_MESSAGE_STATE_FAILD) {
        self.resendBtn.hidden = NO;
    }
    
    // loading
    if (([message direction] == YM_MESSAGE_DIRECTION_SEND && [message status] == YM_MESSAGE_STATE_NEW) || ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_ING)) {
        [self.loadingView setImage:[UIImage sd_animatedGIFNamed:@"yyim_hud"]];
        self.loadingView.hidden = NO;
    }
    
    // readed
    if ([message direction] == YM_MESSAGE_DIRECTION_SEND && ![[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        if ([message status] == YM_MESSAGE_STATE_DELIVERED) {
            self.stateLabel.text = @"已读";
        } else if ([message status] >= YM_MESSAGE_STATE_SENT_OR_READ) {
            self.stateLabel.text = @"未读";
            self.stateLabel.textColor = UIColorFromRGB(0x67c5f8);
        }
    }
    
    //    // read
    //    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [message status] == YM_MESSAGE_STATE_NEW) {
    //        [[YYIMChat sharedInstance].chatManager updateMessageReadedWithPid:[message pid]];
    //    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messagePressed:)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [self.messageView addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(messageLongPress:)];
    [self.messageView addGestureRecognizer:longPressGestureRecognizer];
    
    YYMessageContent *content = [message getMessageContent];
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_TEXT:
        case YM_MESSAGE_CONTENT_CUSTOM:
            [self setMessageText:[message getAttributedString]];
            if ([message contentHeight] > 56) {
                [self.messageLabel setTextAlignment:NSTextAlignmentLeft];
            } else {
                [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
            }
            break;
        case YM_MESSAGE_CONTENT_LOCATION:
            self.locationLabel.text = [content address];
            self.locationLabel.hidden = NO;
        case YM_MESSAGE_CONTENT_IMAGE: {
            UIImage *image = [message getMessageImage];
            [self.messageImage setImage:image];
            [self.messageImage setHidden:NO];
            
            CGSize newSize = [YYIMUtility sizeOfImageThumbSize:image.size withMaxSide:160.0f];
            [self.messageImage addConstraint:[self messageImageConstraint:newSize.width]];
            break;
        }
        case YM_MESSAGE_CONTENT_AUDIO: {
            [self.audioImage setHidden:NO];
            // 未读
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && (![message specificStatus] || [message specificStatus] == YM_MESSAGE_SPECIFIC_INITIAL)) {
                self.unreadImage.image = [UIImage imageNamed:@"icon_unread"];
                self.unreadImage.hidden = NO;
            }
            // duration
            self.durationLabel.text = [NSString stringWithFormat:@"%ld\"", (long)[content duration]];
            self.durationLabel.hidden = NO;
            
            [self.messageImage setHidden:NO];
            NSInteger duration = [content duration] > 60 ? 60 : [content duration];
            [self.messageImage addConstraint:[self messageImageConstraint:52 + duration * 3]];
            break;
        }
        case YM_MESSAGE_CONTENT_FILE: {
            self.fileImage.image = [UIImage imageNamed:[YYIMUtility fileIconWithExt:[content fileExtension]]];
            [self.fileImage addConstraint:[self fileImageConstraint]];
            self.fileImage.hidden = NO;
            self.fileLabel.text = [content fileName];
            self.fileLabel.hidden = NO;
            NSString *downloadState;
            switch ([message downloadStatus]) {
                case YM_MESSAGE_DOWNLOADSTATE_INI:
                case YM_MESSAGE_DOWNLOADSTATE_FAILD:
                    downloadState = @"未下载";
                    break;
                case YM_MESSAGE_DOWNLOADSTATE_ING:
                    downloadState = @"下载中";
                    break;
                case YM_MESSAGE_DOWNLOADSTATE_SUCCESS:
                    downloadState = @"已下载";
                    break;
            }
            self.fileSizeLabel.text = [YYIMUtility fileSize:[content fileSize]];
            self.fileSizeLabel.hidden = NO;
            self.downloadLabel.text = downloadState;
            self.downloadLabel.hidden = NO;
            break;
        }
        case YM_MESSAGE_CONTENT_SHARE: {
            [self.messageImage addConstraint:[self messageImageConstraint:220.0f]];
            [self.shareImage addConstraint:[self shareImageConstraint]];
            
            [self.shareImage sd_setImageWithURL:[NSURL URLWithString:[content shareImageUrl]]];
            [self.shareImage setHidden:NO];
            [self.shareTitleLabel setText:[content shareTitle]];
            [self.shareTitleLabel setHidden:NO];
            [self.shareDescLabel setText:[content shareDesc]];
            [self.shareDescLabel setHidden:NO];
            break;
        }
        default:
            break;
    }
}

- (void) setMessageText:(NSAttributedString *)text {
    [self.messageLabel setText:text];
}

- (void) setMessageImageWithImagePath:(NSString *)imagePath {
    if (imagePath == nil || [imagePath length] == 0) {
        self.messageImage.image = [UIImage imageNamed:@"icon_image"];
    } else {
        self.messageImage.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    [self.messageImage setHidden:NO];
}

#pragma mark tap

- (void)messagePressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    if ([self.message type] == YM_MESSAGE_CONTENT_AUDIO && [self.message direction] == YM_MESSAGE_DIRECTION_RECEIVE && (![self.message specificStatus] || [self.message specificStatus] == YM_MESSAGE_SPECIFIC_INITIAL)) {
        [self.message setSpecificStatus:YM_MESSAGE_SPECIFIC_AUDIO_READ];
        [[YYIMChat sharedInstance].chatManager updateAudioReaded:[self.message pid]];
        self.unreadImage.hidden = YES;
    }
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:tapGestureRecognizer}];
}

- (void)messageLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        [self bubbleLongPressWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:longPressRecognizer}];
    }
}

- (void)headPressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:tapGestureRecognizer, kYMChatPressedHead:[NSNumber numberWithBool:YES]}];
}

- (void)playAudioAnimation:(BOOL)play {
    if (play) {
        self.isAudioPlaying = YES;
        [self.audioImage startAnimating];
    } else {
        [self.audioImage stopAnimating];
        self.isAudioPlaying = NO;
    }
}

- (BOOL)audioAnimationPlaying {
    return self.isAudioPlaying;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self playAudioAnimation:NO];
}

- (void)setBottomShow:(BOOL)isBottomShow {
    if (isBottomShow) {
        [self.bottomView addConstraint:self.bottomConstraint2];
    } else {
        [self.bottomView addConstraint:self.bottomConstraint];
    }
}

- (void)setHeaderShow:(BOOL)isHeaderShow {
    if (isHeaderShow) {
        self.headImage.hidden = NO;
        self.messageView.showArrow = YES;
    } else {
        self.headImage.hidden = YES;
        self.messageView.showArrow = NO;
    }
}

#pragma mark YYIMEmojiLabelDelegate

- (NSString *)emojiLabel:(YYIMEmojiLabel *)emojiLabel imageNameOfEmojiText:(NSString *)emojiText {
    return [[YYIMEmojiHelper sharedInstance] imageNameWithEmojiText:emojiText];
}

- (void)emojiLabel:(YYIMEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(YYIMEmojiLabelLinkType)type {
    if (type == YYIMEmojiLabelLinkTypeURL) {
        [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedURL:link}];
    }
}

#pragma mark private func

- (IBAction)resendAction:(id)sender {
    [[YYIMChat sharedInstance].chatManager resendMessage:[self.message pid]];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSLayoutConstraint *)timeConstraint {
    if (!_timeConstraint) {
        _timeConstraint = [NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
        _timeConstraint.priority = 751;
    }
    return _timeConstraint;
}

- (NSLayoutConstraint *)nameConstraint {
    if (!_nameConstraint) {
        _nameConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:16.0f];
        _nameConstraint.priority = 751;
    }
    return _nameConstraint;
}

- (NSLayoutConstraint *)timeLabelConstraint {
    if (!_timeLabelConstraint) {
        _timeLabelConstraint = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:22.0f];
        _timeLabelConstraint.priority = 751;
    }
    return _timeLabelConstraint;
}

- (NSLayoutConstraint *)fileImageConstraint {
    if (!_fileImageConstraint) {
        _fileImageConstraint = [NSLayoutConstraint constraintWithItem:self.fileImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:36.0f];
        _fileImageConstraint.priority = 751;
    }
    return _fileImageConstraint;
}

- (NSLayoutConstraint *)shareImageConstraint {
    if (!_shareImageConstraint) {
        _shareImageConstraint = [NSLayoutConstraint constraintWithItem:self.shareImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:78.0f];
        _shareImageConstraint.priority = 751;
    }
    return _shareImageConstraint;
}

- (NSLayoutConstraint *)bottomConstraint {
    if (!_bottomConstraint) {
        _bottomConstraint = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0.0];
        _bottomConstraint.priority = 751;
    }
    return _bottomConstraint;
}

- (NSLayoutConstraint *)bottomConstraint2 {
    if (!_bottomConstraint2) {
        _bottomConstraint2 = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:8.0];
        _bottomConstraint2.priority = 751;
    }
    return _bottomConstraint2;
}

- (NSLayoutConstraint *)messageImageConstraint:(CGFloat)imageWidth {
    _messageImageConstraint = [NSLayoutConstraint constraintWithItem:self.messageImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:imageWidth];
    _messageImageConstraint.priority = 751;
    return _messageImageConstraint;
}

@end
