//
//  EmotionDetectorViewController.h
//  EmotionAlarm
//
//  Created by Aurora on 28/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Affdex/Affdex.h>

#import "BaseViewController.h"

@interface EmotionDetectorViewController : BaseViewController

@property (nonatomic,strong) NSString *ringName;
@property (nonatomic,strong) NSDictionary *alarmData;

@end
