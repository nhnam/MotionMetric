//
//  Acceleration.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import "Acceleration.h"
#import "AppController.h"

@implementation Acceleration

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void)setTimetamp:(NSDate *)newValue {
    _timetamp = newValue;
    dispatch_async(dispatch_queue_create("com.acceleration.generate_time", 0), ^{
        NiceDate *niceDate = [NiceDate niceDate];
        niceDate.date = newValue;
        niceDate.format = @"mm:ss";
        _time = [niceDate description];
    });
}

- (NSString*)description {
    return [NSString stringWithFormat:@"(%2.1f,%2.1f, %2.1f) %@", _data.x,_data.y,_data.z, _time];
}

@end
