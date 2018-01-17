//
//  UIImage+YYIMCategory.m
//  YonyouIM
//
//  Created by litfb on 15/6/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UIImage+YYIMCategory.h"
#import "YYIMUtility.h"
#import "YYIMFirstLetterHelper.h"
#import "YYIMColorHelper.h"
#import "SDImageCache.h"

@implementation UIImage (YYIMCategory)

+ (UIImage *)convertViewToImage:(UIView*)view {
    CGSize s = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithDispName:(NSString *)name {
    if (!name) {
        name = @"";
    }
    
    NSString *dispName;
    if ([name length] > 2) {
        NSRegularExpression *regexSingle = [NSRegularExpression regularExpressionWithPattern:@"^([a-z0-9A-Z]+\\s?)*[a-z0-9A-Z]+$" options:0 error:nil];
        NSTextCheckingResult *matchEnglish = [regexSingle firstMatchInString:name options:0 range:NSMakeRange(0, [name length])];
        
        if (matchEnglish) {
            dispName = [name substringToIndex:2];
        } else {
            dispName = [name substringFromIndex:[name length] - 2];
        }
    } else {
        dispName = name;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:dispName];
    if (image) {
        return image;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    if ([YYIMUtility isEmptyString:dispName]) {
        [view setBackgroundColor:[[YYIMColorHelper sharedInstance] colorForLetter:@"#"]];
    } else {
    	NSString *firstLetter = [YYIMFirstLetterHelper firstLetterIncludeNumber:dispName];
    	[view setBackgroundColor:[[YYIMColorHelper sharedInstance] colorForLetter:[firstLetter lowercaseString]]];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 60, 30)];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [label setText:dispName];
    [label setFont:[UIFont systemFontOfSize:18.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:29];
    image = [UIImage convertViewToImage:view];
    [[SDImageCache sharedImageCache] storeImage:image forKey:dispName toDisk:NO];
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color coreIcon:(NSString *)imageName {
    if (!color) {
        color = [UIColor redColor];;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[NSString stringWithFormat:@"%@_%@", imageName, @"color"]];
    
    if (image) {
        return image;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [view setBackgroundColor:color];
   
    UIImageView *coreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 24, 24)];
    [coreImageView setImage:[UIImage imageNamed:imageName]];
    [coreImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view addSubview:coreImageView];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:29];
    image = [UIImage convertViewToImage:view];
    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_%@", imageName, @"color"] toDisk:NO];
    return image;
}

+ (UIImage *)imageWithDispName:(NSString *)name coreIcon:(NSString *)imageName {
    if (!name) {
        name = @"";
    }
    
    NSString *dispName;
    if ([name length] > 2) {
        dispName = [name substringFromIndex:[name length] - 2];
    } else {
        dispName = name;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[NSString stringWithFormat:@"%@_%@", imageName, dispName]];
    if (image) {
        return image;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    if ([YYIMUtility isEmptyString:dispName]) {
        [view setBackgroundColor:[[YYIMColorHelper sharedInstance] colorForLetter:@"#"]];
    } else {
    	NSString *firstLetter = [YYIMFirstLetterHelper firstLetterIncludeNumber:dispName];
    	[view setBackgroundColor:[[YYIMColorHelper sharedInstance] colorForLetter:[firstLetter lowercaseString]]];
    }
    
    UIImageView *coreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 24, 24)];
    [coreImageView setImage:[UIImage imageNamed:imageName]];
    [coreImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view addSubview:coreImageView];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:29];
    image = [UIImage convertViewToImage:view];
    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_%@", imageName, dispName] toDisk:NO];
    return image;
}

+ (UIImage*)gaussBlurWithImage:(UIImage *)image {
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : [NSNumber numberWithBool:YES]}];
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    // create gaussian blur filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:10.0] forKey:kCIInputRadiusKey];
    // blur image
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}

@end
