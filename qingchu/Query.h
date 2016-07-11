//
//  Query.h
//  MomDad
//
//  Created by 张宝 on 16/6/3.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Query : NSObject

@property(nonatomic,strong) NSString *user;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *classId; //商品分类 0 表示所有分类

@property(nonatomic,assign) int      sortBy;//排序条件，1 销量，2 价格
@property(nonatomic,assign) int      isAsc;//是否升序， 1 升序，0 降序
@property(nonatomic,assign) int      pageNum;
@property(nonatomic,assign) int      pageSize;
@property(nonatomic,assign) int      pType;//商品类型， 0 商品（默认），1 服务

- (NSString*)queryString;

@end
