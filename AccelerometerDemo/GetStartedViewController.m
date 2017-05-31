//
//  GetStartedViewController.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import "GetStartedViewController.h"
#import "AppController.h"

@interface GetStartedViewController () <StartController>
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation GetStartedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AppController shared] setStartController:self];
}

- (void)trackingDone {
    [self performSegueWithIdentifier:@"toReport" sender:self];
}

- (IBAction)startDidTouch:(id)sender {
    [self performSegueWithIdentifier:@"toStart" sender:self];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"%@", event);
    }
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
