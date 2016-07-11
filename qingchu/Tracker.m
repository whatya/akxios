//
//  Tracker.m
//  elevator
//
//  Created by 张宝 on 16/5/11.
//  Copyright © 2016年 张宝. All rights reserved.
//

#import "Tracker.h"

@implementation Tracker

+ (Tracker *)shared
{
    static dispatch_once_t once = 0;
    static Tracker *tracker;
    dispatch_once(&once, ^{ tracker = [[Tracker alloc] init]; });
    return tracker;
}

- (void)initLocationManager
{
    self.manager = [[CLLocationManager alloc] init];
    
    self.manager.delegate = self;
    
    // 设置定位精度
    // kCLLocationAccuracyNearestTenMeters:精度10米
    // kCLLocationAccuracyHundredMeters:精度100 米
    // kCLLocationAccuracyKilometer:精度1000 米
    // kCLLocationAccuracyThreeKilometers:精度3000米
    // kCLLocationAccuracyBest:设备使用电池供电时候最高的精度
    // kCLLocationAccuracyBestForNavigation:导航情况下最高精度，一般要有外接电源时才能使用
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // distanceFilter是距离过滤器，为了减少对定位装置的轮询次数，位置的改变不会每次都去通知委托，而是在移动了足够的距离时才通知委托程序
    // 它的单位是米，这里设置为至少移动1000再通知委托处理更新;
    self.manager.distanceFilter = 20; // 如果设为kCLDistanceFilterNone，则每秒更新一次;
    
    [self.manager requestAlwaysAuthorization];
    
    [self.manager startUpdatingLocation];
    
}

- (void)currentTime
{
    self.currentDate = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self currentTime];
    });
}

#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 获取经纬度
    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
    self.lon = newLocation.coordinate.longitude;
    self.lat = newLocation.coordinate.latitude;
    
    // 停止位置更新
    //[manager stopMonitoringSignificantLocationChanges];
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

@end
