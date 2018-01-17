//
//  YYIMStringUtility.m
//  YonyouIM
//
//  Created by litfb on 14/12/31.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "YYIMStringUtility.h"
#import "YYIMConfig.h"
#import <CommonCrypto/CommonDigest.h>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation YYIMStringUtility

+ (BOOL)isEmpty:(NSString *) str {
    if (!str) {
        return YES;
    } else if ([str length] == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)genFullPathRes:(NSString *)res {
    if ([YYIMStringUtility isEmpty:res]) {
        return nil;
    }
    if ([res hasPrefix:@"http:"] || [res hasPrefix:@"https:"] || [res hasPrefix:@"ftp:"]) {
        return res;
    }
    NSString *fullPath = [NSString stringWithFormat:@"%@?attachId=%@&token=%@&downloader=%@", [[YYIMConfig sharedInstance] getResourceDownloadServlet], res, [[YYIMConfig sharedInstance] getToken], [[YYIMConfig sharedInstance] getFullUser]];
    return fullPath;
}

+ (NSString *)genFullPathResThumb:(NSString *)res {
    NSString *path = [self genFullPathRes:res];
    path = [path stringByAppendingString:@"&mediaType=2"];
    return path;
}

+ (NSObject *)notNilString:(NSString *) str {
    if (str == nil) {
        return @"";
    }
    return str;
}

+ (BOOL)isChinese:(NSString *)str {
    NSString *match=@"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
}

+ (NSString *)md5Encode:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSString *)sha1Encode:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSData *)base64Decode:(NSString *)str {
    if ([str length] == 0) {
        return [NSData data];
    }
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL) {
        decodingTable = malloc(256);
        if (decodingTable == NULL) {
            return nil;
        }
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++) {
            decodingTable[(short)encodingTable[i]] = i;
        }
    }
    
    const char *characters = [str cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL) {
        // Not an ASCII string!
        return nil;
    }
    char *bytes = malloc((([str length] + 3) / 4) * 3);
    if (bytes == NULL) {
        return nil;
    }
    
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES) {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++) {
            if (characters[i] == '\0') {
                break;
            }
            if (isspace(characters[i]) || characters[i] == '=') {
                continue;
            }
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX) {
                // Illegal character!
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0) {
            break;
        }
        if (bufferLength == 1) {
            // At least two characters are needed to produce one byte!
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2) {
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        }
        if (bufferLength > 3) {
            bytes[length++] = (buffer[2] << 6) | buffer[3];
        }
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

+ (NSString *)encodeToEscapeString:(NSString *)input {
    NSString * outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)input, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return outputStr;
}

+ (NSString *)decodeFromEscapeString:(NSString *)input {
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)decodeFromUnicode:(NSString *)input {
    NSString *tempStr1 = [input stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

+ (id)decodeJsonString:(NSString *)jsonString error:(NSError **)error {
    // json转换
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:error];
}

+ (NSString *)encodeJsonObject:(id)jsonObject error:(NSError **)error {
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:error];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (BOOL)isNumberString:(NSString *)str {
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (str.length > 0) {
        return NO;
    }
    return YES;
}

@end
