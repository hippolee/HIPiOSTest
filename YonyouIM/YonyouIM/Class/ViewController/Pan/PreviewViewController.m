//
//  PreviewViewController.m
//  YonyouIM
//
//  Created by litfb on 15/7/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PreviewViewController.h"
#import "YYIMUtility.h"
#import "UIColor+YYIMTheme.h"

@interface PreviewViewController ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    [YYIMUtility adapterIOS7ViewController:self];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)]];
    
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [YYIMUtility genThemeNavController:[self navigationController]];
}

- (void)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.file;
}

@end

@implementation YYFile (QLPreviewConvenienceAdditions)

- (NSURL *)previewItemURL {
    return [self fileUrl];
}

- (NSString *)previewItemTitle {
    return @"文件预览";
}

@end
