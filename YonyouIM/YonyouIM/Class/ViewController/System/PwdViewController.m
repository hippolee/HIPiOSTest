//
//  PwdViewController.m
//  YonyouIM
//
//  Created by litfb on 15/7/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PwdViewController.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUIDefs.h"

@interface PwdViewController ()

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *dupPasswordField;

@property NSString *password;

@end

@implementation PwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"修改密码";
    
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction:)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = confirmBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)oldPwdEndAction:(id)sender {
    [self.passwordField becomeFirstResponder];
}

- (IBAction)pwdEndAction:(id)sender {
    [self.dupPasswordField becomeFirstResponder];
}

- (IBAction)dupPwdEndAction:(id)sender {
    [self.oldPasswordField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.dupPasswordField resignFirstResponder];
}

- (void)confirmAction:(id)sender {
    NSString *oldPassword = [self.oldPasswordField text];
    NSString *password = [self.passwordField text];
    NSString *dupPassword = [self.dupPasswordField text];
    if ([YYIMUtility isEmptyString:oldPassword]) {
        [self showHint:@"原密码不能为空"];
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginPassword = [userDefaults objectForKey:YYIM_PASSWORD];
    if (![loginPassword isEqualToString:oldPassword]) {
        [self showHint:@"原密码与登录密码不一致"];
        return;
    }
    
    if ([YYIMUtility isEmptyString:password]) {
        [self showHint:@"新密码不能为空"];
        return;
    }
    if ([YYIMUtility isEmptyString:dupPassword]) {
        [self showHint:@"确认密码不能为空"];
        return;
    }
    
    if (![password isEqualToString:dupPassword]) {
        [self showHint:@"两次输入密码不一致"];
        return;
    }
    self.password = password;
    [[YYIMChat sharedInstance].chatManager modifiPassword:password];
    [self showThemeHudInView:self.view];
}

- (void)didModifyPasswordSuccess {
    [self hideHud];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.password forKey:YYIM_PASSWORD];
    [self showHint:@"修改成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didNotModifyPassword:(YYIMError *)error {
    [self hideHud];
    switch ([error errorCode]) {
        case YMERROR_CODE_ILLEGAL_ARGUMENT:
            [self showHint:@"新密码必须是6-32位非空字符"];
            break;
        default:
            if ([YYIMUtility isEmptyString:[error errorMsg]]) {
                [self showHint:@"修改密码失败"];
            } else {
                [self showHint:[NSString stringWithFormat:@"修改密码失败:%@", [error errorMsg]]];
            }
            break;
    }
    
}

@end
