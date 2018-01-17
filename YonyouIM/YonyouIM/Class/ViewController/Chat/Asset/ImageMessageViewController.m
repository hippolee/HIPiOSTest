//
//  ImageMessageViewController.m
//  YonyouIM
//
//  Created by litfb on 15/4/8.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ImageMessageViewController.h"
#import "YYIMUtility.h"
#import "UIColor+YYIMTheme.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYIMColorHelper.h"
#import "ImageMessageTableViewCell.h"
#import "UIResponder+YYIMCategory.h"
#import "UIViewController+HUDCategory.h"
#import "ChatImageBrowserView.h"

@interface ImageMessageViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSArray *messageArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property CGFloat cellHeight;

@property (retain, nonatomic) NSArray *timeArray;

@property (retain, nonatomic) NSDictionary *dataDic;

// 图片浏览器
@property (retain, nonatomic) ChatImageBrowserView *imageBrowser;

@end

@implementation ImageMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"图片";
    
    self.cellHeight = (CGRectGetWidth([[UIScreen mainScreen] bounds]) - 6) / 4 + 2;
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    // cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"ImageMessageTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 加载数据
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.timeArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.timeArray objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 320, 40);
    label.font = [UIFont systemFontOfSize:16];
    [label setTextColor:UIColorFromRGB(0x4e4e4e)];
    label.text = sectionTitle;
    
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [sectionView setBackgroundColor:[UIColor whiteColor]];
    [sectionView addSubview:label];
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.timeArray objectAtIndex:section];
    NSArray *array = [self.dataDic objectForKey:key];
    return ceil([array count] / 4.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    ImageMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageMessageTableViewCell"];
    
    NSArray *messages = [self getDataWithIndexPath:indexPath];
    [cell setImageMessages:messages];
    return cell;
}

#pragma mark image press

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    YYMessage *curMessage = [userInfo objectForKey:kYMPressedImageMessage];
    if (!curMessage) {
        return;
    }
    
    NSInteger index = 0;
    for (int i = 0; i < self.messageArray.count; i++) {
        if ([[curMessage pid] isEqualToString:((YYMessage *)self.messageArray[i]).pid]) {
            index = i;
            break;
        }
    }
    [self.imageBrowser setImageSourceArray:self.messageArray];
    [self.imageBrowser setImageIndex:index];
    [self.imageBrowser show];
}

- (ChatImageBrowserView *)imageBrowser {
    if (!_imageBrowser) {
        ChatImageBrowserView *imageBrowser = [[ChatImageBrowserView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
        _imageBrowser = imageBrowser;
    }
    return _imageBrowser;
}

#pragma mark YYIMChatDelegate

- (void)didMessageResStatusChanged:(YYMessage *)message error:(YYIMError *)error {
    if ([[message toId] isEqualToString:self.chatId] || [[message fromId] isEqualToString:self.chatId]) {
        [self loadData];
        if ([self.imageBrowser isShown]) {
            [self.imageBrowser setImageSourceArray:self.messageArray];
            [self.imageBrowser reloadData];
        }
    }
}

#pragma mark data gen

- (void)loadData {
    self.messageArray = [[YYIMChat sharedInstance].chatManager getMessageWithId:self.chatId contentType:YM_MESSAGE_CONTENT_IMAGE];
    
    [self generateDataDic];
}

- (void)generateDataDic {
    NSMutableArray *timeArray = [NSMutableArray array];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    for (YYMessage *message in self.messageArray) {
        NSString *timeKey = [self makeTimeKeyWithDataline:[message date]];
        if (![timeArray containsObject:timeKey]) {
            [timeArray addObject:timeKey];
        }
        NSMutableArray *array = [dataDic objectForKey:timeKey];
        if (!array) {
            array = [NSMutableArray array];
            [dataDic setObject:array forKey:timeKey];
        }
        [array addObject:message];
    }
    self.timeArray= timeArray;
    self.dataDic = dataDic;
    [self.tableView reloadData];
}

- (NSString *)makeTimeKeyWithDataline:(NSTimeInterval)timeInMillis {
    // 日历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 传入时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInMillis / 1000];
    // formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear;
    NSDateComponents *dateComponents =  [calendar components:calendarUnit fromDate:date];
    NSDateComponents *nowComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    // 不同年
    if ([dateComponents year] != [nowComponents year]) {
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        return [dateFormatter stringFromDate:date];
    } else if ([dateComponents month] != [nowComponents month]) {// 不同周
        [dateFormatter setDateFormat:@"MM月dd日"];
        return [dateFormatter stringFromDate:date];
    } else if ([dateComponents day] != [nowComponents day]) {// 不同日
        [dateFormatter setDateFormat:@"EEEE"];
        return [dateFormatter stringFromDate:date];
    } else {// 今天
        return @"今天";
    }
}

- (NSArray *)getDataWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [self.dataDic objectForKey:[self.timeArray objectAtIndex:indexPath.section]];
    NSUInteger loc = indexPath.row * 4;
    NSInteger len = [array count] - loc;
    return [array subarrayWithRange:NSMakeRange(loc, MIN(len, 4))];
}

@end
