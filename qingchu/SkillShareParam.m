//
//  SkillShareParam.m
//  qingchu
//
//  Created by 张宝 on 16/7/9.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillShareParam.h"

@implementation SkillShareParam

+ (SkillShareParam *)sharedSkill
{
    static SkillShareParam *sharedManagerInstance = nil;
    static dispatch_once_t  singleton;
    dispatch_once(&singleton, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (void)clear
{
    self.order = nil;
}

@end
