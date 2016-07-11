//
//  Clock.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/7.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "Clock.h"

@implementation Clock


- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _clockTime = dictionary[clockTime_key];
        _cid = dictionary[cid_key];
        _imei = dictionary[imei_key];
        _isValid = dictionary[isValid_key];
        
        _msgId = dictionary[msgId_key];
        _schedule = dictionary[schedule_key];
        _startDate = dictionary[startDate_key];
    }
    return self;
}

@end
