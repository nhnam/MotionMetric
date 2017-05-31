//
//  Acceleration.h
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "NiceDate.h"

typedef struct Motion{
    double x;
    double y;
    double z;
} Motion;

@interface Acceleration : NSObject
@property(assign, nonatomic) Motion data;
@property(strong, nonatomic) NSDate *timetamp;
@property(strong, nonatomic) NSString *time;
@end
