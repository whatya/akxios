//
//  Classification.m
//  MomDad
//
//  Created by 张宝 on 16/6/4.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Classification.h"

@implementation Classification

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _cid = dictionary[K_cid];
        _className = dictionary[K_className];
        _officeId = dictionary[K_officeId];
        _sort = [dictionary[K_sort] intValue];
        _size = [_className sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    }
    return self;
}

@end
