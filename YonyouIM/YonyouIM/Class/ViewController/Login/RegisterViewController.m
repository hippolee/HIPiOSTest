//
//  RegisterViewController.m
//  YonyouIM
//
//  Created by litfb on 15/12/22.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "RegisterViewController.h"
#import "ConfigManager.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMChatHeader.h"

#define INTERVAL_KEYBOARD 30.0f

@interface RegisterViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIControl *controlView;

- (IBAction)alphaAction:(id)sender;

- (IBAction)grayAction:(id)sender;

- (IBAction)betaAction:(id)sender;

- (IBAction)saveAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *socketAddrText;

@property (weak, nonatomic) IBOutlet UITextField *socketPortText;

@property (weak, nonatomic) IBOutlet UITextField *socketSecPortText;

@property (weak, nonatomic) IBOutlet UISwitch *socketSecSwitch;

@property (weak, nonatomic) IBOutlet UITextField *restAddrText;

@property (weak, nonatomic) IBOutlet UITextField *uploadAddrText;

@property (weak, nonatomic) IBOutlet UITextField *downloadAddrText;

@property (weak, nonatomic) IBOutlet UISwitch *restSchemeSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *rosterCollectSwitch;

- (IBAction)textEditingNext:(id)sender;

- (IBAction)textEditingEnd:(id)sender;

// 键盘Rect
@property CGRect keyboardRect;
// 动画时间
@property double duration;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"设置"];
    [self initValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)initValue {
    [self.socketAddrText setText:[[ConfigManager sharedManager] getSettingIMServer]];
    [self.socketPortText setText:[NSString stringWithFormat:@"%ld", (long)[[ConfigManager sharedManager] getSettingIMServerPort]]];
    [self.socketSecPortText setText:[NSString stringWithFormat:@"%ld", (long)[[ConfigManager sharedManager] getSettingIMServerSSLPort]]];
    [self.socketSecSwitch setOn:[[ConfigManager sharedManager] isSettingIMServerEnableSSL]];
    [self.restAddrText setText:[[ConfigManager sharedManager] getSettingIMRestServer]];
    [self.restSchemeSwitch setOn:[[ConfigManager sharedManager] isSettingIMRestServerHTTPS]];
    [self.uploadAddrText setText:[[ConfigManager sharedManager] getSettingResourceUploadServer]];
    [self.downloadAddrText setText:[[ConfigManager sharedManager] getSettingResourceDownloadServer]];
    [self.rosterCollectSwitch setOn:[[ConfigManager sharedManager] isSettingRosterCollect]];
}

- (IBAction)alphaAction:(id)sender {
    [self textEditingEnd:nil];
    [[ConfigManager sharedManager] alphaSettings];
    
    [[ConfigManager sharedManager] sdkConfig];
    [[YYIMConfig sharedInstance] clearMessageVersionNumbers];
    [[YYIMConfig sharedInstance] clearChatGroupVersionNumbers];
    [self initValue];
    [self showHint:@"设置成功"];
}

- (IBAction)grayAction:(id)sender {
    [self textEditingEnd:nil];
    [[ConfigManager sharedManager] graySettings];
    
    [[ConfigManager sharedManager] sdkConfig];
    [[YYIMConfig sharedInstance] clearMessageVersionNumbers];
    [[YYIMConfig sharedInstance] clearChatGroupVersionNumbers];
    [self initValue];
    [self showHint:@"设置成功"];
}

- (IBAction)betaAction:(id)sender {
    [self textEditingEnd:nil];
    [[ConfigManager sharedManager] betaSettings];
    
    [[ConfigManager sharedManager] sdkConfig];
    [[YYIMConfig sharedInstance] clearMessageVersionNumbers];
    [[YYIMConfig sharedInstance] clearChatGroupVersionNumbers];
    [self initValue];
    [self showHint:@"设置成功"];
}

- (IBAction)saveAction:(id)sender {
    
    NSString *socketServer = [YYIMUtility trimString:[self.socketAddrText text]];
    if ([YYIMUtility isEmptyString:socketServer]) {
        [self showHint:@"请填写长连接地址"];
        return;
    }
    NSString *socketPortStr = [YYIMUtility trimString:[self.socketPortText text]];
    if ([YYIMUtility isEmptyString:socketPortStr]) {
        [self showHint:@"请填写长连接端口"];
        return;
    }
    if (![YYIMUtility isIntegerString:socketPortStr]) {
        [self showHint:@"长连接端口错误"];
        return;
    }
    NSString *socketSecPortStr = [YYIMUtility trimString:[self.socketSecPortText text]];
    if ([YYIMUtility isEmptyString:socketSecPortStr]) {
        [self showHint:@"请填写长连接安全端口"];
        return;
    }
    if (![YYIMUtility isIntegerString:socketSecPortStr]) {
        [self showHint:@"长连接安全端口错误"];
        return;
    }
    NSString *restServer = [YYIMUtility trimString:[self.restAddrText text]];
    if ([YYIMUtility isEmptyString:restServer]) {
        [self showHint:@"请填写短连接地址"];
        return;
    }
    
    NSString *uploadServer = [YYIMUtility trimString:[self.uploadAddrText text]];
    if ([YYIMUtility isEmptyString:uploadServer]) {
        [self showHint:@"请填写上传服务地址"];
        return;
    }
    
    NSString *downloadServer = [YYIMUtility trimString:[self.downloadAddrText text]];
    if ([YYIMUtility isEmptyString:downloadServer]) {
        [self showHint:@"请填写下载服务地址"];
        return;
    }
    
    [[ConfigManager sharedManager] setSettingIMServer:socketServer];
    [[ConfigManager sharedManager] setSettingIMServerPort:[socketPortStr integerValue]];
    [[ConfigManager sharedManager] setSettingIMServerSSLPort:[socketSecPortStr integerValue]];
    [[ConfigManager sharedManager] setSettingIMServerEnableSSL:[self.socketSecSwitch isOn]];
    [[ConfigManager sharedManager] setSettingIMRestServer:restServer];
    [[ConfigManager sharedManager] setSettingIMRestServerHTTPS:[self.restSchemeSwitch isOn]];
    [[ConfigManager sharedManager] setSettingResourceUploadServer:uploadServer];
    [[ConfigManager sharedManager] setSettingResourceDownloadServer:downloadServer];
    [[ConfigManager sharedManager] setSettingRosterCollect:[self.rosterCollectSwitch isOn]];
    
    [[ConfigManager sharedManager] sdkConfig];
    [[YYIMConfig sharedInstance] clearMessageVersionNumbers];
    [[YYIMConfig sharedInstance] clearChatGroupVersionNumbers];
    [self initValue];
    [self showHint:@"设置成功"];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.restAddrText) {
        NSString *text = [self.restAddrText text];
        [self.uploadAddrText setText:text];
        [self.downloadAddrText setText:text];
    }
}

- (IBAction)textEditingNext:(id)sender {
    if (sender == self.socketAddrText) {
        [self.socketPortText becomeFirstResponder];
    } else if (sender == self.socketPortText) {
        [self.socketSecPortText becomeFirstResponder];
    } else if (sender == self.socketSecPortText) {
        [self.restAddrText becomeFirstResponder];
    } else if (sender == self.restAddrText) {
        [self.uploadAddrText becomeFirstResponder];
    } else if (sender == self.uploadAddrText) {
        [self.downloadAddrText becomeFirstResponder];
    } else if (sender == self.downloadAddrText) {
        [self.downloadAddrText resignFirstResponder];
    }
    [self judgeView];
}

- (void)textEditingEnd:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

// 键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘Rect
    self.keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 动画时间
    self.duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self judgeView];
}

- (void)judgeView {
    // 获取键盘高度
    CGFloat keyboardHeight = CGRectGetHeight(self.keyboardRect);
    // 当前焦点
    UITextField *textField = [self getFirstResponderTextField];
    if (!textField) {
        return;
    }
    // 计算offset距离
    CGFloat offset = (textField.frame.origin.y + CGRectGetHeight(textField.frame) + INTERVAL_KEYBOARD) - (CGRectGetHeight(self.controlView.frame) - keyboardHeight);
    // 将视图上移计算好的偏移
    if (offset > 0) {
        [UIView animateWithDuration:self.duration animations:^{
            self.view.frame = CGRectMake(0.0f, [self baseHeight] - offset, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

// 键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notification {
    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, [self baseHeight], self.view.frame.size.width, self.view.frame.size.height);
    }];
}

// 键盘改变事件
- (void)keyboardWillChange:(NSNotification *)notification {
    // 获取键盘Rect
    self.keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 动画时间
    self.duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self judgeView];
}

- (UITextField *)getFirstResponderTextField {
    for (UIView *view in [self.controlView subviews]) {
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            return (UITextField *)view;
        }
    }
    return nil;
}

- (CGFloat)baseHeight {
    CGFloat navigationHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    return navigationHeight + statusHeight;
}

@end
