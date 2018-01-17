//
//  YYIMNetMeetingNotifyViewController.m
//  YonyouIM
//
//  Created by litfb on 16/4/7.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingNotifyViewController.h"
#import "ChatMuitiConferenceTableViewCell.h"
#import "YYIMNetMeetingConferenceViewController.h"
#import "YYIMNetMeetingAudienceViewController.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUtility.h"
#import "YMRefreshView.h"
#import "YYIMUIDefs.h"
#import "YYIMNetMeetingBroadcasterViewController.h"
#import "YYIMNetMeetingEditViewController.h"
#import "YYIMNetMeetingCheckViewController.h"
#import "NetMeetingDispatch.h"

#define YYIM_NETMEETING_NOTICE_PAGESIZE 20

@interface YYIMNetMeetingNotifyViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) YMRefreshView *footerView;

@property (retain, nonatomic) YYPubAccount *account;

@property (retain, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSString *joiningChannelId;

@end

@implementation YYIMNetMeetingNotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // account
    self.account = [[YYIMChat sharedInstance].chatManager getPubAccountWithAccountId:YM_NETCONFERENCE_PUBACCOUNT];
    // title
    [self.navigationItem setTitle:[self.account accountName]];
    // view 初始化
    [self initView];
    // 加载数据
    [self reloadData];
    // 标记已读
    [[YYIMChat sharedInstance].chatManager updateMessageReadedWithId:YM_NETCONFERENCE_PUBACCOUNT];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // reloadData
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    // registerCellNib
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatMuitiConferenceTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChatMuitiConferenceTableViewCell"];
}

- (void)reloadData {
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    
    NSInteger limit = [self.dataArray count];
    if (limit < YYIM_NETMEETING_NOTICE_PAGESIZE) {
        limit = YYIM_NETMEETING_NOTICE_PAGESIZE;
    }
    
    NSArray *array = [[YYIMChat sharedInstance].chatManager getNetMeetingNoticeWithOffset:0 limit:limit];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:array];
    
    [self.tableView reloadData];
    
    if ([array count] >= YYIM_NETMEETING_NOTICE_PAGESIZE) {
        // 添加上拉加载
        [self.tableView setTableFooterView:[self footerView]];
    }
}

- (void)loadMoreData:(id)sender {
    NSArray *array = [[YYIMChat sharedInstance].chatManager getNetMeetingNoticeWithOffset:[self.dataArray count] limit:YYIM_NETMEETING_NOTICE_PAGESIZE];
    [self.dataArray addObjectsFromArray:array];
    [self.tableView reloadData];
    
    // 结束刷新(隐藏footer)
    [self.tableView.tableFooterView setHidden:YES];
    
    if ([array count] < YYIM_NETMEETING_NOTICE_PAGESIZE) {
        [self.tableView setTableFooterView:nil];
    }
}

- (YMRefreshView *)footerView {
    if (!_footerView) {
        YMRefreshView *footerView = [[YMRefreshView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 40)];
        [footerView setHidden:YES];
        _footerView = footerView;
    }
    return _footerView;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYNetMeetingInfo *netMeetingInfo = [self.dataArray objectAtIndex:indexPath.row];
    
    ChatMuitiConferenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMuitiConferenceTableViewCell"];
    [cell setActiveData:netMeetingInfo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYNetMeetingInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    
    switch (info.reservationInvalidReason) {
        case YYIMNetMeetingReservationInvalidReasonCancel:
            [self showHint:@"预约会议已取消"];
            return nil;
            break;
        case YYIMNetMeetingReservationInvalidReasonKick:
            [self showHint:@"您已被移出预约会议"];
            return nil;
            break;
        default:
            return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYNetMeetingInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    
    //查看详情
    [[YYIMChat sharedInstance].chatManager getNetmeetingDetail:info.channelId complete:^(BOOL result, YYNetMeetingDetail *detail, NSArray *members, YYIMError *error) {
        if (result) {
            NSString *title;
            if (info.isReservationNotice) {
                title = @"预约会议";
            } else {
                if (detail.netMeetingType == kYYIMNetMeetingTypeLive) {
                    title = @"直播";
                } else {
                    title = @"会议";
                }
            }
            
            //如果是预约会议而且还没有开始，点击消息可以进行修改。否则只能是查看
            if (info.isReservationNotice && info.waitBegin) {
                YYIMNetMeetingEditViewController *netMeetingEditViewController = [[YYIMNetMeetingEditViewController alloc] initWithNibName:@"YYIMNetMeetingEditViewController" bundle:nil];
                netMeetingEditViewController.netMeetingDetail = detail;
                netMeetingEditViewController.memberIdArray = members;
                [self.navigationController pushViewController:netMeetingEditViewController animated:YES];
            } else {
                YYIMNetMeetingCheckViewController *netMeetingCheckViewController = [[YYIMNetMeetingCheckViewController alloc] initWithNibName:@"YYIMNetMeetingCheckViewController" bundle:nil];
                netMeetingCheckViewController.netMeetingDetail = detail;
                netMeetingCheckViewController.memberIdArray = members;
                netMeetingCheckViewController.currentTitle = title;
                netMeetingCheckViewController.isReservation = info.isReservationNotice ? YES : NO;
                
                [self.navigationController pushViewController:netMeetingCheckViewController animated:YES];
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"获取详细信息失败:%@", [error errorMsg]]];
        }
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果tableView还没有数据，就直接返回
    if (self.dataArray.count < YYIM_NETMEETING_NOTICE_PAGESIZE || ![self.tableView.tableFooterView isHidden]) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    // 当最后一个cell完全显示在眼前时，contentOffset的y值
    CGFloat judgeOffsetY = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height - self.tableView.tableFooterView.frame.size.height;
    if (offsetY >= judgeOffsetY) { // 最后一个cell完全进入视野范围内
        // 显示footer
        self.tableView.tableFooterView.hidden = NO;
        // 加载更多数据
        [self performSelector:@selector(loadMoreData:) withObject:nil afterDelay:0.0f];
    }
}

#pragma mark -
#pragma mark YYIMChatDelegate

- (void)didNetMeetingNoticeReceive {
    [self reloadData];
}

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    YYNetMeetingInfo *notice = [userInfo objectForKey:kYMChatPressedMessage];
    
    if (notice.isReservationNotice && notice.waitBegin) {
        if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
            [self showHint:@"当前有会议在进行，操作被禁止"];
        } else {
            [[NetMeetingDispatch sharedInstance] startReservationNetMeeting:notice.channelId];
        }
    } else if (notice.state == kYYIMNetMeetingStateIng){
        if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
            [self showHint:@"当前有会议在进行，操作被禁止"];
        } else {
            [[YYIMChat sharedInstance].chatManager joinNetMeeting:notice.channelId];
        } 
    }
}

@end
