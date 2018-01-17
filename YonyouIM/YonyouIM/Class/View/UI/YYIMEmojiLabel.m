//
//  YYIMEmojiLabel.m
//  YonyouIM
//
//  Created by litfb on 16/6/23.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMEmojiLabel.h"


#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression,regex,option) \
\
static inline NSRegularExpression * k##regularExpression() { \
static NSRegularExpression *_##regularExpression = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil];\
});\
\
return _##regularExpression;\
}\

#define REGULAREXPRESSION(regularExpression,regex) REGULAREXPRESSION_OPTION(regularExpression,regex,NSRegularExpressionCaseInsensitive)

// URL
REGULAREXPRESSION(URLRegularExpression,@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")
// 电话
REGULAREXPRESSION(MobileRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[3578]+\\d{9}|\\d{8}|\\d{7}")
// 邮箱
REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")
// @
REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")
// 话题
REGULAREXPRESSION(TopicRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)#")
// 表情
REGULAREXPRESSION(YYIMEmojiRegularExpression, @"\\[:(\\w{1,8})\\]")

#define YYIM_EMOJI_LINE_SPACING                      4.0
#define YYIM_EMOJI_ASCENT_DESCENT_SCALE              0.25
// 和字体高度的比例
#define YYIM_EMOJI_WITH_RATIO_LINEHEIGHT             1.0//?1.15
// 表情绘制的y坐标矫正值,越大越往下
#define YYIM_EMOJI_ORIGIN_YOFFSET_RATIO_LINEHEIGHT   0// ?0.10

#define YYIM_EMOJI_REPLACE_CHARACTER                 @"\uFFFC"

#define YYIM_EMOJI_GLYPH_ATTRIBUTE_IMAGENAME         @"YYIM_EMOJI_GLYPH_ATTRIBUTE_IMAGENAME"

#define YYIM_URL_ACTION_COUNT                        5

NSString * const kURLActions[] = {@"url->",@"mobile->",@"email->",@"at->",@"topic->"};

#pragma mark - 表情 callback
typedef struct CustomGlyphMetrics {
    CGFloat ascent;
    CGFloat descent;
    CGFloat width;
} CustomGlyphMetrics, *CustomGlyphMetricsRef;

static void deallocCallback(void *refCon) {
    free(refCon), refCon = NULL;
}

static CGFloat ascentCallback(void *refCon) {
    CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
    return metrics->ascent;
}

static CGFloat descentCallback(void *refCon) {
    CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
    return metrics->descent;
}

static CGFloat widthCallback(void *refCon) {
    CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
    return metrics->width;
}

@interface TTTAttributedLabel(YYIMEmojiLabel)

@property (readwrite, nonatomic, strong) TTTAttributedLabelLink *activeLink;

- (void)commonInit;

- (NSArray *)addLinksWithTextCheckingResults:(NSArray *)results attributes:(NSDictionary *)attributes;

- (void)drawStrike:(CTFrameRef)frame inRect:(CGRect)rect context:(CGContextRef)c;

@end

@interface YYIMEmojiLabel ()

@property (nonatomic, assign) BOOL ignoreSetText;

// 初始副本
@property (nonatomic, copy) id emojiText;

@end

@implementation YYIMEmojiLabel

#pragma mark - 初始化和TTT的一些修正
- (void)commonInit {
    [super commonInit];
    
    self.numberOfLines = 0;
    
    // 默认行间距
    self.lineSpacing = YYIM_EMOJI_LINE_SPACING;
    
    // 默认链接识别
    //    _disableMobile = YES;
    //    _disableEmail = YES;
    //    _disableURL = YES;
    //    _disableAtAndTopic = YES;
    [self setDisableMobile:YES];
    [self setDisableEmail:YES];
    [self setDisableURL:YES];
    [self setDisableAtAndTopic:YES];
    // 链接默认样式重新设置
    NSMutableDictionary *mutableLinkAttributes = [@{(NSString *)kCTUnderlineStyleAttributeName:@(NO)}mutableCopy];
    NSMutableDictionary *mutableActiveLinkAttributes = [@{(NSString *)kCTUnderlineStyleAttributeName:@(NO)}mutableCopy];
    UIColor *commonLinkColor = [UIColor colorWithRed:0.112 green:0.000 blue:0.791 alpha:1.000];
    
    //点击时候的背景色
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor colorWithWhite:0.631 alpha:1.000] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    
    if ([NSMutableParagraphStyle class]) {
        [mutableLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
    } else {
        [mutableLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    
    self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    self.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
}

/**
 *  如果是有attributedText的情况下，有可能会返回少那么点的，这里矫正下
 */
- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.attributedText) {
        return [super sizeThatFits:size];
    }
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}

// 这里是抄TTT里的，因为他不是放在外面的
static inline CGFloat TTTFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return 0.5f;
        case NSTextAlignmentRight:
            return 1.0f;
        case NSTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

#pragma mark - 绘制表情
- (void)drawStrike:(CTFrameRef)frame inRect:(CGRect)rect context:(CGContextRef)c {
    [super drawStrike:frame inRect:rect context:c];
    
    CGFloat emojiWith = self.font.lineHeight * YYIM_EMOJI_WITH_RATIO_LINEHEIGHT;
    CGFloat emojiOriginYOffset = self.font.lineHeight * YYIM_EMOJI_ORIGIN_YOFFSET_RATIO_LINEHEIGHT;
    
    // 修正绘制offset，根据当前设置的textAlignment
    CGFloat flushFactor = TTTFlushFactorForTextAlignment(self.textAlignment);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    BOOL truncateLastLine = (self.lineBreakMode == NSLineBreakByTruncatingHead || self.lineBreakMode == NSLineBreakByTruncatingMiddle || self.lineBreakMode == NSLineBreakByTruncatingTail);
    CFRange textRange = CFRangeMake(0, (CFIndex)[self.attributedText length]);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // 这里其实是能获取到当前行的真实origin.x，根据textAlignment，而lineBounds.origin.x其实是默认一直为0的(不会受textAlignment影响)
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
        
        CFIndex truncationAttributePosition = -1;
        // 检测如果是最后一行，是否有替换...
        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                truncationAttributePosition = lastLineRange.location;
                NSLineBreakMode lineBreakMode = self.lineBreakMode;
                
                // Multiple lines, only use UILineBreakModeTailTruncation
                if (numberOfLines != 1) {
                    lineBreakMode = NSLineBreakByTruncatingTail;
                }
                
                switch (lineBreakMode) {
                    case NSLineBreakByTruncatingHead:
                        break;
                    case NSLineBreakByTruncatingMiddle:
                        truncationAttributePosition += (lastLineRange.length / 2);
                        break;
                    case NSLineBreakByTruncatingTail:
                    default:
                        truncationAttributePosition += (lastLineRange.length - 1);
                        break;
                }
            }
        }
        
        // 找到当前行的每一个要素，姑且这么叫吧。可以理解为有单独的attr属性的各个range。
        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns(line)) {
            // 找到此要素所对应的属性
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            // 判断是否有图像，如果有就绘制上去
            NSString *imageName = attributes[YYIM_EMOJI_GLYPH_ATTRIBUTE_IMAGENAME];
            if (imageName) {
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                if (glyphRange.location == truncationAttributePosition) {
                    // 这里因为glyphRange的length肯定为1，所以只做这一个判断足够
                    continue;
                }
                
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;
                
                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                
                if (runBounds.size.width != emojiWith) {
                    continue;
                }
                
                runBounds.size.height = runAscent + runDescent;
                
                CGFloat xOffset = 0.0f;
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location, NULL);
                        break;
                }
                runBounds.origin.x = penOffset + xOffset;
                runBounds.origin.y = lineOrigins[lineIndex].y;
                runBounds.origin.y -= runDescent;
                
                UIImage *image = [UIImage imageNamed:imageName];
                runBounds.origin.y -= emojiOriginYOffset; //稍微矫正下。
                CGContextDrawImage(c, runBounds, image.CGImage);
            }
        }
    }
    
}

/**
 *  返回经过表情识别处理的Attributed字符串
 */
- (NSMutableAttributedString*)mutableAttributeStringWithEmojiText:(NSAttributedString *)emojiText {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    if (!emojiText) {
        return attrStr;
    }
    
    NSArray *emojis = [kYYIMEmojiRegularExpression() matchesInString:emojiText.string options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [emojiText length])];
    NSUInteger location = 0;
    CGFloat emojiWith = self.font.lineHeight * YYIM_EMOJI_WITH_RATIO_LINEHEIGHT;
    
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
        NSAttributedString *attSubStr = [emojiText attributedSubstringFromRange:NSMakeRange(location, range.location - location)];
        [attrStr appendAttributedString:attSubStr];
        
        location = range.location + range.length;
        
        NSAttributedString *emojiKey = [emojiText attributedSubstringFromRange:range];
        
        //如果当前获得key后面有多余的，这个需要记录下
        NSMutableAttributedString *otherAppendStr = nil;
        
        NSString *imageName = nil;
        if (self.emojiDelegate) {
            imageName = [self.emojiDelegate emojiLabel:self imageNameOfEmojiText:[emojiKey string]];
        }
        
        if (imageName) {
            // 这里不用空格，空格有个问题就是连续空格的时候只显示在一行
            NSMutableAttributedString *replaceStr = [[NSMutableAttributedString alloc] initWithString:YYIM_EMOJI_REPLACE_CHARACTER];
            NSRange __range = NSMakeRange([attrStr length], 1);
            [attrStr appendAttributedString:replaceStr];
            // 有其他需要添加的
            if (otherAppendStr) {
                [attrStr appendAttributedString:otherAppendStr];
            }
            
            // 定义回调函数
            CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateCurrentVersion;
            callbacks.getAscent = ascentCallback;
            callbacks.getDescent = descentCallback;
            callbacks.getWidth = widthCallback;
            callbacks.dealloc = deallocCallback;
            
            // 这里设置下需要绘制的图片的大小，这里我自定义了一个结构体以便于存储数据
            CustomGlyphMetricsRef metrics = malloc(sizeof(CustomGlyphMetrics));
            metrics->width = emojiWith;
            metrics->ascent = 1 / (1 + YYIM_EMOJI_ASCENT_DESCENT_SCALE) * metrics->width;
            metrics->descent = metrics->ascent * YYIM_EMOJI_ASCENT_DESCENT_SCALE;
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, metrics);
            [attrStr addAttribute:(NSString *)kCTRunDelegateAttributeName
                            value:(__bridge id)delegate
                            range:__range];
            CFRelease(delegate);
            
            // 设置自定义属性，绘制的时候需要用到
            [attrStr addAttribute:YYIM_EMOJI_GLYPH_ATTRIBUTE_IMAGENAME value:imageName range:__range];
        } else {
            [attrStr appendAttributedString:emojiKey];
        }
    }
    if (location < [emojiText length]) {
        NSRange range = NSMakeRange(location, [emojiText length] - location);
        NSAttributedString *attrSubStr = [emojiText attributedSubstringFromRange:range];
        [attrStr appendAttributedString:attrSubStr];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.lineHeightMultiple = 1;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.minimumLineHeight = self.font.lineHeight;
    paragraphStyle.maximumLineHeight = self.font.lineHeight;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrStr length])];
    
    return attrStr;
}

- (void)setText:(id)text {
    NSParameterAssert(!text || [text isKindOfClass:[NSAttributedString class]] || [text isKindOfClass:[NSString class]]);
    
    if (self.ignoreSetText) {
        [super setText:text];
        return;
    }
    
    if (!text) {
        self.emojiText = nil;
        [super setText:nil];
        return;
    }
    
    // 记录下原始的留作备份使用
    self.emojiText = text;
    
    NSMutableAttributedString *mutableAttributedString = nil;
    if (self.disableEmoji) {
        mutableAttributedString = [text isKindOfClass:[NSAttributedString class]]?[text mutableCopy]:[[NSMutableAttributedString alloc]initWithString:text];
        // 直接设置text即可,这里text可能为attrString，也可能为String,使用TTT的默认行为
        [super setText:text];
    } else {
        // 如果是String，必须通过setText:afterInheritingLabelAttributesAndConfiguringWithBlock:来添加一些默认属性，例如字体颜色。这是TTT的做法，不可避免
        if ([text isKindOfClass:[NSString class]]) {
            mutableAttributedString = [self mutableAttributeStringWithEmojiText:[[NSAttributedString alloc] initWithString:text]];
            //这里面会调用 self setText:，所以需要做个标记避免下无限循环
            self.ignoreSetText = YES;
            [super setText:mutableAttributedString afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
            self.ignoreSetText = NO;
        } else {
            mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
            self.ignoreSetText = YES;
            [super setText:mutableAttributedString afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
            self.ignoreSetText = NO;
        }
    }
    
    NSRange stringRange = NSMakeRange(0, mutableAttributedString.length);
    
    NSRegularExpression * const regexps[] = {kURLRegularExpression(), kMobileRegularExpression(), kEmailRegularExpression(), kAtRegularExpression(),kTopicRegularExpression()};
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSUInteger i = 0; i < YYIM_URL_ACTION_COUNT; i++) {
        switch (i) {
            case 0:
                if ([self disableURL]) {
                    continue;
                }
                break;
            case 1:
                if ([self disableMobile]) {
                    continue;
                }
                break;
            case 2:
                if ([self disableEmail]) {
                    continue;
                }
                break;
            case 3:
            case 4:
                if ([self disableAtAndTopic]) {
                    continue;
                }
                break;
            default:
                break;
        }
        
        NSString *urlAction = kURLActions[i];
        [regexps[i] enumerateMatchesInString:mutableAttributedString.string options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
            
            // 检查是否和之前记录的有交集，有的话则忽略
            for (NSTextCheckingResult *record in results){
                if (NSMaxRange(NSIntersectionRange(record.range, result.range))>0){
                    return;
                }
            }
            
            // 添加链接
            NSString *actionString = [NSString stringWithFormat:@"%@%@",urlAction,[self.text substringWithRange:result.range]];
            
            // 这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
            // 因为有自定义的类型出现，所以这样方便点。
            NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:result.range replacementString:actionString];
            [results addObject:aResult];
        }];
    }
    
    //这里直接调用父类私有方法，好处能内部只会setNeedDisplay一次。一次更新所有添加的链接
    [super addLinksWithTextCheckingResults:results attributes:self.linkAttributes];
}

#pragma mark - methods

- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth {
    maxWidth = maxWidth - self.textInsets.left - self.textInsets.right;
    return [self sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

#pragma mark - setter

- (void)setDisableEmoji:(BOOL)disableEmoji {
    _disableEmoji = disableEmoji;
    self.text = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableMobile:(BOOL)disableMobile {
    _disableMobile = disableMobile;
    self.text = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableEmail:(BOOL)disableEmail {
    _disableEmail = disableEmail;
    self.text = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableURL:(BOOL)disableURL {
    _disableURL = disableURL;
    self.text = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableAtAndTopic:(BOOL)disableAtAndTopic {
    _disableAtAndTopic = disableAtAndTopic;
    self.text = self.emojiText; //简单重新绘制处理下
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    self.text = self.emojiText; //简单重新绘制处理下
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.text = self.emojiText; //简单重新绘制处理下
}

#pragma mark - select link override

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 如果delegate实现了mlEmojiLabel自身的选择link方法
    if (self.emojiDelegate && [self.emojiDelegate respondsToSelector:@selector(emojiLabel:didSelectLink:withType:)]){
        if (self.activeLink && [self.activeLink result].resultType == NSTextCheckingTypeCorrection) {
            NSTextCheckingResult *result = self.activeLink.result;
            // 判断消息类型
            for (NSUInteger i = 0; i < YYIM_URL_ACTION_COUNT; i++) {
                if ([result.replacementString hasPrefix:kURLActions[i]]) {
                    NSString *content = [result.replacementString substringFromIndex:kURLActions[i].length];
                    // type的数组和i刚好对应
                    [self.emojiDelegate emojiLabel:self didSelectLink:content withType:i];
                    self.activeLink = nil;
                    return;
                }
            }
        }
    }
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - UIResponderStandardEditActions
- (void)copy:(__unused id)sender {
    if (!self.emojiText) {
        return;
    }
    
    NSString *text = [self.emojiText isKindOfClass:[NSAttributedString class]] ? ((NSAttributedString *) self.emojiText).string : self.emojiText;
    if (text.length > 0) {
        [[UIPasteboard generalPasteboard] setString:text];
    }
}

@end
