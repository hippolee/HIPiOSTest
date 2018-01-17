//
//  JoinNetMeetingViewController.m
//  YonyouIM
//
//  Created by litfb on 16/3/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "JoinNetMeetingViewController.h"
#import "YYIMColorHelper.h"
#import "YYIMChatHeader.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMNetMeetingAudienceViewController.h"

@interface JoinNetMeetingViewController ()<YYIMChatDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *channelText;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

- (IBAction)joinAction:(id)sender;

@property (retain, nonatomic) YYUser *user;

@end

@implementation JoinNetMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"加入会议"];
    
    [self initView];
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 16.0f, CGRectGetWidth(self.topView.frame), 0.5f)];
    [view1 setBackgroundColor:UIColorFromRGB(0xc0c0c0)];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 64.0f, CGRectGetWidth(self.topView.frame), 0.5f)];
    [view2 setBackgroundColor:UIColorFromRGB(0xd9dadd)];
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 111.0f, CGRectGetWidth(self.topView.frame), 0.5f)];
    [view3 setBackgroundColor:UIColorFromRGB(0xc0c0c0)];
    
    [self.view addSubview:view1];
    [self.view addSubview:view2];
    [self.view addSubview:view3];
    
    // 单击事件
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer setCancelsTouchesInView:YES];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)initData {
    self.user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
    [self.nameLabel setText:[self.user userName]];
}

- (IBAction)joinAction:(id)sender {
    NSString *channelId = [YYIMUtility trimString:[self.channelText text]];
    if ([YYIMUtility isEmptyString:channelId]) {
        return;
    }
    
    if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
        [self showHint:@"当前有会议在进行，操作被禁止"];
    } else {
        [[YYIMChat sharedInstance].chatManager joinNetMeeting:channelId];
        [self.navigationController popViewControllerAnimated:YES];

    }
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.channelText isFirstResponder]) {
        return YES;
    }
    return NO;
}

- (void)tapAction:(id)sender {
    [self.channelText resignFirstResponder];
}

@end
