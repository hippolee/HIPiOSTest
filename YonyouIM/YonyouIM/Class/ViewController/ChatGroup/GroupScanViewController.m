//
//  GroupScanViewController.m
//  YonyouIM
//
//  Created by litfb on 16/3/16.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "GroupScanViewController.h"
#import "UIImageView+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "ChatViewController.h"
#import "UIViewController+HUDCategory.h"

@interface GroupScanViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

- (IBAction)joinAction:(id)sender;

@end

@implementation GroupScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"加入群组";
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    CALayer *layer = [self.joinButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0f];
}

- (void)initData {
    [self.groupLabel setText:[[self.groupInfo group] groupName]];
    [self.countLabel setText:[NSString stringWithFormat:@"(共%ld人)", (long)[[self.groupInfo group] memberCount]]];
    [self.groupImage ym_setImageWithGroupInfo:self.groupInfo placeholderImage:[UIImage imageNamed:@"icon_chatgroup"]];
}

- (IBAction)joinAction:(id)sender {
    [[YYIMChat sharedInstance].chatManager joinChatGroup:[[self.groupInfo group] groupId]];
}

- (void)didJoinChatGroup:(NSString *)groupId {
    if ([groupId isEqualToString:[[self.groupInfo group] groupId]]) {
        ChatViewController *chatViewController = [[ChatViewController alloc] init];
        [chatViewController setChatId:groupId];
        [chatViewController setChatType:YM_MESSAGE_TYPE_GROUPCHAT];
        
        [YYIMUtility pushFromController:self toController:chatViewController];
    }
}

- (void)didNotJoinChatGroup:(NSString *)groupId error:(YYIMError *)error {
    // hint
    NSRange range = [[error errorMsg] rangeOfString:@"limit"];
    
    if (range.location != NSNotFound) {
        [self showHint:@"加入群组失败，群组人数已达到上限"];
    } else {
        [self showHint:@"加入群组失败"];
    }
}

@end
