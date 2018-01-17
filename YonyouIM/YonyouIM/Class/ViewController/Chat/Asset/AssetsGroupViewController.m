//
//  AssetsGroupViewController.m
//  YonyouIM
//
//  Created by litfb on 15/2/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "AssetsGroupViewController.h"
#import "AssetViewController.h"
#import "SingleLineCell.h"
#import "YYIMUtility.h"
#import "AssetBgView.h"
#import "YYIMUIDefs.h"
#import "UIColor+YYIMTheme.h"
#import "ALAssetsGroup+YYIMCatagory.h"

#define IMAGE_SIZE 60

@interface AssetsGroupViewController ()

@property (retain, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (retain, nonatomic) NSMutableArray *groupArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AssetsGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    // 检查相册权限
    __block BOOL auth = [self checkAlAuth];
    if (auth) {
        // asstes library
        if (!self.assetsLibrary) {
            self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        
        // group array
        self.groupArray = [NSMutableArray array];
        __block NSMutableArray *albumArray = [NSMutableArray array];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                switch ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue]) {
                    case ALAssetsGroupSavedPhotos:
                        if ([group getPhotoCount] > 0) {
                            [self.groupArray addObject:group];
                        }
                        
                        break;
                    default:
                        [albumArray addObject:group];
                        break;
                }
            } else {
                if (albumArray.count > 0) {
                    [self.groupArray addObjectsFromArray:albumArray];
                }
                [self reloadData];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"enumerate assets groups failure,%@", error.description);
            if (auth) {
                auth = [self checkAlAuth];
            }
        }];
    }
    
    self.title = @"相册";
    
    // 注册Cell nib
    UINib *leftnib=[UINib nibWithNibName:@"SingleLineCell" bundle:nil];
    [self.tableView registerNib:leftnib forCellReuseIdentifier:@"SingleLineCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell";
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell reuse];
    [cell setImageRadius:0];
    // 取数据
    ALAssetsGroup *assetsGroup = [self.groupArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    CGImageRef posterImage = assetsGroup.posterImage;
    size_t height = CGImageGetHeight(posterImage);
    size_t width = CGImageGetWidth(posterImage);
    float scale = fmaxf(height, width) / IMAGE_SIZE;
    // image
    [cell.iconImage setImage:[UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp]];
    // name
    [cell.nameLabel setAttributedText:[self genAttributeText:[assetsGroup valueForProperty:ALAssetsGroupPropertyName] imageCount:[assetsGroup getPhotoCount]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetViewController *assetViewController = [[AssetViewController alloc] initWithNibName:nil bundle:nil];
    // 相册
    ALAssetsGroup *groupSelected = [self.groupArray objectAtIndex:[indexPath row]];
    // 传参到AlbumImageViewController
    [assetViewController setAssetsGroup:groupSelected];
    [assetViewController setDelegate:self.delegate];
    [self.navigationController pushViewController:assetViewController animated:YES];
    // 取消行选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark private func

- (BOOL)checkAlAuth {
    // 相册权限
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    // 受限或拒绝
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        [self.tableView setHidden:YES];
        [self showNoAuth];
        return NO;
    }
    return YES;
}

- (void)showNoAuth {
    AssetBgView *bgView = [[AssetBgView alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"AssetBgView" owner:bgView options:nil];
    // 设置内容
    [bgView.imageView setImage:[UIImage imageNamed:@""]];
    [bgView.promptLabel setText:@"此应用没有权限访问您的照片或视频"];
    [bgView.detailLabel setText:@"您可以在“隐私设置”中启用访问"];
    // 设置BackgroundView
    [self.tableView setBackgroundView:bgView];
}

- (void)showNoAssets {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AssetBgView" owner:nil options:nil];
    AssetBgView *bgView = [array objectAtIndex:0];
    // 设置内容
    [bgView.promptLabel setText:@"没有照片或视频"];
    [bgView.detailLabel setText:@"您可以使用 iTunes 将照片和视频同步到 iPhone"];
    // 设置BackgroundView
    [self.tableView setBackgroundView:bgView];
}

- (NSAttributedString *)genAttributeText:(NSString *)groupName imageCount:(NSInteger) count {
    // name color
    UIColor *nameColor = [UIColor _0bGrayColor];
    // name attribute
    NSDictionary *nameAttributeDic = @{NSForegroundColorAttributeName:nameColor,NSFontAttributeName:[UIFont systemFontOfSize:18] };
    // init
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:groupName attributes:nameAttributeDic];
    // group image count
    NSString *countStr = [NSString stringWithFormat:@"  (%ld)", (long)count];
    // count color
    UIColor *countColor = [UIColor darkGrayColor];
    // name attribute
    NSDictionary *countAttributeDic = @{NSForegroundColorAttributeName:countColor,NSFontAttributeName:[UIFont systemFontOfSize:13] };
    [attrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:countStr attributes:countAttributeDic]];
    return attrString;
}

- (void)reloadData {
    if ([self.groupArray count] <= 0) {
        [self showNoAssets];
    } else {
        [self.tableView reloadData];
    }
}

@end
