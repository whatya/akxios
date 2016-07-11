//
//  CHTermUserFrame.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/5/18.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CHTermUser;
@interface CHTermUserFrame : NSObject

@property (nonatomic, assign) CGRect nameF;

@property (nonatomic, assign) CGRect sexF;

@property (nonatomic, assign) CGRect userImageF;

@property (nonatomic, assign)  CGRect moveContentViewF;

@property (nonatomic, assign)  CGRect menuContentViewF;
@property(nonatomic, assign) CGRect delBindViewF;
@property(nonatomic, assign) CGRect delBindBtnF;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) CHTermUser *termUser;

@end
