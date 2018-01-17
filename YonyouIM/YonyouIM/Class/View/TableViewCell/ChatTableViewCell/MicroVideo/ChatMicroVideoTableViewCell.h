//
//  ChatMicroVideoTableViewCell.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/7.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYMessage.h"
#import "YYIMLabel.h"
#import "YYIMViewLayerBubbleView.h"

@interface ChatMicroVideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet YYIMLabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet YYIMViewLayerBubbleView *messageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *messageImage;
@property (weak, nonatomic) IBOutlet UIView *playView;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;
@property (retain, nonatomic) IBOutlet UIImageView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

+ (CGFloat)heightForCellWithData:(YYMessage *) message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setName:(NSString *)name;

- (void)setActiveMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow isPlaying:(BOOL)isPlaying;

- (void)playMicroVideo;

- (void)stopMicroVideo;

@end
