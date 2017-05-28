//
//  TrackingViewController.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
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
@property (strong, nonatomic) GraphViewController *graphViewController;

@end

@implementation TrackingViewController {
    NSTimer *countDownTimer;
    NSInteger countDown;
    CGFloat trackedTime;
    NSTimer *trackingTimer;
    CMMotionManager *motionManager;
    CMAcceleration record;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    countDown = 3;
    trackedTime = 0.0;
    [_timerContainer setHidden:NO];
    [_trackingContainer setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addGraphView];
    [self startCountDown];
}

- (void)startTrackingMotion {
    motionManager = [[CMMotionManager alloc] init];
    [motionManager setAccelerometerUpdateInterval:0.1];
    [motionManager setGyroUpdateInterval:0.1];
    NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
    [motionManager startAccelerometerUpdatesToQueue:motionQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        NSLog(@"X:%2.1f Y:%2.1f Z:%2.1f", accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z);
        [[AppController shared] add:accelerometerData.acceleration];
    }];
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
    trackingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(trackingUpdate:) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.graphViewController updateData:[[AppController shared] last10] option: 0];
        });
    }];
}

- (void)trackingUpdate:(NSTimer*)timer {
    trackedTime += 0.1;
    dispatch_async(dispatch_queue_create("com.nhn.trackingtimer", 0), ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [_countingLabel setText:[NSString stringWithFormat:@"%2.2f", trackedTime]];
           record = [[AppController shared] last];
           [_xBar setProgress:fabs(record.x)];
           [_yBar setProgress:fabs(record.y)];
           [_zBar setProgress:fabs(record.z)];
       });
    });
}

- (void) addGraphView {
    GraphViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"aloneGraphViewController"];
    if(_graphViewController) {
        [_graphViewController didMoveToParentViewController:nil];
        [_graphViewController.view removeFromSuperview];
        [_graphViewController removeFromParentViewController];
    }
    [self addChildViewController:vc];
    vc.view.frame = _graphContainer.bounds;
    [_graphContainer addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    _graphViewController = vc;
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
