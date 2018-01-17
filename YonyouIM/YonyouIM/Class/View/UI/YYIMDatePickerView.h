//
//  YYIMDatePickerView.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYIMDatePickerViewDelegate;

typedef NS_ENUM(NSUInteger, YYIMDateSelect) {
    kYYIMDateSelectBegin         = 0,  //开始时间
    kYYIMDateSelectEnd           = 1,  //结束时间
};

@interface YYIMDatePickerView : UIView

@property (nonatomic) YYIMDateSelect dateSelect;

// delegate
@property (nonatomic, weak) id<YYIMDatePickerViewDelegate> delegate;

- (void)setDatePickerDate:(NSDate *)date;

- (void)setDatePickerMinuteInterval:(NSInteger)interval;

@end

@protocol  YYIMDatePickerViewDelegate <NSObject>

@required

- (void)didDatePickerViewCancel:(YYIMDatePickerView *)datePickerView;

- (void)didDatePickerViewSelect:(YYIMDatePickerView *)datePickerView date:(NSDate *)date dateSelect:(YYIMDateSelect)dateSelect;

@end
