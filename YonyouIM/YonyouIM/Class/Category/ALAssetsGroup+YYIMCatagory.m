//
//  ALAssetsGroup+YYIMCatagory.m
//  YonyouIM
//
//  Created by yanghaoc on 15/12/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ALAssetsGroup+YYIMCatagory.h"

@implementation ALAssetsGroup (YYIMCatagory)

- (NSInteger)getPhotoCount {
    __block NSInteger count = 0;
    
    [self enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result && [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            count++;
        }
    }];
    
    return count;
}

-(NSArray *)getPhotoArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self numberOfAssets]];
    
    [self enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            [array addObject:asset];
        }
    }];
    
    if (array.count > 0) {
        return [NSArray arrayWithArray:array];
    } else {
        return [NSArray array];
    }
}

@end
