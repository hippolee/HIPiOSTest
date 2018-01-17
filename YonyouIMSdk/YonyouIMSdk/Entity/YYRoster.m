//
//  YYRoster.m
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYRoster.h"
#import "YYIMStringUtility.h"
#import "YYIMFirstLetterHelper.h"

@interface YYRoster ()

@property (nonatomic, readwrite) NSString *rosterAliasPinyin;
@property (nonatomic, readwrite) NSString *firstLetters;

@end

@implementation YYRoster

- (NSString *)getRosterPhoto {
    return [self.user getUserPhoto];
}

- (NSString *)getFirstLetter {
    if (!_firstLetter) {
        _firstLetter = [[YYIMFirstLetterHelper firstLetter:[self rosterAlias]] uppercaseString];
    }
    return _firstLetter;
}

- (BOOL)isOnline {
    return self.androidState > 0 || self.iosState > 0 || self.webimState > 0 || self.desktopState > 0;
}

- (BOOL)hasTag:(NSString *)tag {
    return [self.rosterTag containsObject:tag];
}

- (NSString *)groupStr {
    if (self.groups) {
        return [self.groups componentsJoinedByString:@"|"];
    }
    return nil;
}

- (void)setGroupsWithStr:(NSString *)groupStr {
    if (groupStr && groupStr.length > 0) {
        self.groups = [groupStr componentsSeparatedByString:@"|"];
    }
}

- (NSString *)rosterAliasPinyin {
    if (!_rosterAliasPinyin) {
        NSMutableString *string = [[self rosterAlias] mutableCopy];
        CFStringTransform((__bridge CFMutableStringRef)string, NULL, kCFStringTransformMandarinLatin, NO);
        string = (NSMutableString *) [string stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
        _rosterAliasPinyin = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return _rosterAliasPinyin;
}

- (NSString *)firstLetters {
    if (!_firstLetters) {
        _firstLetters = [YYIMFirstLetterHelper firstLetters:[self rosterAlias]];
    }
    return _firstLetters;
}

- (NSString *)rosterAlias {
    if ([YYIMStringUtility isEmpty:_rosterAlias] && self.user) {
        return [self.user userName];
    }
    return _rosterAlias;
}

@end
