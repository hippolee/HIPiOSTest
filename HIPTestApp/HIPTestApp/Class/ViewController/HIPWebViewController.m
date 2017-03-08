//
//  HIPWebViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPWebViewController.h"

@interface HIPWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) UIWebView *webView;

@property (weak, nonatomic) UILabel *providerLabel;

@end

@implementation HIPWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // data
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView setDelegate:self];
    [self.view addSubview:webView];
    self.webView = webView;
    
    UILabel *providerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    [providerLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [providerLabel setTextColor:[UIColor whiteColor]];
    [providerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.webView insertSubview:providerLabel atIndex:0];
}

- (void)initData {
    if (!self.url) {
        return;
    }
    // 提供者
    NSString *provider = [self.url host];
    [self.providerLabel setText:[[NSString alloc] initWithFormat:@"此网页由%@提供", provider]];
    // load url
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
