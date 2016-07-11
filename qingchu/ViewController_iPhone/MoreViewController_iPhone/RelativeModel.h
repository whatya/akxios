//
//  RelativeModel.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/15.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RelativeModel : NSObject

@property (nonatomic,strong) NSString *iconBase64String;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *relationship;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *imei;
@property (nonatomic,strong) NSString *sim;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *mcard;

#pragma mark- Detail information
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *height;
@property (nonatomic,strong) NSString *weight;
@property (nonatomic,strong) NSString *medicalHistory;//过往病史
@property (nonatomic,strong) NSString *dailyMedicine;//日常服药史
@property (nonatomic,strong) NSString *allergicHistory;//过敏史


@end
