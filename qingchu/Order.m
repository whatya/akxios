//
//  Order.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/14.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Order.h"

@implementation Order

- (instancetype)initFromDictionary:(NSDictionary *)dictionay
{
    self = [super init];
    if (self) {
        _oId                = dictionay[K_order_Id];
        _title              = dictionay[K_order_title];
        _imageList          = dictionay[K_order_imageList];
        _marketPrice        = [dictionay[K_order_marketPrice] doubleValue];
        
        _salePrice          = [dictionay[K_order_salePrice] doubleValue];
        _orderNum           = [dictionay[K_order_orderNum] intValue];
        _payTime            = dictionay[K_order_payTime];
        _payNum             = [dictionay[K_order_payNum] doubleValue];
        
        _status             = [dictionay[K_order_status] intValue];
        _address            = [[Address alloc] initFromDictionary:dictionay[K_order_address]];
        _logistics          = [[Logistics alloc] initFromDictionary:dictionay[K_order_logistics]];
        _gId                = dictionay[K_order_gId];
        
        _username           = dictionay[K_order_user];
        _deuctionNum        = [dictionay[K_order_deuctionNum] intValue];
        _payPaltform        = [dictionay[K_order_payPaltform] intValue];
        
        
        
        
        _doctorId           = dictionay[K_order_doctorId];
        _receiverId         = dictionay[K_order_receiverId];
        
        _receiverName       = dictionay[K_order_receiverName];
        _doctorName         = dictionay[K_order_doctorName];
        _doctorUsername     = dictionay[K_order_doctorUsername];
        _validDate          = dictionay[K_order_validDate];
        
        _canUseTimes        = [dictionay[K_order_canUseTimes] intValue];
        _version            = dictionay[K_order_version];
        _serverOrderType    = dictionay[K_order_type];
    }
    return self;
}

- (NSDictionary*)asDictinoary
{
    NSMutableDictionary *temp = [NSMutableDictionary new];
    if (self.oId.length > 0) {
        temp[K_order_Id] = self.oId;
    }
    if (self.title.length > 0) {
        temp[K_order_title] = self.title;
    }
    temp[K_order_marketPrice] = [NSString stringWithFormat:@"%f",self.marketPrice];
    temp[K_order_salePrice] = [NSString stringWithFormat:@"%f",self.salePrice];
    temp[K_order_orderNum] = [NSString stringWithFormat:@"%d",self.orderNum];
    temp[K_order_payNum] = [NSString stringWithFormat:@"%f",self.payNum];
    temp[K_order_payPaltform] = [NSString stringWithFormat:@"%d",self.payPaltform];
    temp[K_order_deuctionNum] = [NSString stringWithFormat:@"%d",self.deuctionNum];
    
    if (self.payTime.length > 0) {
        temp[K_order_payTime] = self.payTime;
    }
    
    temp[K_order_status] = [NSString stringWithFormat:@"%d",(int)self.status];
    
    if (self.address.aId.length > 0) {
        temp[K_order_address] = self.address.aId;
    }
    
    if (self.gId.length > 0) {
        temp[K_order_gId] = self.gId;
    }
    
    if (self.username.length > 0) {
        temp[K_address_username] = self.username;
    }
    
    
    
    
    if (self.receiverId.length > 0) {
        temp[K_order_receiverId] = self.receiverId;
    }
    if (self.doctorId.length > 0) {
        temp[K_order_doctorId]   = self.doctorId;
    }
    
    temp[K_order_canUseTimes] = [NSString stringWithFormat:@"%d",self.canUseTimes];
    
    if (self.validDate.length > 0) {
        
        temp[K_order_validDate] = self.validDate;
    }
    
    if (self.version.length > 0) {
        temp[K_order_version] = self.version;
    }
    
    if (self.orderType.length > 0) {
        temp[K_order_type] = self.serverOrderType;
    }
    
    return temp;
}

- (NSDictionary*)asParamsDictionary
{
    NSMutableDictionary *temp = [NSMutableDictionary new];
    temp[@"user"] = self.username;
    temp[@"productId"] = self.gId;
    temp[@"orderNum"] = [NSString stringWithFormat:@"%d",self.orderNum];
    temp[@"payNum"] = [NSString stringWithFormat:@"%.1f",self.payNum];
    temp[@"deductionNum"] = [NSString stringWithFormat:@"%d",self.deuctionNum];
    temp[@"payPaltform"] = [NSString stringWithFormat:@"%d",self.payPaltform];
    temp[@"isDeduction"] = @(self.isDeduction);
    if (self.address) {
        temp[@"addressId"] = self.address.aId;
    }
    
    temp[@"needScore"] = [NSString stringWithFormat:@"%d",(int)(self.orderNum * self.goods.needScore)];
    
    temp[@"doctorId"]   = self.doctorId;
    temp[@"receiverId"] = self.receiverId;
    
    temp[@"canUseTimes"] = [NSString stringWithFormat:@"%d",self.canUseTimes];
    temp[@"validDate"] = self.validDate;
    temp[@"version"] = self.version;
    
    return temp;
}

- (NSString*)statusString
{
    if (self.status == UNPAY) {
        return @"未付款";
    }else if (self.status == PAYED_UNDELIVERED){
        return @"已付款";
    }else if(self.status == DELIVERED){
        return @"已发货";
    }else{
        return @"已付款，不需要发货";
    }
}

@end
