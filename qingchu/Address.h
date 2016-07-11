//
//  Address.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/11.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_address_username @"user"
#define K_address_id       @"id"
#define K_address_realname @"realname"
#define K_address_phone    @"phone"

#define K_address_address  @"address"
#define K_address_recvDate @"recvDate"
#define K_address_recvTime @"recvTime"

@interface Address : NSObject

@property(nonatomic,strong) NSString *user;
@property(nonatomic,strong) NSString *aId;
@property(nonatomic,strong) NSString *realname;
@property(nonatomic,strong) NSString *phone;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *recvDate; //yyyy/MM/dd
@property(nonatomic,strong) NSString *recvTime; //HH:mm:ss~HH:mm:ss

@property(nonatomic,strong) NSString *deliverTerm;

- (instancetype)initFromDictionary:(NSDictionary*)dictionay;
- (NSDictionary*)asDictionay;

@end
