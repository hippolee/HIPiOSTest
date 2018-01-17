//
//  YYIMNetMeetingEditViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/18.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingEditViewController.h"
#import "YYIMChatHeader.h"
#import "YYIMColorHelper.h"
#import "SingleLineCell2.h"
#import "UserCollectionViewCell.h"
#import "GlobalInviteViewController.h"
#import "UserViewController.h"
#import "UIViewController+HUDCategory.h"
#import "UINavigationController+YMInvite.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "YYIMDatePickerView.h"

@interface YYIMNetMeetingEditViewController () <YYIMDatePickerViewDelegate>

// 当前的成员
@property (retain, nonatomic) NSMutableArray *inviteUserArray;

@property (strong, nonatomic) YYIMDatePickerView *datePickerView;

@property CGFloat lastTextViewHeight;

@property BOOL isCreateor;
@property BOOL isMemberEditing;
//是否是编辑状态
@property BOOL editState;

@property (strong, nonatomic) UILabel *placeHolderLabel;

@end

@implementation YYIMNetMeetingEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lastTextViewHeight = AGENDA_TEXT_DEFAULT_HEIGHT;
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    // 隐藏多余分隔线
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    [self loadData];
    self.title = @"预约会议";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadUserData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfCollectionViewItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // cell
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    [cell setRoundCorner:(YM_NETMEETING_MEMBER_CELL_WIDTH - 20) / 2 - 1];
    
    if (indexPath.row == self.inviteUserArray.count) {
        [cell setHeadIcon:@"icon_addmember"];
        [cell setName:@"增加成员"];
    } else if (indexPath.row == self.inviteUserArray.count + 1) {
        [cell setHeadIcon:@"icon_delmember"];
        [cell setName:@"删除成员"];
    } else {
        YYUser *user = [self.inviteUserArray objectAtIndex:indexPath.row];
        [cell setHeadImageWithUrl:[user getUserPhoto] placeholderName:user.userName];
        [cell setName:user.userName];
        if (self.isMemberEditing && ![self.netMeetingDetail.creator isEqualToString:user.userId]) {
            [cell.delView setHidden:NO];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.inviteUserArray.count) {
        NSMutableArray *userIds = [NSMutableArray array];
        
        for (YYUser *user in self.inviteUserArray) {
            [userIds addObject:user.userId];
        }
        
        GlobalInviteViewController *globalInviteViewController = [[GlobalInviteViewController alloc] initWithNibName:@"GlobalInviteViewController" bundle:nil];
        
        globalInviteViewController.disableUserIds = userIds;
        globalInviteViewController.delegate = self;
        globalInviteViewController.actionName = @"发起邀请";
        
        [self.navigationController pushViewController:globalInviteViewController animated:YES];
    } else if (indexPath.row == self.inviteUserArray.count + 1) {
        self.isMemberEditing = YES;
        [self.collectionView reloadData];
    } else {
        YYUser *user = [self.inviteUserArray objectAtIndex:indexPath.row];
        if (self.isMemberEditing) {
            if ([user.userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                return;
            }
            
            [[YYIMChat sharedInstance].chatManager kickReservationNetMeeting:self.netMeetingDetail.channelId member:@[user.userId] complete:^(BOOL result, YYIMError *error) {
                if (result) {
                    [self showHint:@"预约会议移除成员成功"];
                    [self.inviteUserArray removeObject:user];
                    [self.collectionView reloadData];
                    [self.tableView reloadData];
                } else {
                    [self showHint:[NSString stringWithFormat:@"预约会议移除成员失败%@", error.errorMsg]];
                }
            }];
        } else {
            UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
            userViewController.userId = user.userId;
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    }
}

#pragma mark -
#pragma mark table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 3:
            switch (indexPath.row) {
                case 0:
                    return self.lastTextViewHeight + 16;
                    break;
                default:
                    break;
            }
        case 4:
            switch (indexPath.row) {
                case 0:
                    return [self collectionViewHeight] + 1;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return 46.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 16)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView];
    
    UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 16, tableView.bounds.size.width, 0.5)];
    [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView2];
    
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 2;
        case 3:
            return 1;
        case 4:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell.detailLabel setTextAlignment:NSTextAlignmentLeft];
    
    if ([[cell subviews] containsObject:[self collectionView]]) {
        [[self collectionView] removeFromSuperview];
    }
    
    if ([[cell subviews] containsObject:self.agendaTextView]) {
        [self.agendaTextView removeFromSuperview];
    }
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell setName:@"模式"];
                    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
                    
                    switch (self.netMeetingDetail.netMeetingType) {
                        case kYYIMNetMeetingTypeLive:
                            [cell setDetail:@"直播"];
                            break;
                        case kYYIMNetMeetingTypeGroupChat:
                        case kYYIMNetMeetingTypeMeeting:
                            [cell setDetail:@"会议"];
                            break;
                        default:
                            [cell setDetail:@"会议"];
                            break;
                    }
                    
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    if ([self canEditContent]) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                    
                    [cell setName:@"会议主题"];
                    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
                    [cell setDetail:self.netMeetingDetail.topic];
                    break;
                case 1:
                    [cell setName:@"会议ID"];
                    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
                    [cell setDetail:self.netMeetingDetail.channelId];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0: {
                    [cell setName:@"开始时间"];
                    
                    NSString *createTime = [YYIMUtility genTimeString:self.netMeetingDetail.planBeginTime dateFormat:@"yyyy年MM月dd日EEEE HH:mm"];
                    
                    if ([self canEditContent]) {
                        [cell setTimer:createTime enbleEidt:YES];
                    } else {
                        [cell setTimer:createTime enbleEidt:NO];
                    }
                    break;
                }
                case 1: {
                    [cell setName:@"结束时间"];
                    
                    NSString *endTime = [YYIMUtility genTimeString:self.netMeetingDetail.planEndTime dateFormat:@"yyyy年MM月dd日EEEE HH:mm"];
                    
                    if ([self canEditContent]) {
                        [cell setTimer:endTime enbleEidt:YES];
                    } else {
                        [cell setTimer:endTime enbleEidt:NO];
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    [self.agendaTextView setFrame:CGRectMake(8, 8, CGRectGetWidth([UIScreen mainScreen].bounds) - 16, self.lastTextViewHeight)];
                    [cell addSubview:self.agendaTextView];
                    
                    if ([self canEditContent]) {
                        [self.agendaTextView setEditable:YES];
                    } else {
                        [self.agendaTextView setEditable:NO];
                    }
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    [self.collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), [self collectionViewHeight])];
                    [cell addSubview:self.collectionView];
                    
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0: {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改会议主题" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    [textField setText:self.netMeetingDetail.topic];
                    alertView.tag = TAG_ALERTVIEW_NETMEETING_TOPIC;
                    [alertView show];
                    break;
                }
                default:
                    break;
            }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    //弹出开始时间的设置
                    NSDate *begin = [NSDate dateWithTimeIntervalSince1970:self.netMeetingDetail.planBeginTime / 1000];
                    [self openDatePicker:begin dateSelect:kYYIMDateSelectBegin];
                    break;
                }
                case 1: {
                    //弹出结束时间的设置
                    NSDate *end = [NSDate dateWithTimeIntervalSince1970:self.netMeetingDetail.planEndTime / 1000];
                    [self openDatePicker:end dateSelect:kYYIMDateSelectEnd];
                    break;
                }
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    
    if ([self canEditContent]) {
        return indexPath;
    }
    
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.agendaTextView isFirstResponder]) {
        [self.agendaTextView resignFirstResponder];
        [self refreshAgendaHeight];
    }
}

#pragma mark -
#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case TAG_ALERTVIEW_NETMEETING_TOPIC:
            switch (buttonIndex) {
                case 1: {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    NSString *topic = textField.text;
                    
                    if (![YYIMUtility isEmptyString:topic]) {
                        self.netMeetingDetail.topic = topic;
                        [self.tableView reloadData];
                    }
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
#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case TAG_ACTIONSHEET_NETMEETING_CANCEL:
            switch (buttonIndex) {
                case 0: {
                    [self showHint:@"取消预约会议"];
                    [[YYIMChat sharedInstance].chatManager cancelReservationNetMeeting:self.netMeetingDetail.channelId complete:^(BOOL result, YYIMError *error) {
                        if (result) {
                            [self showHint:@"取消会议成功"];
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self showHint:[NSString stringWithFormat:@"取消会议失败:%@", [error errorMsg]]];
                        }
                    }];
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

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView == self.agendaTextView) {
        [UIView animateWithDuration:0.5f animations:^{
            self.tableView.contentOffset = CGPointMake(0, 212.0f);
        }];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (textView == self.agendaTextView) {
            [self.agendaTextView resignFirstResponder];
            [self refreshAgendaHeight];
        }
        
        return NO;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    if (textView == self.agendaTextView) {
        self.placeHolderLabel.hidden = self.agendaTextView.hasText;
    }
}

#pragma mark -
#pragma mark YYIMDatePickerViewDelegate

- (void)didDatePickerViewCancel:(YYIMDatePickerView *)datePickerView {
    if (self.datePickerView) {
        [self.datePickerView removeFromSuperview];
    }
}

- (void)didDatePickerViewSelect:(YYIMDatePickerView *)datePickerView date:(NSDate *)date dateSelect:(YYIMDateSelect)dateSelect {
    if (self.datePickerView) {
        [self.datePickerView removeFromSuperview];
    }
    
    NSTimeInterval interval = [date timeIntervalSince1970] * 1000;
    
    switch (dateSelect) {
        case kYYIMDateSelectBegin:
            self.netMeetingDetail.planBeginTime = interval;
            break;
        case kYYIMDateSelectEnd:
            self.netMeetingDetail.planEndTime = interval;
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark GlobalInviteViewControllerDelegate

- (void)didGlobalInviteViewController:(UIViewController *)viewController InviteUsers:(NSArray *)userArray {
    NSMutableArray *userIdArray = [NSMutableArray array];
    
    for (id user in userArray) {
        if ([user isKindOfClass:[YYUser class]]) {
            [userIdArray addObject:[(YYUser *)user userId]];
        } else if ([user isKindOfClass:[YYRoster class]]) {
            [userIdArray addObject:[(YYRoster *)user rosterId]];
        } else if ([user isKindOfClass:[YYChatGroupMember class]]) {
            [userIdArray addObject:[(YYChatGroupMember *)user memberId]];
        }
    }
    
    if ([userIdArray count] <= 0) { 
        [self showHint:@"请选择会议成员"];
        return;
    }
    
    [self.navigationController popToViewController:self animated:YES];
    [self.navigationController clearData];
    
    [[YYIMChat sharedInstance].chatManager inviteReservationNetMeeting:self.netMeetingDetail.channelId member:userIdArray complete:^(BOOL result, YYIMError *error, NSArray *mismatchMember) {
        if (result) {
            if (mismatchMember && mismatchMember.count > 0) {
                [userIdArray removeObjectsInArray:mismatchMember];
                
                YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[mismatchMember objectAtIndex:0]];
                NSMutableString *misMatchText = [NSMutableString stringWithString:user.userName == nil ? @"" : user.userName];
                
                if (mismatchMember.count > 1) {
                    YYUser *userSecond = [[YYIMChat sharedInstance].chatManager getUserWithId:[mismatchMember objectAtIndex:1]];
                    [misMatchText appendString:@"、"];
                    [misMatchText appendString:userSecond.userName == nil ? @"" : userSecond.userName];
                }
                
                if (mismatchMember.count > 2) {
                    [misMatchText appendString:@"等"];
                    [misMatchText appendString:[NSString stringWithFormat:@"%ld", (unsigned long)mismatchMember.count]];
                    [misMatchText appendString:@"人"];
                }
                
                [misMatchText appendString:@"无通信权限"];
                [self showHint:misMatchText];
            } else {
                [self showHint:@"预约会议邀请成员成功"];
            }
            
            if (userIdArray.count > 0) {
                for (NSString *userId in userIdArray) {
                    [self.inviteUserArray addObject:[[YYIMChat sharedInstance].chatManager getUserWithId:userId]];
                    [self sortInviteArray];
                }
                
                [self.collectionView reloadData];
                [self.tableView reloadData];
            }
        } else {
           [self showHint:[NSString stringWithFormat:@"预约会议邀请成员失败%@", error.errorMsg]];
        }
    }];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.isMemberEditing) {
            return YES;
        }
        return NO;
    } else {
        if (self.isMemberEditing) {
            return NO;
        }
        return YES;
    }
}

- (void)collectionViewTap:(id)sender {
    self.isMemberEditing = NO;
    [self.collectionView reloadData];
}

- (void)memberLongTap:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (!self.isCreateor) {
            return;
        }
        
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath.row < [self.inviteUserArray count]) {
            self.isMemberEditing = YES;
            [self.collectionView reloadData];
        }
    }
}

#pragma mark -
#pragma mark private method

- (void)loadData {
    self.editState = NO;
    
    if ([self.netMeetingDetail.creator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        self.isCreateor = YES;
    }
    
    self.inviteUserArray = [NSMutableArray array];
    for (NSString *userId in self.memberIdArray) {
        YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:userId];
        
        if (!user) {
            YYUser *defualtUser = [[YYUser alloc] init];
            [defualtUser setUserId:userId];
            [defualtUser setUserName:userId];
            [self.inviteUserArray addObject:defualtUser];
        } else {
            [self.inviteUserArray addObject:user];
        }
    }
    [self sortInviteArray];
    
    if (self.isCreateor) {
        [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
        UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        self.confirmBtn.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = self.confirmBtn;
    } else {
        [self.agendaTextView setEditable:NO];
    }
    
    self.agendaTextView.text = self.netMeetingDetail.agenda;
    
    CGSize size = [self.agendaTextView sizeThatFits:CGSizeMake(self.agendaTextView.contentSize.width, MAXFLOAT)];
    
    CGFloat height = size.height;
    height = fmaxf(height, AGENDA_TEXT_DEFAULT_HEIGHT);
    
    self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, CGRectGetWidth(self.agendaTextView.frame), 20)];
    [self.placeHolderLabel setTextColor:UIColorFromRGB(0xa3a3a8)];
    [self.placeHolderLabel setFont:[UIFont systemFontOfSize:14]];
    [self.placeHolderLabel setText:@"请输入议程信息"];
    
    if (self.netMeetingDetail.agenda && self.agendaTextView.text.length > 0) {
        self.placeHolderLabel.hidden = YES;
    }
    
    [self.agendaTextView addSubview:self.placeHolderLabel];

    
    if (self.lastTextViewHeight != height) {
        self.lastTextViewHeight = height;
    }
    
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)reloadUserData {
    NSMutableArray *userIds = [NSMutableArray array];
    for (YYUser *user in self.inviteUserArray) {
        [userIds addObject:user.userId];
    }
    
    [self.inviteUserArray removeAllObjects];
    for (NSString *userId in userIds) {
        YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:userId];
        
        if (!user) {
            YYUser *defualtUser = [[YYUser alloc] init];
            [defualtUser setUserId:userId];
            [defualtUser setUserName:userId];
            [self.inviteUserArray addObject:defualtUser];
        } else {
            [self.inviteUserArray addObject:user];
        }
    }
    
    [self.collectionView reloadData];
}

- (NSInteger)numberOfCollectionViewItems {
    if (self.isCreateor) {
        return [self.inviteUserArray count] + 2;
    }
    
    return [self.inviteUserArray count] + 1;
}


- (void)rightButtonAction {
    if (self.editState) {
        self.netMeetingDetail.agenda = self.agendaTextView.text;
        
        if (!self.netMeetingDetail.agenda || self.netMeetingDetail.agenda.length == 0) {
            self.netMeetingDetail.agenda = @"会议议程";
        }
        
        //修改预约会议
        [[YYIMChat sharedInstance].chatManager EditReservationNetMeeting:self.netMeetingDetail complete:^(BOOL result, YYIMError *error) {
            if (result) {
                [self showHint:@"编辑会议成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self showHint:[NSString stringWithFormat:@"编辑会议失败%@", error.errorMsg]];
            }
        }];

    } else {
        self.editState = YES;
        
        self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
        UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        self.confirmBtn.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = self.confirmBtn;
        
        [self.tableView setTableFooterView:[self footerView]];
        [self.tableView reloadData];
    }
}


- (void)refreshAgendaHeight {    
    CGSize size = [self.agendaTextView sizeThatFits:CGSizeMake(self.agendaTextView.contentSize.width, MAXFLOAT)];
    
    CGFloat height = size.height;
    height = fmaxf(height, AGENDA_TEXT_DEFAULT_HEIGHT);
    
    if (self.lastTextViewHeight != height) {
        self.lastTextViewHeight = height;
        [self.tableView reloadData];
    }
}

- (void)openDatePicker:(NSDate *)date dateSelect:(YYIMDateSelect)dateSelect {
    if ([self.agendaTextView isFirstResponder]) {
        [self.agendaTextView resignFirstResponder];
        [self refreshAgendaHeight];
    }
    
    if (!self.datePickerView) {
        self.datePickerView = [[YYIMDatePickerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) , CGRectGetHeight(self.view.frame))];
    }
    
    self.datePickerView.delegate = self;
    [self.datePickerView setDatePickerDate:date];
    [self.datePickerView setDatePickerMinuteInterval:15];
    self.datePickerView.dateSelect = dateSelect;
    [self.view addSubview:self.datePickerView];
}

- (void)sortInviteArray {
    NSArray *sortArray = [self.inviteUserArray sortedArrayUsingComparator:^NSComparisonResult(YYUser *user1, YYUser *user2) {
        if ([[user1 userId] isEqualToString:[self.netMeetingDetail creator]]) {
            return NSOrderedAscending;
        } else if ([[user2 userId] isEqualToString:[self.netMeetingDetail creator]]) {
            return NSOrderedDescending;
        } else {
            return [[user1 userName] compare:[user2 userName]];
        }
    }];
    self.inviteUserArray = [NSMutableArray arrayWithArray:sortArray];
}

- (BOOL)canEditContent {
    return self.isCreateor && self.editState;
}

@end
