//
//  Skill.h
//  qingchu
//
//  Created by 张宝 on 16/6/22.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Item.h"

#define k_skill_useTimes @"useTimes"
#define k_skill_serviceTerm @"serviceTerm"

@interface Skill : Item

@property (nonatomic,assign) int useTimes; //剩余使用次数
@property (nonatomic,assign) int serviceTerm; //服务周期，单位月

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

@end
