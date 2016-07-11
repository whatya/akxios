//
//  Clock.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/7.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define clockTime_key @"clockTime"
#define cid_key @"id"
#define imei_key @"imei"
#define isValid_key @"isValid"

#define msgId_key @"msgId"
#define schedule_key @"schedule"
#define startDate_key @"startDate"

@interface Clock : NSObject

@property (nonatomic,strong) NSString *clockTime;
@property (nonatomic,strong) NSString *cid;
@property (nonatomic,strong) NSString *imei;
@property (nonatomic,strong) NSString *isValid;
@property (nonatomic,strong) NSString *msgId;
@property (nonatomic,strong) NSString *schedule;
@property (nonatomic,strong) NSString *startDate;


- (instancetype)initFromDictionary:(NSDictionary*)dictionary;

@end
