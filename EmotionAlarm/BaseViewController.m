//
//  BaseViewController.m
//  EmotionAlarm
//
//  Created by Aurora on 28/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeInterface];
    [self makeConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.view bringSubviewToFront:self.backButton];
}

- (void)makeInterface{
    [self.view addSubview:self.backgroundImv];
    [self.view sendSubviewToBack:self.backgroundImv];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.backButton];
    [self.backButton addSubview:self.backIcon];
}

- (void)makeConstraints{
    [[self.backgroundImv.topAnchor constraintEqualToAnchor:self.view.topAnchor]setActive:YES];
    [[self.backgroundImv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]setActive:YES];
    [[self.backgroundImv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]setActive:YES];
    [[self.backgroundImv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]setActive:YES];
    
    [[self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]setActive:YES];
    [[self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:25]setActive:YES];
    [[self.titleLabel.widthAnchor constraintEqualToConstant:100]setActive:YES];
    [[self.titleLabel.heightAnchor constraintEqualToConstant:40]setActive:YES];
    
    [[self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20]setActive:YES];
    [[self.backButton.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor]setActive:YES];
    [[self.backButton.widthAnchor constraintEqualToConstant:50]setActive:YES];
    [[self.backButton.heightAnchor constraintEqualToConstant:40]setActive:YES];
    
    [[self.backIcon.leadingAnchor constraintEqualToAnchor:self.backButton.leadingAnchor constant:5]setActive:YES];
    [[self.backIcon.centerYAnchor constraintEqualToAnchor:self.backButton.centerYAnchor]setActive:YES];
    [[self.backIcon.widthAnchor constraintEqualToConstant:18]setActive:YES];
    [[self.backIcon.heightAnchor constraintEqualToConstant:18]setActive:YES];
    
}

- (void)backButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImageView *)backgroundImv{
    if (!_backgroundImv) {
        _backgroundImv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
        [_backgroundImv setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_backgroundImv setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _backgroundImv;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _titleLabel.textColor = [UIColor colorWithRed:0.31 green:0.29 blue:0.28 alpha:1.00];
        _titleLabel.font = [UIFont fontWithName:@"STXingkai" size:22];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)backIcon{
    if (!_backIcon) {
        _backIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back"]];
        [_backIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
        _backIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backIcon;
}

@end
