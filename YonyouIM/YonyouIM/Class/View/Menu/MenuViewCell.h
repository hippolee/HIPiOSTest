//
//  MenuViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MenuViewCell : UITableViewCell

- (void) reuse;

- (void) setMenuIconImage:(NSString *) imageName;

- (void) setMenuLabelName:(NSString *) name;

- (void) setSeparatorHidden:(BOOL) isHidden;

@end
