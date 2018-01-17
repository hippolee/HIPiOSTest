//
//  YYIMNetMeetingBasicViewController.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"
#import "NetMeetingDispatch.h"

#define YM_NETMEETING_BOTTOM_HEIGHT   160
#define YM_NETMEETING_VIEW_WIDTH      60
#define YM_NETMEETING_VIEW_HEIGHT     80
#define YM_NETMEETING_IMAGE_SIZE      60
#define YM_NETMEETING_VIEW_MARGIN     20
#define YM_NETMEETING_HANGUP_SIZE     50

#define NETMEETING_VIEWCONTROLLER_UIACTIONSHEET_TAG_END      0
#define NETMEETING_VIEWCONTROLLER_UIACTIONSHEET_TAG_INVITE   1

@interface YYIMNetMeetingBasicViewController : YYIMBaseViewController <NetMeetingDispatchDelegate>

//屏幕宽度
@property CGFloat fullViewWidth;
//屏幕高度
@property CGFloat fullViewHeight;

//信号强度
@property (strong, nonatomic) UIImageView *signalImageView;
//主视图显示视频的视图
@property (strong, nonatomic) UIView *videoMainView;
//主视图显示视频的视图
@property (strong, nonatomic) UIView *infoMainView;

@property (strong, nonatomic) UIImageView *infoMainImage;

@property (strong, nonatomic) UILabel *infoMainLabel;

//扬声器按钮
@property (strong, nonatomic) UIButton *speakererButton;

//时间显示
@property (strong, nonatomic) UILabel *timeLabel;

//当前频道对象
@property (strong, nonatomic) YYNetMeeting *netMeeting;

@property (strong, nonatomic) NSString *channelId;
//通话时长
@property (nonatomic) NSUInteger duration;
//当前的网络质量
@property YYIMNetMeetingQuality quality;
//当前预期的扬声器状态
@property BOOL speakerCommand;


- (void)initTopView;

- (void)initBottonView;

- (void)layoutBottonView;

- (void)didClickInviteButton;

- (void)didClickSpeakererButton:(UIButton *)btn;

- (void)didClickManagerButton;

- (void)switchCamera;

- (void)minimize;

- (void)inviteNetMeeting;

- (void)shareNetMeeting;

- (void)closeView;

- (void)loadChannelData;

- (NSString *)getMainViewUserId;

- (void)updateMainInfoView:(YYNetMeetingMember *)member;

- (void)showMainVidio;

- (void)hideMainVidio;

@end
