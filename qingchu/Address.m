//
//  Address.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Address.h"

@implementation Address

- (instancetype)initFromDictionary:(NSDictionary *)dictionay
{
    self = [super init];
    if (self) {
        _user       = dictionay[K_address_username];
        _aId        = dictionay[K_address_id];
        _realname   = dictionay[K_address_realname];
        _phone      = dictionay[K_address_phone];
        _address    = dictionay[K_address_address];
        _recvDate   = dictionay[K_address_recvDate];
        _recvTime   = dictionay[K_address_recvTime];
    }
    return self;
}

- (NSDictionary*)asDictionay
{
    NSMutableDictionary *temp = [NSMutableDictionary new];
    if (self.user.length > 0) {
        temp[K_address_username] = self.user;
    }
    
    if (self.aId.length > 0) {
        temp[K_address_id] = self.aId;
    }
    
    if (self.realname.length > 0) {
        temp[K_address_realname] = self.realname;
    }
    
    if (self.phone.length > 0) {
        temp[K_address_phone] = self.phone;
    }
    
    if (self.address.length>0) {
        temp[K_address_address] = self.address;
    }
    
    if (self.recvDate.length>0) {
        temp[K_address_recvDate] = self.recvDate;
    }
    
    if (self.recvTime.length > 0) {
        temp[K_address_recvTime] = self.recvTime;
    }
    
    return temp;
}

- (NSString *)deliverTerm
{
    return [NSString stringWithFormat:@"%@ %@",self.recvDate,self.recvTime];
}

@end
