//
//  AlarmListCell.h
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlarmListCell;
@protocol AlarmCellSwitchDelegate <NSObject>
- (void)indexOfCell:(NSInteger)index switchValue:(BOOL)isOn;
@end

@interface AlarmListCell : UITableViewCell

@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UISwitch *cellSwitch;
@property (nonatomic)NSInteger index;
@property (weak, nonatomic) id<AlarmCellSwitchDelegate> delegate;

@end
