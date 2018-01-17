//
//  ImageMessageTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/11/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ImageMessageTableViewCell.h"
#import "YYIMChatHeader.h"
#import "UIResponder+YYIMCategory.h"
#import "YYMessage+YYIMCatagory.h"

@interface ImageMessageTableViewCell ()

@property (strong, nonatomic) UITapGestureRecognizer *imageTapRecognizer1;
@property (strong, nonatomic) UITapGestureRecognizer *imageTapRecognizer2;
@property (strong, nonatomic) UITapGestureRecognizer *imageTapRecognizer3;
@property (strong, nonatomic) UITapGestureRecognizer *imageTapRecognizer4;

@property (retain, nonatomic) NSMutableArray *messageArray;

@end

@implementation ImageMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.messageArray = [NSMutableArray array];
    self.imageTapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
    [self.imageTapRecognizer1 setCancelsTouchesInView:YES];
    self.imageTapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
    self.imageTapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
    self.imageTapRecognizer4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
    
    [self.image1 setUserInteractionEnabled:YES];
    [self.image1 setContentMode:UIViewContentModeScaleAspectFill];
    [self.image1 setClipsToBounds:YES];
    
    [self.image2 setUserInteractionEnabled:YES];
    [self.image2 setContentMode:UIViewContentModeScaleAspectFill];
    [self.image2 setClipsToBounds:YES];
    
    [self.image3 setUserInteractionEnabled:YES];
    [self.image3 setContentMode:UIViewContentModeScaleAspectFill];
    [self.image3 setClipsToBounds:YES];
    
    [self.image4 setUserInteractionEnabled:YES];
    [self.image4 setContentMode:UIViewContentModeScaleAspectFill];
    [self.image4 setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self.messageArray removeAllObjects];
    self.image1.image = nil;
    self.image2.image = nil;
    self.image3.image = nil;
    self.image4.image = nil;
    [self.image1 removeGestureRecognizer:self.imageTapRecognizer1];
    [self.image2 removeGestureRecognizer:self.imageTapRecognizer2];
    [self.image3 removeGestureRecognizer:self.imageTapRecognizer3];
    [self.image4 removeGestureRecognizer:self.imageTapRecognizer4];
}

- (void)setImageMessages:(NSArray *)messages {
    [self.messageArray removeAllObjects];
    [self.messageArray addObjectsFromArray:messages];
    
    NSUInteger messageCount = [self.messageArray count];
    switch (messageCount) {
        case 4:
            [self setImageWithMessage:[self.messageArray objectAtIndex:3] imageView:self.image4];
            [self.image4 addGestureRecognizer:self.imageTapRecognizer4];
        case 3:
            [self setImageWithMessage:[self.messageArray objectAtIndex:2] imageView:self.image3];
            [self.image3 addGestureRecognizer:self.imageTapRecognizer3];
        case 2:
            [self setImageWithMessage:[self.messageArray objectAtIndex:1] imageView:self.image2];
            [self.image2 addGestureRecognizer:self.imageTapRecognizer2];
        case 1:
            [self setImageWithMessage:[self.messageArray objectAtIndex:0] imageView:self.image1];
            [self.image1 addGestureRecognizer:self.imageTapRecognizer1];
        default:
            break;
    }
}

- (void)setImageWithMessage:(YYMessage *)message imageView:(UIImageView *)imageView {
    [imageView setImage:[message getMessageImage]];
}

- (void)imagePressed:(UITapGestureRecognizer *)recognizer {
    UIImageView *imageView = (UIImageView *)recognizer.view;
    
    NSInteger tag = [imageView tag];
    if (tag > [self.messageArray count]) {
        return;
    }
    
    YYMessage *tapMessage = [self.messageArray objectAtIndex:tag - 1];
    [self bubbleEventWithUserInfo:[NSDictionary dictionaryWithObject:tapMessage forKey:kYMPressedImageMessage]];
}

@end
