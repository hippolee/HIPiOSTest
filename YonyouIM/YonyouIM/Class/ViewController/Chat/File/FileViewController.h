//
//  FileViewController.h
//  YonyouIM
//
//  Created by litfb on 15/3/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol YYIMFileDelegate;

@interface FileViewController : BaseViewController

@property (weak, nonatomic) id<YYIMFileDelegate> delegate;

@end

@protocol YYIMFileDelegate <NSObject>

@required

- (void)forwardFile:(NSString *)messagePid;

@end