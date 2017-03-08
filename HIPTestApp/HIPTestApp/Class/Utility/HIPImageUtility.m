//
//  HIPImageUtility.m
//  litfb_test
//
//  Created by litfb on 16/1/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPImageUtility.h"
#import "HIPUtility.h"
#import "HIPStringUtility.h"
#import "HIPColorHelper.h"
#import "UIImageView+WebCache.h"

@implementation HIPImageUtility

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)thumbImage:(UIImage *)srcImage maxSide:(CGFloat)maxSide {
    if (srcImage.size.width <= maxSide && srcImage.size.height <= maxSide) {
        return srcImage;
    }
    // 原图尺寸
    CGSize imageSize = srcImage.size;
    CGRect rect;
    if (imageSize.width/imageSize.height < 1) {
        rect.size.width = maxSide * imageSize.width / imageSize.height;
        rect.size.height = maxSide;
        rect.origin.x = 0;
        rect.origin.y = 0;
    } else {
        rect.size.width = maxSide;
        rect.size.height = maxSide * imageSize.height / imageSize.width;
        rect.origin.x = 0;
        rect.origin.y = 0;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(rect);
    [srcImage drawInRect:rect];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbImage;
}

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
    
    if ([HIPStringUtility isEmpty:dispName]) {
        [view setBackgroundColor:[[HIPColorHelper sharedInstance] colorForLetter:@"#"]];
    } else {
        NSString *firstLetter = [HIPStringUtility firstLetterIncludeNumber:dispName];
        [view setBackgroundColor:[[HIPColorHelper sharedInstance] colorForLetter:[firstLetter lowercaseString]]];
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
    image = [HIPImageUtility convertViewToImage:view];
    [[SDImageCache sharedImageCache] storeImage:image forKey:dispName toDisk:NO];
    return image;
}

+ (UIImage *)imageWithDispName2:(NSString *)name {
    if (!name) {
        name = @"";
    }
    
    NSString *dispName;
    if ([name length] > 1) {
        NSRegularExpression *regexSingle = [NSRegularExpression regularExpressionWithPattern:@"^([a-z0-9A-Z]+\\s?)*[a-z0-9A-Z]+$" options:0 error:nil];
        NSTextCheckingResult *matchEnglish = [regexSingle firstMatchInString:name options:0 range:NSMakeRange(0, [name length])];
        
        if (matchEnglish) {
            dispName = [name substringToIndex:1];
        } else {
            dispName = [name substringFromIndex:[name length] - 1];
        }
    } else {
        dispName = name;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:dispName];
    if (image) {
        return image;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    if ([HIPStringUtility isEmpty:dispName]) {
        [view setBackgroundColor:[[HIPColorHelper sharedInstance] colorForLetter:@"#"]];
    } else {
        NSString *firstLetter = [HIPStringUtility firstLetterIncludeNumber:dispName];
        [view setBackgroundColor:[[HIPColorHelper sharedInstance] colorForLetter:[firstLetter lowercaseString]]];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 60, 30)];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [label setText:dispName];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    //    CALayer *layer = [view layer];
    //    [layer setMasksToBounds:YES];
    //    [layer setCornerRadius:29];
    image = [HIPImageUtility convertViewToImage:view];
    [[SDImageCache sharedImageCache] storeImage:image forKey:dispName toDisk:NO];
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
    
    if ([HIPStringUtility isEmpty:dispName]) {
        [view setBackgroundColor:[[HIPColorHelper sharedInstance] colorForLetter:@"#"]];
    } else {
        NSString *firstLetter = [HIPStringUtility firstLetterIncludeNumber:dispName];
        [view setBackgroundColor:[[HIPColorHelper sharedInstance] colorForLetter:[firstLetter lowercaseString]]];
    }
    
    UIImageView *coreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 24, 24)];
    [coreImageView setImage:[UIImage imageNamed:imageName]];
    [coreImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view addSubview:coreImageView];
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:29];
    image = [HIPImageUtility convertViewToImage:view];
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

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGFloat)size power:(CGFloat)power {
    CGRect rect = CGRectMake(0.0f, 0.0f, size, size);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextAddArc(context, size / 2, size / 2, size / 40 * power, 0, 2 * M_PI, 0);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
