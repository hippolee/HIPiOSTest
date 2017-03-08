//
//  HIPTableViewController.m
//  litfb_test
//
//  Created by litfb on 15/12/30.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "HIPTableViewController.h"
#import "HIPUtility.h"
#import "HIPDropRefreshViewController.h"
#import "HIPPullUpViewController.h"
#import "HIPDropDownViewController.h"
#import "HIPQRCodeViewController.h"
#import "HIPScanViewController.h"
#import "HIPPhotoScanViewController.h"
#import "HIPTestViewController.h"
#import "HIPHeadViewController.h"
#import "HIPZipViewController.h"
#import "HIPCusCodeViewController.h"
#import "HIPColorViewController.h"
#import "HIPSvgViewController.h"
#import "HIPStackMenuViewController.h"
#import "HIPLayerController.h"

@interface HIPTableViewController ()

@end

@implementation HIPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self.navigationItem setTitle:@"HIP测试"];
    // 去掉多余分隔线
    [HIPUtility setExtraCellLineHidden:self.tableView];
    // 返回显示
    [HIPUtility setBackButtonText:@"返回" forController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setHidesBottomBarWhenPushed:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableViewIdentifier = @"MainTableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentifier];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    switch (indexPath.row) {
        case 0:
            [[cell textLabel] setText:@"下拉刷新"];
            break;
        case 1:
            [[cell textLabel] setText:@"上拉加载"];
            break;
        case 2:
            [[cell textLabel] setText:@"下拉加载"];
            break;
        case 3:
            [[cell textLabel] setText:@"二维码生成"];
            break;
        case 4:
            [[cell textLabel] setText:@"二维码扫描"];
            break;
        case 5:
            [[cell textLabel] setText:@"图片二维码扫描"];
            break;
        case 6:
            [[cell textLabel] setText:@"头像测试"];
            break;
        case 7:
            [[cell textLabel] setText:@"压缩测试"];
            break;
        case 8:
            [[cell textLabel] setText:@"自定义二维码生成"];
            break;
        case 9:
            [[cell textLabel] setText:@"颜色"];
            break;
        case 10:
            [[cell textLabel] setText:@"SVG"];
            break;
        case 11:
            [[cell textLabel] setText:@"菜单"];
            break;
        case 12:
            [[cell textLabel] setText:@"Layer"];
            break;
        case 13:
            [[cell textLabel] setText:@"ActionSheet"];
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            HIPDropRefreshViewController *pullRefreshController = [[HIPDropRefreshViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:pullRefreshController animated:YES];
            break;
        }
        case 1: {
            HIPPullUpViewController *pullUpController = [[HIPPullUpViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:pullUpController animated:YES];
            break;
        }
        case 2: {
            HIPDropDownViewController *dropDownController = [[HIPDropDownViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:dropDownController animated:YES];
            break;
        }
        case 3: {
            HIPQRCodeViewController *qrCodeController = [[HIPQRCodeViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:qrCodeController animated:YES];
            break;
        }
        case 4: {
            HIPScanViewController *scanViewController = [[HIPScanViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:scanViewController animated:YES];
            break;
        }
        case 5: {
            HIPPhotoScanViewController *photoScanController = [[HIPPhotoScanViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:photoScanController animated:YES];
            break;
        }
        case 6: {
            HIPHeadViewController *headViewController = [[HIPHeadViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:headViewController animated:YES];
            break;
        }
        case 7: {
            HIPZipViewController *zipViewController = [[HIPZipViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:zipViewController animated:YES];
            break;
        }
        case 8: {
            HIPCusCodeViewController *cusCodeViewController = [[HIPCusCodeViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:cusCodeViewController animated:YES];
            break;
        }
        case 9: {
            HIPColorViewController *colorViewController = [[HIPColorViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:colorViewController animated:YES];
            break;
        }
        case 10: {
            HIPSvgViewController *svgViewController = [[HIPSvgViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:svgViewController animated:YES];
            break;
        }
        case 11: {
            HIPStackMenuViewController *stackMenuController = [[HIPStackMenuViewController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:stackMenuController animated:YES];
            break;
        }
        case 12: {
            HIPLayerController *layerController = [[HIPLayerController alloc] init];
            [HIPUtility pushFromViewController:self toViewController:layerController animated:YES];
            break;
        }
        case 13: {
            
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
