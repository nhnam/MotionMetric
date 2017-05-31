//
//  AppController.h
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Acceleration.h"

NS_ASSUME_NONNULL_BEGIN

@protocol StartController <NSObject>
- (void)trackingDone;
@end

@interface AppController : NSObject

@property(weak, nonatomic) id<StartController> startController;

+(instancetype)shared;
-(void)stopTracking;
-(void)restart;
-(Motion)last;
-(void)addAccele:(CMAcceleration)data;
-(void)addGyro:(CMRotationRate)data;
-(NSArray<Acceleration*>*)all;
-(NSArray<Acceleration*>*)last10;
-(void)commit;
@end

NS_ASSUME_NONNULL_END
