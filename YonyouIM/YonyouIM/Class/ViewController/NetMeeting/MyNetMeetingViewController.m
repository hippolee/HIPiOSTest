//
//  MyNetMeetingViewController.m
//  YonyouIM
//
//  Created by litfb on 16/3/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "MyNetMeetingViewController.h"
#import "UIColor+YYIMTheme.h"
#import "UIButton+YYIMCatagory.h"
#import "YYIMColorHelper.h"
#import "YYIMUtility.h"
#import "YYIMChat.h"
#import "UIViewController+HUDCategory.h"
#import "YMRefreshView.h"
#import "MyNetMeetingTableViewCell.h"
#import "JoinNetMeetingViewController.h"
#import "TableBackgroundView.h"
#import "YYIMNetMeetingBroadcasterViewController.h"
#import "YYIMNetMeetingAudienceViewController.h"
#import "NetMeetingDispatch.h"
#import "YYIMNetMeetingReserveViewController.h"
#import "YYIMNetMeetingEditViewController.h"
#import "YYIMNetMeetingCheckViewController.h"
#import "YYNetMeetingHistory.h"

#define MY_NETMEETING_MODE          101
#define MY_NETMEETING_PAGE_SIZE     20

@interface MyNetMeetingViewController ()<YYIMChatDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *reserveButton;

- (IBAction)joinAction:(id)sender;
- (IBAction)createAction:(id)sender;
- (IBAction)reserveAction:(id)sender;

@property (weak, nonatomic) UIRefreshControl *control;

@property (strong, nonatomic) YMRefreshView *footerView;

@property (weak, nonatomic) TableBackgroundView *emptyBgView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableArray *filterDataArray;
// 会议创建的唯一标示
@property (retain, nonatomic) NSString *channelCreatedSeriId;

@property (retain, nonatomic) UISearchDisplayController *searchDisplayController;

@end

@implementation MyNetMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self setTitle:@"我的会议"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData:nil];
    
    if ([self.searchDisplayController isActive]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    // register cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"MyNetMeetingTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyNetMeetingTableViewCell"];
    // 隐藏多余分隔线
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    // searchBar背景色
    [YYIMUtility searchBar:self.searchBar setBackgroundColor:UIColorFromRGB(0xefeff4)];
    // 按钮圆角
    CALayer *joinLayer = [self.joinButton layer];
    [joinLayer setMasksToBounds:YES];
    [joinLayer setCornerRadius:4.0f];
    CALayer *createLayer = [self.createButton layer];
    [createLayer setMasksToBounds:YES];
    [createLayer setCornerRadius:4.0f];
    CALayer *reserveLayer = [self.reserveButton layer];
    [reserveLayer setMasksToBounds:YES];
    [reserveLayer setCornerRadius:4.0f];
    // 添加刷新控件
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
    self.control = control;
    // 单击事件
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer setCancelsTouchesInView:YES];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    // search
    //初始化uisearchdisplaycontroller
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
    [searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"MyNetMeetingTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyNetMeetingTableViewCell"];
    [searchDisplayController.searchResultsTableView setAllowsSelection:NO];
    [YYIMUtility setExtraCellLineHidden:[searchDisplayController searchResultsTableView]];
    self.searchDisplayController = searchDisplayController;
}

- (YMRefreshView *)footerView {
    if (!_footerView) {
        YMRefreshView *footerView = [[YMRefreshView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 40)];
        [footerView setHidden:YES];
        _footerView = footerView;
    }
    return _footerView;
}

- (void)reloadData:(id)sender {
    [[YYIMChat sharedInstance].chatManager getMyNetMeetingWithOffset:0 limit:MY_NETMEETING_PAGE_SIZE complete:^(BOOL result, NSArray *netMeetings, YYIMError *error) {
        if (result) {
            if (!self.dataArray) {
                self.dataArray = [NSMutableArray array];
            } else {
                [self.dataArray removeAllObjects];
            }
            
            [self.dataArray addObjectsFromArray:netMeetings];
            [self.tableView reloadData];
            
            if ([netMeetings count] >= MY_NETMEETING_PAGE_SIZE) {
                // 添加上拉加载
                [self.tableView setTableFooterView:[self footerView]];
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"加载数据失败:%@", [error errorMsg]]];
        }
        // 结束刷新
        if ([self.control isRefreshing]) {
            [self.control endRefreshing];
        }
        [self checkDataEmpty];
    }];
}

- (void)loadMoreData:(id)sender {
    [[YYIMChat sharedInstance].chatManager getMyNetMeetingWithOffset:[self.dataArray count] limit:MY_NETMEETING_PAGE_SIZE complete:^(BOOL result, NSArray *netMeetings, YYIMError *error) {
        if (result) {
            [self.dataArray addObjectsFromArray:netMeetings];
            [self.tableView reloadData];
        } else {
            [self showHint:[NSString stringWithFormat:@"加载数据失败:%@", [error errorMsg]]];
        }
        // 结束刷新(隐藏footer)
        [self.tableView.tableFooterView setHidden:YES];
        if ([netMeetings count] < MY_NETMEETING_PAGE_SIZE) {
            [self.tableView setTableFooterView:nil];
        }
    }];
}

- (IBAction)joinAction:(id)sender {
    JoinNetMeetingViewController *joinNetMeetingViewController = [[JoinNetMeetingViewController alloc] initWithNibName:@"JoinNetMeetingViewController" bundle:nil];
    [self.navigationController pushViewController:joinNetMeetingViewController animated:YES];
}

- (IBAction)createAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"会议模式", @"直播模式", nil];
    [actionSheet setTag:MY_NETMEETING_MODE];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            // 调用创建频道的接口
            if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                [self showHint:@"当前有会议在进行，操作被禁止"];
            } else {
                [[NetMeetingDispatch sharedInstance] createNetMeetingWithNetMeetingType:kYYIMNetMeetingTypeMeeting netMeetingMode:kYYIMNetMeetingModeDefault invitees:nil topic:nil];
            }
            break;
        }
        case 1:
            // 调用创建频道的接口
            if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                [self showHint:@"当前有会议在进行，操作被禁止"];
            } else {
                [[NetMeetingDispatch sharedInstance] createNetMeetingWithNetMeetingType:kYYIMNetMeetingTypeLive netMeetingMode:kYYIMNetMeetingModeDefault invitees:nil topic:nil];
            }
            break;
        default:
            break;
    }
}

- (IBAction)reserveAction:(id)sender {
    YYIMNetMeetingReserveViewController *netMeetingReserveViewController = [[YYIMNetMeetingReserveViewController alloc] initWithNibName:@"YYIMNetMeetingReserveViewController" bundle:nil];
    [self.navigationController pushViewController:netMeetingReserveViewController animated:YES];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self.dataArray count];
    } else {
        return [self.filterDataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"MyNetMeetingTableViewCell";
    MyNetMeetingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    
    // 取数据
    YYNetMeetingHistory *history;
    if (tableView == self.tableView) {
        history = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        history = [self.filterDataArray objectAtIndex:indexPath.row];
    }
    
    // 为cell设置数据
    [cell activeData:history];
    // 按钮点击
    [cell.joinButton addTarget:self action:@selector(joinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYNetMeetingHistory *history;
    if (tableView == self.tableView) {
        if (indexPath.row >= [self.dataArray count]) {
            return NO;
        }
        
        history = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        if (indexPath.row >= [self.filterDataArray count]) {
            return NO;
        }
        
        history = [self.filterDataArray objectAtIndex:indexPath.row];
    }
    
    //如果是已结束的会议，所有人都可以删除这条历史记录
    if (history.state == kYYIMNetMeetingStateEnd) {
        return YES;
    }
    
    //如果是预约会议未开始的，主持人可以取消预约。
    if (history.state == kYYIMNetMeetingStateNew) {
        return YES;
    }
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYNetMeetingHistory *history;
    if (tableView == self.tableView) {
        history = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        history = [self.filterDataArray objectAtIndex:indexPath.row];
    }
    
    //如果是已结束的会议，所有人都可以删除这条历史记录
    if (history.state == kYYIMNetMeetingStateEnd) {
        return @"删除";
    }
    
    //如果是预约会议未开始的，主持人可以取消预约。
    if (history.state == kYYIMNetMeetingStateNew) {
        if ([history.moderator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            return @"取消预约";
        } else {
            return @"删除";
        }
    }
    
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 取数据
        YYNetMeetingHistory *history;
        if (tableView == self.tableView) {
            history = [self.dataArray objectAtIndex:indexPath.row];
        } else {
            history = [self.filterDataArray objectAtIndex:indexPath.row];
        }
        
        //如果是已结束的会议，所有人都可以删除这条历史记录
        if (history.state == kYYIMNetMeetingStateEnd || (![history.moderator isEqualToString:[[YYIMConfig sharedInstance] getUser]] && history.state == kYYIMNetMeetingStateNew)) {
            [[YYIMChat sharedInstance].chatManager removeNetMeetingWithChannelId:[history channelId] complete:^(BOOL result, YYIMError *error) {
                if (result) {
                    [self.dataArray removeObject:history];
                    [self.tableView reloadData];
                    if (tableView != self.tableView) {
                        [self.filterDataArray removeObject:history];
                        [[self.searchDisplayController searchResultsTableView] reloadData];
                    } else {
                        [self checkDataEmpty];
                    }
                } else {
                    [self showHint:[NSString stringWithFormat:@"删除失败:%@", [error errorMsg]]];
                }
            }];
        }
        
        //如果是预约会议未开始的，主持人可以取消预约。
        if ([history.moderator isEqualToString:[[YYIMConfig sharedInstance] getUser]] && history.state == kYYIMNetMeetingStateNew) {
            [[YYIMChat sharedInstance].chatManager cancelReservationNetMeeting:history.channelId complete:^(BOOL result, YYIMError *error) {
                if (result) {
                    [self.dataArray removeObject:history];
                    [self.tableView reloadData];
                    if (tableView != self.tableView) {
                        [self.filterDataArray removeObject:history];
                        [[self.searchDisplayController searchResultsTableView] reloadData];
                    } else {
                        [self checkDataEmpty];
                    }
                } else {
                    [self showHint:[NSString stringWithFormat:@"取消预约失败:%@", [error errorMsg]]];
                }
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYNetMeetingHistory *history = [self.dataArray objectAtIndex:indexPath.row];
    
    //查看详情
    [[YYIMChat sharedInstance].chatManager getNetmeetingDetail:history.channelId complete:^(BOOL result, YYNetMeetingDetail *detail, NSArray *members, YYIMError *error) {
        if (result) {
            NSString *title;
            if (detail.state == kYYIMNetMeetingStateNew) {
                title = @"预约会议";
            } else {
                if (detail.netMeetingType == kYYIMNetMeetingTypeLive) {
                    title = @"直播";
                } else {
                    title = @"会议";
                }
            }
            
            //如果是预约会议而且还没有开始，点击消息可以进行修改。否则只能是查看
            if (detail.state == kYYIMNetMeetingStateNew) {
                YYIMNetMeetingEditViewController *netMeetingEditViewController = [[YYIMNetMeetingEditViewController alloc] initWithNibName:@"YYIMNetMeetingEditViewController" bundle:nil];
                netMeetingEditViewController.netMeetingDetail = detail;
                netMeetingEditViewController.memberIdArray = members;
                [self.navigationController pushViewController:netMeetingEditViewController animated:YES];
            } else {
                YYIMNetMeetingCheckViewController *netMeetingCheckViewController = [[YYIMNetMeetingCheckViewController alloc] initWithNibName:@"YYIMNetMeetingCheckViewController" bundle:nil];
                netMeetingCheckViewController.netMeetingDetail = detail;
                netMeetingCheckViewController.memberIdArray = members;
                netMeetingCheckViewController.currentTitle = title;
                netMeetingCheckViewController.isReservation = detail.state == kYYIMNetMeetingStateNew ? YES : NO;
                
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
    if (self.dataArray.count < MY_NETMEETING_PAGE_SIZE || ![self.tableView.tableFooterView isHidden]) {
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

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.searchBar isFirstResponder]) {
        return YES;
    }
    return NO;
}

- (void)tapAction:(id)sender {
    [self.searchBar resignFirstResponder];
}

#pragma mark UISearchBarDelegate, UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    // 处理statusbar的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // 处理背景显示
    [self performSelector:@selector(dealSearchDisplay) withObject:nil afterDelay:0.01];
}

- (void)dealSearchDisplay {
    UIView *dimmingView = [YYIMUtility findSubviewWithClassName:@"_UISearchDisplayControllerDimmingView" inView:self.view];
    if (dimmingView) {
        [dimmingView setAlpha:1.0f];
        [dimmingView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    // 处理statusbar的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self checkDataEmpty];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    UILabel *label = (UILabel *)[YYIMUtility findSubviewWithClassName:@"UILabel" inView:controller.searchResultsTableView];
    if (label) {
        [label setText:@""];
    }
    
    if ([YYIMUtility isEmptyString:searchString]) {
        self.filterDataArray = nil;
    } else {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"topic CONTAINS[cd] %@ OR moderatorName CONTAINS[cd] %@", searchString, searchString];
        self.filterDataArray = [NSMutableArray arrayWithArray:[self.dataArray filteredArrayUsingPredicate:pre]];
    }
    return YES;
}

#pragma mark YYIMChatDelegate

- (void)didReceiveMessage:(YYMessage *)message {
    if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT] && [[message fromId] isEqualToString:YM_NETCONFERENCE_PUBACCOUNT]) {
        [self reloadData:nil];
    }
}

#pragma mark -
#pragma mark private

- (void)joinBtnClick:(UIButton *)sender {
    // 点击cell
    MyNetMeetingTableViewCell *cell =(MyNetMeetingTableViewCell *)[YYIMUtility superCellForView:sender];
    if (!cell) {
        return;
    }
    // indexPath
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
    // 取数据
    YYNetMeetingHistory *history = [self.dataArray objectAtIndex:indexPath.row];
    switch (history.state) {
        case kYYIMNetMeetingStateIng:
            if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                [self showHint:@"当前有会议在进行，操作被禁止"];
            } else {
                [[YYIMChat sharedInstance].chatManager joinNetMeeting:[history channelId]];
            }
            break;
        case kYYIMNetMeetingStateNew:
            if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                [self showHint:@"当前有会议在进行，操作被禁止"];
            } else {
                [[NetMeetingDispatch sharedInstance] startReservationNetMeeting:history.channelId];
            }
            break;
        default:
            break;
    }
}

- (void)checkDataEmpty {
    if ([self.dataArray count] > 0) {
        if (self.emptyBgView) {
            [self.emptyBgView removeFromSuperview];
        }
    } else {
        if (!self.emptyBgView) {
            TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableView.frame)) title:@"还没有会议哦" type:kYYIMTableBackgroundTypeNormal];
            [emptyBgView addBtnTarget:self action:@selector(createAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
            self.emptyBgView = emptyBgView;
        }
    }
}

@end
