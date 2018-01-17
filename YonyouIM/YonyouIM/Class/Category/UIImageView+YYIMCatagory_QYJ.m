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
    NSArray *memberArray = [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:groupId limit:5];
    NSMutableArray *imageMemberArray = [NSMutableArray array];
    
    // 群组总人数
    NSInteger memberCount = [chatGroup memberCount];
    if (memberCount <= 1) {
        self.image = [UIImage imageNamed:@"icon_chatgroup"];
        return;
    } else {
        for (int i = 0; i < fmin(memberArray.count, 5); i++) {
            YYChatGroupMember *member = memberArray[i];
            if ([[member memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                continue;
            }
            [imageMemberArray addObject:member];
        }
    }
    [self setImageWithImageSourceArray:imageMemberArray groupId:groupId memberCount:memberCount];
}

- (void)setImageWithImageSourceArray:(NSArray *)imageSrcArray groupId:(NSString *)groupId memberCount:(NSInteger)count {
    [self viewFowImageSourceArray:imageSrcArray count:count complete:^(UIImage *image) {
        [[SDImageCache sharedImageCache] storeImage:image forKey:groupId toDisk:YES];
        [self setImage:image];
    }];
}

- (void)viewFowImageSourceArray:(NSArray *)imageSrcArray count:(NSInteger)count complete:(void (^)(UIImage* image))complete {
    CGFloat side = 200.0f;
    NSMutableArray *imageViewArray = [NSMutableArray array];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, side, side)];
    [view setBackgroundColor:[UIColor clearColor]];
    if (count == 2) {
        CGFloat imageBorder = 4.0f;
        CGFloat bgSide = side;
        CGFloat imageSide = bgSide - imageBorder * 2;
        
        UIView *bgView1 = [self backgroundViewWithFrame:CGRectMake(0, 0, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(imageBorder, imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        [view addSubview:bgView1];
        [view addSubview:view1];
        
        [imageViewArray addObject:view1];
    } else if (count == 3) {
        CGFloat imageBorder = 6.0f;
        CGFloat bgSide = side * 16.0f / 25.0f;
        CGFloat imageSide = bgSide - imageBorder * 2;
        
        CGFloat bgx = 0;
        CGFloat bgy = side * 9.0f / 25.0f;
        
        UIView *bgView1 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        bgx = side * 9.0f / 25.0f;
        bgy = 0;
        
        UIView *bgView2 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        [view addSubview:bgView1];
        [view addSubview:view1];
        [view addSubview:bgView2];
        [view addSubview:view2];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
    } else if (count == 4) {
        CGFloat imageBorder = 6.0f;
        CGFloat bgSide = side * 3.0f / 5.0f;
        CGFloat imageSide = bgSide - imageBorder * 2;
        
        CGFloat bgx = 0;
        CGFloat bgy = side * 2.0f / 5.0f;
        
        UIView *bgView1 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        bgx = side * 2.0f / 5.0f;
        bgy = side * 2.0f / 5.0f;
        
        UIView *bgView2 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        bgx = side / 5.0f;
        bgy = 0.0f;
        
        UIView *bgView3 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view3 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        [view addSubview:bgView1];
        [view addSubview:view1];
        [view addSubview:bgView2];
        [view addSubview:view2];
        [view addSubview:bgView3];
        [view addSubview:view3];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
        [imageViewArray addObject:view3];
    } else {
        CGFloat imageBorder = 4.0f;
        CGFloat bgSide = side / 2.0f;
        CGFloat imageSide = bgSide - imageBorder * 2;
        
        CGFloat bgx = 0;
        CGFloat bgy = 0;
        
        UIView *bgView1 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        bgx = side / 2.0f;
        bgy = 0.0f;
        
        UIView *bgView2 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        bgx = 0.0f;
        bgy = side / 2.0f;
        
        UIView *bgView3 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIImageView *view3 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        
        bgx = side / 2.0f;
        bgy = side / 2.0f;
        
        UIView *bgView4 = [self backgroundViewWithFrame:CGRectMake(bgx, bgy, bgSide, bgSide) radius:bgSide / 2];
        UIView *view4;
        if (count > 5) {
            view4 = [self numberViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) count:count radius:imageSide / 2];
        } else {
            view4 = [self imageViewWithFrame:CGRectMake(bgx + imageBorder, bgy + imageBorder, imageSide, imageSide) radius:imageSide / 2];
        }
        
        [view addSubview:bgView1];
        [view addSubview:view1];
        [view addSubview:bgView2];
        [view addSubview:view2];
        [view addSubview:bgView3];
        [view addSubview:view3];
        [view addSubview:bgView4];
        [view addSubview:view4];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
        [imageViewArray addObject:view3];
        if (count == 5) {
            [imageViewArray addObject:view4];
        }
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
            if (!image) {
                if ([[member user] userName]) {
                    image = [UIImage imageWithDispName:[[member user] userName]];
                } else {
                    image = [UIImage imageNamed:@"icon_head"];
                }
                [imageView setImage:image];
            }
            
            completed++;
            if (completed == imageViewArray.count) {
                complete([UIImage convertViewToImage:view]);
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
    [label setFont:[UIFont systemFontOfSize:36]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xd5564f)];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    return view;
}

- (UIView *)backgroundViewWithFrame:(CGRect)frame radius:(CGFloat)radius {
    UIView *view = [[UIImageView alloc] initWithFrame:frame];
    [view setBackgroundColor:[UIColor whiteColor]];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    return view;
}

@end
