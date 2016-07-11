//
//  SelectUser.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/12.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHTermUser.h"

@interface SelectUser : NSObject

@property (nonatomic,strong) CHTermUser *users;

@property (nonatomic,assign) BOOL checked;
@property (nonatomic,strong) NSIndexPath *indexPath;


@end
