//
//  CHTermUserFrame.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/5/18.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "CHTermUserFrame.h"
#import "CHTermUser.h"

@implementation CHTermUserFrame

- (void)setTermUser:(CHTermUser *)termUser
{
    _termUser = termUser;
    
    CGFloat padding = 10;
    
    CGFloat userImageX = padding;
    CGFloat userImageY = 0;
    CGFloat userImageW = 42;
    CGFloat userImageH = 42;
    self.userImageF = CGRectMake(userImageX, userImageY, userImageW, userImageH);
    
    CGFloat nameX = CGRectGetMaxX(self.userImageF) + 2*padding;
    CGFloat nameY = 0;
    CGFloat nameW = 40;
    CGFloat nameH = 42;
    self.nameF = CGRectMake(nameX, nameY, nameW, nameH);
    
    CGFloat sexX = CGRectGetMaxX(self.nameF) + padding;
    CGFloat sexY = 0;
    CGFloat sexW = 20;
    CGFloat sexH = 42;
    self.sexF = CGRectMake(sexX, sexY, sexW, sexH);
    
    self.cellHeight = 44;
    
}
@end
