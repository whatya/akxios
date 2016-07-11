//
//  NSUserDefaults+Util.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/4.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "NSUserDefaults+Util.h"

#define PosttionPre     @"Position_"
#define SecurePlacePre  @"Secure_"

@implementation NSUserDefaults (Util)

+ (void)room:(NSString *)roomID shouldRemind:(BOOL)remind
{
    [[NSUserDefaults standardUserDefaults] setObject:@(remind) forKey:roomID];
}

+ (BOOL)shouldRoomRemind:(NSString *)roomID
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:roomID] boolValue];
}

+ (void)saveLastPlace:(NSDictionary*)place forImei:(NSString*)imei
{
    NSString *key = [NSString stringWithFormat:@"%@%@",PosttionPre,imei];
    [[NSUserDefaults standardUserDefaults] setObject:place forKey:key];
}

+ (NSDictionary*)placeForImei:(NSString*)imei
{
    NSString *key = [NSString stringWithFormat:@"%@%@",PosttionPre,imei];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)saveSecurePlace:(NSDictionary*)place forIme:(NSString*)imei
{
    NSString *key = [NSString stringWithFormat:@"%@%@",SecurePlacePre,imei];
    [[NSUserDefaults standardUserDefaults] setObject:place forKey:key];
}

+ (NSDictionary*)securePlaceForImei:(NSString*)imei
{
    NSString *key = [NSString stringWithFormat:@"%@%@",SecurePlacePre,imei];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end
