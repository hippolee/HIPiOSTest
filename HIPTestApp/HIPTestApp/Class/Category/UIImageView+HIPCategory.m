//
//  UIImageView+HIPCategory.m
//  litfb_test
//
//  Created by litfb on 16/1/18.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "UIImageView+HIPCategory.h"
#import "HIPImageUtility.h"
#import "HIPColorHelper.h"
#import "UIImageView+WebCache.h"

#define HIP_HEAD_IMAGE_WHOLE_TAG         200
#define HIP_HEAD_IMAGE_LEFTTOP_TAG       201
#define HIP_HEAD_IMAGE_LEFTDOWN_TAG      202
#define HIP_HEAD_IMAGE_RIGHTTOP_TAG      203
#define HIP_HEAD_IMAGE_RIGHTDOWN_TAG     204
#define HIP_HEAD_IMAGE_LEFT_TAG          205
#define HIP_HEAD_IMAGE_RIGHT_TAG         206

@implementation UIImageView (HIPCategory)

- (void)setImageWithKey:(NSString *)key headCount:(NSInteger)count {
    if (count <= 0) {
        return;
    }
    NSArray *imageSrcArray = [self imageSrcArrayWithCount:count];
    [self setImageWithImageSourceArray:imageSrcArray key:key count:count];
}

- (NSArray *)imageSrcArrayWithCount:(NSInteger)count {
    NSMutableArray *array = [NSMutableArray array];
    switch (count) {
        case 1:
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            break;
        case 2:
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            break;
        case 3:
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            break;
        case 4:
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            break;
        default:
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
            break;
    }
    return array;
}


//- (NSArray *)imageSrcArrayWithCount:(NSInteger)count {
//    NSMutableArray *array = [NSMutableArray array];
//    switch (count) {
//        case 1:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            break;
//        case 2:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            break;
//        case 3:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508878.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            break;
//        case 4:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508878.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            break;
//        default:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508878.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"url", @"龍", @"name", nil]];
//            break;
//    }
//    return array;
//}

//- (NSArray *)imageSrcArrayWithCount:(NSInteger)count {
//    NSMutableArray *array = [NSMutableArray array];
//    switch (count) {
//        case 1:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            break;
//        case 2:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507800.jpg", @"url", @"龍", @"name", nil]];
//            break;
//        case 3:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507800.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508878.jpg", @"url", @"龍", @"name", nil]];
//            break;
//        case 4:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507800.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508878.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508448.jpg", @"url", @"龍", @"name", nil]];
//            break;
//        default:
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507741.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080507800.jpg", @"url", @"龍", @"name", nil]];
//            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.qqzhi.com/uploadpic/2014-09-19/080508878.jpg", @"url", @"龍", @"name", nil]];
//            break;
//    }
//    return array;
//}

- (void)setImageWithImageSourceArray:(NSArray *)imageSrcArray key:(NSString *)key count:(NSInteger)count {
    [self viewFowImageSourceArray:imageSrcArray count:count complete:^(UIImage *image, BOOL isStore) {
        if (isStore) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:key toDisk:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:image];
        });
    }];
}

- (void)viewFowImageSourceArray:(NSArray *)imageSrcArray count:(NSInteger)count complete:(void (^)(UIImage* image, BOOL isStore))complete {
    CGFloat side = 200.0f;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat separator = 2 * scale;
    CGFloat halfSide = (side - separator) / 2;
    
    NSMutableArray *imageViewArray = [NSMutableArray array];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, side, side)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:99.5f];
    
    if (count == 1) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(0, 0, side, side)];
        [view1 setContentMode:UIViewContentModeScaleAspectFill];
        [view1 setTag:HIP_HEAD_IMAGE_WHOLE_TAG];
        
        [view addSubview:view1];
        [imageViewArray addObject:view1];
    } else if (count == 2) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(0, 0, halfSide, side)];
        [view1 setContentMode:UIViewContentModeScaleAspectFill];
        [view1 setTag:HIP_HEAD_IMAGE_LEFT_TAG];
        
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(halfSide + separator, 0, halfSide, side)];
        [view2 setContentMode:UIViewContentModeScaleAspectFill];
        [view2 setTag:HIP_HEAD_IMAGE_RIGHT_TAG];
        
        [view addSubview:view1];
        [view addSubview:view2];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
    } else if (count == 3) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(0, 0, halfSide, side)];
        [view1 setContentMode:UIViewContentModeScaleAspectFill];
        [view1 setTag:HIP_HEAD_IMAGE_LEFT_TAG];
        
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(halfSide + separator, 0, halfSide, halfSide)];
        [view2 setContentMode:UIViewContentModeScaleAspectFill];
        [view2 setTag:HIP_HEAD_IMAGE_RIGHTTOP_TAG];
        
        UIImageView *view3 = [self imageViewWithFrame:CGRectMake(halfSide + separator, halfSide + separator, halfSide, halfSide)];
        [view3 setContentMode:UIViewContentModeScaleAspectFill];
        [view3 setTag:HIP_HEAD_IMAGE_RIGHTDOWN_TAG];
        
        [view addSubview:view1];
        [view addSubview:view2];
        [view addSubview:view3];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
        [imageViewArray addObject:view3];
    } else if (count >= 4) {
        UIImageView *view1 = [self imageViewWithFrame:CGRectMake(0, 0, halfSide, halfSide)];
        [view1 setContentMode:UIViewContentModeScaleAspectFill];
        [view1 setTag:HIP_HEAD_IMAGE_LEFTTOP_TAG];
        
        UIImageView *view2 = [self imageViewWithFrame:CGRectMake(0, halfSide + separator, halfSide, halfSide)];
        [view2 setContentMode:UIViewContentModeScaleAspectFill];
        [view2 setTag:HIP_HEAD_IMAGE_LEFTDOWN_TAG];
        
        UIImageView *view3 = [self imageViewWithFrame:CGRectMake(halfSide + separator, 0, halfSide, halfSide)];
        [view3 setContentMode:UIViewContentModeScaleAspectFill];
        [view3 setTag:HIP_HEAD_IMAGE_RIGHTTOP_TAG];
        
        UIImageView *view4 = [self imageViewWithFrame:CGRectMake(halfSide + separator, halfSide + separator, halfSide, halfSide)];
        [view4 setContentMode:UIViewContentModeScaleAspectFill];
        [view4 setTag:HIP_HEAD_IMAGE_RIGHTDOWN_TAG];
        
        [view addSubview:view1];
        [view addSubview:view2];
        [view addSubview:view3];
        [view addSubview:view4];
        
        [imageViewArray addObject:view1];
        [imageViewArray addObject:view2];
        [imageViewArray addObject:view3];
        [imageViewArray addObject:view4];
    }
    
    __block int completed = 0;
    __block BOOL isStore = YES;
    for (int i = 0; i < imageViewArray.count; i++) {
        UIImageView *imageView = [imageViewArray objectAtIndex:i];
        
        // 头像url
        NSString *imageRes;
        // 群组成员
        //        YYChatGroupMember *member;
        //        if (i < imageSrcArray.count) {
        //            member = [imageSrcArray objectAtIndex:i];
        //            imageRes = [member getMemberPhoto];
        //        }
        //
        //        if ([imageRes rangeOfString:DEFAULT_AVATAR_URL].location != NSNotFound) {
        //            imageRes = nil;
        //        }
        NSDictionary *dic;
        if (i < imageSrcArray.count) {
            dic = [imageSrcArray objectAtIndex:i];
            imageRes = [dic valueForKey:@"url"];
        }
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageRes] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                //                if (![member user]) {
                //                    isStore = NO;
                //                }
                NSString *name = [dic valueForKey:@"name"];
                if ([name length] > 0) {
                    image = [HIPImageUtility imageWithDispName2:name];
                    
                    NSUInteger tag = [imageView tag];
                    switch (tag) {
                        case HIP_HEAD_IMAGE_LEFTTOP_TAG:
                            [imageView setImage:[self getSubImage:image rect:CGRectMake(12 * scale, 12 * scale, 30 * scale, 30 * scale)]];
                            break;
                        case HIP_HEAD_IMAGE_LEFTDOWN_TAG:
                            [imageView setImage:[self getSubImage:image rect:CGRectMake(12 * scale, 18 * scale, 30 * scale, 30 * scale)]];
                            break;
                        case HIP_HEAD_IMAGE_RIGHTTOP_TAG:
                            [imageView setImage:[self getSubImage:image rect:CGRectMake(18 * scale, 12 * scale, 30 * scale, 30 * scale)]];
                            break;
                        case HIP_HEAD_IMAGE_RIGHTDOWN_TAG:
                            [imageView setImage:[self getSubImage:image rect:CGRectMake(18 * scale, 18 * scale, 30 * scale, 30 * scale)]];
                            break;
                        case HIP_HEAD_IMAGE_LEFT_TAG:
                            [imageView setImage:[self getSubImage:image rect:CGRectMake(12 * scale, 0, 30 * scale, 60 * scale)]];
                            break;
                        case HIP_HEAD_IMAGE_RIGHT_TAG:
                            [imageView setImage:[self getSubImage:image rect:CGRectMake(18 * scale, 0, 30 * scale, 60 * scale)]];
                            break;
                        default:
                            [imageView setImage:image];
                            break;
                    }
                } else {
                    image = [UIImage imageNamed:@"icon_head"];
                    [imageView setImage:image];
                }
            }
            
            completed++;
            if (completed == imageViewArray.count) {
                complete([HIPImageUtility convertViewToImage:view], isStore);
            }
            //            if (!image) {
            //                if (![member user]) {
            //                    isStore = NO;
            //                }
            //                if ([[member memberName] length] > 0) {
            //                    image = [UIImage imageWithYYIMDispName:member.memberName];
            //                } else {
            //                    image = [UIImage imageNamed:@"icon_head"];
            //                }
            //                [imageView setImage:image];
            //            }
            //
            //            completed++;
            //            if (completed == imageViewArray.count) {
            //                complete([UIImage convertViewToImage:view], isStore);
            //            }
        }];
    }
}

- (UIImage*)getSubImage:(UIImage *)image rect:(CGRect)rect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

//- (UIImageView *)imageViewWithFrame:(CGRect)frame radius:(CGFloat)radius {
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
//    CALayer *layer = [imageView layer];
//    [layer setMasksToBounds:YES];
//    [layer setCornerRadius:radius];
//    return imageView;
//}

- (UIImageView *)imageViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    CALayer *layer = [imageView layer];
    [layer setMasksToBounds:YES];
    return imageView;
}

- (UIView *)numberViewWithFrame:(CGRect)frame count:(NSInteger)count radius:(CGFloat)radius {
    UIView *view = [[UIImageView alloc] initWithFrame:frame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/8, CGRectGetHeight(frame)/8, CGRectGetWidth(frame) * 3/4, CGRectGetHeight(frame) * 3/4)];
    [label setText:[NSString stringWithFormat:@"%ld", (long)count]];
    [label setFont:[UIFont systemFontOfSize:radius]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xbfcdd9)];
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
