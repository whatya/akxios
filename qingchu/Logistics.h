//
//  Logistics.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/14.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_transactionId @"transactionId"
#define K_expressName   @"expressName"
#define K_deliveryTime  @"deliveryTime"

@interface Logistics : NSObject

@property(nonatomic,strong) NSString* transactionId;
@property(nonatomic,strong) NSString* expressName;
@property(nonatomic,strong) NSString* deliveryTime;

- (instancetype)initFromDictionary:(NSDictionary*)dictionary;

@end
