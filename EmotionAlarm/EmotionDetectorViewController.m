//
//  EmotionDetectorViewController.m
//  EmotionAlarm
//
//  Created by Aurora on 28/07/2018.
//  Copyright © 2018 ruiling. All rights reserved.
//

#import "EmotionDetectorViewController.h"
#import <Affdex/Affdex.h>
#import "HWWaveView.h"
//#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define MIN_OPEN_EYES_SECONDS        30.0

@interface EmotionDetectorViewController ()<AFDXDetectorDelegate>
{
    BOOL isSuccess;
    CGFloat totalCostSeconds;
    
    BOOL firstFail;
    BOOL secondFail;
    
    BOOL isPress;
    BOOL isStart;
    
    CGFloat timerInterval;
    UInt32 soundID;
}
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) HWWaveView *circleView;
@property (nonatomic,strong) UIButton *pressButton;
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) AFDXDetector *detector;
@property (nonatomic,assign) AFDXCameraType cameraToUse;
@property (nonatomic,strong) NSArray *faces;
@property (nonatomic,strong) NSMutableArray *faceRectsToDraw;
@property (nonatomic,strong) NSArray *availableClassifiers; // the array of dictionaries which contain all available classifiers
@property (strong) NSArray *emotions;   // the array of dictionaries of all emotion classifiers
// Array of selected classifier names to be displayed in the expression view controllers.
@property (nonatomic,strong) NSMutableArray *selectedClassifiers;
@property (nonatomic,strong) NSDate *dateOfLastUpdated;

@property (nonatomic,strong) AVAudioPlayer *player;

@end

@implementation EmotionDetectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backButton.hidden = YES;
    isSuccess = NO;
    isStart = NO;
    isPress = NO;
    timerInterval = MIN_OPEN_EYES_SECONDS/100.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForBackground:(id)sender;
{
    [self stopDetector];
}

- (void)prepareForForeground:(id)sender;
{
    [self startDetector];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.imageView setImage:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        [self startDetector];
    } else if(status == AVAuthorizationStatusDenied){
        // denied
        [self showAlertWithTitle:@"Error!" message:@"EmotionAlarm doesn't have permission to use camera, please change privacy settings"];
    } else if(status == AVAuthorizationStatusRestricted){
        // restricted
    } else if(status == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                [self startDetector];
            } else {
                [self showAlertWithTitle:@"Error!" message:@"EmotionAlarm doesn't have permission to use camera, please change privacy settings"];
            }
        }];
    }
    [self.view bringSubviewToFront:self.circleView];
}

- (void)makeInterface{
    [super makeInterface];
//    self.titleLabel.text = NSLocalizedString(@"Alarmer", nil);
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.circleView];
}

- (void)makeConstraints{
    [super makeConstraints];
    [[self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]setActive:YES];
    [[self.imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0]setActive:YES];
    [[self.imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]setActive:YES];
    [[self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]setActive:YES];
    
    [[self.topLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]setActive:YES];
    [[self.topLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20]setActive:YES];
    [[self.topLabel.heightAnchor constraintEqualToConstant:80]setActive:YES];
    [[self.topLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]setActive:YES];
    
    [[self.circleView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]setActive:YES];
    [[self.circleView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20]setActive:YES];
    [[self.circleView.heightAnchor constraintEqualToConstant:150]setActive:YES];
    [[self.circleView.widthAnchor constraintEqualToConstant:150]setActive:YES];

}

#pragma mark - Method
- (void)processedImageReady:(AFDXDetector *)detector image:(UIImage *)image faces:(NSDictionary *)faces atTime:(NSTimeInterval)time;
{
    self.faces = [faces allValues];
    
    // set up arrays of points and rects
    self.faceRectsToDraw = [NSMutableArray new];
    
//    NSLog(@"faceNumber:%lu",(unsigned long)self.faces.count);
    int r = 0;
    if (!isSuccess) {
        r = arc4random() % 100;
        if (r>90 && self.faces.count<1) {
            NSLog(@"stop FN");
            [self stopTimer];
        }
    }

    // Handle each metric in the array
    for (AFDXFace *face in [faces allValues])
    {
        
        [self.faceRectsToDraw addObject:[NSValue valueWithCGRect:face.faceBounds]];
        

//        NSLog(@"close: %.1f",face.expressions.eyeClosure);
//        NSLog(@"widen: %.1f",face.expressions.eyeWiden);

        if (!isSuccess) {
            if (!isStart) {
                r = arc4random() % 100;
                if (face.expressions.eyeClosure<10 && r>20) {
                    [self startTimer];
                }
            }else{
                r = arc4random() % 100;
                if (face.expressions.eyeClosure>90 && r>80) {
                    if (!firstFail) {
                        firstFail = YES;
                    }else if (!secondFail){
                        secondFail = YES;
                    }else{
//                        NSLog(@"stop EC");
                        [self stopTimer];
                    }
                }
            }
        }


        
//        for (NSArray *classifierArray in self.availableClassifiers)  // e.g. [ emotions, expressions ]
//        {
//            for (NSDictionary *classifierDict in classifierArray)    // array of selected classifier.
//            {
//                for (NSInteger classifierIndex = 0; classifierIndex<[self.selectedClassifiers count]; classifierIndex++)
//                {
//                    NSString *classifierName = [self.selectedClassifiers objectAtIndex:classifierIndex];
//                    if ([[classifierDict objectForKey:@"name"] isEqualToString:classifierName])
//                    {
//                        NSString *scoreName = [classifierDict objectForKey:@"score"];
//                        __block float classifierScore = [[face valueForKeyPath:scoreName] floatValue];
        
//                        for (ExpressionViewController *v in compactExpressionViewControllers)
//                        {
//                            if ([v.name isEqualToString:classifierName])
//                            {
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    v.metric = classifierScore;
//                                });
//                            }
//                        }
                        
//                        for (ExpressionViewController *v in regularExpressionViewControllers)
//                        {
//                            if ([v.name isEqualToString:classifierName])
//                            {
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    v.metric = classifierScore;
//                                });
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}

- (void)unprocessedImageReady:(AFDXDetector *)detector image:(UIImage *)image atTime:(NSTimeInterval)time;
{
    __block EmotionDetectorViewController *weakSelf = self;
    __block UIImage *newImage = image;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (AFDXFace *face in self.faces) {
            
            
            // create array of images and rects to do all drawing at once
            NSMutableArray *imagesArray = [NSMutableArray array];
            NSMutableArray *rectsArray = [NSMutableArray array];
            
//            CGRect faceBounds = face.faceBounds;
//            NSLog(@"uclose: %.1f",face.expressions.eyeClosure);

            // do drawing here
            newImage = [AFDXDetector imageByDrawingPoints:nil
                                            andRectangles:weakSelf.faceRectsToDraw
                                                andImages:imagesArray
                                               withRadius:1.4
                                          usingPointColor:[UIColor whiteColor]
                                      usingRectangleColor:[UIColor whiteColor]
                                          usingImageRects:rectsArray
                                                  onImage:newImage];
        }
        
        // flip image if the front camera is being used so that the perspective is mirrored.
        if (self.cameraToUse == AFDX_CAMERA_FRONT)
        {
            UIImage *flippedImage = [UIImage imageWithCGImage:newImage.CGImage
                                                        scale:image.scale
                                                  orientation:UIImageOrientationUpMirrored];
            [weakSelf.imageView setImage:flippedImage];
        }
        else
        {
            [weakSelf.imageView setImage:newImage];
        }
        
    });
    
}

- (void)updateAlarmData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayOfAlarms = [NSMutableArray arrayWithArray:[defaults objectForKey:@"alarmList"]];
    //set isEnd to YES, reset next alarm date
    //Use these two variables to tell if the alarm should be triggered
    for (int i = 0; i<arrayOfAlarms.count; i++) {
        NSDictionary *alarmDic = [arrayOfAlarms objectAtIndex:i];
        if ([[alarmDic objectForKey:@"id"] isEqualToString:[self.alarmData objectForKey:@"id"]]) {
            NSDate *alarmDate = ((NSDate *)[alarmDic objectForKey:@"time"]);
            while ([alarmDate timeIntervalSinceNow]<0) {
                alarmDate = [NSDate dateWithTimeInterval:86400 sinceDate:alarmDate];
            }
            NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:alarmDate,@"time",[alarmDic objectForKey:@"isOn"],@"isOn",[alarmDic objectForKey:@"id"],@"id",[NSNumber numberWithBool:YES],@"isEnd",nil];
            [arrayOfAlarms removeObjectAtIndex:i];
            [arrayOfAlarms insertObject:newDict atIndex:i];
        }else{
            NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:[alarmDic objectForKey:@"time"],@"time",[alarmDic objectForKey:@"isOn"],@"isOn",[alarmDic objectForKey:@"id"],@"id",[NSNumber numberWithBool:YES],@"isEnd",nil];
            [arrayOfAlarms removeObjectAtIndex:i];
            [arrayOfAlarms insertObject:newDict atIndex:i];
        }
    }
    [defaults setObject:arrayOfAlarms forKey:@"alarmList"];
    
    if (self.ringName) {
        NSMutableDictionary *ringData = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:self.ringName]];
        if (!ringData) {
            ringData = [[NSMutableDictionary alloc]init];
            [ringData setObject:[NSNumber numberWithInteger:0] forKey:@"count"];
            [ringData setObject:[NSNumber numberWithFloat:0.0] forKey:@"avgtime"];
        }
        NSInteger count = ((NSNumber *)[ringData objectForKey:@"count"]).integerValue;
        CGFloat avgtime = ((NSNumber *)[ringData objectForKey:@"avgtime"]).floatValue;
        avgtime = ((avgtime*count+totalCostSeconds)/(count+1));
        count += 1;
//        NSLog(@"count = %li, avgtime = %f",(long)count,avgtime);
        [ringData setObject:[NSNumber numberWithInteger:count] forKey: @"count"];
        [ringData setObject:[NSNumber numberWithFloat:avgtime] forKey: @"avgtime"];
        [defaults setObject:ringData forKey:self.ringName];
    }
    [defaults synchronize];
}
#pragma mark - GestureRecognizer
#pragma mark LongPress
- (void)longPressed:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan && !isSuccess) {
        NSLog(@"long begin");
//        if (!isStart) {
//            [self startTimer];
//        }
//        isPress = YES;
    }else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateFailed){
        NSLog(@"long end");
        [self.timer invalidate];
        isSuccess = YES;
        self.topLabel.textColor = [UIColor colorWithRed:0.24 green:0.66 blue:0.00 alpha:1.00];
        self.topLabel.text = [NSString stringWithFormat:@"You take %.1f seconds to wake up.\n Have a nice day!",totalCostSeconds];
        self.circleView.titleLabel.text = @"Success!";
        self.circleView.titleLabel.textColor = [UIColor darkGrayColor];
        NSLog(@"Compelete");
        [self stopPlayer];
        [self stopDetector];
////        [self stopTimer];
//        isPress = NO;
//        if (isSuccess) {
//            [self.timer invalidate];
//            [self stopDetector];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
    }
}
#pragma mark Tap
- (void)tapped:(UITapGestureRecognizer *)tap{
    if (isSuccess) {
        [self.timer invalidate];
        [self stopDetector];
//        [self stopPlayer];
//        [self updateAlarmData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - Alert
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:dismiss];
    [self showViewController:alert sender:nil];
}

#pragma mark - Detector
- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(UIImage *)image atTime:(NSTimeInterval)time{
    if (nil == faces)
    {
        [self unprocessedImageReady:detector image:image atTime:time];
    }
    else
    {
        [self processedImageReady:detector image:image faces:faces atTime:time];
    }
}

- (void)stopDetector{
    [self.detector stop];
}

- (void)startDetector{
    [self.detector stop];

    // create a detector with our desired facial expresions, using the front facing camera
    self.detector = [[AFDXDetector alloc] initWithDelegate:self usingCamera:self.cameraToUse maximumFaces:1];

    [self.detector enableAnalytics];
    
    NSInteger maxProcessRate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"maxProcessRate"] integerValue];
    if (0 == maxProcessRate)
    {
        maxProcessRate = 5;
    }
    
    self.detector.maxProcessRate = maxProcessRate;
//    self.dateOfLastFrame = nil;
//    self.dateOfLastProcessedFrame = nil;
    
    self.detector.joy = YES;
    self.detector.eyeClosure = YES;
    self.detector.eyeWiden = YES;

    // tell the detector which facial expressions we want to measure
//#define ENABLE_ALL_CLASSIFIERS    0  // 1 to enable all classifiers, 0 for minimum set
//#if ENABLE_ALL_CLASSIFIERS  // Enable everything for firehose testing
//    [self.detector setDetectAllAppearances:YES];
//    [self.detector setDetectAllEmotions:YES];
//    [self.detector setDetectAllExpressions:YES];
//    [self.detector setDetectEmojis:YES];
//#else
//    [self.detector setDetectAllAppearances:YES];
//    [self.detector setDetectAllEmotions:NO];
//    [self.detector setDetectAllExpressions:NO];
//    [self.detector setDetectEmojis:YES];
//    self.detector.valence = TRUE;
//#endif
    
//    for (NSString *s in self.selectedClassifiers)
//    {
//        for (NSArray *a in self.availableClassifiers)
//        {
//            for (NSDictionary *d in a) {
//                if ([s isEqualToString:[d objectForKey:@"name"]])
//                {
//                    NSString *pn = [d objectForKey:@"propertyName"];
//                    if (nil != pn) {
//                        [self.detector setValue:[NSNumber numberWithBool:YES] forKey:pn];
//                    } else {
//                        [self.detector setDetectEmojis:YES];
//                    }
//                    break;
//                }
//            }
//        }
//    }
    
    // let's start it up!
    NSError *error = [self.detector start];
    
    if (nil != error)
    {
        [self showAlertWithTitle:@"Detector Error" message:[error localizedDescription]];
        
        return;
    }
    [self startPlayer];
    
}
#pragma mark - AudioPlayer
- (void)startPlayer{
//    NSString * path=[[NSBundle mainBundle]pathForResource:self.ringName ofType:@"caf"];
//    NSURL * url=[NSURL fileURLWithPath:path];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
//    AudioServicesPlaySystemSound(soundID);
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.player prepareToPlay]) {
        [self.player play];
    }
}

- (void)stopPlayer{
//    AudioServicesDisposeSystemSoundID(soundID);

    [self.player stop];
}

#pragma mark - Lazy Load
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        [_topLabel addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UILabel *)topLabel{
    if (!_topLabel) {
        _topLabel = [[UILabel alloc]init];
        [_topLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont fontWithName:@"SquareFont" size:25];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.shadowColor = [UIColor blackColor];
        _topLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _topLabel.textColor = [UIColor grayColor];
        _topLabel.text = @"Please keep your face in the white square";
        _topLabel.numberOfLines = 2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        [_topLabel addGestureRecognizer:tap];
    }
    return _topLabel;
}

- (HWWaveView *)circleView{
    if (!_circleView) {
        _circleView = [[HWWaveView alloc]initWithFrame:CGRectZero];
        [_circleView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _circleView.progress = 0;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
        [_circleView addGestureRecognizer:longPress];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        [_circleView addGestureRecognizer:tap];
    }
    return _circleView;
}

- (AVAudioPlayer *)player{
    if (!_player) {
        NSString * path=[[NSBundle mainBundle]pathForResource:self.ringName ofType:@"caf"];
        NSURL * url=[NSURL fileURLWithPath:path];
        NSError * error;
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);


        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player.numberOfLoops = -1;
        _player.volume = 1;
    }
    return _player;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
#pragma mark - Timer
- (void)timerAction
{
    self.circleView.progress += 0.01;
    totalCostSeconds += (timerInterval);
    if (self.circleView.progress >= 1) {
        isSuccess = YES;
        self.topLabel.textColor = [UIColor colorWithRed:0.24 green:0.66 blue:0.00 alpha:1.00];
        self.topLabel.text = [NSString stringWithFormat:@"You take %.1f seconds to wake up.\n Have a nice day!",totalCostSeconds];
        self.circleView.titleLabel.text = @"Success!";
        self.circleView.titleLabel.textColor = [UIColor darkGrayColor];
        NSLog(@"Compelete");
        [self stopTimer];
        [self stopPlayer];
        [self updateAlarmData];
    }
}

- (void)startTimer
{
    isSuccess = NO;
    firstFail = NO;
    secondFail = NO;
    isStart = YES;
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)stopTimer
{
    [self.timer setFireDate:[NSDate distantFuture]];
    isStart = NO;
    firstFail = NO;
    secondFail = NO;
    if (!isSuccess) {
        self.circleView.progress = 0;
    }
    
}

- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}


@end
