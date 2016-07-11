//
//  ByteManager.h
//  BytePractice
//
//  Created by ZhuXiaoyan on 15/10/12.
//  Copyright © 2015年 张宝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ByteData.h"

@interface ByteManager : NSObject

@property (nonatomic,strong) NSMutableArray *values;
@property (nonatomic,strong) ByteData *byteData;

- (void)showValues;

- (instancetype)initWithData:(NSData*)data;

@end
