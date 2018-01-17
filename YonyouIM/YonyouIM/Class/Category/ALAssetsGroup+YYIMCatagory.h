//
//  ALAssetsGroup+YYIMCatagory.h
//  YonyouIM
//
//  Created by yanghaoc on 15/12/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsGroup (YYIMCatagory)

/**
 *  获得资源组的实际图片数量
 *
 *  @return 实际图片数量
 */
- (NSInteger)getPhotoCount;

/**
 *  获得资源组的图片数组
 *
 *  @return 图片数组
 */
-(NSArray *)getPhotoArray;

@end
