//
//  AlarmListViewController.m
//  EmotionAlarm
//
//  Created by Aurora on 29/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "AlarmListViewController.h"
#import "AlarmListCell.h"
#import "SetAlarmViewController.h"
#import "EmotionDetectorViewController.h"

@interface AlarmListViewController ()<UITableViewDelegate,UITableViewDataSource,AlarmCellSwitchDelegate,SetAlarmDelegate>
{
    BOOL isEmptyArray;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *arrayOfAlarms;
@property (nonatomic,strong) NSDateFormatter *dateFormat;

@end

@implementation AlarmListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backButton.hidden = YES;
    [self loadData];
    [self.tableView reloadData];
}

//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self checkAlarmStatus];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.arrayOfAlarms = [NSMutableArray arrayWithArray:[defaults objectForKey:@"alarmList"]];
}

//- (void)checkAlarmStatus{//find all alarms before current time which didn't finish(turn off in normal method)
//    for (int i = 0; i<self.arrayOfAlarms.count; i++) {
//        NSDictionary *dict = [self.arrayOfAlarms objectAtIndex:i];
//        if (!((NSNumber *)[dict objectForKey:@"isEnd"]).boolValue && ((NSNumber *)[dict objectForKey:@"isOn"]).boolValue && [((NSDate *)[dict objectForKey:@"time"]) timeIntervalSinceNow]<0) {
//            EmotionDetectorViewController *alarmVC = [[EmotionDetectorViewController alloc]init];
//            alarmVC.ringName = [dict objectForKey:@"ring"];
//            alarmVC.alarmData = dict;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self presentViewController:alarmVC animated:YES completion:nil];
//            });
//            return;
//        }
//    }
//}

- (void)updateData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.arrayOfAlarms forKey:@"alarmList"];
}

- (void)makeInterface{
    [super makeInterface];
    self.titleLabel.text = NSLocalizedString(@"Alarm List", nil);
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.titleLabel];
}

- (void)makeConstraints{
    [super makeConstraints];
    [[self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]setActive:YES];
    [[self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50]setActive:YES];
    [[self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]setActive:YES];
    [[self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]setActive:YES];
}

- (void)setAlarmData:(NSDictionary *)data index:(NSInteger)index{
    if (self.arrayOfAlarms.count>index) {
        [self removeNotificationWithIdentifier:[data objectForKey:@"id"]];
        [self.arrayOfAlarms removeObjectAtIndex:index];
    }
    [self.arrayOfAlarms insertObject:data atIndex:index];
    [self addNotificationWithData:data];
    [self.tableView reloadData];
    [self updateData];
}



#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayOfAlarms.count == 0) {
        isEmptyArray = YES;
    }else{
        isEmptyArray = NO;
    }
    return self.arrayOfAlarms.count+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.arrayOfAlarms.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"Add New Alarm +";
        }
        return cell;
    }else{
        AlarmListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alarmCell"];
        NSDictionary *dict = [self.arrayOfAlarms objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.dateFormat stringFromDate:[dict objectForKey:@"time"]];
        cell.cellSwitch.on = [[dict objectForKey:@"isOn"]boolValue];
        cell.index = indexPath.row;
        cell.delegate = self;
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.arrayOfAlarms.count) {
        return NO;
    }else{
        return YES;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        if (indexPath.row<[self.arrayOfAlarms count]) {
            NSDictionary *alarmData = [self.arrayOfAlarms objectAtIndex:indexPath.row];
            [self removeNotificationWithIdentifier:[alarmData objectForKey:@"id"]];
            [self.arrayOfAlarms removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self updateData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SetAlarmViewController *vc = [[SetAlarmViewController alloc]init];
    if (indexPath.row == self.arrayOfAlarms.count) {
        vc.alarmData = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"time",[NSNumber numberWithBool:YES],@"isOn", nil];
    }else{
        vc.alarmData = [self.arrayOfAlarms objectAtIndex:indexPath.row];
    }
    vc.index = indexPath.row;
    vc.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}
    
#pragma mark - SwitchDelegate
- (void)indexOfCell:(NSInteger)index switchValue:(BOOL)isOn{
    NSDictionary *dict = [self.arrayOfAlarms objectAtIndex:index];
    if (isOn != [[dict objectForKey:@"isOn"]boolValue]) {
        NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"time"],@"time",[NSNumber numberWithBool:isOn],@"isOn",[dict objectForKey:@"id"],@"id",[dict objectForKey:@"isEnd"],@"isEnd",nil];
        if (self.arrayOfAlarms.count>index) {
            [self removeNotificationWithIdentifier:[dict objectForKey:@"id"]];
            [self.arrayOfAlarms removeObjectAtIndex:index];
        }
        [self.arrayOfAlarms insertObject:newDict atIndex:index];
        if (isOn) {
            [self addNotificationWithData:newDict];
        }
        [self.tableView reloadData];
        [self updateData];
    }
}

#pragma mark - Notification
- (void)addNotificationWithData:(NSDictionary *)data{
    //create new notification's content
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"OPEN YOUR EYES";
    content.body = @"It's time to get up!";
    content.userInfo = data;

    UNNotificationSound *sound = [UNNotificationSound soundNamed:[NSString stringWithFormat:@"%@.caf",[data objectForKey:@"ring"]]];
//    NSLog(@"ring %@",[data objectForKey:@"ring"]);
    content.sound = sound;
    
    NSDate *time = [data objectForKey:@"time"];
//    NSLog(@"alarm date:%@",time);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:time];
    components.second = 0;
    UNCalendarNotificationTrigger *repeatTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    //create UNNotificationRequest object
    NSString *requertIdentifier = [data objectForKey:@"id"];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requertIdentifier content:content trigger:repeatTrigger];
    
    //add to notificationceter
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        NSLog(@"run here");
        if (error) {
            NSLog(@"Error:%@",error);
        }
    }];
//    NSLog(@"add:%@",requertIdentifier);
    
//    [self performSelector:@selector(addRepeatNotifications) withObject:nil afterDelay:60];
}

- (void)addRepeatNotifications{
//    NSLog(@"perform add repeat notifications");
//    NSLog(@"current date: %@", [NSString stringWithFormat:@"%@",[NSDate date]]);
    UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:61.0f repeats:YES];
    NSString *requertIdentifier = @"repeat";
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"OPEN YOUR EYES";
    content.body = @"It's time to get up!";

    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requertIdentifier content:content trigger:timeTrigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        NSLog(@"run here 222");
        if (error) {
            NSLog(@"Error:%@",error);
        }
    }];
}

- (void)removeNotificationWithIdentifier:(NSString *)identifier{
    NSLog(@"remove:%@",identifier);
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
}

#pragma mark - Lazy Load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]init];
        [_tableView registerClass:[AlarmListCell class] forCellReuseIdentifier:@"alarmCell"];
    }
    return _tableView;
}

- (NSDateFormatter *)dateFormat{
    if (!_dateFormat) {
        _dateFormat = [[NSDateFormatter alloc]init];
        [_dateFormat setDateFormat:@"hh:mm aa"];
    }
    return _dateFormat;
}


@end
