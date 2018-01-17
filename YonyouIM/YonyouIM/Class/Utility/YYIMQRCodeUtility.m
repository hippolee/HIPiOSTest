//
//  YYIMQRCodeUtility.m
//  YonyouIM
//
//  Created by litfb on 16/1/13.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMQRCodeUtility.h"
#import "YYIMResourceUtility.h"
#import "YYIMUtility.h"
#import "WebViewController.h"
#import "ChatViewController.h"
#import "GroupScanViewController.h"
#import "GroupQRCCodeAlreadyFullViewController.h"
#import "GroupQRCCodeExpiredViewController.h"

@implementation YYIMQRCodeUtility

+ (CIImage *)createQRCodeImageWithSource:(NSString *)source {
    // source data
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    // filter
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    // 设置纠错等级越高；即识别越容易，值可设置为L(Low) |  M(Medium) | Q | H(High)
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    return filter.outputImage;
}

+ (CIImage *)recolorQRCodeImage:(CIImage *)image withForegroundColor:(UIColor *)fColor backgroundColor:(UIColor *)bColor {
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",image,
                             @"inputColor0",[CIColor colorWithCGColor:fColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:bColor.CGColor],
                             nil];
    
    return colorFilter.outputImage;
}

+ (UIImage *)resizeQRCodeImage:(CIImage *)image withDimension:(CGFloat)dimension {
    // 绘制
    CGSize size = CGSizeMake(dimension, dimension);
    // cgImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    return outputImage;
}

+ (UIImage *)createQRCodeImageWithSource:(NSString *)source dimension:(CGFloat)dimension {
    // CIImage
    CIImage *ciImage = [self createQRCodeImageWithSource:source];
    // resize
    return [self resizeQRCodeImage:ciImage withDimension:dimension];
}

+ (UIImage *)createQRCodeImageWithSource:(NSString *)source foregroundColor:(UIColor *)fColor backgroundColor:(UIColor *)bColor dimension:(CGFloat)dimension {
    // CIImage
    CIImage *ciImage = [self createQRCodeImageWithSource:source];
    // recolor
    ciImage = [self recolorQRCodeImage:ciImage withForegroundColor:fColor backgroundColor:bColor];
    // resize
    return [self resizeQRCodeImage:ciImage withDimension:dimension];
}

+ (UIImage *)decorateQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon iconSize:(CGSize)iconSize {
    // image size
    CGFloat widthOfImage = image.size.width;
    CGFloat heightOfImage = image.size.height;
    // icon size
    CGFloat widthOfIcon = iconSize.width;
    CGFloat heightOfIcon = iconSize.height;
    // icon background size
    CGFloat widthOfIconBack = widthOfIcon + 4;
    CGFloat heightOfIconBack = heightOfIcon + 4;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    // draw image
    [image drawInRect:CGRectMake(0, 0, widthOfImage, heightOfImage)];
    // draw icon background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, CGRectMake((widthOfImage - widthOfIconBack) / 2, (heightOfImage - heightOfIconBack) / 2, widthOfIconBack, heightOfIconBack));
    CGContextFillPath(context);
    // draw icon
    [icon drawInRect:CGRectMake((widthOfImage - widthOfIcon) / 2, (heightOfImage - heightOfIcon) / 2, widthOfIcon, heightOfIcon)];
    // output image
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

+ (UIImage *)decorateQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon scale:(CGFloat)scale {
    // image size
    CGFloat widthOfImage = image.size.width;
    CGFloat heightOfImage = image.size.height;
    // icon background size
    CGFloat widthOfIconBack = widthOfImage * scale;
    CGFloat heightOfIconBack = heightOfImage * scale;
    // icon size
    CGFloat widthOfIcon = widthOfIconBack - 4;
    CGFloat heightOfIcon = heightOfIconBack - 4;
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    // draw image
    [image drawInRect:CGRectMake(0, 0, widthOfImage, heightOfImage)];
    // draw icon background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, CGRectMake((widthOfImage - widthOfIconBack) / 2, (heightOfImage - heightOfIconBack) / 2, widthOfIconBack, heightOfIconBack));
    CGContextFillPath(context);
    // draw icon
    [icon drawInRect:CGRectMake((widthOfImage - widthOfIcon) / 2, (heightOfImage - heightOfIcon) / 2, widthOfIcon, heightOfIcon)];
    // output image
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

+ (ZXResult *)attemptScanQRCodeImage:(UIImage *)image {
    for (int i = 0; i < 5; i++) {
        CGFloat side = 720.0f - i * 120.0f;
        
        UIImage *thumbImage = [YYIMResourceUtility thumbImage:image maxSide:side];
        ZXResult *result = [self scanQRCodeImage:thumbImage];
        
        if (result) {
            return result;
        }
    }
    return nil;
}

+ (ZXResult *)scanQRCodeImage:(UIImage *)image {
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    [hints setTryHarder:YES];
    [hints setPureBarcode:NO];
    [hints addPossibleFormat:kBarcodeFormatQRCode];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:&error];
    if (!result) {
        NSLog(@"scan error:%@", [error localizedDescription]);
    }
    return result;
}

+ (void)dealQrCodeWithText:(NSString *)qrCodeText atVC:(UIViewController *)controller closeVC:(BOOL)isClose {
    NSString *qrCodeStr = [YYIMUtility decodeFromEscapeString:qrCodeText];
    NSURL *url = [NSURL URLWithString:qrCodeStr];
    if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]) {
        WebViewController *webViewController = [[WebViewController alloc] init];
        [webViewController setUrlString:qrCodeStr];
        
        if (isClose) {
            [YYIMUtility pushFromController:controller toController:webViewController];
        } else {
            [controller.navigationController pushViewController:webViewController animated:YES];
        }
    } else if ([[url scheme] isEqualToString:@"yyim"]) {
        [[YYIMChat sharedInstance].chatManager getChatGroupInfoWithQrCode:qrCodeStr complete:^(BOOL result, YYChatGroupInfo *groupInfo, YYIMError *error) {
            if (result) {
                if (![groupInfo isValidGroup]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:@"非本应用群组二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    if (isClose) {
                        [controller.navigationController popViewControllerAnimated:YES];
                    }
                } else if ([groupInfo isJoindGroup]) {
                    ChatViewController *chatViewController = [[ChatViewController alloc] init];
                    [chatViewController setChatId:[[groupInfo group] groupId]];
                    [chatViewController setChatType:YM_MESSAGE_TYPE_GROUPCHAT];
                    
                    if (isClose) {
                        [YYIMUtility pushFromController:controller toController:chatViewController];
                    } else {
                        [controller.navigationController pushViewController:chatViewController animated:YES];
                    }
                } else if (groupInfo.group.memberCount >= groupInfo.maxMemberCount) {
                    //如果当前成员数量已经大于了群组上限，弹出成员已满的界面。
                    GroupQRCCodeAlreadyFullViewController *groupQRCCodeAlreadyFullViewController = [[GroupQRCCodeAlreadyFullViewController alloc] init];
                    groupQRCCodeAlreadyFullViewController.groupInfo = groupInfo;
                    
                    if (isClose) {
                        [YYIMUtility pushFromController:controller toController:groupQRCCodeAlreadyFullViewController];
                    } else {
                        [controller.navigationController pushViewController:groupQRCCodeAlreadyFullViewController animated:YES];
                    }
                } else {
                    GroupScanViewController *groupScanViewController = [[GroupScanViewController alloc] initWithNibName:@"GroupScanViewController" bundle:nil];
                    [groupScanViewController setGroupInfo:groupInfo];
                    
                    if (isClose) {
                        [YYIMUtility pushFromController:controller toController:groupScanViewController];
                    } else {
                        [controller.navigationController pushViewController:groupScanViewController animated:YES];
                    }
                }
            } else {
                if (error.errorCode == YMERROR_CODE_CHATGROUP_EXPIRED) {
                    //弹出二维码已经过期的界面
                    GroupQRCCodeExpiredViewController *groupQRCCodeExpiredViewController = [[GroupQRCCodeExpiredViewController alloc] init];
                    
                    if (isClose) {
                        groupQRCCodeExpiredViewController.needReturnScan = YES;
                        [YYIMUtility pushFromController:controller toController:groupQRCCodeExpiredViewController];
                    } else {
                        groupQRCCodeExpiredViewController.needReturnScan = NO;
                        [controller.navigationController pushViewController:groupQRCCodeExpiredViewController animated:YES];
                    }
                } else if (error.errorCode == YMERROR_CODE_CHATGROUP_UNEXIST) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:@"群组已被删除" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    if (isClose) {
                        [controller.navigationController popViewControllerAnimated:YES];
                    }
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:@"获取二维码信息失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    if (isClose) {
                        [controller.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:qrCodeStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        if (isClose) {
            [controller.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
