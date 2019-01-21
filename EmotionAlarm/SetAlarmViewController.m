//
//  SetAlarmViewController.m
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "SetAlarmViewController.h"
#import "TimePickerCell.h"
#import <AVFoundation/AVFoundation.h>
//#import <AudioToolbox/AudioToolbox.h>

@interface SetAlarmViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,TimePickerCellDelegate>
{
    UInt32 soundID;
    UInt32 soundID_1;
    UInt32 soundID_2;
    UInt32 soundID_3;
    UInt32 soundID_4;

}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDate *updateDate;
@property (nonatomic,strong) UIAlertController *ringList;
@property (nonatomic,strong) NSString *ringName;
@property (nonatomic,strong) AVAudioPlayer *player01;
@property (nonatomic,strong) AVAudioPlayer *player02;
@property (nonatomic,strong) AVAudioPlayer *player03;
@property (nonatomic,strong) AVAudioPlayer *player04;
@property (nonatomic,strong) AVAudioPlayer *currentPlayer;

@end

@implementation SetAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self loadSoundID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeInterface{
    [super makeInterface];
//    self.titleLabel.text = NSLocalizedString(@"Alarmer", nil);
    [self.view addSubview:self.tableView];
}

- (void)makeConstraints{
    [super makeConstraints];
    [[self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]setActive:YES];
    [[self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0]setActive:YES];
    [[self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]setActive:YES];
    [[self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]setActive:YES];
}

- (void)loadSoundID{
    NSString * path=[[NSBundle mainBundle]pathForResource:@"Music01" ofType:@"caf"];
    NSURL * url=[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID_1);

    path=[[NSBundle mainBundle]pathForResource:@"Music02" ofType:@"caf"];
    url=[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID_2);
    
    path=[[NSBundle mainBundle]pathForResource:@"Music03" ofType:@"caf"];
    url=[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID_3);
    
    path=[[NSBundle mainBundle]pathForResource:@"Music04" ofType:@"caf"];
    url=[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID_4);
    
    path=[[NSBundle mainBundle]pathForResource:self.ringName ofType:@"caf"];
    url=[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
}
#pragma mark - TimePickerDelegateMethod
- (void)setTime:(NSDate *)date{
    self.updateDate = date;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        return 150;
    }else{
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"Set Alarm Time";
            cell.separatorInset = UIEdgeInsetsMake(30, 10, 30, 10);
        }
        return cell;
    }
    else if (indexPath.row == 1){
        TimePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
        if (!cell) {
            cell = [[TimePickerCell alloc]init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.separatorInset = UIEdgeInsetsMake(30, 10, 30, 10);
        }
        cell.timePicker.date = self.updateDate;
        return cell;
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ringCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ringCell"];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
//            cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Choose Ring";
            cell.detailTextLabel.text = self.ringName;
            cell.detailTextLabel.tag = 1212;
            cell.separatorInset = UIEdgeInsetsMake(30, 10, 30, 10);
        }
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"doneCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"doneCell"];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
            cell.textLabel.text = @"Done";
            cell.separatorInset = UIEdgeInsetsMake(30, 10, 30, 10);
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        [self presentViewController:self.ringList animated:YES completion:nil];
//        [self.player play];
        if (self.currentPlayer) {
            [self.currentPlayer play];
        }
    }else if (indexPath.row == 3) {
        
        while ([self.updateDate timeIntervalSinceNow]<0) {
            self.updateDate = [NSDate dateWithTimeInterval:86400 sinceDate:self.updateDate];
        }
        NSString *alarmerId = nil;
        if ([self.alarmData objectForKey:@"id"]) {
            alarmerId = [self.alarmData objectForKey:@"id"];
        }else{
            alarmerId = [NSString stringWithFormat:@"em%f",[self.updateDate timeIntervalSince1970]];
        }
        NSDictionary *newData = [NSDictionary dictionaryWithObjectsAndKeys:self.updateDate,@"time",[self.alarmData objectForKey:@"isOn"],@"isOn",alarmerId,@"id",self.ringName,@"ring",[NSNumber numberWithBool:NO],@"isEnd",nil];
        NSLog(@"update date: %@",self.updateDate);
        [self.delegate setAlarmData:newData index:self.index];
        [self.currentPlayer stop];
//        AudioServicesDisposeSystemSoundID(soundID);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - Lazy Load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 150;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

- (UIAlertController *)ringList{
    if (!_ringList) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _ringList = [UIAlertController alertControllerWithTitle:@"Choose Ring" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSMutableDictionary *ringData = [defaults objectForKey:@"Music01"];
        UIAlertAction *ring1 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Music01 (avg wake up time %.1fs)",((NSNumber *)[ringData objectForKey:@"avgtime"]).floatValue] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"ring1");
            self.ringName = @"Music01";
            UILabel *label = [self.view viewWithTag:1212];
            label.text = self.ringName;
            
            [self.currentPlayer stop];
            [self.player01 play];
            self.currentPlayer = self.player01;
//            NSLog(@"soundID = %i, sound01ID = %i",soundID,soundID_1);
//            AudioServicesDisposeSystemSoundID(soundID);
//            soundID = soundID_1;
//            AudioServicesPlaySystemSound(soundID_1);
        }];
        
        ringData = [defaults objectForKey:@"Music02"];
        UIAlertAction *ring2 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Music02 (avg wake up time %.1fs)",((NSNumber *)[ringData objectForKey:@"avgtime"]).floatValue] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"ring2");
            self.ringName = @"Music02";
            UILabel *label = [self.view viewWithTag:1212];
            label.text = self.ringName;
            
            [self.currentPlayer stop];
            [self.player02 play];
            self.currentPlayer = self.player02;
//            NSLog(@"soundID = %i, sound02ID = %i",soundID,soundID_2);
//            AudioServicesDisposeSystemSoundID(soundID);
//            soundID = soundID_2;
//            AudioServicesPlaySystemSound(soundID_2);
        }];
        
        ringData = [defaults objectForKey:@"Music03"];
        UIAlertAction *ring3 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Music03 (avg wake up time %.1fs)",((NSNumber *)[ringData objectForKey:@"avgtime"]).floatValue] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"ring3");
            self.ringName = @"Music03";
            UILabel *label = [self.view viewWithTag:1212];
            label.text = self.ringName;
            
            [self.currentPlayer stop];
            [self.player03 play];
            self.currentPlayer = self.player03;
//            NSLog(@"soundID = %i, sound03ID = %i",soundID,soundID_3);
//            AudioServicesDisposeSystemSoundID(soundID);
//            soundID = soundID_3;
//            AudioServicesPlaySystemSound(soundID_3);
        }];
        
        ringData = [defaults objectForKey:@"Music04"];
        UIAlertAction *ring4 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Music04 (avg wake up time %.1fs)",((NSNumber *)[ringData objectForKey:@"avgtime"]).floatValue] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"ring4");
            self.ringName = @"Music04";
            UILabel *label = [self.view viewWithTag:1212];
            label.text = self.ringName;
            
            [self.currentPlayer stop];
            [self.player04 play];
            self.currentPlayer = self.player04;
//            NSLog(@"soundID = %i, sound04ID = %i",soundID,soundID_4);
//            AudioServicesDisposeSystemSoundID(soundID);
//            soundID = soundID_4;
//            AudioServicesPlaySystemSound(soundID_4);
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancel");
            [self.currentPlayer stop];
//            AudioServicesDisposeSystemSoundID(soundID);
//            [self.player stop];
        }];
        [_ringList addAction:ring1];
        [_ringList addAction:ring2];
        [_ringList addAction:ring3];
        [_ringList addAction:ring4];
        [_ringList addAction:cancel];
        
    }
    return _ringList;
}

- (NSDate *)updateDate{
    if (!_updateDate) {
        _updateDate = [self.alarmData objectForKey:@"time"];
    }
    return _updateDate;
}

- (NSString *)ringName{
    if (!_ringName) {
        if ([self.alarmData objectForKey:@"ring"]) {
            _ringName = [self.alarmData objectForKey:@"ring"];
        }else{
            _ringName = @"Music01";
        }
    }
    NSLog(@"ringname: %@",_ringName);
    return _ringName;
}

- (AVAudioPlayer *)player01{
    if (!_player01) {
        NSString * path=[[NSBundle mainBundle]pathForResource:@"Music01" ofType:@"caf"];
        NSURL * url=[NSURL fileURLWithPath:path];
        NSError * error;
        
        _player01 = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player01.numberOfLoops = -1;
        _player01.volume = 1;
    }
    return _player01;
}

- (AVAudioPlayer *)player02{
    if (!_player02) {
        NSString * path=[[NSBundle mainBundle]pathForResource:@"Music02" ofType:@"caf"];
        NSURL * url=[NSURL fileURLWithPath:path];
        NSError * error;
        
        _player02 = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player02.numberOfLoops = -1;
        _player02.volume = 1;
    }
    return _player02;
}

- (AVAudioPlayer *)player03{
    if (!_player03) {
        NSString * path=[[NSBundle mainBundle]pathForResource:@"Music03" ofType:@"caf"];
        NSURL * url=[NSURL fileURLWithPath:path];
        NSError * error;
        
        _player03 = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player03.numberOfLoops = -1;
        _player03.volume = 1;
    }
    return _player03;
}

- (AVAudioPlayer *)player04{
    if (!_player04) {
        NSString * path=[[NSBundle mainBundle]pathForResource:@"Music04" ofType:@"caf"];
        NSURL * url=[NSURL fileURLWithPath:path];
        NSError * error;
        
        _player04 = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player04.numberOfLoops = -1;
        _player04.volume = 1;
    }
    return _player04;
}

- (AVAudioPlayer *)currentPlayer{
    if (!_currentPlayer) {
        if ([self.ringName hasSuffix:@"1"]) {
            _currentPlayer = self.player01;
        }else if([self.ringName hasSuffix:@"2"]){
            _currentPlayer = self.player02;
        }else if([self.ringName hasSuffix:@"3"]){
            _currentPlayer = self.player03;
        }else if([self.ringName hasSuffix:@"4"]){
            _currentPlayer = self.player04;
        }
    }
    return _currentPlayer;
}

@end
