//
//  NSUserDefaults+Util.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/4.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Util)

+ (void)room:(NSString *)roomID shouldRemind:(BOOL)remind;

+ (BOOL)shouldRoomRemind:(NSString *)roomID;

+ (void)saveLastPlace:(NSDictionary*)place forImei:(NSString*)imei;

+ (NSDictionary*)placeForImei:(NSString*)imei;

+ (void)saveSecurePlace:(NSDictionary*)place forIme:(NSString*)imei;

+ (NSDictionary*)securePlaceForImei:(NSString*)imei;

@end
