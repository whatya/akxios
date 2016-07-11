//
//  SkillCell.m
//  qingchu
//
//  Created by 张宝 on 16/5/25.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SkillCell.h"
#import "CommonConstants.h"

@interface SkillCell()



@end

@implementation SkillCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //添加边框
    AddCornerBorder(self.continerView, 0, 0.5, [UIColor lightGrayColor].CGColor)
    AddCornerBorder(self.imv, 0, 0.5, [UIColor lightGrayColor].CGColor)
    
}



@end
