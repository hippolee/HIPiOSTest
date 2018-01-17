//
//  YYIMNetMeetingCheckViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingCheckViewController.h"
#import "UserCollectionViewCell.h"
#import "GlobalInviteViewController.h"
#import "UserViewController.h"
#import "YYIMColorHelper.h"
#import "SingleLineCell2.h"
#import "YYIMUtility.h"

@interface YYIMNetMeetingCheckViewController ()

// 当前的成员
@property (retain, nonatomic) NSMutableArray *inviteUserArray;

@property CGFloat lastTextViewHeight;

@end

@implementation YYIMNetMeetingCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    // 隐藏多余分隔线
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    [self loadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadUserData];
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
    
    YYUser *user = [self.inviteUserArray objectAtIndex:indexPath.row];
    [cell setHeadImageWithUrl:[user getUserPhoto] placeholderName:user.userName];
    [cell setName:user.userName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYUser *user = [self.inviteUserArray objectAtIndex:indexPath.row];
    UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
    userViewController.userId = user.userId;
    
    [self.navigationController pushViewController:userViewController animated:YES];
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
                    return self.lastTextViewHeight;
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
                    [cell setName:@"会议主题"];
                    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
                    [cell setDetail:self.netMeetingDetail.topic];
                    break;
                case 1:
                    [cell setName:@"会议ID"];
                    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
                    [cell setDetail:self.netMeetingDetail.channelId];
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0: {
                    [cell setName:@"开始时间"];
                    
                    NSTimeInterval begin = self.isReservation ? self.netMeetingDetail.planBeginTime : self.netMeetingDetail.createTime;
                    
                    NSString *createTime = [YYIMUtility genTimeString:begin dateFormat:@"yyyy年MM月dd日 EEEE HH:mm"];
                    [cell setTimer:createTime enbleEidt:NO];
                    break;
                }
                case 1: {
                    [cell setName:@"结束时间"];
                    
                    NSTimeInterval end = self.isReservation ? self.netMeetingDetail.planEndTime : self.netMeetingDetail.endTime;
                    
                    NSString *endTime;
                    if (end && end > 0) {
                        endTime = [YYIMUtility genTimeString:end dateFormat:@"yyyy年MM月dd日 EEEE HH:mm"];
                    } else {
                        endTime = @"";
                    }
                    [cell setTimer:endTime enbleEidt:NO];
                    break;
                }
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    [self.agendaTextView setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), self.lastTextViewHeight)];
                    [cell addSubview:self.agendaTextView];
                    [self.agendaTextView setEditable:NO];
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

#pragma mark -
#pragma mark private method

- (void)loadData {
    self.title = self.currentTitle;
    
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
    
    [self.agendaTextView setEditable:NO];
    self.agendaTextView.text = self.netMeetingDetail.agenda;
    
    CGSize size = [self.agendaTextView sizeThatFits:CGSizeMake(self.agendaTextView.contentSize.width, MAXFLOAT)];
    
    CGFloat height = size.height;
    height = fmaxf(height, AGENDA_TEXT_DEFAULT_HEIGHT);
    
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
    return [self.inviteUserArray count];
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

@end
