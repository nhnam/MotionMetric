//
//  TrackingViewController.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <MSSimpleGauge/MSRangeGauge.h>
#import "TrackingViewController.h"
#import "AppController.h"
#import "AccelerometerDemo-Swift.h"

@interface TrackingViewController ()
@property (weak, nonatomic) IBOutlet UIView *timerContainer;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *trackingContainer;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *countingLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *xBar;
@property (weak, nonatomic) IBOutlet UIProgressView *yBar;
@property (weak, nonatomic) IBOutlet UIProgressView *zBar;
@property (weak, nonatomic) IBOutlet UIView *graphContainer;
@property (weak, nonatomic) IBOutlet UISwitch *acceleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *gyroSwitch;
@property (strong, nonatomic) MSRangeGauge *xGauge;
@property (strong, nonatomic) MSRangeGauge *yGauge;
@property (strong, nonatomic) MSRangeGauge *zGauge;
@property (weak, nonatomic) IBOutlet UIView *xContainer;
@property (weak, nonatomic) IBOutlet UIView *yContainer;
@property (weak, nonatomic) IBOutlet UIView *zContainer;

@end

@implementation TrackingViewController {
    NSTimer *countDownTimer;
    NSInteger countDown;
    CGFloat trackedTime;
    NSTimer *trackingTimer;
    CMMotionManager *motionManager;
    Motion record;
    NSOperationQueue *gyroMotionQueue;
    NSOperationQueue *acceleMotionQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    countDown = 3;
    trackedTime = 0.0;
    [_timerContainer setHidden:NO];
    [_trackingContainer setHidden:YES];
    [_acceleSwitch setOn:NO];
    [_gyroSwitch setOn:YES];
    
    motionManager = [[CMMotionManager alloc] init];
    [motionManager setAccelerometerUpdateInterval:0.01];
    [motionManager setGyroUpdateInterval:0.01];
    acceleMotionQueue = [[NSOperationQueue alloc] init];
    gyroMotionQueue = [[NSOperationQueue alloc] init];
    
    _xGauge = [[MSRangeGauge alloc] initWithFrame:_xContainer.bounds];
    _yGauge = [[MSRangeGauge alloc] initWithFrame:_yContainer.bounds];
    _zGauge = [[MSRangeGauge alloc] initWithFrame:_zContainer.bounds];
    
    [_xContainer addSubview:_xGauge];
    [_yContainer addSubview:_yGauge];
    [_zContainer addSubview:_zGauge];
    
    for(MSRangeGauge* view in @[_xGauge,_yGauge,_zGauge]) {
        view.minValue = 0;
        view.maxValue = 100;
        view.upperRangeValue = 80;
        view.lowerRangeValue = 20;
        view.value = 50;
        view.rangeFillColor = [UIColor colorWithRed:.41 green:.76 blue:.73 alpha:1];
    }
    
    if( motionManager.isGyroAvailable ) {
        [motionManager startGyroUpdatesToQueue:gyroMotionQueue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            [[AppController shared] addGyro:gyroData.rotationRate];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startCountDown];
}

- (IBAction)switcherValueDidChanged:(id)sender {
    [self stateChanged];
}


- (void)startTrackingMotion {
    [self stateChanged];
}

- (void)stateChanged {
    if (_acceleSwitch.isOn) {
        if(motionManager.isAccelerometerAvailable) {
            [motionManager startAccelerometerUpdatesToQueue:acceleMotionQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                [[AppController shared] addAccele:accelerometerData.acceleration];
            }];
        }
        [_gyroSwitch setOn:NO];
        return;
    } else if (motionManager.isAccelerometerActive){
        [motionManager stopAccelerometerUpdates];
    }
    
    if (_gyroSwitch.isOn) {
        if( motionManager.isGyroAvailable ) {
            [motionManager startGyroUpdatesToQueue:gyroMotionQueue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
                [[AppController shared] addGyro:gyroData.rotationRate];
            }];
        }
        [_acceleSwitch setOn:NO];
        return;
    } else if (motionManager.isGyroActive) {
        [motionManager stopGyroUpdates];
    }
}

- (void)startCountDown  {
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDownUpdate:) userInfo:nil repeats:YES];
}

- (void)countDownUpdate:(NSTimer*)timer {
    if(countDown > 0) {
        countDown --;
        dispatch_async(dispatch_queue_create("com.nhn.countdowntimer", 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_timerLabel setText:(countDown > 0) ? [NSString stringWithFormat:@"%@", @(countDown)] : @"BUMP!"];
                [self startTrackingMotion];
            });
        });
    } else {
        [self startTrackingTimer];
        [countDownTimer invalidate];
    }
}

- (void)startTrackingTimer  {
    [_timerContainer setHidden:YES];
    [_trackingContainer setHidden:NO];
    trackingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(trackingUpdate:) userInfo:nil repeats:YES];
}

- (void)trackingUpdate:(NSTimer*)timer {
    trackedTime += 0.01;
    dispatch_async(dispatch_queue_create("com.nhn.trackingtimer", 0), ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [_countingLabel setText:[NSString stringWithFormat:@"%2.2f", trackedTime]];
           record = [[AppController shared] last];
           [_xBar setProgress:fabs(record.x)];
           [_yBar setProgress:fabs(record.y)];
           [_zBar setProgress:fabs(record.z)];
           [_xGauge setValue: (record.x*10)+50 animated:NO];
           [_yGauge setValue: (record.y*10)+50 animated:NO];
           [_zGauge setValue: (record.z*10)+50 animated:NO];
       });
    });
}

- (IBAction)stopDidTouch:(id)sender {
    [trackingTimer invalidate];
    [motionManager stopAccelerometerUpdates];
    [self dismissViewControllerAnimated:YES completion:^{
        [[AppController shared] stopTracking];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
