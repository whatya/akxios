//
//  OrderDataService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/14.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "OrderDataService.h"

@implementation OrderDataService

#pragma mark- 获取设置地址
- (void)addressByUsername:(NSString *)username withCallback:(void (^)(NSString *, Address *))action
{ShowLog
    
    [self.httpService addressByUsername:username withCallback:^(NSString *errorString, NSDictionary *address) {
       
        if (errorString) {
            action(errorString,nil);
        }else{

            Address *model = [[Address alloc] initFromDictionary:address];
            action(nil,model);

        }
        
    }];
}

- (void)setAddress:(Address *)address withCallback:(void (^)(NSString *))action
{ShowLog
    
    [self.httpService setAddress:[address asDictionay] withCallback:^(NSString *errorString) {
       
        action(errorString);
        
    }];
    
}

#pragma mark-- 提交订单
- (void)initOrder:(Order *)order withCallback:(void (^)(NSString *,NSString *))action
{ShowLog
        
    [self.httpService initOrderWithDcitionay:order.asParamsDictionary withCallback:^(NSString *errorString,NSString* orderId) {
        
        action(errorString,orderId);
        
    }];
    
}

#pragma mark- 获取订单详情
- (void)orderDetailWithUsername:(NSString *)username andOrderId:(NSString *)oid withCallback:(void (^)(NSString *, Order *))action
{ShowLog
    
    [self.httpService orderDetailWithUsername:username andOrderId:oid withCallback:^(NSString *errorString, NSDictionary *order) {
        
        if (errorString) {
            action(errorString,nil);
        }else{
            Order *model = [[Order alloc] initFromDictionary:order];
            action(nil,model);
        }
        
        
    }];
    
}

#pragma mark- 获取订单列表
- (void)orderListWithUser:(NSString *)username from:(int)pageIndex to:(int)pageSize withCallback:(void (^)(NSString *, NSArray *))action
{ShowLog
    
    [self.httpService orderListWithUser:username from:pageIndex to:pageSize withCallback:^(NSString *errorString, NSArray *orders) {
       
        if (errorString) {
            action(errorString,@[]);
        }else{
            NSMutableArray *tempArray = [NSMutableArray new];
            for (NSDictionary* tempDic in orders){
                Order *model = [[Order alloc] initFromDictionary:tempDic];
                [tempArray addObject:model];
            }
            
            action(nil,tempArray);
        }
        
    }];
    
}

- (OrderHttpService *)httpService
{
    if (!_httpService) {
        _httpService = [[OrderHttpService alloc] init];
    }
    return _httpService;
}




@end
