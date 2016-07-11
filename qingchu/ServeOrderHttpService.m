//
//  ServeOrderHttpService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ServeOrderHttpService.h"

@implementation ServeOrderHttpService


#pragma mark- 提交订单


- (void)initServeOrderWithDcitionay:(NSDictionary*)dictionary withCallback:(void(^)(NSString *errorString,NSString* serveOrderId))action
{
ShowLog
    
    if (dictionary.allKeys.count == 0) {
        
        action(@"参数不能为空！",nil);
        return;
    }
    
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:dictionary.allKeys withValues:dictionary.allValues];
    
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:SubmitOrder portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            action(@"服务错误！",nil);
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            NSLog(@"%@",ErrorString(jsonData));
            action(ErrorString(jsonData),nil);
            return;
        }
        NSLog(@"sun%@",jsonData[@"data"][@"orderId"]);
        action(nil,jsonData[@"data"][@"orderId"]);
    }];
}

#pragma mark- 订单列表
- (void)serveOrderListWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray* serves))action{
ShowLog
    
    NSArray *keys = @[@"user",@"pageNum",@"pageSize",@"pType"];
    NSArray *values = @[username,[NSString stringWithFormat:@"%d",pageIndex],[NSString stringWithFormat:@"%d",pageSize],@"1"];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:OrderList portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            action(@"服务错误！",@[]);
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            NSLog(@"%@",ErrorString(jsonData));
            action(ErrorString(jsonData),@[]);
            return;
        }
        
        NSLog(@"%@",jsonData);
        action(nil,jsonData[@"data"]);
        
    }];
}

#pragma mark- 订单详情
- (void)serveOrderDetailWithUsername:(NSString*)username andOrderId:(NSString*)oid withCallback:(void(^)(NSString *errorString,NSDictionary* serve))action{

    NSArray *keys = @[@"user",@"id"];
    NSArray *values = @[username,oid];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:OrderDetail portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            action(@"服务错误！",@{});
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            NSLog(@"%@",ErrorString(jsonData));
            action(ErrorString(jsonData),@{});
            return;
        }
        
        action(nil,jsonData[@"data"]);
        
    }];

}

@end
