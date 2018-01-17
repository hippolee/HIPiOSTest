//
//  UserViewController.m
//  YonyouIM
//
//  Created by litfb on 15/3/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UserViewController.h"
#import "YYIMChatHeader.h"
#import "YYIMUtility.h"
#import "SingleLineCell2.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "MenuView.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMColorHelper.h"

@interface UserViewController ()<UIGestureRecognizerDelegate, MenuViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MenuView *menuView;

@property (weak, nonatomic) UIImageView *headBgImage;
@property (weak, nonatomic) UIImageView *headImage;
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UIButton *sendButton;

@property (retain, nonatomic) YYUser *user;

@property (retain, nonatomic) YYRoster *roster;
@property (retain, nonatomic) NSArray *menuArray;

@property (retain, nonatomic) NSArray *userSetting;

@property (retain, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

- (IBAction)sendAction:(id)sender;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self.userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(menuAction:)];
        self.navigationItem.rightBarButtonItem = menuBtn;
        
        [self.menuView setMenuDelegate:self];
    }
    
    [[YYIMChat sharedInstance].chatManager loadUser:self.userId];
    
    [self initView];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTap:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer setCancelsTouchesInView:YES];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    self.tapGestureRecognizer = tapGestureRecognizer;
    
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (IBAction)sendAction:(id)sender {
    if (![self.menuView isHidden]) {
        [self.menuView setHidden:YES];
        return;
    }
    
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    chatViewController.chatId = self.userId;
    chatViewController.chatType = YM_MESSAGE_TYPE_CHAT;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)initView {
    CGFloat viewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat headBgViewHeight = viewWidth * 9 / 16;
    CGFloat viewHeight = headBgViewHeight + 12;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *headBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, headBgViewHeight)];
    [headBgImage setContentMode:UIViewContentModeScaleAspectFill];
    [headBgImage setClipsToBounds:YES];
    [view addSubview:headBgImage];
    self.headBgImage = headBgImage;
    
    CGFloat headImageHeight = headBgViewHeight / 2;
    CGFloat headImageX = (viewWidth - headImageHeight) / 2;
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(headImageX, headImageHeight / 2, headImageHeight, headImageHeight)];
    CALayer *headLayer = [headImage layer];
    [headLayer setMasksToBounds:YES];
    [headLayer setCornerRadius:headImageHeight / 2];
    [view addSubview:headImage];
    self.headImage = headImage;
    
    CGFloat nameLabelY = headBgViewHeight * 3 / 4 + 8;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabelY, viewWidth, 16)];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [view addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    [self.tableView setTableHeaderView:view];
}

#pragma mark table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userSetting.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    
    NSString *showCol = [self.userSetting objectAtIndex:indexPath.row];
    
    if ([showCol isEqualToString:@"nickname"]) {
        [cell setName:@"姓名"];
        [cell setDetail:[self.user userName]];
    } else if ([showCol isEqualToString:@"email"]) {
        [cell setName:@"邮箱"];
        [cell setDetail:[self.user userEmail]];
    } else if ([showCol isEqualToString:@"organization"]) {
        [cell setName:@"部门"];
        [cell setDetail:[self.user userOrg]];
    } else if ([showCol isEqualToString:@"mobile"]) {
        [cell setName:@"手机号"];
        [cell setDetail:[self.user userMobile]];
    } else if ([showCol isEqualToString:@"position"]) {
        [cell setName:@"职位"];
        [cell setDetail:[self.user userTitle]];
    } else if ([showCol isEqualToString:@"gender"]) {
        [cell setName:@"性别"];
        [cell setDetail:[self.user userGender]];
    } else if ([showCol isEqualToString:@"number"]) {
        [cell setName:@"工号"];
        [cell setDetail:[self.user userNumber]];
    } else if ([showCol isEqualToString:@"telephone"]) {
        [cell setName:@"分机号"];
        [cell setDetail:[self.user userTelephone]];
    } else if ([showCol isEqualToString:@"location"]) {
        [cell setName:@"办公地点"];
        [cell setDetail:[self.user userLocation]];
    } else if ([showCol isEqualToString:@"remarks"]) {
        [cell setName:@"备注"];
        [cell setDetail:[self.user userDesc]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self tableTap:nil];
}

#pragma mark yyimchat delegate

- (void)didUserInfoUpdate:(YYUser *)user {
    if ([[user userId] isEqualToString:self.userId]) {
        [self reloadData];
    }
}

- (void)didRosterDelete:(NSString *)rosterId {
    if ([self.userId isEqualToString:rosterId]) {
        [self reloadData];
    }
}

- (void)didRosterUpdate:(YYRoster *)roster {
    if (roster && [[roster rosterId] isEqualToString:self.userId]) {
        [self reloadData];
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![self.menuView isHidden]) {
        return YES;
    }
    return NO;
}

#pragma mark utility

- (void)reloadData {
    NSMutableArray *userSetting = [NSMutableArray arrayWithArray:[[YYIMConfig sharedInstance] getUserSetting]];
    [userSetting removeObject:@"photo"];
    self.userSetting = userSetting;
    
    self.user = [[YYIMChat sharedInstance].chatManager getUserWithId:self.userId];
    self.roster = [[YYIMChat sharedInstance].chatManager getRosterWithId:self.userId];
    
    self.navigationItem.title = @"个人信息";
    
    NSString *name;
    if (self.roster) {
        name = [self.roster rosterAlias];
    } else {
        name = [self.user userName];
    }
    [self.nameLabel setText:name];
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:[self.user getUserPhoto]] placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"");
    }];
    
    [self.headBgImage sd_setImageWithURL:[NSURL URLWithString:[self.user getUserPhoto]] placeholderImage:[UIImage imageNamed:@"bg_user"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            UIImage *gaussianimage = [UIImage gaussBlurWithImage:image];
            self.headBgImage.image = gaussianimage;
        }
    }];
    
    [self.tableView reloadData];
    
    NSMutableArray *array = [NSMutableArray array];
    if (self.roster) {
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_delete", @"icon", @"删除好友", @"name", nil]];
    } else {
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_addroster", @"icon", @"加为好友", @"name", nil]];
    }
    self.menuArray = array;
    [self.menuView reloadData];
}

- (void)menuAction:(id)sender {
    if ([self.menuView isHidden]) {
        [self.menuView setHidden:NO];
    } else {
        [self.menuView setHidden:YES];
    }
}

- (NSArray *)menuDataDicArray {
    return self.menuArray;
}

- (void)didSelectMenuAtIndex:(NSUInteger)index {
    if (self.roster) {
        [[YYIMChat sharedInstance].chatManager deleteRoster:self.userId];
    } else {
        [[YYIMChat sharedInstance].chatManager addRoster:self.userId];
    }
}

- (void)tableTap:(UITapGestureRecognizer *)tapRecognizer {
    [self.menuView setHidden:YES];
}

@end
