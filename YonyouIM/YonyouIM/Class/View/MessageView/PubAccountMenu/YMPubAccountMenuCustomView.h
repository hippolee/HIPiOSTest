//
//  YMPubAccountMenuCustomView.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

@protocol YMPubAccountMenuCustomViewDelegate;

@interface YMPubAccountMenuCustomView : UIView

// delegate
@property (nonatomic, weak) id<YMPubAccountMenuCustomViewDelegate> delegate;

- (void)updateContent:(YYPubAccountMenu *)accountMenu;

- (NSInteger)getCurrentIndex;

- (NSInteger)getLastIndex;

@end

@protocol YMPubAccountMenuCustomViewDelegate <NSObject>

- (void)didPubAccountMenuCustomViewClick:(YMPubAccountMenuCustomView *)pubAccountMenuCustomView index:(NSInteger)index;

@end
