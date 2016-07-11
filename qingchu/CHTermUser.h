//
//  CHTermUser.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/5/18.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTermUser : NSObject
@property (nonatomic, copy)  NSString *name;
@property (nonatomic, copy)  NSString *imei;
@property (nonatomic, copy)  NSString *relative;
@property (nonatomic, copy)  NSString *sim;
@property (nonatomic, copy)  NSString *sex;
@property (nonatomic, copy)  NSString *image;
@property (nonatomic, copy)  NSString *phone;
@property (nonatomic, copy)  NSString *userId;

#pragma mark- detail
#pragma mark- Detail information
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *height;
@property (nonatomic,strong) NSString *weight;
@property (nonatomic,strong) NSString *medicalHistory;//过往病史
@property (nonatomic,strong) NSString *dailyMedicine;//日常服药史
@property (nonatomic,strong) NSString *allergicHistory;//过敏史
@property (nonatomic,assign) BOOL      isMaster;//是否是管理员

@property (nonatomic,strong) NSString *mcard;//会员卡号

+(instancetype)termUserWithDict:(NSDictionary*)dict;

@end
