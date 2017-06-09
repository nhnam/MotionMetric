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
#import "EverChart.h"

@interface TrackingViewController ()
@property (weak, nonatomic) IBOutlet UIView *timerContainer;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *trackingContainer;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *countingLabel;
@property (weak, nonatomic) IBOutlet UIView *graphContainer;
@property (weak, nonatomic) IBOutlet UISwitch *acceleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *gyroSwitch;
@property (weak, nonatomic) IBOutlet UIView *xContainer;
@property (weak, nonatomic) IBOutlet UIView *yContainer;
@property (weak, nonatomic) IBOutlet UIView *zContainer;

@property (strong, nonatomic) EverChart *chartX;
@property (strong, nonatomic) EverChart *chartY;
@property (strong, nonatomic) EverChart *chartZ;

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
    
    if( motionManager.isGyroAvailable ) {
        [motionManager startGyroUpdatesToQueue:gyroMotionQueue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            [[AppController shared] addGyro:gyroData.rotationRate];
        }];
    }
    
    [self addGraphView];
}

- (void) addGraphView {
    
    CGFloat width = MAX(self.xContainer.frame.size.width, self.xContainer.frame.size.height);
    CGFloat height = MIN(self.xContainer.frame.size.width, self.xContainer.frame.size.height);
    
    self.chartX = [[EverChart alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    self.chartX.userInteractionEnabled = false;
    [self.xContainer addSubview:self.chartX];
    
    self.chartY = [[EverChart alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.chartY.userInteractionEnabled = false;
    [self.yContainer addSubview:self.chartY];
    
    self.chartZ = [[EverChart alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.chartZ.userInteractionEnabled = false;
    [self.zContainer addSubview:self.chartZ];
    
    [self initMiniChart];
    
    [self renderChart];
}

- (void)viewDidLayoutSubviews {
    self.chartX.frame = self.xContainer.bounds;
    self.chartY.frame = self.yContainer.bounds;
    self.chartZ.frame = self.zContainer.bounds;
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
    trackingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(trackingUpdate:) userInfo:nil repeats:YES];
}

- (void)trackingUpdate:(NSTimer*)timer {
    trackedTime += 0.1;
    dispatch_async(dispatch_queue_create("com.nhn.trackingtimer", 0), ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [_countingLabel setText:[NSString stringWithFormat:@"%2.2f", trackedTime]];
           record = [[AppController shared] last];
           
           [self renderChart];
       });
    });
}

-(void)initMiniChart{
    
    NSMutableArray *paddingx = [NSMutableArray arrayWithObjects:@"0",@"0",@"20",@"5",nil];
    [self.chartX setPadding:paddingx];
    
    NSMutableArray *paddingy = [NSMutableArray arrayWithArray:paddingx];
    [self.chartX setPadding:paddingy];
    
    NSMutableArray *paddingz = [NSMutableArray arrayWithArray:paddingx];
    [self.chartX setPadding:paddingz];
    
    NSMutableArray *secsx = [[NSMutableArray alloc] init];
    
    [secsx addObject:@"1"];
    
    [self.chartX addSections:1 withRatios:secsx];
    
    [[[self.chartX sections] objectAtIndex:0] addYAxis:0];
    
    [self.chartX getYAxis:0 withIndex:0].tickInterval = 4;
    
    self.chartX.range = 241;
    
    NSMutableArray *secsy = [NSMutableArray arrayWithArray:secsx];
    
    [self.chartY addSections:1 withRatios:secsy];
    
    [[[self.chartY sections] objectAtIndex:0] addYAxis:0];
    
    [self.chartY getYAxis:0 withIndex:0].tickInterval = 4;
    
    self.chartY.range = 241;
    
    NSMutableArray *secsz = [NSMutableArray arrayWithArray:secsx];
    
    [self.chartZ addSections:1 withRatios:secsz];
    
    [[[self.chartZ sections] objectAtIndex:0] addYAxis:0];
    
    [self.chartZ getYAxis:0 withIndex:0].tickInterval = 4;
    
    self.chartZ.range = 241;
    
    NSMutableArray *series = [[NSMutableArray alloc] init];
    NSMutableArray *secOne = [[NSMutableArray alloc] init];
    
    //    //均价
    NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    //实时价
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiNowNameLine forKey:@"name"];
    [serie setObject:@"数值" forKey:@"label"];
    [serie setObject:data forKey:@"data"];
    [serie setObject:kFenShiLine forKey:@"type"];
    [serie setObject:@"1" forKey:@"yAxisType"];
    [serie setObject:@"0" forKey:@"section"];
    [serie setObject:kFenShiNowColor forKey:@"color"];
    [series addObject:serie];
    [secOne addObject:serie];
    
    [self.chartX setSeries:series];
    [[[self.chartX sections] objectAtIndex:0] setSeries:secOne];
    
    NSMutableArray *seriesy = [NSMutableArray arrayWithArray:series];
    NSMutableArray *secOney = [NSMutableArray arrayWithArray:secOne];
    [self.chartY setSeries:seriesy];
    [[[self.chartY sections] objectAtIndex:0] setSeries:secOney];
    
    NSMutableArray *seriesz = [NSMutableArray arrayWithArray:series];
    NSMutableArray *secOnez = [NSMutableArray arrayWithArray:secOne];
    [self.chartZ setSeries:seriesz];
    [[[self.chartZ sections] objectAtIndex:0] setSeries:secOnez];
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie {
    [serie setObject:[options objectForKey:@"name"] forKey:@"name"];
    [serie setObject:[options objectForKey:@"label"] forKey:@"label"];
    [serie setObject:[options objectForKey:@"type"] forKey:@"type"];
    [serie setObject:[options objectForKey:@"yAxis"] forKey:@"yAxis"];
    [serie setObject:[options objectForKey:@"section"] forKey:@"section"];
    [serie setObject:[options objectForKey:@"color"] forKey:@"color"];
}

- (void)renderChart {
    
    [self.chartX reset];
    [self.chartX clearData];
    [self.chartX clearCategory];
    
    [self.chartY reset];
    [self.chartY clearData];
    [self.chartY clearCategory];
    
    [self.chartZ reset];
    [self.chartZ clearData];
    [self.chartZ clearCategory];
    
    NSMutableArray *datax =[[NSMutableArray alloc] init];
    NSMutableArray *datay =[[NSMutableArray alloc] init];
    NSMutableArray *dataz =[[NSMutableArray alloc] init];
    
    NSMutableArray *categoryx =[[NSMutableArray alloc] init];
    NSMutableArray *categoryy =[[NSMutableArray alloc] init];
    NSMutableArray *categoryz =[[NSMutableArray alloc] init];
    
    NSArray *listArray = [[AppController shared] all];
    
    for (int i = 0;i<listArray.count;i++) {
        
        Acceleration *dic = listArray[i];
        [categoryx addObject:dic.timetamp];
        [categoryy addObject:dic.timetamp];
        [categoryz addObject:dic.timetamp];
        
                NSArray *item1 = @[@(dic.data.x)];
                [datax addObject:item1];
        
                item1 = @[@(dic.data.y)];
                [datay addObject:item1];

                item1 = @[@(dic.data.z)];
                [dataz addObject:item1];
    }
    
    [self.chartX appendToData:datax forName:kFenShiNowNameLine];
    [self.chartX appendToCategory:categoryx forName:kFenShiNowNameLine];
    
    [self.chartY appendToData:datay forName:kFenShiNowNameLine];
    [self.chartY appendToCategory:categoryy forName:kFenShiNowNameLine];
    
    [self.chartZ appendToData:dataz forName:kFenShiNowNameLine];
    [self.chartZ appendToCategory:categoryz forName:kFenShiNowNameLine];
    
    [self.chartX setNeedsDisplay];
    [self.chartY setNeedsDisplay];
    [self.chartZ setNeedsDisplay];
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
