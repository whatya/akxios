//
//  PeopleGetCell.m
//  qingchu
//
//  Created by 张宝 on 16/7/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "PeopleGetCell.h"
#import "CommonConstants.h"

@implementation PeopleGetCell


- (void)awakeFromNib {
    [super awakeFromNib];
    AddCornerBorder(self.imv, self.imv.bounds.size.width/2, 0.5, [UIColor lightGrayColor].CGColor);
}


@end
