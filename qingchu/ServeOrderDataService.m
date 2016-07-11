//
//  ServeOrderDataService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/17.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ServeOrderDataService.h"

@implementation ServeOrderDataService

- (ServeOrderHttpService *)httpService
{
    if (!_httpService) {
        _httpService = [[ServeOrderHttpService alloc] init];
    }
    return _httpService;
}


#pragma mark- 提交订单
- (void)initServeOrder:(Order*)order withCallback:(void(^)(NSString *errorString,NSString* serveOrderId))action{
ShowLog
    [self.httpService initServeOrderWithDcitionay:order.asParamsDictionary withCallback:^(NSString *errorString,NSString* serveOrderId) {
        
        action(errorString,serveOrderId);
        
    }];
}

#pragma mark- 订单列表
- (void)serveOrderListWithUser:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray* serves))action{
    ShowLog
    [self.httpService serveOrderListWithUser:username from:pageIndex to:pageSize withCallback:^(NSString *errorString, NSArray *serves) {
        
        if (errorString) {
            action(errorString,@[]);
        }else{
            NSMutableArray *tempArray = [NSMutableArray new];
            for (NSDictionary* tempDic in serves){
                Order *model = [[Order alloc] initFromDictionary:tempDic];
                [tempArray addObject:model];
            }
            
            action(nil,tempArray);
        }
        
    }];
}

#pragma mark- 订单详情
- (void)serveOrderDetailWithUsername:(NSString*)username andServeOrderId:(NSString*)oid withCallback:(void(^)(NSString *errorString,Order* serve))action{
ShowLog
    [self.httpService serveOrderDetailWithUsername:username andOrderId:oid withCallback:^(NSString *errorString, NSDictionary *serve) {
        
        if (errorString) {
            action(errorString,nil);
        }else{
            Order *model = [[Order alloc] initFromDictionary:serve];
            action(nil,model);
        }
    }];
}

@end
