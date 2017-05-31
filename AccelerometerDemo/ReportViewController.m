//
//  ReportViewController.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import "ReportViewController.h"
#import "AppController.h"
#import "AccelerometerDemo-Swift.h"
#import "EverChart.h"

@interface ReportViewController ()

@property (strong, nonatomic) EverChart *fenshiChart;
@property (weak, nonatomic) IBOutlet UIView *graphContainer;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) GraphViewController *graphViewController;
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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    [self renderChart:responseObject];
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
    if (selectedIndex == 0) {
        [_graphViewController updateData:[[AppController shared] all] option:0];
    }
    if (selectedIndex == 1) {
        [_graphViewController updateData:[[AppController shared] all] option:1];
    }
    if (selectedIndex == 2) {
        [_graphViewController updateData:[[AppController shared] all] option:2];
    }
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
    [secs addObject:@"2"];
    [secs addObject:@"1"];
    
    [self.fenshiChart addSections:2 withRatios:secs];
    [[[self.fenshiChart sections] objectAtIndex:0] addYAxis:0];
    [[[self.fenshiChart sections] objectAtIndex:1] addYAxis:0];
    
    [self.fenshiChart getYAxis:0 withIndex:0].tickInterval = 4;
    [self.fenshiChart getYAxis:1 withIndex:0].tickInterval = 2;
    self.fenshiChart.range = 241;
    
    NSMutableArray *series = [[NSMutableArray alloc] init];
    
    NSMutableArray *secOne = [[NSMutableArray alloc] init];
    NSMutableArray *secTwo = [[NSMutableArray alloc] init];
    
    //均价
    NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiAvgNameLine forKey:@"name"];
    [serie setObject:@"均价" forKey:@"label"];
    [serie setObject:data forKey:@"data"];
    [serie setObject:kFenShiLine forKey:@"type"];
    [serie setObject:@"0" forKey:@"yAxisType"];
    [serie setObject:@"0" forKey:@"section"];
    [serie setObject:kFenShiAvgColor forKey:@"color"];
    [series addObject:serie];
    [secOne addObject:serie];
    
    
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
    
    //VOL
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiVolNameColumn forKey:@"name"];
    [serie setObject:@"量" forKey:@"label"];
    [serie setObject:data forKey:@"data"];
    [serie setObject:kFenShiColumn forKey:@"type"];
    [serie setObject:@"1" forKey:@"section"];
    [serie setObject:@"0" forKey:@"decimal"];
    [series addObject:serie];
    [secTwo addObject:serie];
    
    [self.fenshiChart setSeries:series];
    
    [[[self.fenshiChart sections] objectAtIndex:0] setSeries:secOne];
    [[[self.fenshiChart sections] objectAtIndex:1] setSeries:secTwo];
    
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;{
    [serie setObject:[options objectForKey:@"name"] forKey:@"name"];
    [serie setObject:[options objectForKey:@"label"] forKey:@"label"];
    [serie setObject:[options objectForKey:@"type"] forKey:@"type"];
    [serie setObject:[options objectForKey:@"yAxis"] forKey:@"yAxis"];
    [serie setObject:[options objectForKey:@"section"] forKey:@"section"];
    [serie setObject:[options objectForKey:@"color"] forKey:@"color"];
}


- (void)renderChart:(NSDictionary *)responseObject{
    
    [self.fenshiChart reset];
    [self.fenshiChart clearData];
    [self.fenshiChart clearCategory];
    
    NSMutableArray *data1 =[[NSMutableArray alloc] init];
    NSMutableArray *data2 =[[NSMutableArray alloc] init];
    NSMutableArray *data3 =[[NSMutableArray alloc] init];
    
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    NSArray *listArray = responseObject[@"newList"];
    NSArray *closeYesterday = responseObject[@"yesterdayEndPri"];
    
    for (int i = 0;i<listArray.count;i++) {
        
        NSDictionary *dic = listArray[i];
        [category addObject:dic[@"dateTime"]];
        
        NSArray *item1 = @[dic[@"maTimeSharing"],closeYesterday];
        NSArray *item2 = @[dic[@"nowPri"],closeYesterday];
        
        NSString *volume = [NSString stringWithFormat:@"%d",[dic[@"traNumber"] intValue]/100];
        NSArray *item3 = @[volume,dic[@"nowPri"],closeYesterday];
        
        [data1 addObject:item1];
        [data2 addObject:item2];
        [data3 addObject:item3];
        
    }
    
    [self.fenshiChart appendToData:data1 forName:kFenShiAvgNameLine];
    [self.fenshiChart appendToData:data2 forName:kFenShiNowNameLine];
    [self.fenshiChart appendToData:data3 forName:kFenShiVolNameColumn];
    
    [self.fenshiChart appendToCategory:category forName:kFenShiAvgNameLine];
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
