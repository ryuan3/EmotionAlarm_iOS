//
//  SetAlarmViewController.h
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "BaseViewController.h"

@class SetAlarmViewController;
@protocol SetAlarmDelegate <NSObject>
- (void)setAlarmData:(NSDictionary *)data index:(NSInteger)index;
@end

@interface SetAlarmViewController : BaseViewController

@property (nonatomic,strong)NSDictionary *alarmData;
@property (weak, nonatomic) id<SetAlarmDelegate> delegate;
@property (nonatomic)NSInteger index;

@end
