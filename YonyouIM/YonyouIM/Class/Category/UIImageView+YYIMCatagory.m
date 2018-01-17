//
//  UIImageView+YYIMCatagory.m
//  YonyouIM
//
//  Created by litfb on 15/4/22.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UIImageView+YYIMCatagory.h"
#import "YYIMChatHeader.h"
#import "SDWebImagePrefetcher.h"
#import "SDImageCache.h"
#import "UIColor+YYIMTheme.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMUtility.h"
#import "YYIMColorHelper.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (YYIMCatagory)

- (void)ym_setImageWithGroupId:(NSString *)groupId placeholderImage:(UIImage *)placeholder {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:groupId];
    if (image) {
        self.image = image;
        return;
    }
    
    if (placeholder && !self.image) {
        self.image = placeholder;
    }
    
    YYChatGroup *chatGroup = [[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:groupId];
    NSArray *memberArray = [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:groupId limit:4];
    NSMutableArray *imageMemberArray = [NSMutableArray array];
    
    // 群组总人数
    NSInteger memberCount = [chatGroup memberCount];
    if (memberCount <= 0) {
        self.image = [UIImage imageNamed:@"icon_chatgroup"];
        return;
    } else {
        for (int i = 0; i < fmin(memberArray.count, 4); i++) {
            YYChatGroupMember *member = memberArray[i];
            [imageMemberArray addObject:member];
        }
    }
    [self setImageWithImageSourceArray:imageMemberArray groupId:groupId memberCount:memberCount];
}

- (void)ym_setImageWithGroupInfo:(YYChatGroupInfo *)groupInfo placeholderImage:(UIImage *)placeholder {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[groupInfo group] groupId]];
    if (image) {
        self.image = image;
        return;
    }
    
    if (placeholder && !self.image) {
        self.image = placeholder;
    }
    
    YYChatGroup *chatGroup = [groupInfo group];
    NSArray *memberArray = [groupInfo memberArray];
    NSMutableArray *imageMemberArray = [NSMutableArray array];
    
    // 群组总人数
    NSInteger memberCount = [chatGroup memberCount];
    if (memberCount <= 0) {
        self.image = [UIImage imageNamed:@"icon_chatgroup"];
        return;
    } else {
        for (int i = 0; i < fmin(memberArray.count, 4); i++) {
            YYChatGroupMember *member = memberArray[i];
            [imageMemberArray addObject:member];
        }
    }
    [self setImageWithImageSourceArray:imageMemberArray groupId:[[groupInfo group] groupId] memberCount:memberCount];
}

- (void)setImageWithImageSourceArray:(NSArray *)imageSrcArray groupId:(NSString *)groupId memberCount:(NSInteger)count {
    [self viewFowImageSourceArray:imageSrcArray count:count complete:^(UIImage *image, BOOL isStore) {
        if (isStore) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:groupId toDisk:YES];
        }
        [self setImage:image];
    }];
}

- (void)viewFowImageSourceArray:(NSArray *)imageSrcArray count:(NSInteger)count complete:(void (^)(UIImage* image, BOOL isStore))complete {
    CGFloat side = 200.0f;
    NSMutableArray *imageViewArray = [NSMutableArray array];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, side, side)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    CGFloat radius = side / 4;
    if (count == 1) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(0, 0, side, side) radius:radius * 2];
        [view addSubview:view1];
        [imageViewArray addObject:view1];
    } else if (count == 2) {
        CGFloat x = side / 4 - side / (4 * sqrt(2));
        CGFloat y = side / 4 - side / (4 * sqrt(2));
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(x, y, side / 2, side / 2) radius:radius];
        
        x = side / 4 + side / (4 * sqrt(2));
        y = side / 4 + side / (4 * sqrt(2));
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(x, y, side / 2, side / 2) radius:radius];
        
        [view addSubview:view1];
        [view addSubview:view2];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
    } else if (count == 3) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(side / 4, 2 * side / 4 - sqrt(3) * side / 4, side / 2, side / 2) radius:radius];
        
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(0, side / 2, side / 2, side / 2) radius:radius];
        
        UIImageView *view3 = [self imageViewWithFrame:CGRectMake(side / 2, side / 2, side / 2, side / 2) radius:radius];
        
        [view addSubview:view1];
        [view addSubview:view2];
        [view addSubview:view3];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
        [imageViewArray addObject:view3];
    } else if (count >= 4) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(0, 0, side / 2, side / 2) radius:radius];
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(side / 2, 0, side / 2, side / 2) radius:radius];
        UIImageView *view3 = [self imageViewWithFrame:CGRectMake(0, side / 2, side / 2, side / 2) radius:radius];
        
        [view addSubview:view1];
        [view addSubview:view2];
        [view addSubview:view3];
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
        [imageViewArray addObject:view3];
        
//        if (count > 4) {
//            UIView *view4 = [self numberViewWithFrame:CGRectMake(side / 2, side / 2, side / 2, side / 2) count:count radius:radius];
//            [view addSubview:view4];
//        } else {
            UIImageView *view4 = [self imageViewWithFrame:CGRectMake(side / 2, side / 2, side / 2, side / 2) radius:radius];
            [view addSubview:view4];
            [imageViewArray addObject:view4];
//        }
    }
    
    __block int completed = 0;
    for (int i = 0; i < imageViewArray.count; i++) {
        UIImageView *imageView = [imageViewArray objectAtIndex:i];
        
        // 头像url
        NSString *imageRes;
        // 群组成员
        YYChatGroupMember *member;
        if (i < imageSrcArray.count) {
            member = [imageSrcArray objectAtIndex:i];
            imageRes = [member getMemberPhoto];
        }
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageRes] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            BOOL isStore = YES;
            if (!image) {
                if (![member user]) {
                    isStore = NO;
                }
                if ([[member memberName] length] > 0) {
                    image = [UIImage imageWithDispName:[member memberName]];
                } else {
                    image = [UIImage imageNamed:@"icon_head"];
                }
                [imageView setImage:image];
            }
            
            completed++;
            if (completed == imageViewArray.count) {
                complete([UIImage convertViewToImage:view], isStore);
            }
        }];
    }
}

- (UIImageView *)imageViewWithFrame:(CGRect)frame radius:(CGFloat)radius {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    CALayer *layer = [imageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    return imageView;
}

- (UIView *)numberViewWithFrame:(CGRect)frame count:(NSInteger)count radius:(CGFloat)radius {
    UIView *view = [[UIImageView alloc] initWithFrame:frame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/8, CGRectGetHeight(frame)/8, CGRectGetWidth(frame) * 3/4, CGRectGetHeight(frame) * 3/4)];
    [label setText:[NSString stringWithFormat:@"%ld", (long)count]];
    [label setFont:[UIFont systemFontOfSize:40]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xd5564f)];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    return view;
}

@end
