//
//  ChatBatchMixedSubCell.h
//  YonyouIM
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

@interface ChatBatchMixedSubCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *sepView;

- (void)setActivePaContent:(YYPubAccountContent *)paContent;

@end
