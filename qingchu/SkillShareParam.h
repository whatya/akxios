//
//  SkillShareParam.h
//  qingchu
//
//  Created by 张宝 on 16/7/9.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTermUser.h"
#import "Item.h"
#import "Order.h"
#import "ServeUserModel.h"

@interface SkillShareParam : NSObject

@property(nonatomic,strong) Order *order;


+ (SkillShareParam*)sharedSkill;

- (void)clear;

@end
