//
//  ChatMicroVideoBrowserController.h
//  YonyouIM
//
//  Created by litfb on 16/3/17.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMicroVideoBrowserController : UIViewController

@property (assign, nonatomic) BOOL isVisible;

@property (retain, nonatomic) NSArray *videoSourceArray;

@property (assign, nonatomic) NSInteger videoIndex;

- (void)reloadData;

@end
