//
//  AssetViewController.h
//  YonyouIM
//
//  Created by litfb on 15/7/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsGroupViewController.h"
#import "BaseViewController.h"

@interface AssetViewController : BaseViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (retain, nonatomic) ALAssetsGroup *assetsGroup;

@property (weak, nonatomic) id<YYIMAssetDelegate> delegate;

@end
