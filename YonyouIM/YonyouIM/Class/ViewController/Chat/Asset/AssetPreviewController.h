//
//  AssetPreviewController.h
//  YonyouIM
//
//  Created by litfb on 15/4/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AssetsGroupViewController.h"

@interface AssetPreviewController : BaseViewController

@property (weak, nonatomic) id<YYIMAssetDelegate> delegate;

@property (nonatomic) NSInteger imageIndex;

@property (retain, nonatomic) NSArray *imageSourceArray;

@property (retain, nonatomic) NSMutableArray *selectedArray;

@end
