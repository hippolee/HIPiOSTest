//
//  YYIMNetMeetingManagerViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingManagerViewController.h"
#import "ConferenceManagerCell.h"
#import "SingleLineSelCell.h"
#import "SingleLineCell2.h"
#import "YYIMUtility.h"
#import "YYIMChatHeader.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "AppDelegate.h"
#import "UIViewController+HUDCategory.h"
#import "NetMeetingDispatch.h"
#import "GlobalInviteViewController.h"
#import "ChatSelViewController.h"
#import "ChatSelNavController.h"
#import "YYIMWeiXinManager.h"
#import "UINavigationController+YMInvite.h"

@interface YYIMNetMeetingManagerViewController () <YYIMChatDelegate, UIActionSheetDelegate, UIAlertViewDelegate, YMChatSelDelegate, GlobalInviteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) YYNetMeeting *netMeeting;

@property (strong, nonatomic) NSArray *channelMembers;

@property (strong, nonatomic) NSMutableArray *selectedMemberIds;

@property (strong, nonatomic) YYNetMeetingMember *moderator;

@property BOOL isEdit;

@property (strong, nonatomic) NSString *moderatorNewId;

@property (retain, nonatomic) NSArray *letterArray;

@property (retain, nonatomic) NSDictionary *dataDic;

@end

@implementation YYIMNetMeetingManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"参与人";
    
    self.selectedMemberIds = [NSMutableArray array];
    
    [self.tableView setAllowsSelection:YES];
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"ConferenceManagerCell" bundle:nil] forCellReuseIdentifier:@"ConferenceManagerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineSelCell" bundle:nil] forCellReuseIdentifier:@"SingleLineSelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    
    // 索引样式
    if (YYIM_iOS7) {
        [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    }
    
    [self.tableView setSectionIndexColor:UIColorFromRGB(0xb6b6b6)];
    
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

#pragma mark -
#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.netMeeting.lock) {
        switch (buttonIndex) {
            case 0:
                [[YYIMChat sharedInstance].chatManager unlockNetMeeting:self.channelId];
                break;
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                [[YYIMChat sharedInstance].chatManager lockNetMeeting:self.channelId];
                break;
            case 1: {
                [self inviteNetMeeting];
                break;
            }
            case 2: {
                [self shareNetMeeting];
                break;
            }
            case 3: {
                [self shareToWeiXin];
                break;
            }
            case 4: {
                [self copyToPasteBoard];
                break;
            }
            default:
                break;
        }

    }
}

#pragma mark -
#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 0: {
            if (buttonIndex == 1) {
                UITextField *textField=[alertView textFieldAtIndex:0];
                NSString *newVal = textField.text;
                
                if (newVal && newVal.length > 0) {
                    //调用修改主题
                    [[YYIMChat sharedInstance].chatManager editNetMeetingTopic:self.netMeeting.channelId topic:newVal];
                } else {
                    [[NetMeetingDispatch sharedInstance] showHint:@"主题不能为空" from:self];
                }
            }
            
            break;
        }
        case 20: {
            switch (buttonIndex) {
                case 1:
                    [[YYIMChat sharedInstance].chatManager roleConversionOfNetMeeting:self.channelId withUserId:self.moderatorNewId];
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
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
#pragma mark table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + self.letterArray.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.letterArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    return index + 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section > 2) {
        return [self.letterArray objectAtIndex:section - 3];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        switch (self.netMeeting.netMeetingType) {
            case kYYIMNetMeetingTypeMeeting:
            case kYYIMNetMeetingTypeGroupChat:
                if ([self.moderator.memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                    return 2;
                } else {
                    return 1;
                }
            case kYYIMNetMeetingTypeLive:
                return 1;
            default:
                return 0;
        }
    } else if (section == 2) {
        return 0;
    } else {
        return [(NSArray *)[self.dataDic objectForKey:[self.letterArray objectAtIndex:section - 3]] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 10;
            break;
        case 1:
            return 10;
            break;
        case 2:
            return 30;
        default:
            return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionView = [[UIView alloc] init];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    
    switch (section) {
        case 0:
        case 1: {
            sectionView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 10);
            UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
            UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 10, tableView.bounds.size.width, 0.5)];
            [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            [sectionView addSubview:sepView];
            [sectionView addSubview:sepView2];
            
            break;
        }
        case 2: {
            sectionView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 30);
            
            UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
            UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 30, tableView.bounds.size.width, 0.5)];
            [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            [sectionView addSubview:sepView];
            [sectionView addSubview:sepView2];
            
            UILabel *memberLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 2, 100, 26)];
            [memberLabel setFont:[UIFont systemFontOfSize:18]];
            [memberLabel setTextColor:UIColorFromRGB(0xa3a3a3)];
            [memberLabel setTextAlignment:NSTextAlignmentLeft];
            [memberLabel setText:@"参会人员"];
            [sectionView addSubview:memberLabel];
            
            if ([self isModerator]) {
                UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 100, 2, 92, 26)];
                [editButton setBackgroundColor:[UIColor clearColor]];
                [editButton setTitle:self.isEdit ? @"确定" : @"移除成员" forState:UIControlStateNormal];
                [editButton addTarget:self action:@selector(editChange) forControlEvents:UIControlEventTouchUpInside];
                [editButton setTitleColor:UIColorFromRGB(0x067dff) forState:UIControlStateNormal];
                [sectionView addSubview:editButton];
            }
        
            break;
        }
        default: {
            NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
            
            if (sectionTitle == nil) {
                return nil;
            }
            
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(10, 0, 320, 24);
            label.font = [UIFont systemFontOfSize:14];
            [label setTextColor:UIColorFromRGB(0x4e4e4e)];
            label.text = sectionTitle;
            
            UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
            [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 24, tableView.bounds.size.width, 0.5)];
            [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            
            sectionView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 24);
            [sectionView addSubview:label];
            [sectionView addSubview:sepView];
            [sectionView addSubview:sepView2];
            break;
        }
    }
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell2"];
            [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
            
            if ([self isModerator]) {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            [cell reuse];
            
            switch (indexPath.row) {
                case 0: {
                    [cell setName:@"会议主题"];
                    [cell setDetail:self.netMeeting.topic];
                }
                default:
                    break;
            }
            
            return cell;
        }
        case 1: {
            SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell2"];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell reuse];
            
            if (self.netMeeting.netMeetingType == kYYIMNetMeetingTypeLive || ![self.moderator.memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                switch (indexPath.row) {
                    case 0: {
                        NSString *moderatorShow = [NSString stringWithFormat:@"%@ (主持人)", self.moderator.memberName];
                        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:moderatorShow];
                        
                        [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x4e4e4e) range:NSMakeRange(0,self.moderator.memberName.length)];
                        [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xc2c0c0) range:NSMakeRange(self.moderator.memberName.length,6)];
                        
                        [cell setAttributeName:str];
                        
                        break;
                    }
                        
                    default:
                        break;
                }

            } else {
                switch (indexPath.row) {
                    case 0: {
                        [cell setName:@"全部禁言"];
                        [cell setSwitchState:self.netMeeting.muteAll enable:[self isModerator]];
                        [cell.switchControl setTag:0];
                        [cell.switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
                        
                        break;
                    }
                    case 1: {
                        NSString *moderatorShow = [NSString stringWithFormat:@"%@ (主持人)", self.moderator.memberName];
                        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:moderatorShow];
                        
                        [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x4e4e4e) range:NSMakeRange(0,self.moderator.memberName.length)];
                        [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xc2c0c0) range:NSMakeRange(self.moderator.memberName.length,6)];
                        
                        [cell setAttributeName:str];
                        
                        break;
                    }
                        
                    default:
                        break;
                }

            }
            
            return cell;
        }
        case 2: {
            return nil;
        }
            
        default: {
            // 取数据
            YYNetMeetingMember *member = [self getDataWithIndexPath:indexPath];
            
            if (self.isEdit) {
                SingleLineSelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineSelCell"];
                [cell reuse];
                [cell setImageRadius:16.0f];
                [cell setName:member.memberName];
                [cell setHeadImageWithUrl:[member getMemberPhoto] placeholderName:member.memberName];
                
                if (member.inviteState != kYYIMNetMeetingInviteStateJoined) {
                    [cell setSelectEnable:NO];
                } else {
                    [cell setSelectEnable:YES];
                }
                
                if ([self.selectedMemberIds containsObject:member.memberId]) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                
                return cell;
            } else {
                ConferenceManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConferenceManagerCell"];
                [cell setImageRadius:16.0f];
                [cell setName:member.memberName];
                [cell setHeadImageWithUrl:[member getMemberPhoto] placeholderName:member.memberName];
                [cell setConferenceMember:member isModerator:[self isModerator] conferenceType:self.netMeeting.netMeetingType];
                
                return cell;
            }
        }
    }
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isModerator]) {
        return nil;
    }
    
    //人员列表非编辑态不能选择
    if (!self.isEdit && indexPath.section > 2) {
        return nil;
    }
    
     //主持人相关行非编辑态不能选择
    if (indexPath.section == 1) {
        return nil;
    }
    
     //编辑态不能改名
    if (self.isEdit && indexPath.section == 0) {
        return nil;
    }
    
    //非加入状态的用户不能选择剔除
    if (self.isEdit && indexPath.section > 2) {
        YYNetMeetingMember *member = [self getDataWithIndexPath:indexPath];
        
        if (member.inviteState != kYYIMNetMeetingInviteStateJoined) {
            return nil;
        }
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && !self.isEdit) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改会议主题" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = 0;
        UITextField *textField = [alertView textFieldAtIndex:0];
        [textField setText:self.netMeeting.topic];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setKeyboardType:UIKeyboardTypeDefault];
        
        [alertView show];
    } else if (indexPath.section > 2 && self.isEdit) {
        YYNetMeetingMember *member = [self getDataWithIndexPath:indexPath];
        
        if (![self.selectedMemberIds containsObject:member.memberId]) {
            [self.selectedMemberIds addObject:member.memberId];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 2) {
        return;
    }
    
    if (self.isEdit) {
        YYNetMeetingMember *member = [self getDataWithIndexPath:indexPath];
        
        [self.selectedMemberIds removeObject:member.memberId];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

#pragma mark -
#pragma mark yyimchat delegate

- (void)didNetMeetingInvited:(NSString *)channelId userArray:(NSArray *)userArray {
    if ([channelId isEqualToString:self.channelId]) {
        [self reloadData];
    }
}

/**
 *  会议中有人进入
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberEnter:(NSString *)userId {
    [self reloadData];
}

/**
 *  会议中有人被踢
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberkicked:(NSString *)userId{
    [self reloadData];
}

/**
 *  会议中有人退出
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberExit:(NSString *)userId {
    [self reloadData];
}

/**
 *  因为忙而不能接听
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberBusy:(NSString *)userId {
    [self reloadData];
}

/**
 *  拒绝参加会议
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberRefuse:(NSString *)userId {
    [self reloadData];
}

/**
 *  邀请超时的回调
 *
 *  @param channelId 频道id
 *  @param userId    用户id
 */
- (void)didNetMeetingInviteTimeout:(NSString *)channelId userId:(NSString *)userId {
    [self reloadData];
}

/**
 *  会议中有人主持人发生变更
 *
 *  @param oldUserId 老主持人id
 *  @param newUserId 新主持人id
 */
- (void)didNetMeetingModeratorChange:(NSString *)oldUserId to:(NSString *)newUserId {
    [self reloadData];
}

/**
 *  会议被锁定
 */
- (void)didLockNetMeeting {
    [self reloadData];
}

/**
 *  会议被解锁
 */
- (void)didUnLockNetMeeting {
    [self reloadData];
}

/**
 *  被要求在频道内禁言
 */
- (void)didNetMeetingDisableSpeak:(NSString *)userId {
    [self reloadData];
}

/**
 *  被要求在频道内取消禁言
 */
- (void)didNetMeetingEnableSpeak:(NSString *)userId {
    [self reloadData];
}

- (void)didNetMeetingEditTopic:(NSString *)topic channelId:(NSString *)channeId {
    [self reloadData];
}

- (void)didNotNetMeetingEditTopic:(NSString *)channeId error:(YYIMError *)error {
    if ([channeId isEqualToString:self.channelId]) {
        if (error.errorCode == YMERROR_CODE_MISS_PARAMETER) {
            [[NetMeetingDispatch sharedInstance] showHint:error.errorMsg from:self];
        } else {
            [[NetMeetingDispatch sharedInstance] showHint:@"编辑主题失败" from:self];
        }
    }
}

#pragma mark -
#pragma mark private method

- (void)didSwitch:(UISwitch *)switchControl {
    if (switchControl.isOn) {
        [[YYIMChat sharedInstance].chatManager disableAllSpeakFromNetMeeting:self.channelId];
    } else {
        [[YYIMChat sharedInstance].chatManager enableAllSpeakFromNetMeeting:self.channelId];
    }
}

- (void)backAction {
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadData {
    self.netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:self.channelId];
    
    NSArray *members = [[YYIMChat sharedInstance].chatManager getNetMeetingMembersWithChannelId:self.channelId];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (YYNetMeetingMember *member in members) {
        if (member.isModerator) {
            self.moderator = member;
        } else {
            if (member.inviteState == kYYIMNetMeetingInviteStateJoined
                || member.inviteState == kYYIMNetMeetingInviteStateInviting
                || member.inviteState == kYYIMNetMeetingInviteStateTimeout
                || member.inviteState == kYYIMNetMeetingInviteStateBusy
                ) {
                [array addObject:member];
            }
        }
    }
    
    self.channelMembers = array;
    [self generateDataDic];
    [self.tableView reloadData];
    
    if ([self.moderator.memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(openActionSheet)]];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)generateDataDic {
    NSMutableArray *letterArray = [NSMutableArray array];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
    for (YYNetMeetingMember *member in self.channelMembers) {
        if (![letterArray containsObject:[member getFirstLetter]]) {
            [letterArray addObject:[member getFirstLetter]];
        }
        
        NSMutableArray *array = [dataDic objectForKey:[member getFirstLetter]];
        
        if (!array) {
            array = [NSMutableArray array];
            [dataDic setObject:array forKey:[member firstLetter]];
        }
        
        [array addObject:member];
    }
    
    self.letterArray = letterArray;
    self.dataDic = dataDic;
}

- (YYNetMeetingMember *)getDataWithIndexPath:(NSIndexPath *) indexPath {
    NSArray *array = [self.dataDic objectForKey:[self.letterArray objectAtIndex:indexPath.section - 3]];
    YYNetMeetingMember *member = [array objectAtIndex:indexPath.row];
    return member;
}

- (void)openActionSheet {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邀请同事", @"分享到用友IM", @"分享到微信", @"复制会议ID",  nil];
    if (self.netMeeting.lock) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"会议解锁", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [actionSheet showInView:self.view];

    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"会议加锁", @"邀请同事", @"分享到用友IM", @"分享到微信", @"复制会议ID",  nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [actionSheet showInView:self.view];
    }
}

- (BOOL)isModerator {
    return [self.moderator.memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]];
}

- (void)editChange {
    self.isEdit = !self.isEdit;
    
    if (!self.isEdit) {
        [self.tableView setAllowsSelection:YES];
        
        if (self.selectedMemberIds.count > 0) {
            [[YYIMChat sharedInstance].chatManager kickMemberFromNetMeeting:self.channelId memberArray:self.selectedMemberIds];
        }
    } else {
        [self.tableView setAllowsMultipleSelection:YES];
    }
    
    [self.selectedMemberIds removeAllObjects];
    [self.tableView reloadData];
}

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    YYIMLogDebug(@"%@",userInfo);
    
    if (![self isModerator]) {
        return;
    }
    
    YYNetMeetingMember *member = [userInfo objectForKey:kYMConferenceManagerPressedMember];
    NSNumber *typeNum = [userInfo objectForKey:kYMConferenceManagerPressedType];
    
    if ([typeNum intValue] == 0) {
        //切换主持人,弹框把这个比较重要
        self.moderatorNewId = member.memberId;
        
        UIAlertView *roleConversionAlertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确认将主持人权限转移给%@?",member.memberName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        roleConversionAlertView.tag = 20;
        [roleConversionAlertView show];
        
    } else if ([typeNum intValue] && !self.netMeeting.muteAll) {
        //最新的禁言状态
        BOOL forbidState = member.forbidAudio;
        
        if (forbidState) {
            [[YYIMChat sharedInstance].chatManager enableMemberSpeakFromNetMeeting:self.channelId userId:member.memberId];
        } else {
            [[YYIMChat sharedInstance].chatManager disableMemberSpeakFromNetMeeting:self.channelId userId:member.memberId];
        }
    }
}

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


@end
