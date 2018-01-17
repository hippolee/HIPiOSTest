//
//  YYIMNetMeetingAudienceViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingAudienceViewController.h"
#import "YYIMChatHeader.h"
#import "YYIMColorHelper.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMNetMeetingManagerViewController.h"
#import "YYIMUtility.h"
#import "GlobalInviteViewController.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@interface YYIMNetMeetingAudienceViewController ()

//------------------------bottom view-----------------------------
@property (strong, nonatomic) UIView *speakererView;

@property (strong, nonatomic) UIView *inviteView;

@property (strong, nonatomic) UIView *managerView;
//------------------------buttons-----------------------------
//邀请按钮
@property (strong, nonatomic) UIButton *inviteButton;
//管理按钮
@property (strong, nonatomic) UIButton *managerButton;

@property (strong, nonatomic) UIButton *hangUpButton;
//------------------------label-----------------------------

@property (strong, nonatomic) UILabel *idLabel;

@property (strong, nonatomic) UILabel *channelLabel;

@property (strong, nonatomic) UIImageView *teleImageView;

@property (strong, nonatomic) UIImageView *topicImageView;

//------------------------data-----------------------------
//直播主持人
@property (strong, nonatomic) YYNetMeetingMember *moderator;

@end

@implementation YYIMNetMeetingAudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.speakerCommand = YES;
    [[YYIMChat sharedInstance].chatManager setNetMeetingProfile:kYYIMNetMeetingProfileAudience];
    [[YYIMChat sharedInstance].chatManager enableNetMeetingVideo];
    [[YYIMChat sharedInstance].chatManager enterNetMeeting:self.channelId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadVideoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark initView
- (void)initTopView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 36, self.fullViewWidth, 70)];
    
    UIButton *windowSwitch = [[UIButton alloc] initWithFrame:CGRectMake(self.fullViewWidth - 56, 0, 40, 40)];
    [windowSwitch setImage:[UIImage imageNamed:@"icon_neetmeeting_minimize"] forState:UIControlStateNormal];
    [windowSwitch addTarget:self action:@selector(minimize) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:windowSwitch];
    
    self.topicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 6, 28, 28)];
    [self.topicImageView setImage:[UIImage imageNamed:@"icon_netmeeting_live_white"]];
    [topView addSubview:self.topicImageView];
    
    NSString *topic = self.netMeeting.topic;
    self.channelLabel = [[UILabel alloc] init];
    [self.channelLabel setFont:[UIFont systemFontOfSize:18]];
    [self.channelLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.channelLabel setTextAlignment:NSTextAlignmentLeft];
    [self.channelLabel setText:topic];
    [self.channelLabel setFrame:CGRectMake(50, 6, self.fullViewWidth - 100, 28)];
    
    [topView addSubview:self.channelLabel];
    
    self.teleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 54, 12, 12)];
    [self.teleImageView setImage:[UIImage imageNamed:@"icon_netmeeting_tele"]];
    [topView addSubview:self.teleImageView];
    
    self.signalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 54, 12, 12)];
    [self.signalImageView setImage:[UIImage imageNamed:@"icon_netmeeting_signal_good"]];
    [topView addSubview:self.signalImageView];
    
    self.timeLabel = [[UILabel alloc] init];
    [self.timeLabel setFont:[UIFont systemFontOfSize:14]];
    [self.timeLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.timeLabel setTextAlignment:NSTextAlignmentLeft];
    [self.timeLabel setText:@"00:00"];
    
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(100, MAXFLOAT)];
    [self.timeLabel setFrame:CGRectMake(44, 50, timeSize.width, 20)];
    
    [topView addSubview:self.timeLabel];
    
    self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeSize.width + 54, 50, self.fullViewWidth - timeSize.width - 66 - 60, 20)];
    [self.idLabel setFont:[UIFont systemFontOfSize:14]];
    [self.idLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.idLabel setTextAlignment:NSTextAlignmentLeft];
    [self.idLabel setText:[NSString stringWithFormat:@"ID:%@", self.netMeeting.channelId]];
    
    [topView addSubview:self.idLabel];
    
    [self.view addSubview:topView];
}

- (void)initBottonView {
    UIView *bottomVIew = [[UIView alloc] initWithFrame:CGRectMake(0, self.fullViewHeight - YM_NETMEETING_BOTTOM_HEIGHT, self.fullViewWidth, YM_NETMEETING_BOTTOM_HEIGHT)];
    [bottomVIew setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    
    //speakererView
    self.speakererButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, YM_NETMEETING_IMAGE_SIZE, YM_NETMEETING_IMAGE_SIZE)];
    [self.speakererButton setImage:[UIImage imageNamed:@"icon_netmeeting_speaker_normal"] forState:UIControlStateNormal];
    [self.speakererButton setImage:[UIImage imageNamed:@"icon_netmeeting_speaker_highlight"] forState:UIControlStateSelected];
    [self.speakererButton addTarget:self action:@selector(didClickSpeakererButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.speakererButton setSelected:YES];
    
    UILabel *speakererLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, YM_NETMEETING_IMAGE_SIZE, YM_NETMEETING_VIEW_WIDTH, YM_NETMEETING_VIEW_HEIGHT - YM_NETMEETING_IMAGE_SIZE)];
    [speakererLabel setFont:[UIFont systemFontOfSize:14]];
    [speakererLabel setTextColor:UIColorFromRGB(0xffffff)];
    [speakererLabel setTextAlignment:NSTextAlignmentCenter];
    [speakererLabel setText:@"免提"];
    
    self.speakererView = [[UIView alloc] init];
    [self.speakererView addSubview:self.speakererButton];
    [self.speakererView addSubview:speakererLabel];
    
    //inviteView
    self.inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, YM_NETMEETING_IMAGE_SIZE, YM_NETMEETING_IMAGE_SIZE)];
    [self.inviteButton setImage:[UIImage imageNamed:@"icon_netmeeting_invite_normal"] forState:UIControlStateNormal];
    [self.inviteButton addTarget:self action:@selector(didClickInviteButton) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, YM_NETMEETING_IMAGE_SIZE, YM_NETMEETING_VIEW_WIDTH, YM_NETMEETING_VIEW_HEIGHT - YM_NETMEETING_IMAGE_SIZE)];
    [inviteLabel setFont:[UIFont systemFontOfSize:14]];
    [inviteLabel setTextColor:UIColorFromRGB(0xffffff)];
    [inviteLabel setTextAlignment:NSTextAlignmentCenter];
    [inviteLabel setText:@"邀请"];
    
    self.inviteView = [[UIView alloc] init];
    [self.inviteView addSubview:self.inviteButton];
    [self.inviteView addSubview:inviteLabel];
    
    //managerView
    self.managerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, YM_NETMEETING_IMAGE_SIZE, YM_NETMEETING_IMAGE_SIZE)];
    [self.managerButton setImage:[UIImage imageNamed:@"icon_netmeeting_manager"] forState:UIControlStateNormal];
    [self.managerButton addTarget:self action:@selector(didClickManagerButton) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *managerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, YM_NETMEETING_IMAGE_SIZE, YM_NETMEETING_VIEW_WIDTH, YM_NETMEETING_VIEW_HEIGHT - YM_NETMEETING_IMAGE_SIZE)];
    [managerLabel setFont:[UIFont systemFontOfSize:14]];
    [managerLabel setTextColor:UIColorFromRGB(0xffffff)];
    [managerLabel setTextAlignment:NSTextAlignmentCenter];
    [managerLabel setText:@"参与人"];
    
    self.managerView = [[UIView alloc] init];
    [self.managerView addSubview:self.managerButton];
    [self.managerView addSubview:managerLabel];
    
    //hangUpButton
    self.hangUpButton = [[UIButton alloc] init];
    [self.hangUpButton setImage:[UIImage imageNamed:@"icon_netmeeting_reject"] forState:UIControlStateNormal];
    [self.hangUpButton addTarget:self action:@selector(didClickHangUpButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *childTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.fullViewWidth, YM_NETMEETING_BOTTOM_HEIGHT / 2)];
    [childTopView setBackgroundColor:[UIColor clearColor]];
    UIView *childbottomView = [[UIView alloc] initWithFrame:CGRectMake(0, YM_NETMEETING_BOTTOM_HEIGHT / 2, self.fullViewWidth, YM_NETMEETING_BOTTOM_HEIGHT / 2)];
    [childbottomView setBackgroundColor:[UIColor clearColor]];
    
    [childTopView addSubview:self.inviteView];
    [childTopView addSubview:self.managerView];
    [childTopView addSubview:self.speakererView];
    
    [childbottomView addSubview:self.hangUpButton];
    
    [bottomVIew addSubview:childTopView];
    [bottomVIew addSubview:childbottomView];
    
    [self.view addSubview:bottomVIew];
}

- (void)layoutBottonView {
    CGFloat space1 = (self.fullViewWidth - 2 * YM_NETMEETING_VIEW_MARGIN - 3 * YM_NETMEETING_VIEW_WIDTH) / 2;
    
    [self.speakererView setFrame:CGRectMake(YM_NETMEETING_VIEW_MARGIN, 0, YM_NETMEETING_VIEW_WIDTH, YM_NETMEETING_VIEW_HEIGHT)];
    
    [self.managerView setFrame:CGRectMake(YM_NETMEETING_VIEW_MARGIN + YM_NETMEETING_VIEW_WIDTH + space1, 0, YM_NETMEETING_VIEW_WIDTH, YM_NETMEETING_VIEW_HEIGHT)];
    
    [self.inviteView setFrame:CGRectMake(YM_NETMEETING_VIEW_MARGIN + 2 * (YM_NETMEETING_VIEW_WIDTH + space1), 0, YM_NETMEETING_VIEW_WIDTH, YM_NETMEETING_VIEW_HEIGHT)];
    
    [self.hangUpButton setFrame:CGRectMake((self.fullViewWidth - YM_NETMEETING_HANGUP_SIZE) / 2, 10, YM_NETMEETING_HANGUP_SIZE, YM_NETMEETING_HANGUP_SIZE)];
}

#pragma mark -
#pragma mark action

- (void)didClickHangUpButton{
    [[YYIMChat sharedInstance].chatManager exitNetMeeting:self.channelId];
    [self closeView];
}

#pragma mark -
#pragma mark YYIMChatDelegate

- (void)didJoinNetMeetingSuccessed:(NSString *)channelId elapsed:(NSInteger)elapsed {
    [self loadVideoView];
}

/**
 *  会议中有人被踢
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberkicked:(NSArray *)userArray {
    if ([userArray containsObject:[[YYIMConfig sharedInstance] getUser]]) {
        [self closeView];
    }
}

/**
 *  会议被锁定
 */
- (void)didLockNetMeeting {
    [self updateLockStatus];
}

/**
 *  会议被解锁
 */
- (void)didUnLockNetMeeting {
    [self updateLockStatus];
}

- (void)didNetMeetingEditTopic:(NSString *)topic channelId:(NSString *)channeId {
    if (self.netMeeting.netMeetingType != kYYIMNetMeetingTypeSingleChat) {
        self.channelLabel.text = topic;
    }
}

/**
 *  通知频道成员改变视频状态
 *
 *  @param enable  是否开启
 *  @param userIds 成员id集合
 */
- (void)didNetMeetingMembersEnableVideo:(BOOL)enable userId:(NSString *)userId {
    if ([self.moderator.memberId isEqualToString:userId]) {
        [self loadVideoView];
    }
}

#pragma mark -
#pragma mark private method

- (void)loadChannelData {
    self.netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:self.channelId];
    
    NSArray *members = [[YYIMChat sharedInstance].chatManager getNetMeetingMembersWithChannelId:self.channelId];
    
    for (YYNetMeetingMember *member in members) {
        if (member.isModerator) {
            self.moderator = member;
            break;
        }
    }
}

- (void)updateLockStatus {
    self.netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:self.channelId];
    
    if (self.netMeeting.lock) {
        [self.inviteButton setImage:[UIImage imageNamed:@"icon_netmeeting_invite_disable"] forState:UIControlStateNormal];
    } else {
        [self.inviteButton setImage:[UIImage imageNamed:@"icon_netmeeting_invite_normal"] forState:UIControlStateNormal];
    }
}

/**
 *  加载视频控制
 */
- (void)loadVideoView {
    self.moderator = [[YYIMChat sharedInstance].chatManager getNetMeetingMemberWithChannelId:self.channelId memberId:self.moderator.memberId];
    [self updateMainInfoView:self.moderator];
    [[NetMeetingDispatch sharedInstance] showWindowDetail:self.moderator.memberId channelId:self.channelId];
    
    if (self.moderator.enableVideo) {
        [self showMainVidio];
        [[YYIMChat sharedInstance].chatManager setupNetMeetingRemoteVideo:self.videoMainView userId:self.moderator.memberId];
    } else {
        [self hideMainVidio];
    }
}

- (NSString *)getMainViewUserId {
    return self.moderator.memberId;
}

@end
