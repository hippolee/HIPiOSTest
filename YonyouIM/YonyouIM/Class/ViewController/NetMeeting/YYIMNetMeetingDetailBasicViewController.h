//
//  YYIMNetMeetingDetailBasicViewController.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMGlobalInviteDelegate.h"
#import "YYIMChatHeader.h"
#import "YYIMBaseViewController.h"

#define TAG_ALERTVIEW_NETMEETING_TOPIC          11

#define TAG_ACTIONSHEET_NETMEETING_CANCEL       21
#define TAG_ACTIONSHEET_NETMEETING_TYPE         22

#define AGENDA_TEXT_DEFAULT_HEIGHT              60

#define YM_NETMEETING_MEMBER_CELL_WIDTH         60.0f

@interface YYIMNetMeetingDetailBasicViewController : YYIMBaseViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GlobalInviteViewControllerDelegate,UIAlertViewDelegate, UIActionSheetDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionFlowLayout;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (strong, nonatomic) UITextView *agendaTextView;

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UIBarButtonItem *confirmBtn;

@property (retain, nonatomic) YYNetMeetingDetail *netMeetingDetail;

@property (nonatomic) NSInteger cellNumberPerRow;

#pragma mark public -
#pragma mark public method
- (CGFloat)collectionViewHeight;

@end

