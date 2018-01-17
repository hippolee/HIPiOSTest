//
//  YYIMUtility.m
//  YonyouIM
//
//  Created by litfb on 15/1/8.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMColorHelper.h"
#import "YYIMEmojiLabel.h"
#import <CommonCrypto/CommonDigest.h>
#import "YYIMEmojiHelper.h"

@implementation YYIMUtility

+ (NSTimeInterval)getHalfTimeOfNow {
    // 日历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour;
    NSDateComponents *nowComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    NSInteger minute = nowComponents.minute;
    
    if (minute >= 30) {
        nowComponents.minute = 0;
        
        NSDate *convertdate = [calendar dateFromComponents:nowComponents];
        NSTimeInterval time = [convertdate timeIntervalSince1970] + 60 * 60;
        return time;
    } else {
        nowComponents.minute = 0;
        NSDate *convertdate = [calendar dateFromComponents:nowComponents];
        NSTimeInterval time = [convertdate timeIntervalSince1970] + 60 * 30;
        return time;
    }
}

+ (NSString *)genTimeString:(NSTimeInterval)timeInMillis {
    // 传入时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInMillis/1000];
    
    return [self genTimeStringWithDate:date];
}

+ (NSString *)genTimeStringWithDate:(NSDate *)date {
    // 日历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitWeekOfYear;
    NSDateComponents *dateComponents =  [calendar components:calendarUnit fromDate:date];
    NSDateComponents *nowComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    
    // 不同年
    if ([dateComponents year] != [nowComponents year]) {
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        return [dateFormatter stringFromDate:date];
    } else if ([dateComponents weekOfYear] != [nowComponents weekOfYear]) {// 不同周
        [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
        return [dateFormatter stringFromDate:date];
    } else if ([dateComponents day] == [nowComponents day]) {// 今天
        [dateFormatter setDateFormat:@"aa HH:mm"];
        return [dateFormatter stringFromDate:date];
    } else if ([dateComponents day] == [nowComponents day] - 1) {// 昨天
        [dateFormatter setDateFormat:@"昨天 HH:mm"];
        return [dateFormatter stringFromDate:date];
    } else {// 本周
        [dateFormatter setDateFormat:@"EEEE HH:mm"];
        return [dateFormatter stringFromDate:date];
    }
    return nil;
}

+ (NSString *)genSimpleTimeString:(NSTimeInterval)timeInMillis {
    // 日历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 传入时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInMillis/1000];
    
    // formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitWeekOfYear;
    
    NSDateComponents *dateComponents =  [calendar components:calendarUnit fromDate:date];
    NSDateComponents *nowComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    // 不同年
    if ([dateComponents year] != [nowComponents year]) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateFormatter stringFromDate:date];
    } else if (([dateComponents month] == [nowComponents month]) && ([dateComponents day] == [nowComponents day])) {// 今天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [dateFormatter stringFromDate:date];
    } else {
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        return [dateFormatter stringFromDate:date];
    }
    return nil;
}

+ (NSString *)genTimeString:(NSTimeInterval)timeInMillis dateFormat:(NSString *)dateFormat {
    // 传入时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInMillis/1000];
    return [self genTimeStringWithDate:date dateFormat:dateFormat];
}

+ (NSString *)genTimeStringWithDate:(NSDate *)date dateFormat:(NSString *)dateFormat {
    // formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    // format date
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)genGroupName:(YYUser *)user invites:(NSArray *)inviteArray {
    if (!inviteArray && [inviteArray count] <= 0) {
        return nil;
    }
    NSMutableString *name = [NSMutableString string];
    [name appendString:[user userName]];
    for (id invite in inviteArray) {
        if ([invite isKindOfClass:[YYUser class]]) {
            [name appendString:@"、"];
            [name appendString:[invite userName]];
        } else if ([invite isKindOfClass:[YYRoster class]]) {
            if ([invite rosterAlias]) {
                [name appendString:@"、"];
                [name appendString:[invite rosterAlias]];
            }
        } else if ([invite isKindOfClass:[YYChatGroupMember class]]) {
            YYChatGroupMember *member = (YYChatGroupMember *)invite;
            if ([member user]) {
                [name appendString:@"、"];
                [name appendString:member.user.userName];
            } else if (member.memberName && [member.memberName length] != 0) {
                [name appendString:@"、"];
                [name appendString:[member memberName]];
            }
        }
    }
    return name;
}

+ (void)setExtraCellLineHidden:(UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+ (BOOL)isEmptyString:(NSString *) str {
    if (!str) {
        return YES;
    } else if ([str length] == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)trimString:(NSString *)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (void)initNavigationBarStyle {
    [[UINavigationBar appearance] setBarTintColor:[UIColor themeColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    // 去掉系统navigationBar自带底下黑边
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

+ (UINavigationController *)themeNavController:(UIViewController *)rootViewController {
    // nav
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self genThemeNavController:navController];
    return navController;
}

+ (void)genThemeNavController:(UINavigationController *)navController {
    [navController.navigationBar setBarTintColor:[UIColor themeColor]];
    [navController.navigationBar setTranslucent:NO];
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark file

#define YYIMWordExt @[@"docx", @"doc", @"wps"]
#define YYIMExcelExt @[@"xlsx", @"xls"]
#define YYIMPptExt @[@"ppt", @"pptx"]
#define YYIMPdfExt @[@"pdf"]
#define YYIMTxtExt @[@"txt"]
#define YYIMImageExt @[@"bmp", @"jpg", @"jpeg", @"png", @"gif"]
#define YYIMVideoExt @[@"avi", @"rmvb", @"rm", @"asf", @"divx", @"mpg", @"mpeg", @"mpe", @"wmv", @"mp4", @"mkv", @"vob"]
#define YYIMMusicExt @[@"wav", @"mp3", @"aif", @"wmv", @"mpg4"]

+ (NSString *)fileIconWithExt:(NSString *)ext {
    ext = [ext lowercaseString];
    if ([YYIMWordExt containsObject:ext]) {
        return @"icon_file_word";
    } else if ([YYIMExcelExt containsObject:ext]) {
        return @"icon_file_excel";
    } else if ([YYIMPptExt containsObject:ext]) {
        return @"icon_file_ppt";
    } else if ([YYIMPdfExt containsObject:ext]) {
        return @"icon_file_pdf";
    } else if ([YYIMTxtExt containsObject:ext]) {
        return @"icon_file_txt";
    } else if ([YYIMImageExt containsObject:ext]) {
        return @"icon_file_image";
    } else if ([YYIMVideoExt containsObject:ext]) {
        return @"icon_file_video";
    } else if ([YYIMMusicExt containsObject:ext]) {
        return @"icon_file_music";
    }
    return @"icon_file_other";
}

+ (NSString *)fileSize:(long long)size {
    NSString *sizeStr;
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    [fmt setMaximumFractionDigits:2];
    
    if (size < 0) {
        size = 0;
    }
    
    if (size < 1024) {
        sizeStr = [NSString stringWithFormat:@"%lldB", size];
    } else if (size < 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%@K", [fmt stringFromNumber:[NSNumber numberWithDouble:(double)size / 1024]]];
    } else if (size < 1024 * 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%@M", [fmt stringFromNumber:[NSNumber numberWithDouble:(double)size / 1024 / 1024]]];
    } else {
        sizeStr = [NSString stringWithFormat:@"%@G", [fmt stringFromNumber:[NSNumber numberWithDouble:(double)size / 1024 / 1024 / 1024]]];
    }
    return sizeStr;
}

+ (void)adapterIOS7ViewController:(UIViewController *)viewController {
    if (YYIM_iOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        // 边缘要延伸的方向
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        // 当Bar使用了不透明图片时，视图是否延伸至Bar所在区域
        viewController.extendedLayoutIncludesOpaqueBars = NO;
        // scrollview是否自调整
        viewController.automaticallyAdjustsScrollViewInsets = NO;
        viewController.modalPresentationCapturesStatusBarAppearance = NO;
        // 去除半透明
        viewController.tabBarController.tabBar.translucent = NO;
    }
}

+ (void)clearBackButtonText:(UIViewController *)viewController {
    [viewController.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil]];
}

+ (UITableViewCell *)superCellForView:(UIView *)view {
    while (view) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)view;
        }
        view = [view superview];
    }
    return nil;
}

+ (UICollectionViewCell *)superCollectionCellForView:(UIView *)view {
    while (view) {
        if ([view isKindOfClass:[UICollectionViewCell class]]) {
            return (UICollectionViewCell *)view;
        }
        view = [view superview];
    }
    return nil;
}

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger) tag {
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
    [item setTag:tag];
    
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  UIColorFromRGB(0x67c5f8), NSForegroundColorAttributeName,
                                  nil] forState:UIControlStateSelected];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  UIColorFromRGB(0x6f7275), NSForegroundColorAttributeName,
                                  nil] forState:UIControlStateNormal];
    item.titlePositionAdjustment = UIOffsetMake(0, -3);
    return item;
}

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title tag:(NSInteger) tag {
    UITabBarItem *item;
    if (YYIM_iOS7) {
        item = [[UITabBarItem alloc] initWithTitle:title image:nil selectedImage:nil];
        [item setTag:tag];
    } else {
        item = [[UITabBarItem alloc] initWithTitle:title image:nil tag:tag];
    }
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  UIColorFromRGB(0x67c5f8), NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil] forState:UIControlStateSelected];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  UIColorFromRGB(0x6f7275), NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    item.titlePositionAdjustment = UIOffsetMake(0, -12);
    return item;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSString *)cacheKeyForYMImageUrl:(NSURL *)url {
    NSString *attachId = [[self class] getParamValueFromUrl:[url absoluteString] forParam:@"attachId"];
    if (attachId) {
        return attachId;
    } else {
        return [url absoluteString];
    }
}

+ (NSString *)getParamValueFromUrl:(NSString *)url forParam:(NSString *)param {
    NSRange start = [url rangeOfString:[param stringByAppendingString:@"="]];
    if (start.location == NSNotFound) {
        return nil;
    }
    NSRange end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
    NSUInteger index = start.location + start.length;
    
    NSString * str = nil;
    if (end.location == NSNotFound) {
        str = [url substringFromIndex:index];
    } else {
        str = [url substringWithRange:NSMakeRange(index, end.location)];
    }
    str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

+ (CGSize)sizeOfNSString:(NSString *)string withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode limitSize:(CGSize)limitSize {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrStr length])];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineHeightMultiple = 1;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.minimumLineHeight = font.lineHeight;
    paragraphStyle.maximumLineHeight = font.lineHeight;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrStr length])];
    
    return [YYIMEmojiLabel sizeThatFitsAttributedString:attrStr withConstraints:limitSize limitedToNumberOfLines:0];
}

+ (CGSize)sizeOfNSString2:(NSString *)string withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode limitSize:(CGSize)limitSize {
    UILabel *label = [[UILabel alloc] init];
    [label setText:string];
    [label setFont:font];
    [label setLineBreakMode:lineBreakMode];
    return [label sizeThatFits:limitSize];
}

+ (CGSize)sizeOfImageThumbSize:(CGSize)size withMaxSide:(CGFloat)side {
    CGSize newSize;
    if (size.width/size.height < 1) {
        if (size.height > side) {
            newSize.width = side * size.width / size.height;
            newSize.height = side;
        } else {
            return size;
        }
    } else {
        if (size.width > side) {
            newSize.width = side;
            newSize.height = side * size.height / size.width;
        } else {
            return size;
        }
    }
    return newSize;
}

+ (NSMutableAttributedString *)attributeStringWithString:(NSString *)string keyword:(NSString *)keyword hilightColor:(UIColor *)color {
    if (!string) {
        return [[NSMutableAttributedString alloc] init];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = [[string lowercaseString] rangeOfString:[keyword lowercaseString]];
    if (range.location != NSNotFound) {
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    return attrString;
}

+ (NSString *)getSimpleMessage:(YYMessage *)message {
    YYMessageContent *content = [message getMessageContent];
    NSString *simpleMessage;
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_PROMPT:{
            NSString *promptType = [content attributeForKey:@"promptType"];
            if ([promptType isEqualToString:@"accept_roster"]) {// 同意好友
                NSString *userName = [self userNameWithId:[message rosterId]];
                if (userName) {
                    simpleMessage = [NSString stringWithFormat:@"你已添加了%@，现在可以开始聊天了", userName];
                }
            } else if ([promptType isEqualToString:@"create"] || [promptType isEqualToString:@"invite"]) {// 创建群组// 邀请
                NSString *cipher = [content attributeForKey:@"cipher"];
                NSArray *operhand = [content attributeForKey:@"operhand"];
                
                if ([promptType isEqualToString:@"create"] && cipher) {
                    simpleMessage = [NSString stringWithFormat:@"你创建了群组，身边朋友可通过数字%@加入", cipher];
                } else {
                    NSMutableString *str = [NSMutableString string];
                    NSString *operator = [content attributeForKey:@"operator"];
                    NSString *operatorName = [self userNameWithId:operator];
                    if (operatorName) {
                        [str appendString:operatorName];
                    }
                    
                    if (operhand.count <= 0) {
                        [str appendString:@"创建了群组"];
                    } else {
                        [str appendString:@"邀请"];
                        NSMutableArray *operhandNameArray = [NSMutableArray array];
                        for (NSString *userId in operhand) {
                            NSString *operhandName = [self userNameWithId:userId];
                            if (operhandName) {
                                [operhandNameArray addObject:operhandName];
                            }
                        }
                        [str appendString:[operhandNameArray componentsJoinedByString:@"、"]];
                        [str appendString:@"加入了群组"];
                    }
                    simpleMessage = str;
                }
            } else if ([promptType isEqualToString:@"modify"]) {// 改名
                NSMutableString *str = [NSMutableString string];
                
                NSString *operator = [content attributeForKey:@"operator"];
                NSString *operatorName = [self userNameWithId:operator];
                if (operatorName) {
                    [str appendString:operatorName];
                }
                [str appendString:@"将群名称修改为"];
                [str appendString:[content attributeForKey:@"operhand"]];
                simpleMessage = str;
            } else if ([promptType isEqualToString:@"kickmember"]) {// 踢人
                NSMutableString *str = [NSMutableString string];
                
                NSString *operator = [content attributeForKey:@"operator"];
                NSString *operatorName = [self userNameWithId:operator];
                if (operatorName) {
                    [str appendString:operatorName];
                    [str appendString:@"将"];
                }
                NSArray *operhand = [content attributeForKey:@"operhand"];
                NSMutableArray *operhandNameArray = [NSMutableArray array];
                for (NSString *userId in operhand) {
                    NSString *operhandName = [self userNameWithId:userId];
                    if (operhandName) {
                        [operhandNameArray addObject:operhandName];
                    }
                }
                [str appendString:[operhandNameArray componentsJoinedByString:@"、"]];
                [str appendString:@"踢出了房间"];
                simpleMessage = str;
            } else if ([promptType isEqualToString:@"exit"]) {// 退群
                NSMutableString *str = [NSMutableString string];
                
                NSString *operator = [content attributeForKey:@"operator"];
                NSString *operatorName = [self userNameWithId:operator];
                if (operatorName) {
                    [str appendString:operatorName];
                } else {
                    [str appendString:@"一位用户"];
                }
                [str appendString:@"退出了群组"];
                simpleMessage = str;
            } else if ([promptType isEqualToString:@"join"]) {// 加入
                NSMutableString *str = [NSMutableString string];
                
                NSString *operator = [content attributeForKey:@"operator"];
                NSString *operatorName = [self userNameWithId:operator];
                if (operatorName) {
                    [str appendString:operatorName];
                } else {
                    [str appendString:@"一位用户"];
                }
                [str appendString:@"加入了群组"];
                simpleMessage = str;
            } else {
                simpleMessage = content.message;
            }
            break;
        }
        case YM_MESSAGE_CONTENT_REVOKE:
            simpleMessage = [NSString stringWithFormat:@"%@撤回了一条消息", [self userNameWithId:[message fromId] quotes:YES]];
            break;
        default:
            simpleMessage = [content getSimpleMessage:message];
            break;
    }
    return simpleMessage;
}

+ (NSString *)userNameWithId:(NSString *)userId {
    return [self userNameWithId:userId quotes:NO];
}

+ (NSString *)userNameWithId:(NSString *)userId quotes:(BOOL)quotes {
    NSString *name = @"";
    if ([userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        name = @"你";
    } else {
        YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:userId];
        if (![YYIMUtility isEmptyString:[user userName]]) {
            name = [user userName];
            if (quotes) {
                name = [NSString stringWithFormat:@"\"%@\" ", name];
            }
        }
    }
    return name;
}

+ (BOOL)isIntegerString:(NSString *)str {
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (NSString *)md5Encode:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSString *)encodeToEscapeString:(NSString *)input {
    NSString * outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)input, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return outputStr;
}

+ (NSString *)decodeFromEscapeString:(NSString *)input {
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (void)pushFromController:(UIViewController *)fromVC toController:(UIViewController *)toVC {
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[fromVC.navigationController viewControllers]];
    [viewControllers removeObject:fromVC];
    [viewControllers addObject:toVC];
    [fromVC.navigationController setViewControllers:viewControllers animated:YES];
}

+ (NSString *)genTimingStringWithTime:(NSInteger)millisecond {
    if (millisecond && millisecond > 0) {
        NSInteger secondTotal = millisecond / 1000;
        
        NSInteger second = secondTotal % 60;
        NSInteger minute = secondTotal / 60;
        
        NSString *secondString;
        NSString *minuteString;
        
        if (second > 9) {
            secondString = [NSString stringWithFormat:@"%ld", (long)second];
        } else {
            secondString = [NSString stringWithFormat:@"0%ld", (long)second];
        }
        
        if (minute > 9) {
            minuteString = [NSString stringWithFormat:@"%ld", (long)minute];
        } else {
            minuteString = [NSString stringWithFormat:@"0%ld", (long)minute];
        }
        
        return [NSString stringWithFormat:@"%@:%@", minuteString, secondString];
    }
    
    
    return @"00:00";
}

+ (UIView *)findSubviewWithClassName:(NSString *)className inView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:NSClassFromString(className)]) {
            return subView;
        }
        
        UIView *result = [self findSubviewWithClassName:className inView:subView];
        if (result) {
            return result;
        }
    }
    return nil;
}

+ (void)searchBar:(UISearchBar *)searchBar setBackgroundColor:(UIColor *)color {
    UIView *searchBarBgView = [self findSubviewWithClassName:@"UISearchBarBackground" inView:searchBar];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(searchBarBgView.frame), CGRectGetHeight(searchBarBgView.frame))];
    [view setBackgroundColor:color];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [searchBarBgView addSubview:view];
}

+ (NSAttributedString *)getHighlightContent:(NSString *)content keyword:(NSString *)keyword defaultFont:(UIFont *)font textColor:(UIColor *)color {
    NSMutableAttributedString *attributedString = attributedString = [[YYIMEmojiHelper sharedInstance] attributeStringWithEmojiText:content];
    if (font) {
        [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
    }
    
    if (color) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    }
    
    if (keyword) {
        NSRange range = [content rangeOfString:keyword];
        if (range.location != NSNotFound) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor themeBlueColor] range:range];
        }
    }
    return attributedString;
}

@end
