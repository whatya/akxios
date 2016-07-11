//
//  KJLocation.h
//  WSDropMenuView
//
//  Created by EIT on 16/5/12.
//  Copyright © 2016年 EIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJLocation : NSObject
/**
 *  国家
 */
@property (nonatomic, copy) NSString *country;
/**
 *  省份
 */
@property (nonatomic, copy) NSString *state;
/**
 *  城市
 */
@property (nonatomic, copy) NSString *city;
/**
 *  街道
 */
@property (nonatomic, copy) NSString *street;
/**
 *  区域，地方
 */
@property (nonatomic, copy) NSString *district;
/**
 *  纬度
 */
@property (nonatomic, assign) double latitude;
/**
 *  经度
 */
@property (nonatomic, assign) double longitude;
@end
