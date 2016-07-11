//  Classification.h
//  MomDad
//
//  Created by 张宝 on 16/6/4.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_cid       @"id"
#define K_className @"className"
#define K_officeId  @"officeId"
#define K_sort      @"sort"

@interface Classification : NSObject

@property(nonatomic,strong) NSString *cid;
@property(nonatomic,strong) NSString *className;
@property(nonatomic,strong) NSString *officeId;
@property(nonatomic,assign) int      sort;

@property(nonatomic,assign) CGSize size;
@property(nonatomic,assign) BOOL selected;

- (instancetype)initFromDictionary:(NSDictionary*)dictionary;

@end
