//
//  ChatImageBrowserController.h
//  YonyouIM
//
//  Created by litfb on 16/3/17.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatImageBrowserController : UIViewController

@property (assign, nonatomic) BOOL isVisible;

@property (retain, nonatomic) NSArray *imageSourceArray;

@property (assign, nonatomic) NSInteger imageIndex;

- (void)reloadData;

@end
