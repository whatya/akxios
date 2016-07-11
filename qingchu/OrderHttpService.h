
//
//  OrderHttpService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonConstants.h"
#import "ItemAPI.h"
#include "HttpManager.h"

@interface OrderHttpService : NSObject


#pragma mark- 获取设置地址
- (void)addressByUsername:(NSString*)username withCallback:(void(^)(NSString *errorString,NSDictionary *address))action;

- (void)setAddress:(NSDictionary*)dictionary withCallback:(void(^)(NSString *errorString))action;

#pragma mark- 提交订单
- (void)initOrderWithDcitionay:(NSDictionary*)dictionary withCallback:(void(^)(NSString *errorString,NSString* orderId))action;

#pragma mark- 订单列表
- (void)orderListWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray* orders))action;

#pragma mark- 订单详情
- (void)orderDetailWithUsername:(NSString*)username andOrderId:(NSString*)oid withCallback:(void(^)(NSString *errorString,NSDictionary* order))action;

@end
