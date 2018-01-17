//
//  ChatViewController.m
//  YonyouIM
//
//  Created by litfb on 15/5/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatInfoViewController.h"
#import "GroupInfoViewController.h"
#import "AccountInfoViewController.h"
#import "LocationShowController.h"
#import "AssetsGroupViewController.h"
#import "FileViewController.h"
#import "LocationViewController.h"
#import "MemberSelViewController.h"
#import "PubAccountDisplayController.h"
#import "UserViewController.h"
#import "UIViewController+HUDCategory.h"
#import "YMMessageToolView.h"
#import "YMMessageExtendView.h"
#import "YYIMChatHeader.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "ChatTableViewCell.h"
#import "ChatMicroVideoTableViewCell.h"
#import "ChatSingleMixedTableViewCell.h"
#import "ChatBatchMixedTableViewCell.h"
#import "ChatPromptTableViewCell.h"
#import "ChatImageBrowserView.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMEmojiKeyboardBuilder.h"
#import "YYIMEmojiDefs.h"
#import "YYIMUIDefs.h"
#import "ChatSelNavController.h"
#import "ChatSelViewController.h"
#import "PreviewViewController.h"
#import "UIImage+YYIMCategory.h"
#import "WebViewController.h"
#import "YMRefreshView.h"
#import "ChatImageBrowserController.h"
#import "ChatMicroVideoBrowserController.h"
#import "ChatSingleConferenceTableViewCell.h"
#import "ChatSingleConferenceTableLeftCell.h"
#import "ChatMuitiConferenceTableViewCell.h"
#import "YYIMColorHelper.h"
#import "ChatShareConferenceTableLeftCell.h"
#import "ChatShareConferenceTableRightCell.h"
#import "YYIMNetMeetingAudienceViewController.h"
#import "YYIMNetMeetingBroadcasterViewController.h"
#import "NetMeetingDispatch.h"
#import "YYIMMicroVideoRecordView.h"
#import "YMPubAccountMenuCustomView.h"
#import "YMTableMenu.h"

#define YYIMUI_CHAT_TIME_THRESHOLD 60*1000

#define YYIM_MESSAGE_PAGESIZE 20

#define YYIM_PUBACCOUNT_MENU_OVERDUE_THRESHOLD 60 * 5

#define YYIM_PUBACCOUNT_MENU_HEIGHT 40

@interface ChatViewController ()<YYIMChatDelegate, YMMessageToolViewDelegate, YMMessageExtendDelegate, YYIMAssetDelegate, YYIMFileDelegate, YYIMLocationDelegate, YMMemberSelDelegate, YMChatSelDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, AVAudioRecorderDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, YYIMMicroVideoRecordViewDelegate, YMPubAccountMenuCustomViewDelegate, YMTableMenuDelegate> {
    
    double animationDuration;
    CGRect keyboardRect;
    
}

@property (strong, nonatomic) UITableView *chatTableView;

@property (strong, nonatomic) YMMessageToolView *messageToolView;

@property (strong, nonatomic) YYIMEmojiKeyboard *emojiView;

@property (strong, nonatomic) YMMessageExtendView *extendView;

@property (strong, nonatomic) UIView *pubAccountMenuView;
@property (strong, nonatomic) YMPubAccountMenuCustomView *pubAccountMenuCustomView;
@property (strong, nonatomic) YMTableMenu *tableMenu;

@property (strong, nonatomic) YYIMMicroVideoRecordView *microVideoView;

@property (strong, nonatomic) UILabel *groupTitleLabel;

// chat messages
@property (retain, nonatomic) NSMutableArray *messageArray;
// chat with roster
@property (retain, nonatomic) YYRoster *roster;
// chat with user
@property (retain, nonatomic) YYUser *chatUser;
// chat with pub account
@property (retain, nonatomic) YYPubAccount *account;
// chat with pub account
@property (retain, nonatomic) YYPubAccountMenu *accountMenu;
// chat in chatgroup
@property (retain, nonatomic) YYChatGroup *group;
// group ext
@property (retain, nonatomic) YYChatGroupExt *groupExt;
// users dic
@property (retain, nonatomic) NSDictionary *groupUserDic;
// self
@property (retain, nonatomic) YYUser *user;

// 音频会话
@property (retain, nonatomic) AVAudioSession *audioSession;
// 录音器
@property (retain, nonatomic) AVAudioRecorder *audioRecorder;
// 播放器
@property (retain, nonatomic) AVAudioPlayer *audioPlayer;
// 用来监听动态显示声波的timer
@property (retain, nonatomic) NSTimer *timer;
@property float timeSec;

// imagePicker
@property (retain, nonatomic) UIImagePickerController *imagePicker;

// 当前点击对象
@property (retain, nonatomic) ChatTableViewCell *curPlayingCell;
@property (retain, nonatomic) YYMessage *curMessage;

@property (retain, nonatomic) UIDocumentInteractionController *documentController;

// 图片浏览器
@property (retain, nonatomic) ChatImageBrowserController *imageBrowserController;
// 小视频浏览器
@property (retain, nonatomic)ChatMicroVideoBrowserController *videoBrowserController;

@property NSArray *imageMessageArray;
@property NSArray *videoMessageArray;

// 只读模式
@property BOOL isReadOnly;

@property (strong, nonatomic) NSMutableArray *playingVideoArray;

//当前选中的会议模式
@property YYIMNetMeetingMode selectedConferenceMode;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playingVideoArray = [NSMutableArray array];
    
    if (![YM_ADMIN_USER isEqualToString:self.chatId] && ![[[YYIMConfig sharedInstance] getUser] isEqualToString:self.chatId]) {
        NSString *infoIconName = [YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:self.chatType] ? @"icon_groupinfo" : @"icon_userinfo";
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:infoIconName] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)]];
    }
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    // view 初始化
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 键盘监听
    [self observerKeyboard];
    [self observerMenu];
    
    // 加载相关信息数据
    [self loadInfoData];
    // 加载消息数据
    if ([self messageArray].count <= 0) {
        [self loadData];
    } else {
        [self reloadMessage:NO];
    }
    
    
    if (![YYIMUtility isEmptyString:[self.messageToolView getMessageInputText]]) {
        [self.messageToolView.messageInputView becomeFirstResponder];
    }
    
    if (self.isReadOnly) {
        [self messageViewAnimationWithBottomRect:CGRectZero toolViewRect:CGRectZero duration:0.0f state:YMMessageViewStateShowNone];
        [self pubAccountMenuChange];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![YYIMUtility isEmptyString:[self.messageToolView getMessageInputText]]) {
        [self.messageToolView.messageInputView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self shrinkBottomViews];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self closeMicroVideoView];
    [self removeObserverKeyboard];
    [self removeObserverMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    [self.view setBackgroundColor:[UIColor f9GrayColor]];
    [self initToolView];
    [self initEmojiView];
    [self initExtendView];
    [self initTableView];
    [self initAudioSession];
    [self initPubAccountMenuView];
}

- (void)observerKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)observerMenu {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)initToolView {
    self.messageToolView = [[YMMessageToolView alloc]initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - kYMMessageToolViewDefaultHeight, CGRectGetWidth(self.view.frame), kYMMessageToolViewDefaultHeight)];
    self.messageToolView.delegate = self;
    [self.view addSubview:self.messageToolView];
}

- (void)initEmojiView{
    self.emojiView = [YYIMEmojiKeyboardBuilder sharedEmojiKeyboard];
    self.emojiView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), kYYIMEmojiKeyboardDefaultHeight);
    [self.emojiView attachToTextInput:[self.messageToolView messageInputView]];
    [self.view addSubview:self.emojiView];
}

- (void)initExtendView {
    self.extendView = [[YMMessageExtendView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), kYMMessageExtendViewDefaultHeight)];
    self.extendView.delegate = self;
    [self.view addSubview:self.extendView];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"image" icon:@"icon_extimage" name:@"图片"]];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"camera" icon:@"icon_extcamera" name:@"拍照"]];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"file" icon:@"icon_extfile" name:@"文件"]];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"location" icon:@"icon_extlocation" name:@"位置"]];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"tele" icon:@"icon_exttele" name:@"通话"]];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"netmeeting" icon:@"icon_extnetmeeting" name:@"视频聊天"]];
    [array addObject:[YMMessageExtendViewItem itemWithIdentifer:@"microvideo" icon:@"icon_extnetmeeting" name:@"小视频"]];
    
    [self.extendView setExtendItems:array];
}

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f,0.0f,CGRectGetWidth(self.view.frame), [self baseViewHeight] - CGRectGetHeight(self.messageToolView.frame)) style:UITableViewStylePlain];
    [tableView setAllowsSelection:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor f9GrayColor]];
    [self.view addSubview:tableView];
    self.chatTableView = tableView;
    
    // 注册Cell nib
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatTableLeftCell" bundle:nil] forCellReuseIdentifier:@"ChatTableLeftCell"];
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatTableRightCell" bundle:nil] forCellReuseIdentifier:@"ChatTableRightCell"];
    // 注册小视频 Cell nib
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatMicroVideoTableLeftCell" bundle:nil] forCellReuseIdentifier:@"ChatMicroVideoTableLeftCell"];
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatMicroVideoTableRightCell" bundle:nil] forCellReuseIdentifier:@"ChatMicroVideoTableRightCell"];
    // cell for pubaccount
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatSingleMixedTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChatSingleMixedTableViewCell"];
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatBatchMixedTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChatBatchMixedTableViewCell"];
    // cell for prompt
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatPromptTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChatPromptTableViewCell"];
    
    // cell for net-meeting
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatSingleConferenceTableLeftCell" bundle:nil] forCellReuseIdentifier:@"ChatSingleConferenceTableLeftCell"];
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatSingleConferenceTableRightCell" bundle:nil] forCellReuseIdentifier:@"ChatSingleConferenceTableRightCell"];
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatMuitiConferenceTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChatMuitiConferenceTableViewCell"];
    
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatShareConferenceTableLeftCell" bundle:nil] forCellReuseIdentifier:@"ChatShareConferenceTableLeftCell"];
    [self.chatTableView registerNib:[UINib nibWithNibName:@"ChatShareConferenceTableRightCell" bundle:nil] forCellReuseIdentifier:@"ChatShareConferenceTableRightCell"];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkBottomViews)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [self.chatTableView addGestureRecognizer:tapGestureRecognizer];
    
    YMRefreshView *headerView = [[YMRefreshView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.chatTableView.frame), 40)];
    [headerView setHidden:YES];
    [self.chatTableView setTableHeaderView:headerView];
}

- (void)initPubAccountMenuView {
    self.pubAccountMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 40)];
    [self.pubAccountMenuView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.pubAccountMenuView];
}

- (void)initAudioSession {
    // 初始化音频会话
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
}

- (void)dealloc {
    self.messageToolView = nil;
    self.emojiView = nil;
    self.extendView = nil;
}

- (void)removeObserverKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeObserverMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)backAction {
    if (self.backToMain) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)infoAction:(id)sender {
    if ([YM_MESSAGE_TYPE_CHAT isEqualToString:self.chatType]) {
        ChatInfoViewController *chatInfoViewController = [[ChatInfoViewController alloc] initWithNibName:@"ChatInfoViewController" bundle:nil];
        chatInfoViewController.userId = self.chatId;
        [self.navigationController pushViewController:chatInfoViewController animated:YES];
    } else if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:self.chatType]) {
        GroupInfoViewController *groupInfoViewController = [[GroupInfoViewController alloc] initWithNibName:@"GroupInfoViewController" bundle:nil];
        groupInfoViewController.groupId = self.chatId;
        [self.navigationController pushViewController:groupInfoViewController animated:YES];
    } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:self.chatType]) {
        AccountInfoViewController *accountInfoViewController = [[AccountInfoViewController alloc] initWithNibName:@"AccountInfoViewController" bundle:nil];
        accountInfoViewController.accountId = self.chatId;
        [self.navigationController pushViewController:accountInfoViewController animated:YES];
    }
}

#pragma mark -
#pragma mark keyboard

- (void)keyboardWillHide:(NSNotification *)notification{
    keyboardRect = CGRectZero;
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self messageViewAnimationWithBottomRect:keyboardRect toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)keyboardChange:(NSNotification *)notification{
    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self messageViewAnimationWithBottomRect:keyboardRect toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
}

#pragma mark -
#pragma mark messageView animation

- (void)messageViewAnimationWithBottomRect:(CGRect)rect toolViewRect:(CGRect)toolViewRect duration:(double)duration state:(YMMessageViewState)state {
    [UIView animateWithDuration:duration animations:^{
        self.messageToolView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect) - CGRectGetHeight(toolViewRect), CGRectGetWidth(self.view.frame), CGRectGetHeight(toolViewRect));
        
        switch (state) {
            case YMMessageViewStateShowNone:
                self.emojiView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.emojiView.frame));
                self.extendView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.extendView.frame));
                break;
            case YMMessageViewStateShowEmoji:
                self.emojiView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect),CGRectGetWidth(self.view.frame), CGRectGetHeight(rect));
                self.extendView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.extendView.frame));
                break;
            case YMMessageViewStateShowExtend:
                self.extendView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect),CGRectGetWidth(self.view.frame), CGRectGetHeight(rect));
                self.emojiView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.emojiView.frame));
                break;
            default:
                break;
        }
        self.chatTableView.frame = CGRectMake(0.0f, 0.0f , CGRectGetWidth(self.view.frame), [self baseViewHeight] - CGRectGetHeight(self.messageToolView.frame) - CGRectGetHeight(rect));
        [self scrollTableViewBottom:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)scrollTableViewBottom:(BOOL)animated {
    NSUInteger rowCount = [self tableView:self.chatTableView numberOfRowsInSection:0];
    if (rowCount > 0) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark -
#pragma mark YMPubAccountMenuCustomViewDelegate

- (void)didPubAccountMenuCustomViewClick:(YMPubAccountMenuCustomView *)pubAccountMenuCustomView index:(NSInteger)index {
    YYPubAccountMenuItem *item = [self.accountMenu.menuItemArray objectAtIndex:index];
    
    if (item) {
        if (item.itemArray && item.itemArray.count > 0) {
            
            NSMutableArray *nameArray =[NSMutableArray arrayWithCapacity:item.itemArray.count];
            
            for (YYPubAccountMenuItem *obj in item.itemArray) {
                [nameArray addObject:obj.itemName];
            }
            
            if (index == [self.pubAccountMenuCustomView getLastIndex] && self.tableMenu.hidden == NO) {
                self.tableMenu.hidden = YES;
                return;
            }
            
            //调用tableMenu
            [self showPubAccountTableMenuAtIndex:index];
        } else {
            switch (item.itemType) {
                case kYYPubAccountMenuItemTypeCommand: {
                    [[YYIMChat sharedInstance].chatManager sendPubAccountMenuCommand:self.chatId item:item];
                    break;
                }
                case kYYPubAccountMenuItemTypeURL: {
                    WebViewController *webViewController = [[WebViewController alloc] init];
                    [webViewController setUrlString:item.itemUrl];
                    [self.navigationController pushViewController:webViewController animated:YES];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

#pragma mark -
#pragma mark YMTableMenuDelegate
- (void)didClickMTableMenu:(YMTableMenu*)menu atIndex:(NSInteger)index {
    NSInteger menuIndex = [self.pubAccountMenuCustomView getCurrentIndex];
    
    if (self.accountMenu && self.accountMenu.menuItemArray && self.accountMenu.menuItemArray.count > menuIndex) {
        YYPubAccountMenuItem *menu = [self.accountMenu.menuItemArray objectAtIndex:menuIndex];
        
        if (menu && menu.itemArray.count > index) {
            YYPubAccountMenuItem *item = [menu.itemArray objectAtIndex:index];
            
            switch (item.itemType) {
                case kYYPubAccountMenuItemTypeCommand: {
                    [[YYIMChat sharedInstance].chatManager sendPubAccountMenuCommand:self.chatId item:item];
                    break;
                }
                case kYYPubAccountMenuItemTypeURL: {
                    WebViewController *webViewController = [[WebViewController alloc] init];
                    [webViewController setUrlString:item.itemUrl];
                    [self.navigationController pushViewController:webViewController animated:YES];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

#pragma mark -
#pragma mark YMMessageToolViewDelegate

- (void)didSwitchToAudioState:(BOOL)isAudioState {
    if (isAudioState){
        [self messageViewAnimationWithBottomRect:CGRectZero toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
    } else {
        [self messageViewAnimationWithBottomRect:keyboardRect toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
    }
}

- (void)didSwitchToEmojiState:(BOOL)isEmojiState {
    if (isEmojiState) {
        [self messageViewAnimationWithBottomRect:self.emojiView.frame toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowEmoji];
    } else {
        [self messageViewAnimationWithBottomRect:keyboardRect toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
    }
}

- (void)didSwitchToExtendState:(BOOL)isExtedState {
    if (isExtedState) {
        [self messageViewAnimationWithBottomRect:self.extendView.frame toolViewRect:self.messageToolView.frame duration:animationDuration
                                           state:YMMessageViewStateShowExtend];
    } else {
        [self messageViewAnimationWithBottomRect:keyboardRect toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
    }
}

- (void)didToolViewHeightChange:(BOOL)isEmojiState {
    if (isEmojiState) {
        [self messageViewAnimationWithBottomRect:self.emojiView.frame toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowEmoji];
    } else {
        [self messageViewAnimationWithBottomRect:keyboardRect toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
    }
}

- (void)didInputAt {
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        MemberSelViewController *memberSelViewController = [[MemberSelViewController alloc] initWithNibName:@"MemberSelViewController" bundle:nil];
        memberSelViewController.groupId = self.chatId;
        memberSelViewController.delegate = self;
        memberSelViewController.identifiy = @"at";
        UINavigationController *memberSelNavController = [YYIMUtility themeNavController:memberSelViewController];
        
        [self presentViewController:memberSelNavController animated:YES completion:nil];
    }
}

- (void)didShrink {
    [self messageViewAnimationWithBottomRect:CGRectZero toolViewRect:self.messageToolView.frame duration:animationDuration state:YMMessageViewStateShowNone];
}

// 开始录音
- (void)didStartRecording {
    // audioSession active
    [self.audioSession setActive:YES error:nil];
    // show hud for voice
    [self showHudVoice:self.view volume:1];
    // create audioRecorder
    self.audioRecorder = [YYIMResourceUtility createAudioRecorder];
    // 开始录音
    if (self.audioRecorder) {
        [self.audioRecorder setDelegate:self];
        [self.audioRecorder setMeteringEnabled:YES];
        [self.audioRecorder prepareToRecord];
        [self.audioRecorder record];
    }
    // 计时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(updateMeters:) userInfo:nil repeats:YES];
    self.timeSec = 0.0f;
}

// 停止录音
- (void)didEndRecording {
    if ([self.audioRecorder isRecording]) {
        // 停止录音
        [self.audioRecorder stop];
        // audioUrl
        NSURL *audioUrl = [self.audioRecorder url];
        // audioPlayer
        self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:nil];
        NSLog(@"duration:%f",self.audioPlayer.duration);
        if (self.audioPlayer.duration >= 1) {
            [[YYIMChat sharedInstance].chatManager sendAudioMessage:self.chatId wavPath:[audioUrl absoluteString] chatType:self.chatType];
        } else {
            [self showHint:@"时间过短"];
        }
    }
    // 停止定时器timer
    if (self.timer && self.timer.isValid){
        [self.timer invalidate];
        self.timeSec = 0.0f;
    }
    // hide hud
    [self hideHud];
}

// 取消录音
- (void)didCancelRecording {
    // 停止定时器timer
    if (self.timer && self.timer.isValid){
        [self.timer invalidate];
        self.timeSec = 0.0f;
    }
    // hide hud
    [self hideHud];
}

- (void)willCancelRecording {
    if ([self.audioRecorder isRecording]) {
        [self hudTextRefresh:@"松开手指 取消发送"];
    }
}

- (void)didResumeRecording {
    if ([self.audioRecorder isRecording]) {
        [self hudTextRefresh:@"手指上滑 取消发送"];
    }
}

- (void)updateMeters:(id)sender {
    if (self.audioRecorder.isRecording){
        self.timeSec += 0.2f;
        
        if (self.timeSec > 50.0f && self.timeSec < 60.0f) {
            [self hudVoiceCountDown:ceilf(60.0f - self.timeSec)];
        } else if (self.timeSec >= 60.0f) {
            [self didEndRecording];
        } else {
            // 刷新音量数据
            [self.audioRecorder updateMeters];
            
            float avgPower = [self.audioRecorder averagePowerForChannel:0];
            [self hudVoiceRefresh:avgPower];
        }
    }
}

- (BOOL)messageInputDidEndEditing:(UITextView *)messageInputView {
    return [self sendTextMessage:messageInputView];
}

#pragma mark -
#pragma mark YYIMMicroVideoRecordViewDelegate

- (void)didMicroVideoRecordViewNeedClose {
    [self closeMicroVideoView];
}

- (void)didMicroVideoRecordViewNeedShowMessage:(NSString *)message {
    [self showHint:message];
}

- (void)didMicroVideoRecordViewWillSaveFile {
    [self showThemeHudInView:self.view];
}

- (void)didMicroVideoRecordViewSaveFileFailed {
    [self hideHud];
    
    [self showHint:@"小视频保存失败"];
}

- (void)didMicroVideoRecordViewfinishSaveFile:(NSString *)filePath thumbPath:(NSString *)thumbPath {
    [self hideHud];
    [self closeMicroVideoView];
    //发送消息
    
    [[YYIMChat sharedInstance].chatManager sendMicroVideoMessage:self.chatId filePath:filePath thumbPath:thumbPath chatType:self.chatType];
}

#pragma mark -
#pragma mark YMMessageExtendDelegate

- (void)didSelectExtendItem:(YMMessageExtendViewItem *)item atIndex:(NSInteger)index {
    if ([@"image" isEqualToString:[item identifer]]) {
        [self imageExtAction];
    } else if ([@"camera" isEqualToString:[item identifer]]) {
        [self cameraExtAction];
    } else if ([@"file" isEqualToString:[item identifer]]) {
        [self fileExtAction];
    } else if ([@"location" isEqualToString:[item identifer]]) {
        [self locationExtAction];
    } else if ([@"tele" isEqualToString:[item identifer]]) {
        [self teleExtAction];
    } else if ([@"netmeeting" isEqualToString:[item identifer]]) {
        [self netMeetingExtAction];
    } else if ([@"microvideo" isEqualToString:[item identifer]]) {
        [self recordMicroVideoAction];
    }
}

- (void)closeMicroVideoView {
    if (self.microVideoView) {
        //开始动画
        [self.microVideoView prepareToHide];
        
        [UIView animateWithDuration:1.0f animations:^{
            self.microVideoView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
        
        [self.microVideoView removeFromSuperview];
        self.microVideoView = nil;
    }
}

- (void)recordMicroVideoAction {
    [self shrinkBottomViews];
    
    //这个时候的交互是类似于微信，弹出一个view
    self.microVideoView = [YYIMMicroVideoRecordView initMicroVideoRecordView];
    self.microVideoView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self.microVideoView setBackgroundColor:[UIColor clearColor]];
    [self.microVideoView setDelegate:self];
    [self.view addSubview:self.microVideoView];
    
    //开始动画
    [UIView animateWithDuration:1.0f animations:^{
        self.microVideoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.microVideoView prepareToShow];
    }];
}

- (void)netMeetingExtAction {
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"视频聊天", @"语音聊天", nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [actionSheet showInView:self.view];
    } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        MemberSelViewController *memberSelViewController = [[MemberSelViewController alloc] initWithNibName:@"MemberSelViewController" bundle:nil];
        memberSelViewController.groupId = self.chatId;
        memberSelViewController.delegate = self;
        memberSelViewController.identifiy = @"netmeeting";
        UINavigationController *memberSelNavController = [YYIMUtility themeNavController:memberSelViewController];
        [self presentViewController:memberSelNavController animated:YES completion:nil];
    }
}

- (void)imageExtAction {
    AssetsGroupViewController *assetsGroupViewController = [[AssetsGroupViewController alloc] initWithNibName:@"AssetsGroupViewController" bundle:nil];
    [assetsGroupViewController setDelegate:self];
    
    UINavigationController *assetsGroupNavController = [YYIMUtility themeNavController:assetsGroupViewController];
    [self presentViewController:assetsGroupNavController animated:YES completion:nil];
}

- (void)cameraExtAction {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSInteger sourceType = UIImagePickerControllerSourceTypeCamera;
        [self openImagePicker:sourceType];
    }
}

- (void)fileExtAction {
    FileViewController *fileViewController = [[FileViewController alloc] initWithNibName:@"FileViewController" bundle:nil];
    fileViewController.delegate = self;
    
    UINavigationController *fileNavController = [YYIMUtility themeNavController:fileViewController];
    [self presentViewController:fileNavController animated:YES completion:nil];
}

- (void)locationExtAction {
    LocationViewController *locationViewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
    locationViewController.delegate = self;
    
    UINavigationController *locationNavController = [YYIMUtility themeNavController:locationViewController];
    [self presentViewController:locationNavController animated:YES completion:nil];
}

- (void)teleExtAction {
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        [[YYIMChat sharedInstance].chatManager createTeleConferenceWithCaller:[[YYIMConfig sharedInstance] getUser] participants:[NSArray arrayWithObject:self.chatId]];
    } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        MemberSelViewController *memberSelViewController = [[MemberSelViewController alloc] initWithNibName:@"MemberSelViewController" bundle:nil];
        memberSelViewController.groupId = self.chatId;
        memberSelViewController.delegate = self;
        memberSelViewController.identifiy = @"tele";
        UINavigationController *memberSelNavController = [YYIMUtility themeNavController:memberSelViewController];
        [self presentViewController:memberSelNavController animated:YES completion:nil];
    }
}

- (void)openImagePicker:(NSInteger)sourceType {
    // 跳转相册或相机页面
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        [self.imagePicker setDelegate:self];
        [self.imagePicker setSourceType:sourceType];
        [self.imagePicker setAllowsEditing:NO];
    }
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.selectedConferenceMode = kYYIMNetMeetingModeDefault;
    
    switch (buttonIndex) {
        case 0: {
            self.selectedConferenceMode = kYYIMNetMeetingModeVideo;
        }
            break;
        case 1: {
            self.selectedConferenceMode = kYYIMNetMeetingModeAudio;
        }
            break;
        default:
            return;
    }
    
    //单聊直接进入视屏通信房间，群聊的话需要选择成员
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        NSArray *invitees = [[NSArray alloc] initWithObjects:self.chatId, nil];
        
        if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
            [self showHint:@"当前有会议在进行，操作被禁止"];
        } else {
            [[NetMeetingDispatch sharedInstance] createNetMeetingWithNetMeetingType:kYYIMNetMeetingTypeSingleChat netMeetingMode:self.selectedConferenceMode invitees:invitees topic:@""];
        }
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 得到图片
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // AssetsLibrary
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Request to save the image to camera roll
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
    // save image
    NSString *path = [YYIMResourceUtility saveImage:image];
    [[YYIMChat sharedInstance].chatManager sendImageMessage:self.chatId paths:[NSArray arrayWithObject:path] chatType:self.chatType];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark YYIMAssetDelegate, YYIMFileDelegate, YYIMLocationDelegate, YMMemberSelDelegate

- (void)didSelectAssets:(NSArray *)assets isOriginal:(BOOL)isOriginal {
    if (assets && [assets count] > 0) {
        [[YYIMChat sharedInstance].chatManager sendImageMessage:self.chatId assets:assets chatType:self.chatType isOriginal:isOriginal];
    }
}

- (void)forwardFile:(NSString *)messagePid {
    NSLog(@"%@", @"forwardFile");
    [[YYIMChat sharedInstance].chatManager forwardFileMessage:self.chatId pid:messagePid chatType:self.chatType];
}

- (void)doSendLocation:(NSString *)imagePath address:(NSString *) address longitude:(CGFloat) longitude latitude:(CGFloat) latitude {
    [[YYIMChat sharedInstance].chatManager sendLocationManager:self.chatId imagePath:imagePath address:address longitude:longitude latitude:latitude chatType:self.chatType];
}

- (BOOL)allowMultipleMemberSelect:(MemberSelViewController *)controller {
    if ([[controller identifiy] isEqualToString:@"at"]) {
        return NO;
    }
    return YES;
}

- (void)memberSelController:(MemberSelViewController *)controller identifiy:(NSString *)identifiy didSelMember:(YYChatGroupMember *)member {
    if ([identifiy isEqualToString:@"at"]) {
        [self.messageToolView inputAtText:[NSString stringWithFormat:@"%@ ", [member memberName]] withUserId:[member memberId]];
    }
}

- (void)memberSelController:(MemberSelViewController *)controller identifiy:(NSString *)identifiy didSelMembers:(NSArray *)memberArray {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([identifiy isEqualToString:@"tele"]) {
            NSMutableArray *userIdArray = [NSMutableArray arrayWithCapacity:[memberArray count]];
            
            for (YYChatGroupMember *member in memberArray) {
                [userIdArray addObject:[member memberId]];
            }
            
            [[YYIMChat sharedInstance].chatManager createTeleConferenceWithCaller:[[YYIMConfig sharedInstance] getUser] participants:userIdArray];
        } else if ([identifiy isEqualToString:@"netmeeting"]) {
            NSMutableArray *invitees = [NSMutableArray array];
            
            for (YYNetMeetingMember *member in memberArray) {
                if (![member.memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                    [invitees addObject:member.memberId];
                }
            }
            
            //调用创建频道的接口
            NSString *topic = [NSString stringWithFormat:@"%@群", self.group.groupName];
            
            if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                [self showHint:@"当前有会议在进行，操作被禁止"];
            } else {
                [[NetMeetingDispatch sharedInstance] createNetMeetingWithNetMeetingType:kYYIMNetMeetingTypeGroupChat netMeetingMode:kYYIMNetMeetingModeVideo invitees:invitees topic:topic];
            }
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYMessage *message = [self.messageArray objectAtIndex:indexPath.row];
    
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_SINGLE_MIXED: {
            ChatSingleMixedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatSingleMixedTableViewCell"];
            [cell setActiveMessage:message];
            return cell;
        }
        case YM_MESSAGE_CONTENT_BATCH_MIXED: {
            ChatBatchMixedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatBatchMixedTableViewCell"];
            [cell setActiveMessage:message];
            return cell;
        }
        case YM_MESSAGE_CONTENT_PROMPT:
        case YM_MESSAGE_CONTENT_REVOKE: {
            ChatPromptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatPromptTableViewCell"];
            [message setUser:self.chatUser];
            [cell setActiveMessage:message];
            
            BOOL isTimeShow = [self isTimeShow:indexPath.row];
            if (isTimeShow) {
                [cell setTimeText:[YYIMUtility genTimeString:[message date]]];
            }
            return cell;
        }
        case YM_MESSAGE_CONTENT_MICROVIDEO: {
            ChatMicroVideoTableViewCell *cell;
            NSString *identifier;
            
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                identifier = @"ChatMicroVideoTableLeftCell";
            } else {
                identifier = @"ChatMicroVideoTableRightCell";
            }
            
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
                    if (self.roster) {
                        [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.roster rosterAlias]];
                    } else {
                        [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.chatUser userName]];
                    }
                } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
                    
                    YYUser *user = [self.groupUserDic objectForKey:message.rosterId];
                    [cell setHeadImageWithUrl:[user getUserPhoto] placeholderName:[user userName]];
                    if ([self.groupExt showName] && [self isHeaderShow:indexPath.row]) {
                        [cell setName:[user userName]];
                    }
                }
            }
            
            if ([self.playingVideoArray containsObject:message.pid]) {
                [cell setActiveMessage:message isTimeShow:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row] isHeaderShow:[self isHeaderShow:indexPath.row] isPlaying:YES];
                [cell playMicroVideo];
            } else {
                [cell setActiveMessage:message isTimeShow:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row] isHeaderShow:[self isHeaderShow:indexPath.row] isPlaying:NO];
            }
            
            return cell;
        }
        case YM_MESSAGE_CONTENT_NETMEETING: {
            YYNetMeetingContent *conference = [message getMessageContent].netMeetingContent;
            
            switch (conference.messageType) {
                case kYYIMNetMeetingMessageTypeSingelChatNotify: {
                    ChatSingleConferenceTableViewCell *cell;
                    NSString *identifier;
                    
                    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                        identifier = @"ChatSingleConferenceTableLeftCell";
                    } else {
                        identifier = @"ChatSingleConferenceTableRightCell";
                    }
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    
                    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                        if (self.roster) {
                            [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.roster rosterAlias]];
                        } else {
                            [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.chatUser userName]];
                        }
                    }
                    
                    [cell setActiveMessage:message isTimeShow:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row] isHeaderShow:[self isHeaderShow:indexPath.row]];
                    
                    return cell;
                    
                }
                case kYYIMNetMeetingMessageTypeConferenceShare: {
                    ChatShareConferenceTableViewCell *cell;
                    NSString *identifier;
                    
                    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                        identifier = @"ChatShareConferenceTableLeftCell";
                    } else {
                        identifier = @"ChatShareConferenceTableRightCell";
                    }
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    
                    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                        if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
                            if (self.roster) {
                                [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.roster rosterAlias]];
                            } else {
                                [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.chatUser userName]];
                            }
                        } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
                            
                            YYUser *user = [self.groupUserDic objectForKey:message.rosterId];
                            [cell setHeadImageWithUrl:[user getUserPhoto] placeholderName:[user userName]];
                            if ([self.groupExt showName] && [self isHeaderShow:indexPath.row]) {
                                [cell setName:[user userName]];
                            }
                        }
                    }
                    
                    [cell setActiveMessage:message isTimeShow:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row] isHeaderShow:[self isHeaderShow:indexPath.row]];
                    
                    return cell;
                }
                default:
                    break;
            }
        }
        default: {
            ChatTableViewCell *cell;
            NSString *identifier;
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                identifier = @"ChatTableLeftCell";
            } else {
                identifier = @"ChatTableRightCell";
            }
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            BOOL isTimeShow = [self isTimeShow:indexPath.row];
            if (isTimeShow) {
                [cell setTimeText:[YYIMUtility genTimeString:[message date]]];
            }
            BOOL isBottomShow = [self isBottomShow:indexPath.row];
            [cell setBottomShow:isBottomShow];
            
            BOOL isHeaderSow = [self isHeaderShow:indexPath.row];
            [cell setHeaderShow:isHeaderSow];
            
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
                    if ([YM_ADMIN_USER isEqualToString:self.chatId]) {
                        [cell.headImage setImage:[UIImage imageNamed:@"icon_system"]];
                    } else if (self.roster) {
                        [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.roster rosterAlias]];
                    } else {
                        [cell setHeadImageWithUrl:[self.chatUser getUserPhoto] placeholderName:[self.chatUser userName]];
                    }
                } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT]) {
                    [cell.headImage setImage:[UIImage imageWithDispName:[self.account accountName] coreIcon:@"icon_pubaccount_core"]];
                } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
                    if ([YM_ADMIN_USER isEqualToString:[message rosterId]]) {
                        [cell setHeadImageName:@"icon_system"];
                        if ([self.groupExt showName] && isHeaderSow) {
                            [cell setName:@"系统消息"];
                        }
                    } else {
                        YYUser *user = [self.groupUserDic objectForKey:message.rosterId];
                        [cell setHeadImageWithUrl:[user getUserPhoto] placeholderName:[user userName]];
                        if ([self.groupExt showName] && isHeaderSow) {
                            [cell setName:[user userName]];
                        }
                    }
                }
            }
            
            [cell setActiveMessage:message];
            
            [message updateReadState];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYMessage *message = [self.messageArray objectAtIndex:indexPath.row];
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_SINGLE_MIXED:
            return [ChatSingleMixedTableViewCell heightForCellWithData:message];
        case YM_MESSAGE_CONTENT_BATCH_MIXED:
            return [ChatBatchMixedTableViewCell heightForCellWithData:message];
        case YM_MESSAGE_CONTENT_PROMPT:
        case YM_MESSAGE_CONTENT_REVOKE:
            [message setUser:self.chatUser];
            return [ChatPromptTableViewCell heightForCellWithData:message isTimeShow:[self isTimeShow:indexPath.row]];
        case YM_MESSAGE_CONTENT_MICROVIDEO: {
            return [ChatMicroVideoTableViewCell heightForCellWithData:message isTimeShow:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row]];
        }
        case YM_MESSAGE_CONTENT_NETMEETING: {
            YYNetMeetingContent *conference = [message getMessageContent].netMeetingContent;
            
            switch (conference.messageType) {
                case kYYIMNetMeetingMessageTypeSingelChatNotify: {
                    return [ChatSingleConferenceTableViewCell heightForCell:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row]];
                }
                case kYYIMNetMeetingMessageTypeConferenceShare: {
                    CGFloat height = [ChatShareConferenceTableViewCell heightForCell:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row]];
                    
                    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
                        if ([self.groupExt showName] && [self isHeaderShow:indexPath.row]) {
                            height += 16;
                        }
                    }
                    
                    return height;
                }
                default:
                    break;
            }
        }
        default: {
            CGFloat height = [ChatTableViewCell heightForCellWithData:message isTimeShow:[self isTimeShow:indexPath.row] isBottomShow:[self isBottomShow:indexPath.row]];
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
                if ([self.groupExt showName] && [self isHeaderShow:indexPath.row]) {
                    height += 16;
                }
            }
            return height;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self shrinkBottomViews];
}

- (void)shrinkBottomViews {
    [self.messageToolView shrinkBottomViews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果tableView还没有数据，就直接返回
    if (self.messageArray.count < YYIM_MESSAGE_PAGESIZE || ![self.chatTableView.tableHeaderView isHidden]) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) { // 最后一个cell完全进入视野范围内
        // 显示header
        self.chatTableView.tableHeaderView.hidden = NO;
        
        // 加载更多数据
        [self performSelector:@selector(loadMoreMessage) withObject:nil afterDelay:0.0f];
    }
}

#pragma mark -
#pragma mark YYIMChatDelegate

- (void)didReceiveMessage:(YYMessage *)message {
    NSLog(@"didReceiveMessage:%@", [message pid]);
    if ([[message fromId] isEqualToString:self.chatId]) {
        BOOL isScrollBottom = NO;
        NSArray *visibleCells = [self.chatTableView visibleCells];
        if ([visibleCells count] > 0) {
            NSIndexPath *indexPath = [self.chatTableView indexPathForCell:[visibleCells lastObject]];
            if (indexPath.row >= ([self.messageArray count] - 2)) {
                isScrollBottom = YES;
            }
        }
        [self reloadMessage:isScrollBottom];
    }
}

- (void)didReceiveOfflineMessages {
    [self reloadMessage:NO];
}

- (void)didSendMessage:(YYMessage *)message {
    NSLog(@"didSendMessage:%@", [message pid]);
    if ([[message toId] isEqualToString:self.chatId]) {
        [self reloadMessage:YES];
    }
}

- (void)didSendMessageFaild:(YYMessage *)message error:(YYIMError *)error {
    NSLog(@"didSendMessageFaild:%@", [message pid]);
    if ([[message toId] isEqualToString:self.chatId]) {
        [self reloadMessage:NO];
    }
}

- (void)willSendMessage:(YYMessage *)message {
    NSLog(@"willSendMessage:%@", [message pid]);
    if ([[message toId] isEqualToString:self.chatId]) {
        [self doUpdateMessage:message];
    }
}

- (void)didMessageStateChange:(YYMessage *)message {
    NSLog(@"didMessageStateChange:%@", [message pid]);
    
    NSLog(@"didMessageStateChange:%@|%ld", [message pid], (long)[message status]);
    if ([[message toId] isEqualToString:self.chatId] || [[message fromId] isEqualToString:self.chatId]) {
        [self reloadMessage:NO];
    }
}

- (void)didMessageResStatusChanged:(YYMessage *)message error:(YYIMError *)error {
    NSLog(@"didMessageResStatusChanged:%@", [message pid]);
    if ([[message toId] isEqualToString:self.chatId] || [[message fromId] isEqualToString:self.chatId]) {
        [self reloadMessage:NO];
    }
}

- (void)didRevokeMessageWithPid:(NSString *)pid {
    [self hideHud];
}

- (void)didNotRevokeMessageWithPid:(NSString *)pid error:(YYIMError *)error {
    [self hideHud];
    if ([error errorCode] == YMERROR_CODE_MESSAGE_REVOKE_TIMEOUT) {
        [self showHint:@"超过两分钟的消息不能撤回"];
    } else {
        [self showHint:@"消息撤回失败"];
    }
}

- (void)didMessageRevoked:(YYMessage *)message {
    NSLog(@"didMessageRevoked:%@", [message pid]);
    if ([[message toId] isEqualToString:self.chatId] || [[message fromId] isEqualToString:self.chatId]) {
        [self reloadMessage:NO];
    }
}

- (void)doUpdateMessage:(YYMessage *)message {
    BOOL flag = NO;
    for (long i = self.messageArray.count - 1; i >= 0; i--) {
        YYMessage *currMsg = [self.messageArray objectAtIndex:i];
        if ([message.pid isEqualToString:currMsg.pid]) {
            [message clearContentHeight];
            flag = YES;
            [self.messageArray replaceObjectAtIndex:i withObject:message];
            [self.chatTableView reloadData];
            break;
        }
    }
    if (!flag) {
        [self.messageArray addObject:message];
        [self.chatTableView reloadData];
        [self scrollTableViewBottom:YES];
    }
}

- (void)didConferenceStartWithSessionId:(NSString *)sessionId {
    [self showHint:@"电话会议即将开始，请接听回拨"];
}

- (void)didNotConferenceStartWithError:(YYIMError *)error {
    switch ([error errorCode]) {
        case YMERROR_CODE_UNEXPECT_STATE:
            [self showHint:[error errorMsg]];
            break;
        case YMERROR_CODE_USER_NOT_FOUND:
            [self showHint:[error errorMsg]];
            break;
        case YMERROR_CODE_USER_MOBILE_NOT_FOUND:
            [self showHint:[error errorMsg]];
            break;
        default:
            if (![error srcError]) {
                if ([YYIMUtility isEmptyString:[error errorMsg]]) {
                    [self showHint:@"发起会议失败"];
                } else {
                    [self showHint:[error errorMsg]];
                }
            } else {
                if ([[[error srcError] domain] isEqualToString:@"NSURLErrorDomain"]) {
                    [self showHint:@"发起会议失败，请检查网络状态后重试"];
                } else {
                    [self showHint:@"发起会议失败"];
                }
            }
            break;
    }
}

- (void)didUserInfoUpdate:(YYUser *)user {
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        if ([[user userId] isEqualToString:self.chatId]) {
            self.chatUser = user;
            if (!self.roster) {
                [self.navigationItem setTitle:[self.chatUser userName]];
            }
        }
    }
}

- (void)didUserInfoUpdate {
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        [self loadGroupChatUser];
    }
}

- (void)didChatGroupInfoUpdate:(YYChatGroup *)group {
    if ([[group groupId] isEqualToString:self.chatId] && [self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        [self loadGroupData];
    }
}

- (void)didChatGroupMemberUpdate:(NSString *)groupId {
    if ([groupId isEqualToString:self.chatId] && [self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        [self loadGroupData];
    }
}

- (void)didPubAccountMenuChange:(NSString *)accountId {
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT] && [self.chatId isEqualToString:accountId]) {
        self.accountMenu = [[YYIMChat sharedInstance].chatManager getPubAccountMenu:self.chatId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pubAccountMenuChange];
        });
    }
}

#pragma mark -
#pragma mark private func

- (void)loadInfoData {
    // 单聊
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        [self loadChatData];
    } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT]) {// 公共号
        [self loadAccountData];
    } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {// 群聊
        [self loadGroupData];
    }
    // selfUser
    self.user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
}

- (void)loadData {
    // messages
    if (self.pid) {
        NSArray *messages = [[YYIMChat sharedInstance].chatManager getMessageWithId:self.chatId afterPid:self.pid];
        [[YYIMChat sharedInstance].chatManager updateMessageReadedWithId:self.chatId];
        
        self.messageArray = [NSMutableArray arrayWithArray:messages];
        [self.chatTableView reloadData];
        
        [self.chatTableView setContentOffset:CGPointMake(0.0f, 44.0f)];
        
        [self resetImageMessageArray];
        [self resetVideoMessageArray];
    } else {
        [self loadMessage:YES];
    }
}

- (void)loadMessage:(BOOL)scrollBottom {
    NSArray *messages = [[YYIMChat sharedInstance].chatManager getMessageWithId:self.chatId beforePid:nil pageSize:YYIM_MESSAGE_PAGESIZE];
    [[YYIMChat sharedInstance].chatManager updateMessageReadedWithId:self.chatId];
    if (messages.count < YYIM_MESSAGE_PAGESIZE) {
        [self.chatTableView setTableHeaderView:nil];
    }
    self.messageArray = [NSMutableArray arrayWithArray:messages];
    [self.chatTableView reloadData];
    if (scrollBottom) {
        [self scrollTableViewBottom:NO];
    }
    
    [self resetImageMessageArray];
    [self resetVideoMessageArray];
}

- (void)resetImageMessageArray {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"type == %ld", YM_MESSAGE_CONTENT_IMAGE];
    NSArray *array = [self.messageArray filteredArrayUsingPredicate:pre];
    self.imageMessageArray = array;
}

- (void)resetVideoMessageArray {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"type == %ld", YM_MESSAGE_CONTENT_MICROVIDEO];
    NSArray *array = [self.messageArray filteredArrayUsingPredicate:pre];
    self.videoMessageArray = array;
}

- (void)loadMoreMessage {
    NSLog(@"loadMoreMessage");
    if (!self.chatTableView.tableHeaderView) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessage *message = [self.messageArray objectAtIndex:0];
        NSArray *messages = [[YYIMChat sharedInstance].chatManager getMessageWithId:self.chatId beforePid:[message pid] pageSize:YYIM_MESSAGE_PAGESIZE];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.messageArray];
        NSInteger messageCount = [messages count];
        if (messageCount > 0) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messageCount)];
            [array insertObjects:messages atIndexes:indexSet];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (messageCount < YYIM_MESSAGE_PAGESIZE) {
                [self.chatTableView setTableHeaderView:nil];
            }
            
            self.messageArray = array;
            CGFloat offsetOfButtom = self.chatTableView.contentSize.height - self.chatTableView.contentOffset.y;
            [self.chatTableView reloadData];
            self.chatTableView.contentOffset = CGPointMake(0.0f, self.chatTableView.contentSize.height - offsetOfButtom);
            
            // 结束刷新(隐藏header)
            [self.chatTableView.tableHeaderView setHidden:YES];
            
            [self resetImageMessageArray];
            [self resetVideoMessageArray];
        });
    });
}

- (void)reloadMessage:(BOOL)scrollBottom {
    if ([self.messageArray count] < YYIM_MESSAGE_PAGESIZE) {
        [self loadMessage:scrollBottom];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessage *message = [self.messageArray objectAtIndex:0];
        NSArray *messages = [[YYIMChat sharedInstance].chatManager getMessageWithId:self.chatId afterPid:[message pid]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.messageArray = [NSMutableArray arrayWithArray:messages];
            [self.chatTableView reloadData];
            if (scrollBottom) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollTableViewBottom:NO];
                });
            }
            [self resetImageMessageArray];
            [self resetVideoMessageArray];
        });
    });
    
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        [self loadGroupChatUser];
    }
}

- (void)loadChatData {
    if ([YM_ADMIN_USER isEqualToString:self.chatId]) {
        [self.navigationItem setTitle:@"系统消息"];
        self.isReadOnly = YES;
    } else {
        self.roster = [[YYIMChat sharedInstance].chatManager getRosterWithId:self.chatId];
        self.chatUser = [[YYIMChat sharedInstance].chatManager getUserWithId:self.chatId];
        if ([[[YYIMConfig sharedInstance] getUser] isEqualToString:self.chatId]) {
            [self.navigationItem setTitle:@"我的电脑"];
        } else if (self.roster) {
            [self.navigationItem setTitle:[self.roster rosterAlias]];
        } else {
            [self.navigationItem setTitle:[self.chatUser userName]];
        }
    }
}

- (void)loadAccountData {
    self.account = [[YYIMChat sharedInstance].chatManager getPubAccountWithAccountId:self.chatId];
    [self.navigationItem setTitle:[self.account accountName]];
    self.isReadOnly = YES;
    
    self.accountMenu = [[YYIMChat sharedInstance].chatManager getPubAccountMenu:self.chatId];
    
    if ([self isPubAccountMenuNeedRequest:self.accountMenu]) {
        [[YYIMChat sharedInstance].chatManager LoadPubAccountMenu:self.chatId];
    }
}

- (void)loadGroupData {
    self.group = [[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:self.chatId];
    self.groupExt = [[YYIMChat sharedInstance].chatManager getChatGroupExtWithId:self.chatId];
    
    [self.groupTitleLabel setText:[NSString stringWithFormat:@"%@(%lu)", [self.group groupName], (unsigned long)[self.group memberCount]]];
    [self.navigationItem setTitleView:self.groupTitleLabel];
    
    [self loadGroupChatUser];
}

- (void)loadGroupChatUser {
    NSArray *userArray = [[YYIMChat sharedInstance].chatManager getChatUserWithChatId:self.chatId];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    for (YYUser *user in userArray) {
        [userDic setObject:user forKey:[user userId]];
    }
    self.groupUserDic = userDic;
}

- (UILabel *)groupTitleLabel {
    if (!_groupTitleLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 44)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:17]];
        _groupTitleLabel = label;
    }
    return _groupTitleLabel;
}

- (BOOL)sendTextMessage:(UITextView *)messageInputView {
    NSString *text = messageInputView.text;
    if (text && ![@"" isEqualToString:text]) {
        if ([text length] > 1000) {
            [self showHint:@"输入字数过长，请缩减至1000字以内"];
            return NO;
        }
        
        //不能输入纯空格
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
            [self showHint:@"不能发送空白消息"];
            return NO;
        }
        
        [[YYIMChat sharedInstance].chatManager sendTextMessage:self.chatId text:text chatType:self.chatType atUserArray:[self.messageToolView atUserArray]];
        messageInputView.text = nil;
        [self.messageToolView clearAtUser];
        return YES;
    }
    return NO;
}

- (BOOL)isHeaderShow:(NSInteger)row {
    if (row == 0) {
        return YES;
    }
    YYMessage *thisMessage = [self.messageArray objectAtIndex:row];
    YYMessage *lastMessage = [self.messageArray objectAtIndex:row - 1];
    
    if ([thisMessage direction] != [lastMessage direction]) {
        return YES;
    }
    
    if ([lastMessage type] == YM_MESSAGE_CONTENT_PROMPT || [lastMessage type] == YM_MESSAGE_CONTENT_REVOKE) {
        return YES;
    }
    
    if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        if ([thisMessage date] - [lastMessage date] <= YYIMUI_CHAT_TIME_THRESHOLD && [[thisMessage fromId] isEqualToString:[lastMessage fromId]] && [[thisMessage rosterId] isEqualToString:[lastMessage rosterId]]) {
            return NO;
        }
    } else if ([self.chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        if ([thisMessage date] - [lastMessage date] <= YYIMUI_CHAT_TIME_THRESHOLD && [[thisMessage fromId] isEqualToString:[lastMessage fromId]]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isBottomShow:(NSInteger)row {
    if (row >= self.messageArray.count - 1) {
        return YES;
    }
    YYMessage *thisMessage = [self.messageArray objectAtIndex:row];
    YYMessage *nextMessage = [self.messageArray objectAtIndex:row + 1];
    if ([[thisMessage fromId] isEqualToString:[nextMessage fromId]] && [nextMessage date] - [thisMessage date] <= YYIMUI_CHAT_TIME_THRESHOLD) {
        return NO;
    }
    return YES;
}

- (BOOL)isTimeShow:(NSInteger)row {
    if (row == 0) {
        return YES;
    }
    YYMessage *thisMessage = [self.messageArray objectAtIndex:row];
    YYMessage *lastMessage = [self.messageArray objectAtIndex:row - 1];
    if ([thisMessage date] - [lastMessage date] <= YYIMUI_CHAT_TIME_THRESHOLD && [lastMessage type] != YM_MESSAGE_CONTENT_PROMPT) {
        return NO;
    }
    return YES;
}

- (CGFloat)baseViewHeight {
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat navigationHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    return screenHeight - navigationHeight - statusHeight;
}

- (BOOL)isPubAccountMenuNeedRequest:(YYPubAccountMenu *)menu {
    if (!menu) {
        return YES;
    }
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970];
    if (timeInterval - [menu lastUpdate] > YYIM_PUBACCOUNT_MENU_OVERDUE_THRESHOLD) {
        return YES;
    }
    return NO;
}

- (void)pubAccountMenuChange {
    if (!self.tableMenu) {
        self.tableMenu = [YMTableMenu initYMTableMenu];
        self.tableMenu.delegate = self;
        [self.view addSubview:self.tableMenu];
    }
    
    [self.tableMenu setHidden:YES];
    
    //如果用菜单，添加菜单
    if (self.accountMenu) {
        self.pubAccountMenuView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - YYIM_PUBACCOUNT_MENU_HEIGHT, CGRectGetWidth(self.view.frame), YYIM_PUBACCOUNT_MENU_HEIGHT);
        self.chatTableView.frame = CGRectMake(0.0f, 0.0f , CGRectGetWidth(self.view.frame), [self baseViewHeight] - YYIM_PUBACCOUNT_MENU_HEIGHT);
        
        //更新menu自定义控件
        if (!self.pubAccountMenuCustomView) {
            self.pubAccountMenuCustomView = [[YMPubAccountMenuCustomView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.pubAccountMenuView.frame), CGRectGetHeight(self.pubAccountMenuView.frame))];
            self.pubAccountMenuCustomView.delegate = self;
            [self.pubAccountMenuView addSubview:self.pubAccountMenuCustomView];
        }
        
        [self.pubAccountMenuCustomView updateContent:self.accountMenu];
    } else {
        self.pubAccountMenuView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), YYIM_PUBACCOUNT_MENU_HEIGHT);
        self.chatTableView.frame = CGRectMake(0.0f, 0.0f , CGRectGetWidth(self.view.frame), [self baseViewHeight]);
        
        //清除menu自定义控件
        if (self.pubAccountMenuCustomView) {
            [self.pubAccountMenuCustomView removeFromSuperview];
            self.pubAccountMenuCustomView = nil;
        }
    }
}

- (void)showPubAccountTableMenuAtIndex:(NSInteger) index{
    if (self.tableMenu && self.accountMenu && self.accountMenu.menuItemArray && self.accountMenu.menuItemArray.count > index) {
        YYPubAccountMenuItem *item = [self.accountMenu.menuItemArray objectAtIndex:index];
        
        if (item && item.itemArray && item.itemArray.count > 0) {
            //布局tableMenu
            CGFloat menuWith = CGRectGetWidth(self.view.frame) / self.accountMenu.menuItemArray.count;
            self.tableMenu.frame = CGRectMake(index * menuWith, CGRectGetHeight(self.view.frame) - (item.itemArray.count + 1) *YYIM_PUBACCOUNT_MENU_HEIGHT, menuWith, item.itemArray.count * YYIM_PUBACCOUNT_MENU_HEIGHT);
            
            NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:item.itemArray.count];
            for (YYPubAccountMenuItem *child in item.itemArray) {
                [nameArray addObject:child.itemName];
            }
            
            [self.tableMenu setMenuItems:nameArray];
            [self.tableMenu setHidden:NO];
        }
    }
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording:%@", flag?@"success":@"failure");
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur:%@", error.description);
}

#pragma mark -
#pragma mark message pressed

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    // 收起bottomViews
    [self shrinkBottomViews];
    YYMessage *message = [userInfo objectForKey:kYMChatPressedMessage];
    YYMessageContent *content = [message getMessageContent];
    ChatTableViewCell *cell = [userInfo objectForKey:kYMChatPressedCell];
    // 点击头像
    NSNumber *pressHead = [userInfo objectForKey:kYMChatPressedHead];
    if (pressHead && [pressHead boolValue]) {
        [self pressHeadWithMessage:message];
        return;
    }
    // 点击URL
    NSString *urlString = [userInfo objectForKey:kYMChatPressedURL];
    if (urlString) {
        [self pressMessageURL:urlString];
        return;
    }
    // 点击消息内容
    self.curMessage = message;
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_MICROVIDEO: {
            if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && (([message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_INI || [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_FAILD) && [YYIMUtility isEmptyString:[message getResThumbLocal]])) {
                //再次尝试下载短视频的缩略图
                [[YYIMChat sharedInstance].chatManager downloadMessageRes:message.pid];
            } else if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [YYIMUtility isEmptyString:message.getResLocal] && message.downloadStatus != YM_MESSAGE_DOWNLOADSTATE_ING){
                //开始下载
                [[YYIMChat sharedInstance].chatManager downloadMicroVideoMessageRes:message.pid progress:nil complete:^(BOOL result, NSString *filePath, YYIMError *error) {
                    if (result) {
                        if (![self.playingVideoArray containsObject:message.pid]) {
                            [self.playingVideoArray addObject:message.pid];
                        }
                    }
                }];
            } else if (![YYIMUtility isEmptyString:message.getResLocal]) {
                ChatMicroVideoTableViewCell *cell = [userInfo objectForKey:kYMChatPressedCell];
                
                if (![self.playingVideoArray containsObject:message.pid]) {
                    [cell playMicroVideo];
                    [self.playingVideoArray addObject:message.pid];
                } else {
                    [cell stopMicroVideo];
                    [self.playingVideoArray removeObject:message.pid];
                    
                    //停止播放的同时，打开预览
                    NSInteger index = 0;
                    for (int i = 0; i < self.videoMessageArray.count; i++) {
                        if ([[message pid] isEqualToString:((YYMessage *)self.videoMessageArray[i]).pid]) {
                            index = i;
                            break;
                        }
                    }
                    
                    self.videoBrowserController = [[ChatMicroVideoBrowserController alloc] initWithNibName:nil bundle:nil];
                    [self.videoBrowserController setVideoSourceArray:self.videoMessageArray];
                    [self.videoBrowserController setVideoIndex:index];
                    [self.navigationController pushViewController:self.videoBrowserController animated:NO];
                }
            }
            
            break;
        }
        case YM_MESSAGE_CONTENT_AUDIO: {
            if (self.audioPlayer && [self.audioPlayer isPlaying]) {
                if ([cell audioAnimationPlaying]) {
                    [self.audioPlayer stop];
                    [cell playAudioAnimation:NO];
                    return;
                } else if ([self.curPlayingCell audioAnimationPlaying]) {
                    [self.audioPlayer stop];
                    [self.curPlayingCell playAudioAnimation:NO];
                }
            }
            
            self.curPlayingCell = cell;
            NSString *wavPath = [message getResLocal];
            if (wavPath) {
                [cell playAudioAnimation:YES];
                self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:wavPath] error:nil];
                [self.audioPlayer prepareToPlay];
                [self.audioPlayer play];
                [self.audioPlayer setDelegate:cell];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_LOCATION: {
            LocationShowController *locationShowController = [[LocationShowController alloc] initWithNibName:@"LocationShowController" bundle:nil];
            locationShowController.longitude = [[content longitude] floatValue];
            locationShowController.latitude = [[content latitude] floatValue];
            locationShowController.address = [content address];
            
            UINavigationController *locationShowNavController = [YYIMUtility themeNavController:locationShowController];
            [self presentViewController:locationShowNavController animated:YES completion:nil];
            break;
        }
        case YM_MESSAGE_CONTENT_FILE:{
            if ([message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_INI || [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_FAILD || [YYIMUtility isEmptyString:[message getResLocal]]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否下载该文件？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            } else if ([message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_SUCCESS) {
                PreviewViewController *previewController = [[PreviewViewController alloc] initWithNibName:nil bundle:nil];
                YYMessageContent *content = [message getMessageContent];
                previewController.file = [YYFile fileWithFileId:[content fileAttachId] fileName:[content fileName] fileSize:[content fileSize] localPath:message.resLocal];
                
                UINavigationController *previewNavController = [YYIMUtility themeNavController:previewController];
                [self presentViewController:previewNavController animated:YES completion:nil];
                //                [self.navigationController pushViewController:preViewController animated:YES];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_IMAGE:{
            if (([message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_INI || [message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_FAILD || [YYIMUtility isEmptyString:[message getResThumbLocal]])) {
                
                [[YYIMChat sharedInstance].chatManager downloadImageMessageRes:[message pid] imageType:kYYIMImageTypeThumb progress:nil complete:nil];
            } else {
                NSInteger index = 0;
                for (int i = 0; i < self.imageMessageArray.count; i++) {
                    if ([[message pid] isEqualToString:((YYMessage *)self.imageMessageArray[i]).pid]) {
                        index = i;
                        break;
                    }
                }
                [self.imageBrowserController setImageSourceArray:self.imageMessageArray];
                [self.imageBrowserController setImageIndex:index];
                [self.navigationController pushViewController:self.imageBrowserController animated:NO];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_SINGLE_MIXED: {
            YYPubAccountContent *paContent = [content paContent];
            PubAccountDisplayController *pubAccountDisplayController = [[PubAccountDisplayController alloc] initWithNibName:@"PubAccountDisplayController" bundle:nil];
            [pubAccountDisplayController setAccount:self.account];
            [pubAccountDisplayController setPaContent:paContent];
            [self.navigationController pushViewController:pubAccountDisplayController animated:YES];
            break;
        }
        case YM_MESSAGE_CONTENT_BATCH_MIXED: {
            NSNumber *idxNumber = [userInfo objectForKey:kYMChatPressedIndex];
            NSInteger index = [idxNumber integerValue];
            YYPubAccountContent *paContent = [[content paArray] objectAtIndex:index];
            
            PubAccountDisplayController *pubAccountDisplayController = [[PubAccountDisplayController alloc] initWithNibName:@"PubAccountDisplayController" bundle:nil];
            [pubAccountDisplayController setAccount:self.account];
            [pubAccountDisplayController setPaContent:paContent];
            [self.navigationController pushViewController:pubAccountDisplayController animated:YES];
            break;
        }
        case YM_MESSAGE_CONTENT_SHARE: {
            NSString *shareUrl = [content shareUrl];
            if (shareUrl) {
                [self showHint:[content shareUrl]];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_NETMEETING: {
            YYNetMeetingContent *conference = content.netMeetingContent;
            
            switch (conference.messageType) {
                case kYYIMNetMeetingMessageTypeSingelChatNotify: {
                    NSArray *invitees = [[NSArray alloc] initWithObjects:self.chatId, nil];
                    
                    //调用创建频道的接口
                    if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                        [self showHint:@"当前有会议在进行，操作被禁止"];
                    } else {
                        [[NetMeetingDispatch sharedInstance] createNetMeetingWithNetMeetingType:kYYIMNetMeetingTypeSingleChat netMeetingMode:conference.netMeetingMode invitees:invitees topic:@""];
                    }
                    break;
                }
                case kYYIMNetMeetingMessageTypeConferenceShare: {
                    if ([[YYIMChat sharedInstance].chatManager isNetMeetingProcessing]) {
                        [self showHint:@"当前有会议在进行，操作被禁止"];
                    } else {
                        [[YYIMChat sharedInstance].chatManager joinNetMeeting:conference.channelId];
                    }
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
}

- (ChatImageBrowserController *)imageBrowserController {
    if (!_imageBrowserController) {
        ChatImageBrowserController *imageBrowserController = [[ChatImageBrowserController alloc] initWithNibName:nil bundle:nil];
        _imageBrowserController = imageBrowserController;
    }
    return _imageBrowserController;
}

- (void)pressHeadWithMessage:(YYMessage *)message {
    // 头像点击
    if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        if (![YM_ADMIN_USER isEqualToString:[message fromId]]) {
            UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
            userViewController.userId = self.chatId;
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    } else if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT]) {
        AccountInfoViewController *accountInfoViewController = [[AccountInfoViewController alloc] initWithNibName:@"AccountInfoViewController" bundle:nil];
        accountInfoViewController.accountId = self.chatId;
        [self.navigationController pushViewController:accountInfoViewController animated:YES];
    } else if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        if (![YM_ADMIN_USER isEqualToString:[message rosterId]]) {
            UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
            userViewController.userId = [message rosterId];
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    }
}

- (void)pressMessageURL:(NSString *)urlString {
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:nil bundle:nil];
    [webViewController setUrlString:urlString];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)bubbleLongPressWithUserInfo:(NSDictionary *)userInfo {
    UILongPressGestureRecognizer *longPressGestureRecognizer = [userInfo objectForKey:kYMChatPressedGestureRecognizer];
    CGPoint location = [longPressGestureRecognizer locationInView:self.chatTableView];
    
    if (![[self.messageToolView messageInputView] isFirstResponder]) {
        ChatTableViewCell *cell = [userInfo objectForKey:kYMChatPressedCell];
        [cell becomeFirstResponder];
    }
    
    YYMessage *message = [userInfo objectForKey:kYMChatPressedMessage];
    self.curMessage = message;
    
    if ([message type] == YM_MESSAGE_CONTENT_PROMPT) {
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    if ([message type] == YM_MESSAGE_CONTENT_TEXT) {
        // 复制
        UIMenuItem *itemCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(handleCopyCell:)];
        [array addObject:itemCopy];
    }
    // 转发
    UIMenuItem *itemForward = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(handleForwardCell:)];
    [array addObject:itemForward];
    // 删除
    UIMenuItem *itDelete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(handleDeleteCell:)];
    [array addObject:itDelete];
    // 撤回
    if ([message direction] == YM_MESSAGE_DIRECTION_SEND && ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_CHAT] || [[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT])) {
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:[message date] / 1000];
        if ([[NSDate date] timeIntervalSinceDate:messageDate] < 120) {
            UIMenuItem *itRevoke = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(handleRevokeCell:)];
            [array addObject:itRevoke];
        }
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:array];
    [menu setTargetRect:CGRectMake(location.x, location.y - 20, 1, 1) inView:self.chatTableView];
    [menu setMenuVisible:YES animated:NO];
}

- (void)handleCopyCell:(id)sender {
    if (self.curMessage) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [[self.curMessage getMessageContent] message];
        self.curMessage = nil;
    }
}

- (void)handleForwardCell:(id)sender {
    ChatSelViewController *chatSelViewController = [[ChatSelViewController alloc] initWithNibName:@"ChatSelViewController" bundle:nil];
    ChatSelNavController *chatSelNavController = [[ChatSelNavController alloc] initWithRootViewController:chatSelViewController];
    [YYIMUtility genThemeNavController:chatSelNavController];
    chatSelNavController.chatSelDelegate = self;
    [self presentViewController:chatSelNavController animated:YES completion:nil];
}

- (void)handleDeleteCell:(id)sender {
    if (self.curMessage) {
        [[YYIMChat sharedInstance].chatManager deleteMessageWithPid:[self.curMessage pid]];
        [self.messageArray removeObject:self.curMessage];
        [self.chatTableView reloadData];
        
        self.curMessage = nil;
    }
}

- (void)handleRevokeCell:(id)sender {
    if (self.curMessage) {
        if ([[self.curMessage chatType] isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
            [[YYIMChat sharedInstance].chatManager revokeChatMessageWithId:[self.curMessage pid]];
        } else if ([[self.curMessage chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
            [[YYIMChat sharedInstance].chatManager revokeGroupChatMessageWithId:[self.curMessage pid]];
        }
        [self showHudInView:self.view hint:nil];
        self.curMessage = nil;
    }
}

- (void)menuDidHide:(id)sender {
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

#pragma mark -
#pragma mark YMChatSelDelegate

- (void)didSelectChatId:(NSString *)chatId chatType:(NSString *)chatType {
    if (self.curMessage) {
        [[YYIMChat sharedInstance].chatManager forwardMessage:chatId pid:[self.curMessage pid] chatType:chatType];
        self.curMessage = nil;
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [[YYIMChat sharedInstance].chatManager downloadMessageRes:[self.curMessage pid]];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    
}

@end
