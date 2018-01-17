//
//  ViewController.m
//  YonyouIM
//
//  Created by litfb on 14/12/15.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+HUDCategory.h"
#import "AppDelegate.h"
#import "YYIMUIDefs.h"
#import "YYIMUtility.h"
#import "UIButton+YYIMCatagory.h"
#import "YYIMColorHelper.h"
#import "YYIMChatHeader.h"
#import "RegisterViewController.h"
#import <PgyUpdate/PgyUpdateManager.h>

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountText;
- (IBAction)next:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)hideKeyBoard:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)settingAction:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[YYIMChat sharedInstance] chatManager] addDelegate:self];
    
    self.accountText.text = [[NSUserDefaults standardUserDefaults] objectForKey:YYIM_LASTLOGIN_ACCOUNT];
    
    // 监听键盘高度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.accountText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordText];
    
    [self.loginBtn setBackgroundColor:UIColorFromRGB(0x50e3c2) forState:UIControlStateDisabled];
    [self.loginBtn setBackgroundColor:UIColorFromRGB(0x29e462) forState:UIControlStateNormal];
    
    [[PgyUpdateManager sharedPgyManager] checkUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)next:(id)sender {
    [self.passwordText becomeFirstResponder];
}

- (IBAction)hideKeyBoard:(id)sender {
    [self.accountText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}

- (void)keyboardWillChange:(NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = endKeyboardRect.size;
    
    [UIView animateWithDuration:duration animations:^{
        CGFloat copyrightHeight = CGRectGetWidth([UIScreen mainScreen].bounds) / 8;
        
        CGFloat miniHeight = 176 + 116 + 25;
        
        CGFloat targetHeight = [[UIScreen mainScreen]bounds].size.height - keyboardSize.height;
        
        if (miniHeight > targetHeight) {
            self.view.frame = CGRectMake(0, targetHeight - miniHeight, self.view.frame.size.width, miniHeight + copyrightHeight);
        } else {
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, targetHeight + copyrightHeight);
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height);
    }completion:^(BOOL finished) {
        
    }];
}

- (void)textFieldChanged:(id)sender {
    NSString *account = self.accountText.text;
    NSString *password = self.passwordText.text;
    if ([YYIMUtility isEmptyString:account] || [YYIMUtility isEmptyString:password]) {
        self.loginBtn.enabled = NO;
    } else {
        self.loginBtn.enabled = YES;
    }
}

- (IBAction)login:(id)sender {
    NSString *account = self.accountText.text;
    NSString *password = self.passwordText.text;
    // trim
    account = [account stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([YYIMUtility isEmptyString:account]) {
        return;
    }
    
    [self hideKeyBoard:nil];
    
    NSError *error;
    account = [self prepareAccount:account password:password error:&error];
    if (error) {
        [self showHint:[error localizedDescription]];
        return;
    }
    
    [self showThemeHudInView:self.view];
    
    YYIMLoginCompleteBlock block = ^(BOOL result, NSDictionary *userInfo, YYIMError *loginError) {
        if (result) {
            [self hideHud];
            [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_LOGINCHANGE object:@YES];
        } else {
            if (loginError) {
                NSString *message;
                if ([[loginError errorMsg] isEqualToString:@"app not found"]) {
                    message = @"登录的应用不存在";
                } else {
                    message = [loginError errorMsg];
                }
                if (!message) {
                    message = @"连接IM服务器失败";
                }
                
                [self hideHud];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[@"登录失败:" stringByAppendingString:message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
    };
    
    if ([YYIMUtility isEmptyString:account]) {
        [[YYIMChat sharedInstance].chatManager loginAnonymousWithCompletion:block];
    } else {
        [[YYIMChat sharedInstance].chatManager login:account completion:block];
    }
}

- (IBAction)settingAction:(id)sender {
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (NSString *)prepareAccount:(NSString *)account password:(NSString *)password error:(NSError **)errPtr {
    // save last login account
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:YYIM_LASTLOGIN_ACCOUNT];
    
    // match reg
    NSRegularExpression *regexFull = [NSRegularExpression regularExpressionWithPattern:@"([a-z0-9A-Z_.-]{1,50})@([\\w]+)\\.([\\w]+)" options:0 error:nil];
    NSTextCheckingResult *matchFull = [regexFull firstMatchInString:account options:0 range:NSMakeRange(0, [account length])];
    
    if (matchFull) {
        // 从account中截取数据
        NSString *app = [account substringWithRange:[matchFull rangeAtIndex:2]];
        NSString *etp = [account substringWithRange:[matchFull rangeAtIndex:3]];
        account = [account substringWithRange:[matchFull rangeAtIndex:1]];
        // 注册app
        [[YYIMChat sharedInstance] registerApp:app etpKey:etp];
        [userDefaults setObject:app forKey:YYIM_APPKEY];
        [userDefaults setObject:etp forKey:YYIM_ETPKEY];
        [userDefaults setObject:account forKey:YYIM_ACCOUNT];
        [userDefaults setObject:password forKey:YYIM_PASSWORD];
        [userDefaults synchronize];
        return account;
    }
    
    NSRegularExpression *regexSingle = [NSRegularExpression regularExpressionWithPattern:@"[a-z0-9A-Z_.-]{1,50}" options:0 error:nil];
    NSTextCheckingResult *matchSingle = [regexSingle firstMatchInString:account options:0 range:NSMakeRange(0, [account length])];
    if (matchSingle) {
        // 注册app
        [[YYIMChat sharedInstance] registerApp:YYIM_DEFAULT_APPKEY etpKey:YYIM_DEFAULT_ETPKEY];
        [userDefaults setObject:YYIM_DEFAULT_APPKEY forKey:YYIM_APPKEY];
        [userDefaults setObject:YYIM_DEFAULT_ETPKEY forKey:YYIM_ETPKEY];
        [userDefaults setObject:account forKey:YYIM_ACCOUNT];
        [userDefaults setObject:password forKey:YYIM_PASSWORD];
        [userDefaults synchronize];
        return account;
    } else {
        *errPtr = [NSError errorWithDomain:@"com.yonyou.sns" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"用户名不合法" forKey:NSLocalizedDescriptionKey]];
        return account;
    }
}

@end
