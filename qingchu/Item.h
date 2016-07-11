//
//  Item.h
//  MomDad
//
//  Created by 张宝 on 16/6/2.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_item_id              @"id"
#define K_item_imageList       @"imageList"
#define K_item_marketPrice     @"marketPrice"
#define K_item_salePrice       @"salePrice"

#define K_item_stockNum        @"stockNum"
#define K_item_title           @"title"
#define K_item_createTime      @"createTime"
#define K_item_description     @"description"

#define K_item_isDeduction     @"isDeduction"
#define K_item_deductionRate   @"deductionRate"
#define K_item_feature         @"feature"
#define K_item_needScore       @"needScore"

#define K_item_exchangeRate    @"exchangeRate"
#define K_item_provider        @"provider"
#define K_item_isShowInfo      @"isShowInfo"

@interface Item : NSObject

@property(nonatomic,strong) NSString    *gId;
@property(nonatomic,strong) NSString    *title;
@property(nonatomic,strong) NSString    *createTime;
@property(nonatomic,strong) NSString    *goodsDesc;

@property(nonatomic,strong) NSArray     *imageList;
@property(nonatomic,assign) double      marketPrice;
@property(nonatomic,assign) double      salePrice;
@property(nonatomic,assign) int         stockNum;

@property(nonatomic,assign) BOOL        isDeduction;
@property(nonatomic,assign) double      deductionRate;
@property(nonatomic,strong) NSString    *feature;
@property(nonatomic,assign) double      needScore;

@property(nonatomic,assign) double      exchangeRate;
@property(nonatomic,strong) NSString    *provider;
@property(nonatomic,assign) BOOL        isShowInfo;


- (instancetype)initFromDictionary:(NSDictionary*)dictionary;

@end
