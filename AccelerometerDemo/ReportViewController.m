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

@interface ReportViewController ()

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
