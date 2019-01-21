//
//  AppDelegate.m
//  EmotionAlarm
//
//  Created by Aurora on 28/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "AppDelegate.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "EmotionDetectorViewController.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //request authorization (badge, sound, alert)
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //if user granted
            center.delegate = self;
            NSLog(@"request authorization successed!");
        }
    }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self checkAlarmStatus];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    EmotionDetectorViewController *alarmVC = [[EmotionDetectorViewController alloc]init];
    alarmVC.alarmData = notification.request.content.userInfo;
    alarmVC.ringName = [notification.request.content.userInfo objectForKey:@"ring"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.window.rootViewController.class isEqual:[EmotionDetectorViewController class]]) {
            [self.window.rootViewController presentViewController:alarmVC animated:YES completion:nil];
        }
    });
    NSLog(@"hahaha");
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    NSLog(@"xixixi");

    EmotionDetectorViewController *alarmVC = [[EmotionDetectorViewController alloc]init];
    alarmVC.alarmData = response.notification.request.content.userInfo;
    alarmVC.ringName = [response.notification.request.content.userInfo objectForKey:@"ring"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.window.rootViewController.class isEqual:[EmotionDetectorViewController class]]) {
            [self.window.rootViewController presentViewController:alarmVC animated:YES completion:nil];
        }
    });
    completionHandler();
}

//- (void)showEmotionDetectorView{
//    NSLog(@"show alarm page");
//    EmotionDetectorViewController *alarmVC = [[EmotionDetectorViewController alloc]init];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (![self.window.rootViewController.class isEqual:[EmotionDetectorViewController class]]) {
//            [self.window.rootViewController presentViewController:alarmVC animated:YES completion:nil];
//        }
//    });
//}

- (void)checkAlarmStatus{//find all alarms before current time which didn't finish(turn off in normal method)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayOfAlarms = [NSMutableArray arrayWithArray:[defaults objectForKey:@"alarmList"]];
    
    for (int i = 0; i<arrayOfAlarms.count; i++) {
        NSDictionary *dict = [arrayOfAlarms objectAtIndex:i];
//        NSLog(@"isEnd: %@, isOn: %@, time: %@",[dict objectForKey:@"isEnd"],[dict objectForKey:@"isOn"], [dict objectForKey:@"time"]);
        if (!((NSNumber *)[dict objectForKey:@"isEnd"]).boolValue && ((NSNumber *)[dict objectForKey:@"isOn"]).boolValue && [((NSDate *)[dict objectForKey:@"time"]) timeIntervalSinceNow]<0) {
            EmotionDetectorViewController *alarmVC = [[EmotionDetectorViewController alloc]init];
            alarmVC.ringName = [dict objectForKey:@"ring"];
            alarmVC.alarmData = dict;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self.window.rootViewController.class isEqual:[EmotionDetectorViewController class]]) {
                    [self.window.rootViewController presentViewController:alarmVC animated:YES completion:nil];
                }
            });
            return;
        }
    }
}

@end
