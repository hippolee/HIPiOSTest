//
//  YYIMResourceUtility.m
//  YonyouIM
//
//  Created by litfb on 15/2/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMResourceUtility.h"
#import "YYIMDefs.h"
#import "YYIMStringUtility.h"
#import "YMVoiceConverter.h"
#import "YYMessage.h"
#import "YYIMJUMPHelper.h"
#import "YYIMConfig.h"
#import "YYIMHttpUtility.h"
#import "YYIMLogger.h"
#import "YYIMStringUtility.h"
#import <ImageIO/ImageIO.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation YYIMResourceUtility

+ (AVAudioRecorder *)createAudioRecorder {
    NSDictionary *settings = @{AVSampleRateKey:@8000.0F,
                               AVFormatIDKey:@(kAudioFormatLinearPCM),
                               AVLinearPCMBitDepthKey:@16,
                               AVNumberOfChannelsKey:@1,
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVEncoderAudioQualityKey:@(AVAudioQualityLow)
                               };
    
    // wav文件
    NSString *resPath = [YYIMResourceUtility resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_AUDIO ext:@"wav"];
    NSURL *wavUrl = [NSURL URLWithString:[YYIMResourceUtility fullPathWithResourceRelaPath:resPath]];
    
    NSError *error = nil;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc]initWithURL:wavUrl settings:settings error:&error];
    if (!recorder) {
        YYIMLogError(@"createAudioRecorderError:%@", error.description);
    }
    return recorder;
}

+ (NSString *)fullPathWithResourceRelaPath:(NSString *)resRelaPath {
    if (!resRelaPath) {
        return nil;
    }
    return [[[self class] resourceRootDirectory] stringByAppendingPathComponent:resRelaPath];
}

+ (NSString *)resourceRootDirectory {
    // document directory
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 文件管理器
    NSFileManager *fileManage = [NSFileManager defaultManager];
    // 资源对应目录
    NSString *fullPath = [documentDirectory stringByAppendingPathComponent:YYIM_RESOURCE_DIRECTORY];
    // 目录不存在重新重新创建
    if (![fileManage fileExistsAtPath:fullPath]) {
        [fileManage createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

+ (NSString *)resourceRelaPathWithResType:(NSString *)resType ext:(NSString *)ext {
    // 文件名
    NSString *fileName = [[NSUUID UUID] UUIDString];
    // 文件管理器
    NSFileManager *fileManage = [NSFileManager defaultManager];
    // 资源对应目录
    NSString *fullResPath = [[[self class] resourceRootDirectory] stringByAppendingPathComponent:resType];
    // 目录不存在重新重新创建
    if (![fileManage fileExistsAtPath:fullResPath]) {
        [fileManage createDirectoryAtPath:fullResPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 文件路径
    NSString *filePath = [resType stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,ext]];
    return filePath;
}

+ (NSString *)resourceRelaPathWithResType:(NSString *)resType filePath:(NSString *)path {
    NSString *resPath = nil;
    // 不在document目录内
    if (![YYIMResourceUtility isResourceRelaPathWithResType:resType filePath:path]) {
        resPath = [YYIMResourceUtility copyFileToResourcePath:resType filePath:path];
    } else {
        NSString *rootDirectory = [[self class] resourceRootDirectory];
        resPath = [resPath substringFromIndex:[rootDirectory length]];
    }
    return resPath;
}

+ (BOOL)isResourceRelaPathWithResType:(NSString *)resType filePath:(NSString *)filePath {
    NSString *rootDirectory = [[self class] resourceRootDirectory];
    NSString *resDirectory = [rootDirectory stringByAppendingPathComponent:resType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE %@", [NSString stringWithFormat:@"%@%%", resDirectory]];
    return [predicate evaluateWithObject:filePath];
}

+ (NSString *)copyFileToResourcePath:(NSString *)resType filePath:(NSString *)filePath {
    // 扩展名
    NSString *fileExt = [filePath pathExtension];
    // res
    NSString *resPath = [[self class] resourceRelaPathWithResType:resType ext:fileExt];
    // full target path
    NSString *targetPath = [[self class] fullPathWithResourceRelaPath:resPath];
    // copy file
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager copyItemAtPath:filePath toPath:targetPath error:&error];
    return resPath;
}

+ (NSString *)resourceAttachRelaPathWithId:(NSString *)attachId ext:(NSString *)ext {
    // 文件管理器
    NSFileManager *fileManage = [NSFileManager defaultManager];
    // 资源对应目录
    NSString *fullResPath = [[[self class] resourceRootDirectory] stringByAppendingPathComponent:YYIM_RESOURCE_TYPE_ATTACH];
    // 目录不存在重新重新创建
    if (![fileManage fileExistsAtPath:fullResPath]) {
        [fileManage createDirectoryAtPath:fullResPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 文件路径
    NSString *fileName = [[YYIMStringUtility md5Encode:attachId] stringByAppendingPathExtension:ext];
    NSString *filePath = [YYIM_RESOURCE_TYPE_ATTACH stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *)saveImage:(UIImage *)image {
    // 调整文件方向
    image = [self fixOrientation:image];
    // image data
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    // 资源相对路径
    NSString *resPath = [[self class] resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_IMAGE ext:@"jpg"];
    // image path
    NSString *imagePath = [[self class] fullPathWithResourceRelaPath:resPath];
    // save
    [imageData writeToFile:imagePath atomically:NO];
    return resPath;
}

+ (NSString *)saveAssets:(ALAsset *)asset {
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    // create a buffer to hold image data
    uint8_t *buffer = (Byte*)malloc((unsigned long)assetRepresentation.size);
    NSUInteger length = [assetRepresentation getBytes:buffer fromOffset:0 length:(unsigned long)assetRepresentation.size error:nil];
    if (length != 0) {
        // buffer -> NSData object; free buffer afterwards
        NSData *imageData = [[NSData alloc] initWithBytesNoCopy:buffer length:(unsigned long)assetRepresentation.size freeWhenDone:YES];
        //        UIImage *image = [UIImage imageWithData:imageData];
        //        image = [image fixOrientation];
        //        NSData *imageData2 = UIImageJPEGRepresentation(image, 0);
        //        NSData *imageData3 = UIImagePNGRepresentation(image);
        // 资源相对路径
        NSString *resPath = [[self class] resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_IMAGE ext:@"jpg"];
        // image path
        NSString *imagePath = [[self class] fullPathWithResourceRelaPath:resPath];
        // save
        [imageData writeToFile:imagePath atomically:NO];
        return resPath;
    } else {
        return nil;
    }
}

+ (NSString *)thumbImagePath:(NSString *)srcImagePath maxSide:(CGFloat)maxSide {
    if (!srcImagePath) {
        return nil;
    }
    
    // 原图完整路径
    NSString *fullPath = [[self class] fullPathWithResourceRelaPath:srcImagePath];
    // 原图
    UIImage *srcImage = [UIImage imageWithContentsOfFile:fullPath];
    // 缩略图
    UIImage *thumbImage = [[self class] thumbImage:srcImage maxSide:maxSide];
    return [[self class] saveImage:thumbImage];
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

+ (UIImage *)fixOrientation:(UIImage *)image {
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (NSString *)wavToAmr:(NSString *)wavPath {
    // amr path
    NSString *amrPath = [[self class] resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_AUDIO ext:@"amr"];
    // convert
    [YMVoiceConverter wavToAmr:[[self class] fullPathWithResourceRelaPath:wavPath] amrSavePath:[[self class] fullPathWithResourceRelaPath:amrPath]];
    return amrPath;
}

+ (NSString *)amrToWav:(NSString *)amrPath {
    // wav path
    NSString *wavPath = [[self class] resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_AUDIO ext:@"wav"];
    // convert
    [YMVoiceConverter amrToWav:[[self class] fullPathWithResourceRelaPath:amrPath] wavSavePath:[[self class] fullPathWithResourceRelaPath:wavPath]];
    return wavPath;
}

+ (NSString *)getAttachKey:(NSString *)attachId imageType:(YYIMImageType)imageType {
    NSString *key = [YYIMStringUtility md5Encode:attachId];
    switch (imageType) {
        case kYYIMImageTypeOriginal:
            return [NSString stringWithFormat:@"%@_%@", key, @"original"];
        case kYYIMImageTypeThumb:
            return [NSString stringWithFormat:@"%@_%@", key, @"thumb"];
        default:
            return key;
    }
}

+ (NSString *)getThumbAttachKey:(NSString *)attachId {
    return [NSString stringWithFormat:@"%@_thumb", [YYIMStringUtility md5Encode:attachId]];
}

+ (NSString *)getFileMD5WithPath:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (handle== nil) {
        return nil;
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done) {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], (int)[fileData length]);
        if([fileData length] == 0) {
            done = YES;
        }
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
