//
//  YYIMNetMeetingDetailBasicViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingDetailBasicViewController.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"

@interface YYIMNetMeetingDetailBasicViewController ()

@end

@implementation YYIMNetMeetingDetailBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Collection每行Cell数量
    self.cellNumberPerRow = floor(CGRectGetWidth([UIScreen mainScreen].bounds) / YM_NETMEETING_MEMBER_CELL_WIDTH);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark chat procotol

- (void)didUserInfoUpdate {
    [self reloadUserData];
}

#pragma mark -
#pragma mark parent method

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), [self collectionViewHeight]) collectionViewLayout:[self collectionFlowLayout]];
        [collectionView setDataSource:self];
        [collectionView setDelegate:self];
        // 注册Cell nib
        [collectionView registerNib:[UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
        
        UIView *bgView = [[UIView alloc] init];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [bgView addGestureRecognizer:[self tapGestureRecognizer]];
        [collectionView setBackgroundView:bgView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionFlowLayout {
    if (!_collectionFlowLayout) {
        UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectionFlowLayout setItemSize:CGSizeMake(YM_NETMEETING_MEMBER_CELL_WIDTH, YM_NETMEETING_MEMBER_CELL_WIDTH)];
        CGFloat offsetX = CGRectGetWidth([UIScreen mainScreen].bounds) - self.cellNumberPerRow * YM_NETMEETING_MEMBER_CELL_WIDTH;
        [collectionFlowLayout setSectionInset:UIEdgeInsetsMake(8.0f, offsetX / 2.0f, 8.0f, offsetX / 2.0f)];
        [collectionFlowLayout setMinimumLineSpacing:8.0f];
        [collectionFlowLayout setMinimumInteritemSpacing:0.0f];
        _collectionFlowLayout = collectionFlowLayout;
    }
    return _collectionFlowLayout;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        // 单击
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewTap:)];
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer setCancelsTouchesInView:YES];
        _tapGestureRecognizer = tapGestureRecognizer;
    }
    return _tapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        // 长按
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(memberLongTap:)];
        longPressGestureRecognizer.delegate = self;
        [longPressGestureRecognizer setCancelsTouchesInView:YES];
        _longPressGestureRecognizer = longPressGestureRecognizer;
    }
    return _longPressGestureRecognizer;
}

- (UIView *)footerView {
    if (!_footerView) {
        CGFloat footerWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, 70.0f)];
        [footerView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
        
        UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, 0.5)];
        [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [footerView addSubview:sepView];
        // 取消预约会议
        UIButton *quitGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 16, footerWidth - 32.0f, 46.0f)];
        [quitGroupBtn setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [quitGroupBtn setBackgroundColor:[UIColor redColor]];
        [quitGroupBtn setTitle:@"取消预约" forState:UIControlStateNormal];
        [quitGroupBtn addTarget:self action:@selector(cancelNetMeetingAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:quitGroupBtn];
        _footerView = footerView;
    }
    return _footerView;
}

//- (UIDatePicker *)datePicker {
//    if (!_datePicker) {
//        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
//        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//        _datePicker = datePicker;
//    }
//    
//    return _datePicker;
//}

- (UITextView *)agendaTextView {
    if (!_agendaTextView) {
        CGFloat agendaWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        UITextView *agendaTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 8, agendaWidth - 16, AGENDA_TEXT_DEFAULT_HEIGHT)];
        [agendaTextView setTextColor:UIColorFromRGB(0x4e4e4e)];
        [agendaTextView setFont:[UIFont systemFontOfSize:14]];
        [agendaTextView setDelegate:self];
        [agendaTextView setReturnKeyType:UIReturnKeyDone];
        [agendaTextView setEnablesReturnKeyAutomatically:YES];
        _agendaTextView = agendaTextView;
    }
    
    return _agendaTextView;
}

- (CGFloat)collectionViewHeight {
    CGFloat count = [self numberOfCollectionViewItems];
    CGFloat line = ceil(count / self.cellNumberPerRow);
    CGFloat height = line * YM_NETMEETING_MEMBER_CELL_WIDTH + (line - 1) * 8.0f + 16.0f;
    
    return height;
}

- (void)cancelNetMeetingAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认取消预约会议？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = TAG_ACTIONSHEET_NETMEETING_CANCEL;
    [actionSheet showInView:self.view];
}

#pragma mark -
#pragma mark abstract method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)numberOfCollectionViewItems {
    return 0;
}

- (void)collectionViewTap:(id)sender {
}

- (void)memberLongTap:(UILongPressGestureRecognizer *)sender {
}

- (void)reloadUserData {
}

@end
