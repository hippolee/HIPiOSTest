//
//  WebViewController.m
//  YonyouIM
//
//  Created by litfb on 15/9/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [webView setDelegate:self];
    [self.view addSubview:webView];
    self.webView = webView;
    
    if (!self.provider) {
        self.provider = [[self genUrl] host];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    [label setText:[[NSString alloc] initWithFormat:@"此网页由%@提供", self.provider]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [self.webView insertSubview:label atIndex:0];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[self genUrl]];
    [self.webView loadRequest:request];
}

- (NSURL *)genUrl {
    if ([self.urlString hasPrefix:@"http:"] || [self.urlString hasPrefix:@"https:"]) {
        return [NSURL URLWithString:self.urlString];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", self.urlString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
