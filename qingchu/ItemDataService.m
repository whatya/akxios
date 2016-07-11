//
//  ItemDataService.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "ItemDataService.h"


@implementation ItemDataService

- (ItemHttpService *)httpService
{
    if (!_httpService) {
        _httpService = [[ItemHttpService alloc] init];
    }
    return _httpService;
}


- (void)itemsWithTitle:(NSString *)title user:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void (^)(NSString *, NSArray *))action
{ShowLog
    
    [self.httpService itemsWithTitle:title user:(NSString*)username from:pageIndex to:pageSize withCallback:^(NSString *errorString, NSArray *items) {
     
        if (errorString) {
            action(errorString,@[]);
        }else{
            NSMutableArray *itemMoels = [NSMutableArray new];
            for (NSDictionary* item in items){
            
                
                Goods *moel = [[Goods alloc] initFromDictionary:item];
                [itemMoels addObject:moel];
            }
            action(nil,itemMoels);
        }
        
    }];
    
}

- (void)itemDescWithID:(NSString *)iId andUserName:(NSString *)username withCallback:(void (^)(NSString *, Goods *))action
{ShowLog
    
    [self.httpService itemDescWithID:iId andUserName:username withCallback:^(NSString *errorString, NSDictionary *item) {
        if (errorString) {
            action(errorString,nil);
        }else{
            Goods *model = [[Goods alloc] initFromDictionary:item];
            action(nil,model);
        }
    }];
    
}

- (void)itemsWithQuery:(Query *)query andCallback:(void (^)(NSString *, NSArray *))action
{ShowLog
    [self.httpService itemsWithQuery:query andCallback:^(NSString *errorString, NSArray *items) {
        if (errorString) {
            action(errorString,@[]);
        }else{
            NSMutableArray *itemMoels = [NSMutableArray new];
            for (NSDictionary* item in items){
                
                if (query.pType == 0) {
                    Goods *moel = [[Goods alloc] initFromDictionary:item];
                    [itemMoels addObject:moel];
                }else if (query.pType == 1 || query.pType == 2){
                    Skill *model = [[Skill alloc] initFromDictionary:item];
                    [itemMoels addObject:model];
                }else{
                    //
                }
                
            }
            action(nil,itemMoels);
        }
        
    }];
}

- (void)classesWith:(NSString*)user andCallback:(void(^)(NSString* errorString,NSArray *classes))action
{ShowLog
    
    [self.httpService classesWith:user andCallback:^(NSString *errorString, NSArray *classes) {
        
        if (errorString) {
            action(errorString,@[]);
        }else{
            NSMutableArray *itemMoels = [NSMutableArray new];
            for (NSDictionary* item in classes){
                Classification *moel = [[Classification alloc] initFromDictionary:item];
                [itemMoels addObject:moel];
            }
            action(nil,itemMoels);
        }
        
        
    }];
    
}


- (void)skillDescWithID:(NSString*)iId andUserName:(NSString*)username withCallback:(void(^)(NSString *errorString,Skill *sever))action
{
    [self.httpService skillDescWithID:iId andUserName:username withCallback:^(NSString *errorString, NSDictionary *sever) {
        if (errorString) {
            action(errorString,nil);
        }else{
            Skill *model = [[Skill alloc] initFromDictionary:sever];
            action(nil,model);
        }
    }];

}

@end
