//
//  FileViewController.m
//  YonyouIM
//
//  Created by litfb on 15/3/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "FileViewController.h"
#import "NormalSelTableViewCell.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "YYUser.h"
#import "UIViewController+HUDCategory.h"

@interface FileViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSArray *fileArray;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我收到的文件";
    
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = confirmBtn;
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"NormalSelTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalSelTableViewCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 消息列表
    [self reload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fileArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"NormalSelTableViewCell";
    NormalSelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setImageRadius:0];
    // 取数据
    YYMessage *message = [self.fileArray objectAtIndex:indexPath.row];
    
    YYMessageContent *content = [message getMessageContent];
    // 为cell设置数据
    [cell setHeadIcon:[YYIMUtility fileIconWithExt:[content fileExtension]]];
    [cell setName:[content fileName]];
    [cell setTime:[YYIMUtility genTimeString:[message date]]];
    [cell setDetail:[NSString stringWithFormat:@"来自%@", [[message user] userName]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView indexPathsForSelectedRows].count == 5) {
        [self showHint:@"超过了最多文件个数"];
        return nil;
    }
    return indexPath;
}

#pragma mark -
#pragma mark util

- (void)sendAction {
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    if (!indexPaths || indexPaths.count <= 0) {
        return;
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        YYMessage *fileMessage = [self.fileArray objectAtIndex:indexPath.row];
        [self.delegate forwardFile:[fileMessage pid]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reload {
    self.fileArray = [[YYIMChat sharedInstance].chatManager getReceivedFileMessage];
    [self.tableView reloadData];
}

@end
