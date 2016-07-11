//
//  OrderHttpService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "OrderHttpService.h"


@implementation OrderHttpService

#pragma mark- 获取上一次收货地址
- (void)addressByUsername:(NSString *)username withCallback:(void (^)(NSString *, NSDictionary *))action
{ShowLog
    
    //error handle Start--
    
    if (username.length == 0) {
        NSLog(@"%@",[NSString stringWithFormat:@"username (输入值：%@)不能为空！",username]);
        action(@"用户名不能为空！",nil);
        return;
    }
    
    //error handle End---
    NSArray *keys = @[@"user"];
    NSArray *values = @[username];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:AddressFetch portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
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

#pragma mark- 设置地址
- (void)setAddress:(NSDictionary *)dictionary withCallback:(void (^)(NSString *))action
{ShowLog
    
    //error handle Start--
    
    if (dictionary.allKeys.count == 0) {
        action(@"参数不能为空！");
        return;
    }
    
    //error handle End--
    
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:dictionary.allKeys withValues:dictionary.allValues];
    
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:EditAddress portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            action(@"服务错误！");
            return ;
        }
        
        if (!IsSuccessful(jsonData)) {
            NSLog(@"%@",ErrorString(jsonData));
            action(ErrorString(jsonData));
            return;
        }
        
        action(nil);
    }];

}

#pragma mark- 提交订单
- (void)initOrderWithDcitionay:(NSDictionary *)dictionary withCallback:(void(^)(NSString *errorString,NSString* orderId))action;
{ShowLog
    
    
    //error handle Start--
    
    if (dictionary.allKeys.count == 0) {
        action(@"参数不能为空！",nil);
        return;
    }
    
    //error handle End--
    
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
        
        action(nil,jsonData[@"data"][@"orderId"]);
    }];
}

#pragma mark- 订单列表
- (void)orderListWithUser:(NSString *)username from:(int)pageIndex to:(int)pageSize withCallback:(void (^)(NSString *, NSArray *))action
{ShowLog
    
    // error handle Start---
    
    if (username.length == 0) {
        NSLog(@"用户名不能为空！");
        return;
    }
    
    if (pageIndex < 0) {
        NSLog(@"%@",[NSString stringWithFormat:@"pageIndex(输入值：%d)不能小于0",pageIndex]);
        return;
    }
    
    if (pageSize < 1) {
        NSLog(@"%@",[NSString stringWithFormat:@"pageSize(输入值：%d)必须大于0",pageSize]);
        return;
    }
    
    // error handld End---
    
    NSArray *keys = @[@"user",@"pageNum",@"pageSize"];
    NSArray *values = @[username,[NSString stringWithFormat:@"%d",pageIndex],[NSString stringWithFormat:@"%d",pageSize]];
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
        
        action(nil,jsonData[@"data"]);
        
    }];
}

#pragma mark- 订单详情
- (void)orderDetailWithUsername:(NSString *)username andOrderId:(NSString *)oid withCallback:(void (^)(NSString *, NSDictionary *))action
{
    // error handle Start --
    
    if (username.length == 0) {
        NSLog(@"用户名不能为空!");
        return;
    }
    
    if (oid.length == 0) {
        NSLog(@"订单id不能为空！");
        return;
    }
    
    // error handle End---
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
