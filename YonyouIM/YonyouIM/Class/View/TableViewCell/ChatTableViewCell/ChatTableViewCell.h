//
//  ChatTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/1/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

#import "YYIMLabel.h"
#import "YYIMEmojiLabel.h"
#import "ChatBubbleView.h"

@interface ChatTableViewCell : UITableViewCell<YYIMEmojiLabelDelegate, AVAudioPlayerDelegate>

@property (retain, nonatomic) UIImage *playImage;
@property (retain, nonatomic) IBOutlet UIView *timeView;
@property (retain, nonatomic) IBOutlet YYIMLabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *headImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet ChatBubbleView *messageView;
@property (retain, nonatomic) IBOutlet YYIMEmojiLabel *messageLabel;
@property (retain, nonatomic) IBOutlet UIImageView *messageImage;
@property (retain, nonatomic) IBOutlet UIImageView *audioImage;
@property (retain, nonatomic) IBOutlet UILabel *durationLabel;
@property (retain, nonatomic) IBOutlet UILabel *stateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *unreadImage;
@property (retain, nonatomic) IBOutlet UIImageView *loadingView;
@property (retain, nonatomic) IBOutlet UIButton *resendBtn;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UIImageView *fileImage;
@property (retain, nonatomic) IBOutlet UILabel *fileLabel;
@property (retain, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *downloadLabel;
@property (retain, nonatomic) IBOutlet UIImageView *shareImage;
@property (retain, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *shareDescLabel;
@property (retain, nonatomic) IBOutlet UIView *bottomView;

+ (CGFloat)heightForCellWithData:(YYMessage *) message isTimeShow:(BOOL) isTimeShow isBottomShow:(BOOL)isBottomShow;

- (void)reuse;

- (void)setTimeText:(NSString *)time;

- (void)setHeadImageName:(NSString *)imageName;

- (void)setHeadImageWithUrl:(NSString *)headUrl;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setName:(NSString *)name;

- (void)setActiveMessage:(YYMessage *)message;

- (void)setMessageText:(NSAttributedString *)text;

- (void)setMessageImageWithImagePath:(NSString *)imagePath;

- (void)playAudioAnimation:(BOOL)play;

- (BOOL)audioAnimationPlaying;

- (void)setBottomShow:(BOOL)isBottomShow;

- (void)setHeaderShow:(BOOL)isHeaderShow;

@end
