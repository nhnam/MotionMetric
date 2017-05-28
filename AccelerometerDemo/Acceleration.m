//
//  Acceleration.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import "Acceleration.h"

@implementation Acceleration
-(void)setTimetamp:(NSDate *)newValue {
    _timetamp = newValue;
    dispatch_async(dispatch_queue_create("com.acceleration.generate_time", 0), ^{
        NiceDate *niceDate = [NiceDate niceDate];
        niceDate.date = newValue;
        niceDate.format = @"hh:mm:ss";
        _time = [niceDate description];
    });
}
@end
