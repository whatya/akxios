//
//  Tracker.h
//  elevator
//
//  Created by 张宝 on 16/5/11.
//  Copyright © 2016年 张宝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Tracker : NSObject<CLLocationManagerDelegate>

@property(nonatomic,strong) NSDate *currentDate;
@property(nonatomic,assign) double lon;//经度
@property(nonatomic,assign) double lat;//纬度

@property(nonatomic,strong) CLLocationManager *manager;

+ (Tracker *)shared;
- (void)initLocationManager;
- (void)currentTime;

@end
