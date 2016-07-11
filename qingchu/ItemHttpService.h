//
//  ItemHttpService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpManager.h"
#import "Query.h"

@interface ItemHttpService : NSObject

- (void)itemsWithTitle:(NSString*)title user:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray *items))action;

- (void)itemDescWithID:(NSString*)iId andUserName:(NSString*)username withCallback:(void(^)(NSString *errorString,NSDictionary *item))action;

- (void)itemsWithQuery:(Query*)query andCallback:(void(^)(NSString *errorString,NSArray *items))action;

- (void)classesWith:(NSString*)user andCallback:(void(^)(NSString* errorString,NSArray *classes))action;

- (void)skillDescWithID:(NSString*)iId andUserName:(NSString*)username withCallback:(void(^)(NSString *errorString,NSDictionary *sever))action;



@end
