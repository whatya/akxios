//
//  Query.m
//  MomDad
//
//  Created by 张宝 on 16/6/3.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "Query.h"
#import "HttpManager.h"

@implementation Query

- (NSString *)queryString
{
    NSString *userTemp = self.user ?: @"";
    NSString *titleTemp = self.title ?: @"";
    NSString *classIdTemp = self.classId ?: @"0";
    
    NSArray *keys = @[@"user",@"title",@"classId",@"sortBy",
                      @"isAsc",@"pageNum",@"pageSize",@"pType"];
    
    NSArray *vals = @[userTemp,titleTemp,classIdTemp,str(self.sortBy),
                      str(self.isAsc),str(self.pageNum),str(self.pageSize),
                      str(self.pType)];
    
    NSString *query = [[HttpManager sharedHttpManager] joinKeys:keys withValues:vals];
    return query;
}

NSString* str(int input)
{
    return [NSString stringWithFormat:@"%d",input];
}



@end
