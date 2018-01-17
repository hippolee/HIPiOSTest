//
//  YYIMEmojiKeyboardKeyGroup.h
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YYIMEmojiKeyboardKeyGroup : NSObject

@property (nonatomic,copy) NSString *title;

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,strong) UIImage *selectedImage;

@property (nonatomic,strong) NSArray *keyItems;

@property (nonatomic,unsafe_unretained) Class keyItemCellClass;

@end
