//
//  ItemHttpService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ItemHttpService.h"
#import "ProgressHUD.h"
#import "ItemAPI.h"
@implementation ItemHttpService

- (void)itemsWithTitle:(NSString *)title user:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void (^)(NSString *, NSArray *))action
{ShowLog
    //error handle Start---
    if (title.length == 0) {
        NSLog(@"title为空！");
    }
    
    if (username.length == 0) {
        NSLog(@"username为空！");
    }
    
    if (pageIndex < 0) {
        NSLog(@"%@",[NSString stringWithFormat:@"pageIndex(输入值：%d)不能小于0",pageIndex]);
        return;
    }
    
    if (pageSize < 1) {
        NSLog(@"%@",[NSString stringWithFormat:@"pageSize(输入值：%d)必须大于0",pageSize]);
        return;
    }
    
    //error handle End--
    
    NSArray *keys = @[@"title",@"user",@"pageNum",@"pageSize"];
    NSArray *values = @[title,username,[NSString stringWithFormat:@"%d",pageIndex],[NSString stringWithFormat:@"%d",pageSize]];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:ItemsList portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
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


- (void)itemDescWithID:(NSString *)iId andUserName:(NSString *)username withCallback:(void (^)(NSString *, NSDictionary *))action
{ShowLog
    //error handle Start---
    if (iId.length == 0) {
         NSLog(@"%@",[NSString stringWithFormat:@"id (输入值：%@)不能为空！",iId]);
        return;
    }
    if (username.length == 0) {
        NSLog(@"用户名为空！");
    }
    
    // error handle End--
    
    NSArray *keys = @[@"id",@"user"];
    NSArray *values = @[iId,username];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:ItemDesc portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
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


- (void)itemsWithQuery:(Query *)query andCallback:(void(^)(NSString *errorString,NSArray *items))action
{
    NSString *queryString = [query queryString];
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:ItemsList portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
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

- (void)classesWith:(NSString *)user andCallback:(void (^)(NSString *, NSArray *))action
{ShowLog
    
    NSArray *keys = @[@"user"];
    NSArray *values = @[user ?: @""];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:ClassesList portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
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



- (void)skillDescWithID:(NSString*)iId andUserName:(NSString*)username withCallback:(void(^)(NSString *errorString,NSDictionary *sever))action
{
    if (iId.length == 0) {
        NSLog(@"%@",[NSString stringWithFormat:@"id (输入值：%@)不能为空！",iId]);
        return;
    }
    if (username.length == 0) {
        NSLog(@"用户名为空！");
    }
    
    // error handle End--
    
    NSArray *keys = @[@"id",@"user"];
    NSArray *values = @[iId,username];
    NSString *queryString = [[HttpManager sharedHttpManager] joinKeys:keys withValues:values];
    
    
    [[HttpManager sharedHttpManager] jsonDataFromServerWithBaseUrl:ItemDesc portID:80 queryString:queryString callBack:^(id jsonData, NSError *error) {
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
        NSLog(@"%@",jsonData[@"data"]);
    }];
    
}

@end
