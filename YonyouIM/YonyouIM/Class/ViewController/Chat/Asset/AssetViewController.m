//
//  AssetViewController.m
//  YonyouIM
//
//  Created by litfb on 15/7/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "AssetViewController.h"
#import "ImageCollectionViewCell.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUIDefs.h"
#import "YYIMUtility.h"
#import "AssetPreviewController.h"
#import "UIColor+YYIMTheme.h"
#import "ALAssetsGroup+YYIMCatagory.h"

@interface AssetViewController ()

@property (nonatomic, strong) NSArray *assetsArray;

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;

@property (weak, nonatomic) UIButton *previewButton;
@property (weak, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) UILabel *numberLabel;

@property (retain, nonatomic) NSMutableArray *selectedArray;

@end

@implementation AssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)]];
    
    [self initToolBar];
    [self initCollectionView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    gestureRecognizer.cancelsTouchesInView = YES;
    [self.collectionView addGestureRecognizer:gestureRecognizer];
    
    // assets
    self.assetsArray = [self.assetsGroup getPhotoArray];
    self.selectedArray = [NSMutableArray array];
    
    [self.collectionView reloadData];
    [self scrollTableViewBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initToolBar {
    // 预览按钮
    UIButton *previewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 30)];
    [previewButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [previewButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor _0bGrayColor] forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [previewButton addTarget:self action:@selector(previewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *priviewItem = [[UIBarButtonItem alloc] initWithCustomView:previewButton];
    self.previewButton = previewButton;
    [self.previewButton setEnabled:NO];
    
    // 发送按钮
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 30)];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [sendButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor themeBlueColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.sendButton = sendButton;
    [self.sendButton setEnabled:NO];
    
    // 数字
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [numberLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [numberLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [numberLabel setTextColor:[UIColor whiteColor]];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setBackgroundColor:[UIColor themeBlueColor]];
    UIBarButtonItem *numberItem = [[UIBarButtonItem alloc] initWithCustomView:numberLabel];
    self.numberLabel = numberLabel;
    [self.numberLabel setHidden:YES];
    
    CALayer *numberLayer = [self.numberLabel layer];
    [numberLayer setMasksToBounds:YES];
    [numberLayer setCornerRadius:9];
    
    UIBarButtonItem *flexibleItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:  UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:priviewItem, flexibleItem, numberItem, sendItem, nil];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = [[UIScreen mainScreen]bounds].size.width / 4;
    [collectionViewLayout setItemSize:CGSizeMake(width, width)];
    [collectionViewLayout setMinimumInteritemSpacing:0];
    [collectionViewLayout setMinimumLineSpacing:0];
    [collectionViewLayout setSectionInset:UIEdgeInsetsZero];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), [self baseViewHeight] - CGRectGetHeight(self.navigationController.toolbar.frame)) collectionViewLayout:collectionViewLayout];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView setAllowsMultipleSelection:YES];
    [collectionView setBackgroundColor:[UIColor themeColor]];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 注册Cell nib
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    [self refreshButtonState];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)scrollTableViewBottom {
    NSUInteger rowCount = self.assetsArray.count;
    if (rowCount > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowCount - 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewAction:(id)sender {
    AssetPreviewController *assetPreviewController = [[AssetPreviewController alloc] initWithNibName:nil bundle:nil];
    assetPreviewController.delegate = self.delegate;
    assetPreviewController.imageSourceArray = [self.selectedArray copy];
    assetPreviewController.imageIndex= 0;
    assetPreviewController.selectedArray = self.selectedArray;
    [self.navigationController pushViewController:assetPreviewController animated:YES];
}

- (void)sendAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate didSelectAssets:self.selectedArray isOriginal:NO];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assetsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // cell
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    // asset
    ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row];
    // set image
    [cell.imageView setImage:[UIImage imageWithCGImage:asset.thumbnail]];
    [cell.checkboxButton addTarget:self action:@selector(imageCheckChange:) forControlEvents:UIControlEventTouchUpInside];
    if ([self.selectedArray containsObject:asset]) {
        [cell setSelected:YES];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark private func

- (void)tapAction:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    AssetPreviewController *assetPreviewController = [[AssetPreviewController alloc] initWithNibName:nil bundle:nil];
    assetPreviewController.delegate = self.delegate;
    assetPreviewController.imageSourceArray = self.assetsArray;
    assetPreviewController.imageIndex = indexPath.row;
    assetPreviewController.selectedArray = self.selectedArray;
    [self.navigationController pushViewController:assetPreviewController animated:YES];
}

- (void)imageCheckChange:(id)sender {
    UICollectionViewCell *cell = [YYIMUtility superCollectionCellForView:sender];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    UIButton *checkboxBtn = (UIButton *)sender;
    if (![checkboxBtn isSelected] && [[self selectedArray] count] >= 9) {
        [self showHint:@"您最多只能选择9张照片"];
        return;
    }
    
    ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row];
    if ([self.selectedArray containsObject:asset]) {
        [self.selectedArray removeObject:asset];
        [cell setSelected:NO];
    } else {
        [[self selectedArray] addObject:asset];
        [cell setSelected:YES];
    }
    [self refreshButtonState];
}

- (void)refreshButtonState {
    NSInteger count = [[self selectedArray] count];
    [self.numberLabel setText:[NSString stringWithFormat:@"%ld", (long)count]];
    if (count <= 0) {
        [self.numberLabel setHidden:YES];
        [self.sendButton setEnabled:NO];
        [self.previewButton setEnabled:NO];
    } else {
        [self.numberLabel setHidden:NO];
        [self.sendButton setEnabled:YES];
        [self.previewButton setEnabled:YES];
    }
}

- (CGFloat)baseViewHeight {
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat navigationHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    return screenHeight - navigationHeight - statusHeight;
}

@end