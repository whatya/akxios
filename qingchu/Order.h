//
//  Order.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/14.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Logistics.h"
#import "Goods.h"

#define K_order_Id                @"id"
#define K_order_title             @"title"
#define K_order_imageList         @"imageList"
#define K_order_marketPrice       @"marketPrice"

#define K_order_salePrice         @"salePrice"
#define K_order_orderNum          @"orderNum"
#define K_order_payNum            @"payNum"
#define K_order_payTime           @"payTime"

#define K_order_status            @"orderStatus"
#define K_order_address           @"addressInfo"
#define K_order_logistics         @"logisticsInfo"
#define K_order_gId               @"productId"

#define K_order_user              @"user"
#define K_order_deuctionNum       @"deuctionNum"
#define K_order_payPaltform       @"payPaltform"
#define K_order_isDeduction       @"isDeduction"



#define K_order_receiverId        @"receiverId"
#define K_order_doctorId          @"doctorId"

#define K_order_canUseTimes       @"canUseTimes"
#define K_order_validDate         @"validDate"
#define K_order_canUseTimes       @"canUseTimes"

#define K_order_receiverName      @"receiverName"
#define K_order_doctorName        @"doctorName"
#define K_order_doctorUsername    @"doctorUsername"
#define K_order_version           @"version"

#define K_order_type               @"orderType"

#pragma -mark 类型
typedef NS_ENUM(NSInteger, OrderStatus) {
    UNPAY = 1,
    PAYED_UNDELIVERED,
    DELIVERED,
    PAYED_NODELIVERYNEED
};


@interface Order : NSObject

@property(nonatomic,strong) NSString*   oId;
@property(nonatomic,strong) NSString*   title;
@property(nonatomic,strong) NSArray*    imageList;
@property(nonatomic,assign) double      marketPrice;

@property(nonatomic,assign) double      salePrice;
@property(nonatomic,assign) int         orderNum;
@property(nonatomic,assign) double      payNum;
@property(nonatomic,strong) NSString*   payTime;

@property(nonatomic,assign) OrderStatus status;
@property(nonatomic,strong) Address     *address;
@property(nonatomic,strong) Logistics   *logistics;
@property(nonatomic,strong) NSString    *gId;

@property(nonatomic,strong) NSString    *username;
@property(nonatomic,assign) int         deuctionNum;
@property(nonatomic,assign) int         payPaltform;
@property(nonatomic,strong) Item       *goods;

@property(nonatomic,assign) BOOL        isDeduction;
@property(nonatomic,assign) double      deductionRate;



@property (nonatomic,strong) NSString * receiverId;
@property (nonatomic,strong) NSString * receiverName;

@property (nonatomic,strong) NSString * doctorId;
@property (nonatomic,strong) NSString * doctorName;
@property (nonatomic,strong) NSString * doctorUsername;

@property (nonatomic,assign) int        canUseTimes;
@property (nonatomic,strong) NSString   *validDate;

@property (nonatomic,strong) NSString   *orderType;
@property (nonatomic,strong) NSString   *serverOrderType;//goods：实物商品订单；once_service一次性服务订单; cycle_service:周期服务订单

@property (nonatomic,strong) NSString   *version;

@property (nonatomic,assign) int        submitScore;



- (instancetype)initFromDictionary:(NSDictionary*)dictionay;
- (NSDictionary*)asDictinoary;
- (NSString*)statusString;
- (NSDictionary*)asParamsDictionary;

@end