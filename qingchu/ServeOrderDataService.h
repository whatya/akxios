//
//  ServeOrderDataService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "CommonConstants.h"
#import "ServeOrderHttpService.h"



@interface ServeOrderDataService : NSObject

@property(nonatomic,strong) ServeOrderHttpService *httpService;


#pragma mark- 提交订单
- (void)initServeOrder:(Order*)order withCallback:(void(^)(NSString *errorString,NSString* serveOrderId))action;

#pragma mark- 订单列表
- (void)serveOrderListWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray* serves))action;

#pragma mark- 订单详情
- (void)serveOrderDetailWithUsername:(NSString*)username andServeOrderId:(NSString*)oid withCallback:(void(^)(NSString *errorString,Order* serve))action;

@end
