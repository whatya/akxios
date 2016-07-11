//
//  CHTermUser.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/5/18.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "CHTermUser.h"

@implementation CHTermUser

+(instancetype)termUserWithDict:(NSDictionary*)dict
{
    CHTermUser *termUser = [[self alloc] init];
    termUser.name = dict[@"name"];
    termUser.imei = dict[@"imei"];
    termUser.sim = dict[@"sim"];
    termUser.relative = dict[@"relative"];
    termUser.sex = dict[@"sex"];
    termUser.image = dict[@"image"];
    termUser.phone = dict[@"phone"];
    termUser.userId = dict[@"userId"];
    
    termUser.birthday = dict[@"birthday"];
    termUser.height = dict[@"height"];
    termUser.weight = dict[@"weight"];
    termUser.medicalHistory = dict[@"illnessRecord"];
    termUser.dailyMedicine = dict[@"dailyMedicine"];
    termUser.allergicHistory = dict[@"allergyRecord"];
    termUser.isMaster   = [dict[@"isMaster"] boolValue];
    termUser.mcard = dict[@"mcard"];
    
    return termUser;
}

@end
