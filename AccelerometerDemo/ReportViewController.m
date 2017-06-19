//
//  ReportViewController.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import "ReportViewController.h"
#import "AppController.h"
#import "EverChart.h"

@interface ReportViewController ()

@property (strong, nonatomic) EverChart *fenshiChart;
@property (weak, nonatomic) IBOutlet UIView *graphContainer;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *metricSegment;
    
@end

@implementation ReportViewController {
    NSUInteger selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGraphView];
}

- (void) addGraphView {
    
    CGFloat width = MAX(self.graphContainer.frame.size.width, self.graphContainer.frame.size.height);
    CGFloat height = MIN(self.graphContainer.frame.size.width, self.graphContainer.frame.size.height);
    
    self.fenshiChart = [[EverChart alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    [self.graphContainer addSubview:self.fenshiChart];
    
    [self initFenShiChart];
    
    [self renderChart:1];
}

- (void)viewDidLayoutSubviews {
    self.fenshiChart.frame = self.graphContainer.bounds;
}

- (IBAction)doneDidTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[AppController shared] restart];
    }];
}

- (IBAction)metricSegmentDicChanged:(id)sender {
    selectedIndex = _metricSegment.selectedSegmentIndex;
}

- (IBAction)didSelectUpdate:(id)sender {
    [self renderChart:selectedIndex];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}


#pragma mark - Chart Action

-(void)initFenShiChart{
    
    NSMutableArray *padding = [NSMutableArray arrayWithObjects:@"0",@"0",@"20",@"5",nil];
    [self.fenshiChart setPadding:padding];
    NSMutableArray *secs = [[NSMutableArray alloc] init];
    [secs addObject:@"1"];
    [self.fenshiChart addSections:1 withRatios:secs];
    [[[self.fenshiChart sections] objectAtIndex:0] addYAxis:0];
    [self.fenshiChart getYAxis:0 withIndex:0].tickInterval = 1;
    self.fenshiChart.range = 241;
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
    [serie setObject:@"1" forKey:@"yAxisType"];
    [serie setObject:@"0" forKey:@"section"];
    [serie setObject:kFenShiNowColor forKey:@"color"];
    [series addObject:serie];
    [secOne addObject:serie];
    [self.fenshiChart setSeries:series];
    [[[self.fenshiChart sections] objectAtIndex:0] setSeries:secOne];
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie {
    [serie setObject:[options objectForKey:@"name"] forKey:@"name"];
    [serie setObject:[options objectForKey:@"label"] forKey:@"label"];
    [serie setObject:[options objectForKey:@"yAxis"] forKey:@"yAxis"];
    [serie setObject:[options objectForKey:@"section"] forKey:@"section"];
    [serie setObject:[options objectForKey:@"color"] forKey:@"color"];
}

- (void)renderChart:(NSInteger)index {
    
    [self.fenshiChart reset];
    [self.fenshiChart clearData];
    [self.fenshiChart clearCategory];
    
    NSMutableArray *records =[[NSMutableArray alloc] init];
    
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    NSArray *listArray = [[AppController shared] all];
    
    for (int i = 0; i<listArray.count; i++) {
        
        Acceleration *dic = listArray[i];
        
        if (dic == nil) {
            continue;
        }
        
        [category addObject:dic.time];
        
        switch (index) {
            case 0: {
                NSArray *xRecords = @[@(dic.data.x)];
                [records addObject:xRecords];
            }
                break;
            case 1: {
                NSArray *yRecords = @[@(dic.data.y)];
                [records addObject:yRecords];
            }
                break;
            case 2: {
                NSArray *zRecords = @[@(dic.data.z)];
                [records addObject:zRecords];
            }
                break;
            default:
                break;
        }
        
        
    }
    
    [self.fenshiChart appendToData:records forName:kFenShiNowNameLine];
    [self.fenshiChart appendToCategory:category forName:kFenShiNowNameLine];
    
    [self.fenshiChart setNeedsDisplay];
    
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
