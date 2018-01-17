//
//  ChatMicroVideoTableViewCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/7.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatMicroVideoTableViewCell.h"
#import "YYIMColorHelper.h"
#import "UIImageView+WebCache.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUtility.h"
#import "YYMessage+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "UIImage+GIF.h"
#import "SCRecorder.h"
#import "MBProgressHUD.h"
#import "YYIMAttachProgressDelegate.h"
#import "YYIMResourceUtility.h"

@interface  ChatMicroVideoTableViewCell() <MBProgressHUDDelegate, YYIMAttachProgressDelegate>

@property (retain, nonatomic) YYMessage *message;

@property (retain, nonatomic) NSLayoutConstraint *timeConstraint;

@property (retain, nonatomic) NSLayoutConstraint *nameConstraint;

@property (retain, nonatomic) NSLayoutConstraint *timeLabelConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint2;

@property (retain, nonatomic) SCPlayer *player;
@property (retain, nonatomic) SCVideoPlayerView *videoPlayerView;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

- (IBAction)resendAction:(id)sender;

@end

@implementation ChatMicroVideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *layer = [self.headImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:20];
    
    CALayer *timeLayer = [self.timeLabel layer];
    [timeLayer setMasksToBounds:YES];
    [timeLayer setCornerRadius:3];
    
    [self.messageImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.timeLabel setEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)clearHud {
    MBProgressHUD *hud;
    
    for (UIView *subview in self.messageView.subviews) {
        if ([subview isKindOfClass:[MBProgressHUD class]]) {
            hud = (MBProgressHUD *)subview;
        }
    }
    
    if (hud) {
        [hud removeFromSuperview];
        hud = nil;
    }
}

- (void)reuse {
    //清除可能存在的加载框
    [self clearHud];
    
    [[YYIMChat sharedInstance].chatManager addAttachProgressDelegate:self];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.timeLabel.text = nil;
    self.timeLabel.hidden = YES;
    self.headImage.image = nil;
    self.headImage.hidden = NO;
    self.nameLabel.text = nil;
    self.messageView.showArrow = YES;
    self.stateLabel.text = nil;
    self.stateLabel.textColor = UIColorFromRGB(0xaaaaaa);
    self.resendBtn.hidden = YES;
    self.playButton.hidden = YES;
    self.loadingView.hidden = YES;
    
    if (self.player && self.player.isPlaying) {
        [self.player pause];
    }
    self.player = nil;
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    self.playView.hidden = YES;
    
    if (_timeConstraint) {
        [self.timeView removeConstraint:_timeConstraint];
    }
    if (_nameConstraint) {
        [self.nameLabel removeConstraint:_nameConstraint];
    }
    if (_timeLabelConstraint) {
        [self.timeLabel removeConstraint:_timeLabelConstraint];
    }
    if (_bottomConstraint) {
        [self.bottomView removeConstraint:_bottomConstraint];
    }
    if (_bottomConstraint2) {
        [self.bottomView removeConstraint:_bottomConstraint2];
    }
}

+ (CGFloat)heightForCellWithData:(YYMessage *) message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow {
    CGFloat height = [message contentHeight];
    
    if (isTimeShow) {
        height += 30;
    }
    
    if (!isBottomShow) {
        height -= 8;
    }
    
    return height;
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

- (void)setActiveMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow isPlaying:(BOOL)isPlaying {
    self.message = message;
    
    UIImage *image = [message getMessageMicroVideoThumb];
    //如果没有缩略图
    if (!image) {
        image = [UIImage imageNamed:@"icon_image"];
    }
    
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
    if (([message direction] == YM_MESSAGE_DIRECTION_SEND && [message status] == YM_MESSAGE_STATE_NEW) ) {
        [self.loadingView setImage:[UIImage sd_animatedGIFNamed:@"yyim_hud"]];
        self.loadingView.hidden = NO;
    }
    
    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_ING) {
        if ([message getMessageMicroVideoThumb]) {
            //如果有缩略图，正在下载视频
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.messageView animated:YES];
            self.progressHUD.color = [UIColor clearColor];
            self.progressHUD.delegate = self;
            self.progressHUD.mode = MBProgressHUDModeDeterminate;
            
            self.playButton.hidden = YES;
        } else {
            [self.loadingView setImage:[UIImage sd_animatedGIFNamed:@"yyim_hud"]];
            self.loadingView.hidden = NO;
        }
    } else if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_FAILD) {
        //下载失败
        self.playButton.hidden = NO;
        [self.playButton setImage:[UIImage imageNamed:@"icon_microvideo_failed"] forState:UIControlStateNormal];
    } else if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_INI) {
        //还没有下载过
        self.playButton.hidden = NO;
        [self.playButton setImage:[UIImage imageNamed:@"icon_microvideo_play"] forState:UIControlStateNormal];
    } else if (isPlaying) {
        //正在播放的
        self.playButton.hidden = YES;
    } else {
        //没有正在播放的
        self.playButton.hidden = NO;
        [self.playButton setImage:[UIImage imageNamed:@"icon_microvideo_play"] forState:UIControlStateNormal];
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messagePressed:)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [self.messageView addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(messageLongPress:)];
    [self.messageView addGestureRecognizer:longPressGestureRecognizer];
    
    [self.messageImage setImage:image];
    [self.messageImage setHidden:NO];
    
    [self layoutByMessage:message isTimeShow:isTimeShow isBottomShow:isBottomShow isHeaderShow:isHeaderShow];
}

- (void)layoutByMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow {
    NSString *timeStr = [YYIMUtility genTimeString:[message date]];
    
    if (isTimeShow && timeStr != nil && timeStr.length > 0) {
        self.timeLabel.text = timeStr;
        self.timeLabel.hidden = NO;
        [self.timeView addConstraint:[self timeConstraint]];
        [self.timeLabel addConstraint:[self timeLabelConstraint]];
    }
    
    if (isBottomShow) {
        [self.bottomView addConstraint:self.bottomConstraint2];
    } else {
        [self.bottomView addConstraint:self.bottomConstraint];
    }
    
    if (isHeaderShow) {
        self.headImage.hidden = NO;
        self.messageView.showArrow = YES;
    } else {
        self.headImage.hidden = YES;
        self.messageView.showArrow = NO;
    }
}

- (void)playMicroVideo {
    if (self.player && self.player.isPlaying) {
        return;
    }
    
    self.playButton.hidden = YES;
    [self.playView setHidden:NO];
    
    //视频
    NSURL *url = [self.message getMessageMicroVideoFile];
    if (url) {
        self.player = [SCPlayer player];
        self.videoPlayerView = [[SCVideoPlayerView alloc] initWithPlayer:self.player];
        self.videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPlayerView.frame = self.playView.bounds;
        self.videoPlayerView.autoresizingMask = self.playView.autoresizingMask;
        [self.playView addSubview:self.videoPlayerView];
        
        self.player.loopEnabled = YES;
        self.player.volume = 0;
        [self.player setItemByUrl:url];
        [self.player play];
    }
}

- (void)stopMicroVideo {
    if (self.player && self.player.isPlaying) {
        [self.player pause];
    }
    
    self.playButton.hidden = NO;
    self.player = nil;
    
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    
    [self.playView setHidden:YES];
}

#pragma mark tap

- (void)messagePressed:(UITapGestureRecognizer *)tapGestureRecognizer {
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

///**
// *  当hud完全消失后的回到
// *
// *  @param hud
// */
//- (void)hudWasHidden:(MBProgressHUD *)hud {
//    if (hud == self.progressHUD) {
//        [self.progressHUD removeFromSuperview];
//        self.progressHUD = nil;
//    }
//}

#pragma mark -
#pragma mark YYIMAttachProgressDelegate

- (void)attachDownloadProgress:(float)progress totalSize:(long long)totalSize readedSize:(long long)readedSize withAttachKey:(NSString *)attachKey {
    YYMessageContent *content = [self.message getMessageContent];
    if ([attachKey isEqualToString:[YYIMResourceUtility getAttachKey:content.fileAttachId imageType:kYYIMImageTypeNormal]]) {
        [self.progressHUD setProgress:(float)readedSize/totalSize];
    }
}

- (void)attachDownloadComplete:(BOOL)result withAttachKey:(NSString *)attachKey error:(YYIMError *)error {
    //不实现，交由message的代理更新
}

@end
