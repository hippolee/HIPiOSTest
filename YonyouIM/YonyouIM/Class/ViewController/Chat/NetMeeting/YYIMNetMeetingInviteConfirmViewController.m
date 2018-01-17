//
//  YYIMNetMeetingInviteConfirmViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/2/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingInviteConfirmViewController.h"
#import "YYIMColorHelper.h"
#import "YYIMChatHeader.h"
#import "UIImageView+WebCache.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMUtility.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>


@interface YYIMNetMeetingInviteConfirmViewController () <YYIMChatDelegate>{
}

//邀请人头像
@property (strong, nonatomic) UIImageView *operatorImageView;

//邀请人名字
@property (strong, nonatomic) UILabel *operatorLabel;

@property (strong, nonatomic) NSURL *inviteUrl;
@property (strong, nonatomic) AVAudioPlayer *player;

@property (assign, nonatomic) SystemSoundID soundId;

@end

@implementation YYIMNetMeetingInviteConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat showWidth = self.view.frame.size.width;
    CGFloat showHeight = self.view.frame.size.height;
    
    [self.view setBackgroundColor:UIColorFromRGB(0x1e2129)];
    
    //初始化按钮
    UIButton *rejectBtn = [[UIButton alloc] initWithFrame:CGRectMake(46, showHeight - 100, 60, 60)];
    [rejectBtn setImage:[UIImage imageNamed:@"icon_netmeeting_reject"] forState:UIControlStateNormal];
    [rejectBtn addTarget:self action:@selector(refuseAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *refuseLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, showHeight - 30, 60, 20)];
    [refuseLabel setFont:[UIFont systemFontOfSize:12]];
    [refuseLabel setTextColor:UIColorFromRGB(0xffffff)];
    [refuseLabel setTextAlignment:NSTextAlignmentCenter];
    refuseLabel.text = @"挂断";
    
    UIButton *answerBtn = [[UIButton alloc] initWithFrame:CGRectMake(showWidth - 106, showHeight - 100, 60, 60)];
    [answerBtn setImage:[UIImage imageNamed:@"icon_netmeeting_answer"] forState:UIControlStateNormal];
    [answerBtn addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *acceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(showWidth - 106, showHeight - 30, 60, 20)];
    [acceptLabel setFont:[UIFont systemFontOfSize:12]];
    [acceptLabel setTextColor:UIColorFromRGB(0xffffff)];
    [acceptLabel setTextAlignment:NSTextAlignmentCenter];
    acceptLabel.text = @"接听";
    
    [self.view addSubview:rejectBtn];
    [self.view addSubview:answerBtn];
    [self.view addSubview:refuseLabel];
    [self.view addSubview:acceptLabel];
    
    //初始化邀请人
    self.operatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake((showWidth - 96) / 2, 48, 96, 96)];
    CALayer *layer = [self.operatorImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:48];
    
    self.operatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, showWidth, 24)];
    [self.operatorLabel setFont:[UIFont systemFontOfSize:18]];
    [self.operatorLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.operatorLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, showWidth, 20)];
    [inviteLabel setFont:[UIFont systemFontOfSize:14]];
    [inviteLabel setTextColor:UIColorFromRGB(0x7c8083)];
    [inviteLabel setTextAlignment:NSTextAlignmentCenter];
    [inviteLabel setText:@"邀请你进行视频通话"];
    
    [self.view addSubview:self.operatorImageView];
    [self.view addSubview:self.operatorLabel];
    [self.view addSubview:inviteLabel];
    
    //播放声音
    self.inviteUrl = [[NSBundle mainBundle] URLForResource:@"netmeeting" withExtension:@"wav"];
    
    if (self.inviteUrl) {
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)self.inviteUrl, &soundID);
        
        if (soundID > 0) {
            self.soundId = soundID;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadChannelData];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if (self.soundId > 0) {
        AudioServicesPlaySystemSound(self.soundId);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.soundId > 0) {
        AudioServicesDisposeSystemSoundID(self.soundId);
    }
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

#pragma mark -
#pragma mark YYIMChatDelegate

- (void)didNetMeetingInviteTimeout:(NSString *)channelId userId:(NSString *)userId {
    if ([self.channelId isEqualToString:channelId] && [userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[NetMeetingDispatch sharedInstance] didNetMeetingDispatchNeedClose];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark action

- (void)refuseAction {
    [[YYIMChat sharedInstance].chatManager refuseEnterNetMeeting:self.channelId];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NetMeetingDispatch sharedInstance] didNetMeetingDispatchNeedClose];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)answerAction {
    if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
        [[NetMeetingDispatch sharedInstance] showHint:@"当前有会议在进行，操作被禁止" from:self];
    } else {
        [[YYIMChat sharedInstance].chatManager agreeEnterNetMeeting:self.channelId];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[NetMeetingDispatch sharedInstance] didNetMeetingDispatchNeedClose];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark private method

- (void)reloadChannelData {
    YYNetMeeting *netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:self.channelId];
    
    YYUser *operator = [[YYIMChat sharedInstance].chatManager getUserWithId:netMeeting.inviterId];
    NSString *operatorName = [operator userName];
    
    [self.operatorLabel setText:operatorName];
    
    UIImage *operatorImage = [UIImage imageWithDispName:operatorName];
    [self.operatorImageView sd_setImageWithURL:[NSURL URLWithString:[operator getUserPhoto]] placeholderImage:operatorImage];
}

@end
