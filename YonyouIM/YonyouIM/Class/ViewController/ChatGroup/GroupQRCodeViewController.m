//
//  GroupQRCodeViewController.m
//  YonyouIM
//
//  Created by litfb on 16/3/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "GroupQRCodeViewController.h"
#import "YYIMColorHelper.h"
#import "YYIMChatHeader.h"
#import "YMAFNetworking.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMQRCodeUtility.h"
#import "YYIMUtility.h"
#import "UIImageView+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"
#import "ChatSelViewController.h"
#import "ChatSelNavController.h"

@interface GroupQRCodeViewController ()<UIActionSheetDelegate, YMChatSelDelegate>

@property (weak, nonatomic) IBOutlet UIView *groupCardView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (retain, nonatomic) YYChatGroup *group;

@end

@implementation GroupQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"群二维码名片"];
    // init
    [self initQRCode];
    [self loadData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    CALayer *cardLayer = [self.contentView layer];
    [cardLayer setMasksToBounds:YES];
    [cardLayer setCornerRadius:4.0f];
    [cardLayer setBorderColor:[UIColor blackColor].CGColor];
    [cardLayer setBorderWidth:1.0f];
    // group image
    [self.groupImage ym_setImageWithGroupId:self.groupId placeholderImage:[UIImage imageNamed:@"icon_chatgroup"]];
    // save
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)]];
}

- (void)loadData {
    self.group = [[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:self.groupId];
    // group name
    [self.groupLabel setText:[self.group groupName]];
}

- (void)initQRCode {
    [[YYIMChat sharedInstance].chatManager genChatGroupQrCodeWithGroupId:self.groupId complete:^(BOOL result, NSDictionary *qrCodeInfo, YYIMError *error) {
        if (!result) {
            [self showHint:@"群组二维码生成失败"];
        } else {
            NSString *qrCodeText = [qrCodeInfo objectForKey:@"qrCodeText"];
            NSTimeInterval qrCodeExpire = [[qrCodeInfo objectForKey:@"qrCodeExpire"] longValue];
            UIImage *image = [YYIMQRCodeUtility createQRCodeImageWithSource:qrCodeText dimension:CGRectGetWidth(self.qrCodeImage.frame)];
            UIImage *image2 = [YYIMQRCodeUtility decorateQRCodeImage:image withIcon:[UIImage imageNamed:@"icon_app"] scale:0.2f];
            [self.qrCodeImage setImage:image2];
            [self.infoLabel setText:[NSString stringWithFormat:@"该二维码7天内(%@)有效，重新进入将更新", [YYIMUtility genTimeString:qrCodeExpire dateFormat:@"MM月dd日"]]];
        }
    }];
}

- (void)saveAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享到用友IM", @"保存到相册", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            ChatSelViewController *chatSelViewController = [[ChatSelViewController alloc] initWithNibName:@"ChatSelViewController" bundle:nil];
            ChatSelNavController *chatSelNavController = [[ChatSelNavController alloc] initWithRootViewController:chatSelViewController];
            [YYIMUtility genThemeNavController:chatSelNavController];
            chatSelNavController.chatSelDelegate = self;
            [self presentViewController:chatSelNavController animated:YES completion:nil];
            break;
        }
        case 1: {
            UIImage *image = [UIImage convertViewToImage:self.groupCardView];
            ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
            NSData *data = UIImagePNGRepresentation(image);
            [assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    [self showHint:@"图片保存失败"];
                } else {
                    [self showHint:@"图片已保存"];
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark YMChatSelDelegate

- (void)didSelectChatId:(NSString *)chatId chatType:(NSString *)chatType {
    UIImage *image = [UIImage convertViewToImage:self.groupCardView];
    // save image
    NSString *path = [YYIMResourceUtility saveImage:image];
    [[YYIMChat sharedInstance].chatManager sendImageMessage:chatId paths:[NSArray arrayWithObject:path] chatType:chatType];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
