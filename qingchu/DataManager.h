//
//  DataManager.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/26.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpManager.h"

@interface DataManager : NSObject

- (void)zanWithUser:(NSString *)username imei:(NSString *)imeiNumber andType:(int)type result:(void(^)(BOOL status,NSString *error))callback;

//0:睡眠 1:运动 2:心率 3:血压
void rate(NSString* username,NSString* imei,int type);

BOOL doIRated(NSString* username,NSString* imei,int type);

@end
