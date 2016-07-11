//
//  SkillHeader.m
//  qingchu
//
//  Created by 张宝 on 16/7/8.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillHeader.h"

@implementation SkillHeader

- (IBAction)showMore:(UIButton *)sender
{
    HeaderMoreAction block = self.pushAction;
    if (block) {
        block();
    }
}


@end
