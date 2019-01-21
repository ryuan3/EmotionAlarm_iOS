//
//  BaseViewController.h
//  EmotionAlarm
//
//  Created by Aurora on 28/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface BaseViewController : UIViewController

@property (nonatomic,strong) UIImageView *backgroundImv;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIImageView *backIcon;

- (void)makeInterface;
- (void)makeConstraints;
- (void)backButtonPressed:(id)sender;

@end
