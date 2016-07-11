//
//  FocusPersonModel.h
//  SlideCellDemo
//
//  Created by ZhuXiaoyan on 15/8/11.
//  Copyright (c) 2015年 ZhuXiaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTermUser.h"

@interface FocusPersonModel : NSObject

@property (nonatomic,strong) CHTermUser *user;

// ui属性
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic)        BOOL       opened;


@end
