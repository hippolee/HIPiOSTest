//
//  MemberSelViewController.m
//  YonyouIM
//
//  Created by litfb on 15/6/10.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "MemberSelViewController.h"
#import "YYIMUtility.h"
#import "NormalSelTableViewCell.h"
#import "YYIMChatHeader.h"
#import "SingleLineCell.h"
#import "UIViewController+HUDCategory.h"

@interface MemberSelViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) UIBarButtonItem *confirmBtn;

@property (retain, nonatomic) NSMutableArray *memberArray;

@end

@implementation MemberSelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群组成员";
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    if ([self isAllowMultipleSelect]) {
        self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
        UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        self.confirmBtn.tintColor = [UIColor whiteColor];
        [self.confirmBtn setEnabled:NO];
        self.navigationItem.rightBarButtonItem = self.confirmBtn;
        
        // 注册Cell nib
        [self.tableView registerNib:[UINib nibWithNibName:@"NormalSelTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalSelTableViewCell"];
    } else {
        // 注册Cell nib
        [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    }
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)confirmAction {
    NSMutableArray *memberArray = [NSMutableArray array];
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in indexPaths) {
        // 取数据
        YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
        [memberArray addObject:member];
    }
    
    if ([self.delegate respondsToSelector:@selector(memberSelController:identifiy:didSelMembers:)]) {
        [self.delegate memberSelController:self identifiy:self.identifiy didSelMembers:memberArray];
    }    
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAllowMultipleSelect]) {
        return 68;
    }
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
    if ([self isAllowMultipleSelect]) {
        // 取cell
        NormalSelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalSelTableViewCell"];
        // 为cell设置数据
        [cell setHeadImageWithUrl:[member getMemberPhoto] placeholderName:[member memberName]];
        [cell setName:[member memberName]];
        [cell setDetail:[[member user] userMobile]];
        
        if ([self.identifiy isEqualToString:@"tele"] && [YYIMUtility isEmptyString:[[member user] userMobile]]) {
            [cell setSelectEnable:NO withDisableImage:[UIImage imageNamed:@"icon_checkbox_dx"]];
        }
        
        if ([[member memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            [cell setSelectEnable:NO];
        }
        
        return cell;
    } else {
        SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
        [cell setImageRadius:16];
        
        [cell setHeadImageWithUrl:[member getMemberPhoto] placeholderName:[member memberName]];
        [cell setName:[member memberName]];
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAllowMultipleSelect]) {
        // 取数据
        YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
        if ([self.identifiy isEqualToString:@"tele"] && [YYIMUtility isEmptyString:[[member user] userMobile]]) {
            return nil;
        }
        if ([[member memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            return nil;
        }
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAllowMultipleSelect]) {
        [self resetConfirmState];
    } else {
        // 取数据
        YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
        
        if ([self.delegate respondsToSelector:@selector(memberSelController:identifiy:didSelMember:)]) {
            [self.delegate memberSelController:self identifiy:self.identifiy didSelMember:member];
        }
        
        [self backAction];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAllowMultipleSelect]) {
        [self resetConfirmState];
    }
}

- (void)resetConfirmState {
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    if (indexPaths.count > 0) {
        [self.confirmBtn setEnabled:YES];
    } else {
        [self.confirmBtn setEnabled:NO];
    }
}

#pragma mark YYIMChatDelegate

- (void)didChatGroupInfoUpdate:(YYChatGroup *)group {
    if ([[group groupId] isEqualToString:self.groupId]) {
        [self reloadData];
    }
}

- (void)didUserInfoUpdate {
    [self reloadData];
}

- (void)didChatGroupMemberUpdate:(NSString *)groupId {
    if (groupId && [groupId isEqualToString:self.groupId]) {
        [self reloadData];
    }
}

#pragma mark private func

- (BOOL)isAllowMultipleSelect {
    if ([self.delegate respondsToSelector:@selector(allowMultipleMemberSelect:)]) {
        return [self.delegate allowMultipleMemberSelect:self];
    }
    return YES;
}

- (void)loadData {
    [self showThemeHudInView:self.view];
    [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId complete:^(BOOL result, NSArray *array, YYIMError *error) {
        [self hideHud];
        if (result && array) {
            self.memberArray = [NSMutableArray arrayWithArray:array];
            
            YYChatGroupMember *member;
            for (YYChatGroupMember *groupMember in self.memberArray) {
                if ([[groupMember memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                    member = groupMember;
                    break;
                }
            }
            
            if (member) {
                [self.memberArray removeObject:member];
            }
            
            [self.tableView reloadData];
        } else {
            [self showHint:[NSString stringWithFormat:@"加载数据失败:%@", [error errorMsg]]];
        }
    }];
}

- (void)reloadData {
    [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId complete:^(BOOL result, NSArray *array, YYIMError *error) {
        if (result && array) {
            self.memberArray = [NSMutableArray arrayWithArray:array];
            
            YYChatGroupMember *member;
            for (YYChatGroupMember *groupMember in self.memberArray) {
                if ([[groupMember memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                    member = groupMember;
                    break;
                }
            }
            
            if (member) {
                [self.memberArray removeObject:member];
            }
            
            [self.tableView reloadData];
        }
    }];
}

@end
