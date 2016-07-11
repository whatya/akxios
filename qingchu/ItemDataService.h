//
//  ItemDataService.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemHttpService.h"
#import "Goods.h"
#import "Skill.h"
#import "Query.h"
#import "Classification.h"

@interface ItemDataService : NSObject

@property(nonatomic,strong) ItemHttpService *httpService;

/**
 *  字段获取商品列表
 *
 *  @param title     商品标题，模糊匹配
 *  @param username  用户名
 *  @param pageIndex 页码
 *  @param pageSize  每页条数
 *  @param action    回调函数
 */
- (void)itemsWithTitle:(NSString*)title user:(NSString*)username from:(int)pageIndex to:(int)pageSize withCallback:(void(^)(NSString *errorString,NSArray *items))action;

/**
 *  商品详情
 *
 *  @param iId      商品ID
 *  @param username 用户名
 *  @param action   回调函数
 */
- (void)itemDescWithID:(NSString*)iId andUserName:(NSString*)username withCallback:(void(^)(NSString *errorString,Goods *item))action;

/**
 *  根据查询对象获取商品列表
 *
 *  @param query  查询对象，查询条件见该类字段
 *  @param action 回调
 */
- (void)itemsWithQuery:(Query*)query andCallback:(void(^)(NSString *errorString,NSArray *items))action;

/**
 *  获取筛选条件
 *
 *  @param user   用户名
 *  @param action 回调
 */
- (void)classesWith:(NSString*)user andCallback:(void(^)(NSString* errorString,NSArray *classes))action;



- (void)skillDescWithID:(NSString*)iId andUserName:(NSString*)username withCallback:(void(^)(NSString *errorString,Skill *sever))action;



@end
