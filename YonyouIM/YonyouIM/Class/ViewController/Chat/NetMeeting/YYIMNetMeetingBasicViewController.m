//
//  YYIMNetMeetingBasicViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingBasicViewController.h"
#import "ChatSelNavController.h"
#import "ChatSelViewController.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "GlobalInviteViewController.h"
#import "YYIMUIDefs.h"
#import "YYIMHeadPhonesManager.h"
#import "YYIMNetMeetingManagerViewController.h"
#import "UINavigationController+YMInvite.h"
#import "YYIMColorHelper.h"
#import "YYIMWeiXinManager.h"
#import "NetMeetingDispatch.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"
#import "YYIMHeadPhonesManager.h"

typedef NS_ENUM(NSUInteger, YYIMNetMeetingSignal) {
    kYYIMNetMeetingSignalGood     = 0,  //图片好
    kYYIMNetMeetingSignalGeneral  = 1,  //图片普通
    kYYIMNetMeetingSignalPoor     = 2,  //图片差
};

@interface YYIMNetMeetingBasicViewController ()<YYIMChatDelegate, YMChatSelDelegate, UIActionSheetDelegate, GlobalInviteViewControllerDelegate>

@end

@implementation YYIMNetMeetingBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.fullViewWidth = self.view.frame.size.width;
    self.fullViewHeight = self.view.frame.size.height;
    
    [self.view setBackgroundColor:UIColorFromRGB(0x1e2129)];
    
    [self loadChannelData];
    
    self.infoMainImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.fullViewWidth - 100)/2, 120, 100, 100)];
    CALayer *layer = [self.infoMainImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:50];
    
    self.infoMainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 230, self.fullViewWidth - 40, 30)];
    [self.infoMainLabel setFont:[UIFont systemFontOfSize:22]];
    [self.infoMainLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.infoMainLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.infoMainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.fullViewWidth, self.fullViewHeight)];
    [self.infoMainView setBackgroundColor:UIColorFromRGB(0x1e2129)];
    [self.infoMainView addSubview:self.infoMainImage];
    [self.infoMainView addSubview:self.infoMainLabel];
    
    [self.view addSubview:self.infoMainView];
    self.infoMainView.hidden = YES;
    
    self.videoMainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.fullViewWidth, self.fullViewHeight)];
    [self.view addSubview:self.videoMainView];
    self.videoMainView.hidden = YES;
    
    [self initTopView];
    [self initBottonView];
    [self layoutBottonView];
        
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headPhoneChange:) name:YYIM_NOTIFICATION_HEADPHONE_CHANGE object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)initTopView {
}

- (void)initBottonView {
}

- (void)layoutBottonView {
}

#pragma mark -
#pragma mark YYIMChatDelegate
- (void)didNetMeetingOccurError:(YYIMError *)error {
    YYIMLogError(@"错误号：%ld,错误信息：%@", (long)error.errorCode, error.errorMsg);
}

- (void)didNetMeetingReportStats:(NSUInteger)duration sendBytes:(NSUInteger)sendBytes receiveBytes:(NSUInteger)receiveBytes {
}

- (void)didNetMeetingConnectionLost {
    [[NetMeetingDispatch sharedInstance] showHint:@"没有网络" from:self];
}

- (void)didRejoinNetMeeting:(NSString *)channelId withUserId:(NSString *)userId elapsed:(NSInteger)elapsed {
}

- (void)didNetMeetingNetworkQuality:(YYIMNetMeetingQuality)quality {
    if (!self.quality) {
        self.quality = kYYIMNetMeetingQualityUnknown;
    }
    
    if (quality == self.quality) {
        return;
    }
    
    self.quality = quality;
    
    switch (quality) {
        case kYYIMNetMeetingQualityExcellent:
            [self updateSignal:kYYIMNetMeetingSignalGood];
            break;
        case kYYIMNetMeetingQualityGood:
            [self updateSignal:kYYIMNetMeetingSignalGood];
            break;
        case kYYIMNetMeetingQualityPoor:
            [self updateSignal:kYYIMNetMeetingSignalGeneral];
            break;
        case kYYIMNetMeetingQualityBad:
            [self updateSignal:kYYIMNetMeetingSignalGeneral];
            break;
        case kYYIMNetMeetingQualityVBad:
            [self updateSignal:kYYIMNetMeetingSignalPoor];
            break;
        case kYYIMNetMeetingQualityDown:
            [self updateSignal:kYYIMNetMeetingSignalPoor];
            break;
        default:
            break;
    }
}

/**
 *  邀请了没有通信权限的用户
 *
 *  @param channelId 频道id
 *  @param userArray 用户数组
 */
- (void)didNetMeetingInviteMisMatchMember:(NSString *)channelId userArray:(NSArray *)userArray {
    if ([channelId isEqualToString:self.channelId]) {
        if (!userArray || userArray.count == 0) {
            return;
        }
        
        YYUser *user = [userArray objectAtIndex:0];
        NSMutableString *misMatchText = [NSMutableString stringWithString:user.userName];
        
        if (userArray.count > 1) {
            YYUser *userSecond = [userArray objectAtIndex:1];
            [misMatchText appendString:@"、"];
            [misMatchText appendString:userSecond.userName];
            
        }
        
        if (userArray.count > 2) {
            [misMatchText appendString:@"等"];
            [misMatchText appendString:[NSString stringWithFormat:@"%ld", (unsigned long)userArray.count]];
            [misMatchText appendString:@"人"];
        }
        
        [misMatchText appendString:@"无通信权限"];
        
        [[NetMeetingDispatch sharedInstance] showHint:misMatchText from:self];
    }
}

#pragma mark -
#pragma mark YMChatSelDelegate

- (void)didSelectChatId:(NSString *)chatId chatType:(NSString *)chatType {
    [[YYIMChat sharedInstance].chatManager sendNetMeetingMessage:chatId chatType:chatType netMeeting:self.netMeeting];
}


#pragma mark -
#pragma mark GlobalInviteViewControllerDelegate
- (void)didGlobalInviteViewController:(UIViewController *)viewController InviteUsers:(NSArray *)userArray {
    NSMutableArray *inviteUserArray = [NSMutableArray arrayWithArray:userArray];
    NSMutableArray *userIdArray = [NSMutableArray array];
    
    for (id user in inviteUserArray) {
        if ([user isKindOfClass:[YYUser class]]) {
            [userIdArray addObject:[(YYUser *)user userId]];
        } else if ([user isKindOfClass:[YYRoster class]]) {
            [userIdArray addObject:[(YYRoster *)user rosterId]];
        } else if ([user isKindOfClass:[YYChatGroupMember class]]) {
            [userIdArray addObject:[(YYChatGroupMember *)user memberId]];
        }
    }
    
    if ([userIdArray count] <= 0) {
        [[NetMeetingDispatch sharedInstance] showHint:@"请选择邀请成员" from:self];
        return;
    }
    
    [[YYIMChat sharedInstance].chatManager inviteNetMeetingMember:self.channelId invitees:userIdArray];
    
    [self.navigationController popToViewController:self animated:YES];
    [self.navigationController clearData];
}

#pragma mark -
#pragma mark NetMeetingDispatchDelegate delegate

- (void)didNetMeetingTimerChange {
    self.duration++;
    NSUInteger seconds = self.duration % 60;
    NSUInteger minutes = (self.duration - seconds) / 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)minutes, (unsigned long)seconds];
    
    BOOL isSpeakerphoneEnabled = [[YYIMChat sharedInstance].chatManager isNetMeetingSpeakerphoneEnabled];
    BOOL hasHeadPhone = [[YYIMHeadPhonesManager sharedInstance] HeadPhoneEnable];
    
    //耳机状态只能使用听筒
    if (isSpeakerphoneEnabled && hasHeadPhone) {
        YYIMLogDebug(@"HeadPhone-强制关闭扬声器");
        [[YYIMChat sharedInstance].chatManager setNetMeetingEnableSpeakerphone:NO];
    }
    
    //没有耳机按照用户的想法设置，之所以定时检查，是因为第三方的扬声器控制可能存在sdk初始化延迟问题。
    if (self.speakerCommand != isSpeakerphoneEnabled && !hasHeadPhone) {
        YYIMLogDebug(@"HeadPhone-没有耳机，按照用户期望设置扬声器状态:%@", self.speakerCommand ? @"YES" : @"NO");
        [[YYIMChat sharedInstance].chatManager setNetMeetingEnableSpeakerphone:self.speakerCommand];
    }

}

#pragma mark -
#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case NETMEETING_VIEWCONTROLLER_UIACTIONSHEET_TAG_END:
            switch (buttonIndex) {
                case 0: {
                    [[YYIMChat sharedInstance].chatManager endNetMeeting:self.channelId];
                    [self closeView];
                }
                    break;
                case 1: {
                    [self openManagerView];
                }
                    break;
                default:
                    break;
            }
            break;
        case NETMEETING_VIEWCONTROLLER_UIACTIONSHEET_TAG_INVITE:
            switch (buttonIndex) {
                case 0: {
                    [self inviteNetMeeting];
                    break;
                }
                case 1: {
                    [self shareNetMeeting];
                    break;
                }
                case 2: {
                    [self shareToWeiXin];
                    break;
                }
                case 3: {
                    [self copyToPasteBoard];
                    break;
                }
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark action
- (void)didClickInviteButton {
    if (self.netMeeting.lock) {
        [[NetMeetingDispatch sharedInstance] showHint:@"会议已加锁" from:self];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邀请同事", @"分享到用友IM", @"分享到微信", @"复制会议ID",  nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.tag = NETMEETING_VIEWCONTROLLER_UIACTIONSHEET_TAG_INVITE;
    [actionSheet showInView:self.view];
}

- (void)didClickSpeakererButton:(UIButton *)btn {
    BOOL useSpeaker = !btn.selected;
    self.speakerCommand = useSpeaker;
    [self.speakererButton setSelected:useSpeaker];
    
    BOOL hasHeadPhone = [[YYIMHeadPhonesManager sharedInstance] HeadPhoneEnable];
    if (!hasHeadPhone) {
        [[YYIMChat sharedInstance].chatManager setNetMeetingEnableSpeakerphone:useSpeaker];
    }
}

- (void)didClickManagerButton {
    [self openManagerView];
}

- (void)switchCamera {
    [[YYIMChat sharedInstance].chatManager switchNetMeetingCamera];
}

- (void)minimize {
    [[NetMeetingDispatch sharedInstance] didNetMeetingDispatchNeedMinimize];
    [[NetMeetingDispatch sharedInstance] showWindowDetail:[self getMainViewUserId] channelId:self.channelId];
}

#pragma mark -
#pragma mark private method
- (void)inviteNetMeeting {
    GlobalInviteViewController *globalInviteViewController = [[GlobalInviteViewController alloc] initWithNibName:@"GlobalInviteViewController" bundle:nil];
    
    globalInviteViewController.delegate = self;
    globalInviteViewController.actionName = @"成员邀请";
    globalInviteViewController.channelId = self.channelId;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:globalInviteViewController animated:YES];
}

- (void)shareNetMeeting {
    ChatSelViewController *chatSelViewController = [[ChatSelViewController alloc] initWithNibName:@"ChatSelViewController" bundle:nil];
    ChatSelNavController *chatSelNavController = [[ChatSelNavController alloc] initWithRootViewController:chatSelViewController];
    [YYIMUtility genThemeNavController:chatSelNavController];
    chatSelNavController.chatSelDelegate = self;
    [self presentViewController:chatSelNavController animated:YES completion:nil];
}

- (void)shareToWeiXin {
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
    NSString *timeString = [YYIMUtility genTimeString:self.netMeeting.createTime dateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *netMeetingType;
    
    switch (self.netMeeting.netMeetingType) {
        case kYYIMNetMeetingTypeMeeting:
        case kYYIMNetMeetingTypeGroupChat:
            netMeetingType = @"会议";
            break;
        case kYYIMNetMeetingTypeLive:
            netMeetingType = @"直播";
        default:
            netMeetingType = @"会议";
            break;
    }
    
    NSString *text = [NSString stringWithFormat:@"%@发起：%@,开始时间：%@,请登录用友IM客户端，加入会议，会议ID号：%@", user.userName, self.netMeeting.topic, timeString, self.channelId];
    
    [YYIMWeiXinManager sendWinXinText:text scene:0];
}

- (void)copyToPasteBoard {
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = self.netMeeting.channelId;
    
    [[NetMeetingDispatch sharedInstance] showHint:@"已成功复制到剪贴板" from:self];
}

- (void)closeView {
    
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.navigationController setNavigationBarHidden:NO];
    
    [[NetMeetingDispatch sharedInstance] didNetMeetingDispatchNeedClose];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openManagerView {
    //进入会议页面
    YYIMNetMeetingManagerViewController *netMeetingManagerViewController = [[YYIMNetMeetingManagerViewController alloc] initWithNibName:nil bundle:nil];
    
    //设置频道号
    netMeetingManagerViewController.channelId = self.channelId;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:netMeetingManagerViewController animated:YES];
}

- (void)loadChannelData {
}

- (NSString *)getMainViewUserId {
    return @"";
}

- (void)updateSignal:(YYIMNetMeetingSignal)signal {
    switch (signal) {
        case kYYIMNetMeetingSignalGood:
            self.signalImageView.image = [UIImage imageNamed:@"icon_netmeeting_signal_good"];
            break;
        case kYYIMNetMeetingSignalGeneral:
            self.signalImageView.image = [UIImage imageNamed:@"icon_netmeeting_signal_normal"];
            break;
        case kYYIMNetMeetingSignalPoor:
            self.signalImageView.image = [UIImage imageNamed:@"icon_netmeeting_signal_bad"];
            break;
        default:
            break;
    }
}

- (void)updateMainInfoView:(YYNetMeetingMember *)member {
    UIImage *image = [UIImage imageWithDispName:member.memberName];
    
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    
    [self.infoMainImage sd_setImageWithURL:[NSURL URLWithString:member.getMemberPhoto]
                          placeholderImage:image options:SDWebImageDelayPlaceholder];
    
    self.infoMainLabel.text = member.memberName;
}

- (void)showMainVidio {
    self.videoMainView.hidden = NO;
    self.infoMainView.hidden = YES;
}

- (void)hideMainVidio {
    self.videoMainView.hidden = YES;
    self.infoMainView.hidden = NO;
}

#pragma mark -
#pragma mark notification
- (void)headPhoneChange:(NSNotification *)notification {
    BOOL headPhoneEnable = [notification.object boolValue];
    
    if (headPhoneEnable) {
        YYIMLogDebug(@"HeadPhone-动作:插入");
        //插入耳机强行切换成听筒
        YYIMLogDebug(@"HeadPhone-强制关闭扬声器");
        [[YYIMChat sharedInstance].chatManager setNetMeetingEnableSpeakerphone:NO];
    } else {
        YYIMLogDebug(@"HeadPhone-动作:拔出");
        YYIMLogDebug(@"HeadPhone-没有耳机，按照用户期望设置扬声器状态:%@", self.speakerCommand ? @"YES" : @"NO");
        //拔出耳机恢复到用户的想法
        if (self.speakerCommand) {
            [[YYIMChat sharedInstance].chatManager setNetMeetingEnableSpeakerphone:YES];
        } else {
            [[YYIMChat sharedInstance].chatManager setNetMeetingEnableSpeakerphone:NO];
        }
    }
}

@end
