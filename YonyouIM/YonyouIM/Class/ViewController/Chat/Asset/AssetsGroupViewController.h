//
//  AssetsGroupViewController.h
//  YonyouIM
//
//  Created by litfb on 15/2/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol YYIMAssetDelegate;

@interface AssetsGroupViewController : BaseViewController

@property (weak, nonatomic) id<YYIMAssetDelegate> delegate;

@end

@protocol YYIMAssetDelegate <NSObject>

@required

- (void)didSelectAssets:(NSArray *)assets isOriginal:(BOOL)isOriginal;

@end