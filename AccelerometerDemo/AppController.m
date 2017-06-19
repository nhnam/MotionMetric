//
//  AppController.m
//  AccelerometerDemo
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 Benjamin. All rights reserved.
//

#import "AppController.h"
#import <Realm/Realm.h>

@interface AppController()
@property(strong, nonatomic,readonly) NSMutableArray<Acceleration*>* accelerations;
@end

@implementation AppController {
    long offset;
    long count;
}

+(instancetype)shared {
    static AppController *_instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

-(id)init {
    if(self = [super init]){
        _accelerations = [[NSMutableArray<Acceleration*> alloc] init];
        _originDate = [NSDate date];
    }
    return self;
}

-(void)stopTracking {
    if(_startController && [_startController respondsToSelector:@selector(trackingDone)]) {
        [_startController performSelector:@selector(trackingDone) withObject:nil];
    }
}

-(void)restart {
    @synchronized (self) {
        [_accelerations removeAllObjects];
        _originDate = [NSDate date];
        NSLog(@"Reset gyro data. %ld records. %@", _accelerations.count, _originDate);
    }
}

-(Motion)last {
    Motion data;
    data.x = 0;
    data.y = 0;
    data.z = 0;
    if(_accelerations.count > 0) {
        data = [_accelerations lastObject].data;
    }
    return data;
}

-(void)addAccele:(CMAcceleration)data {
    Acceleration *acc = [[Acceleration alloc] init];
    Motion motion;
    motion.x = data.x;
    motion.y = data.y;
    motion.z = data.z;
    acc.data = motion;
    acc.timetamp = [NSDate dateWithTimeInterval:0 sinceDate:_originDate];
    [_accelerations addObject:acc];
}

-(void)addGyro:(CMRotationRate)data {
    Acceleration *acc = [[Acceleration alloc] init];
    Motion motion;
    motion.x = data.x;
    motion.y = data.y;
    motion.z = data.z;
    acc.data = motion;
    acc.timetamp = [NSDate dateWithTimeInterval:0 sinceDate:_originDate];
    [_accelerations addObject:acc];
}

-(NSArray<Acceleration*>*)all {
    NSArray *allData = [_accelerations copy];
    count = allData.count;
    return allData;
}

-(NSArray<Acceleration*>*)newData {
    NSArray *allData = [_accelerations copy];
    count = allData.count - 1;
    NSArray *newData = [allData subarrayWithRange:NSMakeRange(offset, count - offset)];
    offset = allData.count - 1;
    return newData;
}

-(NSArray<Acceleration*>*)last10 {
    NSRange endRange = NSMakeRange(_accelerations.count >= 10 ? _accelerations.count - 10 : 0, MIN(_accelerations.count, 10));
    NSArray *lastTenObjects= [_accelerations subarrayWithRange:endRange];
    return lastTenObjects;
}

-(void)commit {
    @synchronized (self) {
        [[NSUserDefaults standardUserDefaults] setObject:_accelerations forKey:@"accelerations"];
        [_accelerations removeAllObjects];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accelerations"]);
    }
}

@end
