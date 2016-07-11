//
//  DataManager.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/26.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

- (void)zanWithUser:(NSString *)username imei:(NSString *)imeiNumber andType:(int)type result:(void(^)(BOOL status,NSString *error))callback;
{
    NSArray *keys = @[@"user",@"imei",@"type"];
    NSArray *values = @[username,imeiNumber,[NSString stringWithFormat:@"%d",type]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    NSString *apiString = @"chunhui/m/user@addZan.do";
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:apiString portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (!error) {
            
            if (IsSuccessful(jsonData)) {
                
                callback(YES,nil);
                
            }else{
                
                callback(NO,ErrorString(jsonData));
            }
            
        }else{
            callback(NO,@"网络错误！");
        }
        
    }];

}

void rate(NSString* username,NSString* imei,int type)
{
    //先移除前一天的数据
    NSString *yesterdayStr = [NSString stringWithFormat:@"%@%@%@%d",dateString(-1),username,imei,type];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:yesterdayStr];
    
    //保存点赞数据
    NSString *todayStr = [NSString stringWithFormat:@"%@%@%@%d",dateString(0),username,imei,type];
    [[NSUserDefaults standardUserDefaults] setObject:@"zaned" forKey:todayStr];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

BOOL doIRated(NSString* username,NSString* imei,int type)
{
    NSString *rateStr = [NSString stringWithFormat:@"%@%@%@%d",dateString(0),username,imei,type];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:rateStr]) {
        return YES;
    }else{
        return NO;
    }
    
}

NSString* dateString(int plusValue)
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:secondsPerDay * plusValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    return [formatter stringFromDate:date];
    
}


@end
