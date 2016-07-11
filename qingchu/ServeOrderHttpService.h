//
//  ServeOrderHttpService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommonConstants.h"
#import "ItemAPI.h"
#import "HttpManager.h"

@interface ServeOrderHttpService : NSObject


#pragma mark- 提交订单
- (void)initServeOrderWithDcitionay:(NSDictionary*)dictionary withCallback:(void(^)(NSString *errorString,NSString* serveOrderId))action;


#pragma mark- 订单列表
- (void)serveOrderListWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray* serves))action;

#pragma mark- 订单详情
- (void)serveOrderDetailWithUsername:(NSString*)username andOrderId:(NSString*)oid withCallback:(void(^)(NSString *errorString,NSDictionary* serve))action;
/**
 
 - (void)addressByUsername:(NSString*)username withCallback:(void(^)(NSString *errorString,NSDictionary *address))action;
 
 - (void)setAddress:(NSDictionary*)dictionary withCallback:(void(^)(NSString *errorString))action;
 
 **/

#pragma mark - 获取收货人信息

//- (void)informationByUserName:(NSString *)username withCallback:(void(^)(NSString *errorString,NSArray* users))action;
//
//- (void)setInformation:(NSArray *)array withCallback:(void(^)(NSString *errorString))action;

@end
