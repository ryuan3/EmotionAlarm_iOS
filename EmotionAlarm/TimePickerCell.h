//
//  TimePickerCell.h
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimePickerCell;
@protocol TimePickerCellDelegate <NSObject>
- (void)setTime:(NSDate *)date;
@end

@interface TimePickerCell : UITableViewCell

@property (nonatomic,strong) UIDatePicker *timePicker;
@property (weak, nonatomic) id<TimePickerCellDelegate> delegate;

@end
