//
//  PubAccountDisplayController.m
//  YonyouIM
//
//  Created by litfb on 15/7/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PubAccountDisplayController.h"

@interface PubAccountDisplayController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PubAccountDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.account accountName]];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[self.paContent contentSourceUrl]]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
