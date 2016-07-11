//
//  OrderDataService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/14.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "OrderHttpService.h"
#import "CommonConstants.h"
#import "Order.h"

@interface OrderDataService : NSObject

@property(nonatomic,strong) OrderHttpService *httpService;

#pragma mark- 设置获取地址
- (void)addressByUsername:(NSString*)username withCallback:(void(^)(NSString *errorString,Address *address))action;

- (void)setAddress:(Address*)address withCallback:(void(^)(NSString *errorString))action;

#pragma mark- 提交订单
- (void)initOrder:(Order*)order withCallback:(void(^)(NSString *errorString,NSString* orderId))action;

#pragma mark- 订单列表
- (void)orderListWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray* orders))action;

#pragma mark- 订单详情
- (void)orderDetailWithUsername:(NSString*)username andOrderId:(NSString*)oid withCallback:(void(^)(NSString *errorString,Order* order))action;
@end
