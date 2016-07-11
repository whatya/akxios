//
//  Skill.m
//  qingchu
//
//  Created by 张宝 on 16/6/22.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Skill.h"

@implementation Skill

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super initFromDictionary:dictionary];
    if (self) {
        _useTimes = [dictionary[k_skill_useTimes] intValue];
        _serviceTerm = [dictionary[k_skill_serviceTerm] intValue];
    }
    return self;
}

    

@end
