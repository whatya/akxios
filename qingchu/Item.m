//
//  Item.m
//  MomDad
//
//  Created by 张宝 on 16/6/2.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Item.h"

@implementation Item

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _gId            = dictionary[K_item_id];
        _imageList      = dictionary[K_item_imageList];
        _marketPrice    = [dictionary[K_item_marketPrice] doubleValue];
        _salePrice      = [dictionary[K_item_salePrice] doubleValue];
        
        _stockNum       = [dictionary[K_item_stockNum] intValue];
        _title          = dictionary[K_item_title];
        _createTime     = dictionary[K_item_createTime];
        _goodsDesc      = dictionary[K_item_description];
        
        _isDeduction    = [dictionary[K_item_isDeduction] boolValue];
        _deductionRate  = [dictionary[K_item_deductionRate] doubleValue];
        _feature        = dictionary[K_item_feature];
        _needScore      = [dictionary[K_item_needScore] doubleValue];
        
        _exchangeRate   = [dictionary[K_item_exchangeRate] doubleValue];
        _provider       = dictionary[K_item_provider];
        _isShowInfo     = [dictionary[K_item_isShowInfo] boolValue];
    }
    return self;
}

@end
