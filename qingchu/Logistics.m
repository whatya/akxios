//
//  Logistics.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/14.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Logistics.h"

@implementation Logistics

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _transactionId = dictionary[K_transactionId];
        _expressName = dictionary[K_expressName];
        _deliveryTime = dictionary[K_deliveryTime];
    }
    return self;
}

@end
